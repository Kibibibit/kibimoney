import 'package:flutter/material.dart';
import 'package:kibimoney/db/database_utils.dart';
import 'package:kibimoney/models/tag_join_model.dart';
import 'package:sqflite/sqflite.dart';

class TagModel {
  static const String tableName = "tag_model";
  static const String createTable =
      "CREATE TABLE IF NOT EXISTS $tableName(id INTEGER PRIMARY KEY, name TEXT, color INTEGER)";

  int? id;
  String name;
  Color color;

  TagModel(this.name, this.color);

  Future<void> save() async {
    id ??= await DatabaseUtils.getNextId(tableName);

    await DatabaseUtils.database.insert(
        tableName, {'id': id, 'name': name, 'color': color.value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete() async {
    await DatabaseUtils.database
        .delete(TagJoinModel.tableName, where: "tagId = ?", whereArgs: [id]);
    await DatabaseUtils.database
        .delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  static Future<TagModel?> getById(int id) async {
    List<TagModel> tags = await _get(true, 'id = ?', [id]);
    if (tags.isNotEmpty) {
      return tags.first;
    } else {
      return null;
    }
  }

  static Future<int> count() async {
    return DatabaseUtils.countTable(tableName);
  }

  static Future<int> getNthId(int i) async {
    return DatabaseUtils.getNthItemId(tableName,i);
  }

  static Future<List<TagModel>> get(
      [String? where, List<Object?>? whereArgs]) async {
    return _get(false, where, whereArgs);
  }

  static Future<List<TagModel>> _get(bool first,
      [String? where, List<Object?>? whereArgs]) async {
    List<Map<String, Object?>> items = await DatabaseUtils.database
        .query(tableName, where: where, whereArgs: whereArgs);

    if (first) {
      items = [items.first];
    }

    List<TagModel> out = [];

    for (Map<String, Object?> map in items) {
      int id = map['id'] as int;
      String name = map['name'] as String;
      Color color = Color(map['color'] as int);

      TagModel model = TagModel(name, color);
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
