import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';

abstract class SheetUtils {
  static late final String? sheetId;
  static late final String? apiKey;
  static late final bool hasEnv;

  static late final HttpClient client;

  static const String authority = "sheets.googleapis.com";
  static const String path = "v4/spreadsheets";
  static late final String? mainSheetName;

  static Uri uri(String sheetName) => Uri.https(authority,
      "/$path/$sheetId/values/$sheetName!A1:ZZ2000", {"key": apiKey});

  static Future<Map<dynamic, dynamic>> decodeData(
      HttpClientResponse response) async {
    return jsonDecode(await utf8.decodeStream(response));
  }

  static Future<void> init() async {
    await dotenv.load();

    client = HttpClient();
    sheetId = dotenv.maybeGet("SHEET_ID");
    apiKey = dotenv.maybeGet("API_KEY");

    if (sheetId != null && apiKey != null) {
      hasEnv = true;
    }
  }

  static Future<bool> getTags() async {
    HttpClientRequest request = await client.getUrl(uri("Metadata"));
    HttpClientResponse response = await request.close();
    if (response.statusCode != 200) {
      return false;
    }

    Map data = await decodeData(response);
    List<List<dynamic>> values =
        (data['values'] as List<dynamic>).cast<List<dynamic>>();
    values = values.sublist(1);
    for (List<dynamic> rowD in values) {
      List<String> row = rowD.cast<String>();
      String tagName = row[2];
      String tagColor = row[3];

      int value = int.parse(tagColor.replaceAll("#", ""), radix: 16);
      Color colorNoAlpha = Color(value);
      Color color = Color.fromARGB(
          255, colorNoAlpha.red, colorNoAlpha.green, colorNoAlpha.blue);

      List<TagModel> test = await TagModel.get("name = ?", [tagName]);
      if (test.isEmpty) {
        TagModel model = TagModel(tagName, color);
        await model.save();
      }
    }

    return true;
  }

  static Future<bool> getTransactions() async {
    HttpClientRequest request = await client.getUrl(uri("Main"));
    HttpClientResponse response = await request.close();
    if (response.statusCode != 200) {
      return false;
    }
    Map data = await decodeData(response);

    List<List<dynamic>> values =
        (data['values'] as List<dynamic>).cast<List<dynamic>>();
    values = values.sublist(1);
    int millis = 0;
    for (List<dynamic> transactionD in values) {
      List<String> transaction = transactionD.cast<String>();
      String dateString = transaction[0];
      String amountString = transaction[1];
      String typeString = transaction[2];
      String name = transaction[3];
      List<String> tagNames = transaction
          .sublist(5, 11)
          .where((element) => element.isNotEmpty)
          .toList();

      List<TagModel> tags = [];
      for (String tagName in tagNames) {
        List<TagModel> models = await TagModel.get("name = ?",[tagName]);
        if (models.isNotEmpty) {
          tags.add(models.first);
        }
      }

      List<int> dateInts =
          dateString.split("-").map((e) => int.parse(e)).toList();
      DateTime date = DateTime(dateInts[0], dateInts[1], dateInts[2]);
      date = date.add(Duration(milliseconds: millis));

      double amount =
          double.parse(amountString.replaceAll("\$", "").replaceAll(",", ""));
      String transactionType = typeString == "CRED"
          ? TransactionModel.typeCredit
          : TransactionModel.typeDebit;

      List<TransactionModel> test = await TransactionModel.get(
          "name = ? AND amount = ? AND transactionType = ? AND date = ?",
          [name, amount, transactionType, date.toIso8601String()]);

      if (test.isEmpty) {
        TransactionModel transactionModel =
            TransactionModel(date, amount, transactionType, name, tags);
        await transactionModel.save();
      }

      millis++;
    }

    return true;
  }
}
