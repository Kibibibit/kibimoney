import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/models/tag_join_model.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:sqflite/sqflite.dart';

class TransactionModel {
  static const String typeCredit = "CREDIT";
  static const String typeDebit = "DEBIT";

  static const String tableName = "transaction_model";
  static const String createTable =
      "CREATE TABLE IF NOT EXISTS $tableName(id INTEGER PRIMARY KEY, date TEXT, amount REAL, transactionType TEXT, name TEXT)";

  late final int id;
  final DateTime date;
  final double amount;
  final String transactionType;
  final String name;
  final List<TagModel> tags;

  TransactionModel(
      this.date, this.amount, this.transactionType, this.name, this.tags);

  Future<void> save() async {
    id = await DatabaseUtils.getNextId(tableName);

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
  }
}
