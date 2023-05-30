
import 'package:flutter/material.dart';
import 'package:kibimoney/models/tag_join_model.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/utils/settings.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtils {

  static late final Database database;

  static Future<void> _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  static Future<void> _onCreate(Database db, int version) async {
    List<String> tables = [TransactionModel.createTable,TagModel.createTable,TagJoinModel.createTable];

    for (String table in tables) {
      await db.execute(table);
    }
  }

  static Future<void> loadDatabase() async {

    WidgetsFlutterBinding.ensureInitialized();

    String dbsPath = await getDatabasesPath();

    String dbPath = join(dbsPath, Settings.dbSettings.dbName);

    database = await openDatabase(dbPath, onCreate: _onCreate, onConfigure: _onConfigure, version: Settings.dbSettings.dbVersion);

  }

  static Future<int> getNextId(String tableName) async {
    List<Map<String, Object?>> queryResult = await DatabaseUtils.database.query(tableName,columns: ['id']);

    int newId = 0;

    for (Map<String,Object?> entry in queryResult) {
      int id = int.parse('${entry['id']}');
      if (id >= newId) {
        newId = id+1;
      }
    }
    return newId;
  }

  static Future<void> wipeData() async {
    List<String> tables = [TagJoinModel.tableName, TagModel.tableName, TransactionModel.tableName];

    for (String table in tables) {
      database.execute("DROP TABLE $table");
    }

    _onConfigure(database);
    _onCreate(database, Settings.dbSettings.dbVersion);
  }

}