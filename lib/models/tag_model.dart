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

  static Future<TagModel?> getById(int id) async {
    List<TagModel> tags = await _get(true, 'id = ?',[id]);
    if (tags.isNotEmpty) {
      return tags.first;
    } else {
      return null;
    }
  }

  static Future<List<TagModel>> get([String? where, List<Object?>? whereArgs]) async {
    return _get(false,where,whereArgs);
  }

  static Future<List<TagModel>> _get(bool first, [String? where, List<Object?>? whereArgs]) async {

    List<Map<String, Object?>> items = await DatabaseUtils.database.query(tableName,where: where, whereArgs: whereArgs);

    if (first) {
      items = [items.first];
    }

    List<TagModel> out = [];

    for (Map<String, Object?> map in items) {

      int id = map['id'] as int;
      String name = map['name'] as String;

      TagModel model = TagModel(name);
      model.id = id;

      out.add(model);

    }

    return out;

  }

  @override
  String toString() {
    return "$tableName($id, $name)";
  }

}
