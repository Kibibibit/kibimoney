import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/utils/string_builder.dart';
import 'package:sqflite/sqflite.dart';

class TagJoinModel {
  static const String tableName = "tag_transaction";
  static final String createTable = StringBuilder.build([
    "CREATE TABLE IF NOT EXISTS $tableName(",
    "transactionId INTEGER,",
    "tagId INTEGER,",
    "FOREIGN KEY(transactionId) REFERENCES ${TransactionModel.tableName}(id),",
    "FOREIGN KEY(tagId) REFERENCES ${TagModel.tableName}(id)",
    ")"
  ]);

  final int transactionId;
  final int tagId;

  TagJoinModel(this.transactionId, this.tagId);

  static Future<void> save(TransactionModel transaction, TagModel tag) async {
    TagJoinModel model = TagJoinModel(transaction.id!, tag.id!);

    await DatabaseUtils.database.insert(
        tableName,
        {
          'transactionId': model.transactionId,
          'tagId': model.tagId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
