import 'package:kibimoney/db/database_utils.dart';
import 'package:sqflite/sqflite.dart';

class TagModel {
  static const String tableName = "tag_model";
  static const String createTable =
      "CREATE TABLE IF NOT EXISTS $tableName(id INTEGER PRIMARY KEY, name TEXT)";

  late final int id;
  final String name;

  TagModel(this.name);

  Future<void> save() async {
    id = await DatabaseUtils.getNextId(tableName);

    await DatabaseUtils.database.insert(tableName, {'id': id, 'name': name},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
