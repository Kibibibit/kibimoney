import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/db/shared_prefs.dart';
import 'package:kibimoney/models/tag_join_model.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/utils/string_builder.dart';
import 'package:sqflite/sqflite.dart';

class TransactionModel {
  static const String typeCredit = "CREDIT";
  static const String typeDebit = "DEBIT";

  static const String tableName = "transaction_model";
  static const String createTable =
      "CREATE TABLE IF NOT EXISTS $tableName(id INTEGER PRIMARY KEY, date TEXT, amount REAL, transactionType TEXT, name TEXT)";

  int? id;
  late DateTime date;
  double amount;
  String transactionType;
  String name;
  List<TagModel> tags;

  TransactionModel(
      DateTime date, this.amount, this.transactionType, this.name, this.tags) {
        // This helps mantain sorting by having the date be offset by the current time, so transactions created later on the same
        // date are moved later on the transaction list.
        DateTime now = DateTime.now();
        this.date = DateTime(date.year, date.month, date.day, now.hour, now.minute, now.second, now.microsecond, now.microsecond);
      }

  Future<void> save() async {
    id ??= await DatabaseUtils.getNextId(tableName);

    await DatabaseUtils.database.delete(TagJoinModel.tableName,
        where: "transactionId = ?", whereArgs: [id]);

    await DatabaseUtils.database.insert(
        tableName,
        {
          'id': id,
          'date': date.toIso8601String(),
          'amount': amount,
          'transactionType': transactionType,
          'name': name,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    for (TagModel tag in tags) {
      await TagJoinModel.save(this, tag);
    }

    await DatabaseUtils.getTotal();
  }

  Future<void> delete() async {
    await DatabaseUtils.database.delete(TagJoinModel.tableName,
        where: "transactionId = ?", whereArgs: [id]);
    await DatabaseUtils.database
        .delete(tableName, where: "id = ?", whereArgs: [id]);
    await DatabaseUtils.getTotal();
  }

  static Future<TransactionModel?> getById(int id) async {
    List<TransactionModel> options = await _get(true, 'id = ?', [id]);
    if (options.isNotEmpty) {
      return options.first;
    } else {
      return null;
    }
  }

  static Future<List<TransactionModel>> get(
      [String? where, List<Object?>? whereArgs]) async {
    return _get(false, where, whereArgs);
  }

  static Future<int> count() async {
    return DatabaseUtils.countTable(tableName);
  }

  static Future<int> getNthId(int i) async {
    return DatabaseUtils.getNthItemId(tableName, i, "date DESC, id DESC");
  }

  static Future<List<TransactionModel>> _get(bool first,
      [String? where, List<Object?>? whereArgs]) async {
    List<Map<String, Object?>> items = await DatabaseUtils.database.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: "date DESC, id DESC");

    if (first) {
      items = [items.first];
    }

    List<TransactionModel> out = [];

    for (Map<String, Object?> map in items) {
      int id = map['id'] as int;
      DateTime date = DateTime.parse(map['date'] as String);
      double amount = map['amount'] as double;
      String transactionType = map['transactionType'] as String;
      String name = map['name'] as String;
      List<TagModel> tags = [];

      List<Map<String, Object?>> joinTags = await DatabaseUtils.database.query(
          TagJoinModel.tableName,
          where: "transactionId = ?",
          whereArgs: [id]);

      for (Map<String, Object?> tagMap in joinTags) {
        TagModel? tag = await TagModel.getById(tagMap['tagId'] as int);
        if (tag != null) {
          tags.add(tag);
        }
      }

      TransactionModel model =
          TransactionModel(date, amount, transactionType, name, tags);
      model.id = id;
      out.add(model);
    }

    return out;
  }

  static Future<double> changeFromLastPay() async {
    List<Map<String,Object?>> queryResult = await DatabaseUtils.database.rawQuery(StringBuilder.build([
      "SELECT transactionId, tagId, date, id FROM ${TagJoinModel.tableName}",
      "LEFT JOIN $tableName ON ${TagJoinModel.tableName}.transactionId = $tableName.id",
      "WHERE tagId = ${DatabaseUtils.payTagId}",
      "ORDER BY date DESC, id DESC",
      "LIMIT 1",
    ]));

    TransactionModel? pay;

    if (queryResult.isNotEmpty) {
      pay = await TransactionModel.getById(queryResult.first['id'] as int);
    }

    if (pay == null) {
      return SharedPrefs.total;
    } else {
      List<TransactionModel> transactionsSinceLastPay = await TransactionModel.get("date > ?",[pay.date.toIso8601String()]);
      double sum = 0;
      for (TransactionModel model in transactionsSinceLastPay) {

        if (model.transactionType == TransactionModel.typeCredit) {
          sum += model.amount;
        } else {
          sum -= model.amount;
        }
      }
      return sum;
    }
  }

  @override
  String toString() {
    return "$tableName($id, $date, $amount, $name, ${tags.join(",")})";
  }
}
