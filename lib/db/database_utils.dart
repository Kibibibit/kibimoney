import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kibimoney/db/shared_prefs.dart';
import 'package:kibimoney/models/tag_join_model.dart';
import 'package:kibimoney/models/tag_model.dart';
import 'package:kibimoney/models/transaction_model.dart';
import 'package:kibimoney/utils/settings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Class that stores all database functions and the database itself.
///
/// It's abstract because all of its members are static.
abstract class DatabaseUtils {
  /// The actual database object. Not initialised until `loadDatabase()` is called and completed.
  static late final Database database;

  /// The id for the `Pay` tag. This is set during `loadDatabase()`
  static late int payTagId;

  /// Without this foreign keys don't work :/
  static Future<void> _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  /// Creates all the tables needed. Version could be used to have it do different things
  /// with different db versions.
  static Future<void> _onCreate(Database db, int version) async {
    List<String> tables = [
      TransactionModel.createTable,
      TagModel.createTable,
      TagJoinModel.createTable
    ];

    for (String table in tables) {
      await db.execute(table);
    }
  }

  /// Loads an initilises the database. Make sure to call this before
  /// doing any database related operations.
  ///
  /// Currently called on the loading screen.
  static Future<void> loadDatabase() async {
    /// Without this, there is a chance the db will try to boot before flutter is initilised, which can cause issues
    WidgetsFlutterBinding.ensureInitialized();

    String dbsPath = Platform.isAndroid ? await getDatabasesPath() : (await getLibraryDirectory()).path;

    String dbPath = join(dbsPath, Settings.dbSettings.dbName);

    database = await openDatabase(dbPath,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
        version: Settings.dbSettings.dbVersion);
    
    await createPayTag();
  }

  static Future<void> createPayTag() async {
    /// As we need Pay for "x since last pay" calculations, we create/find it here
    late TagModel payTag;
    List<TagModel> payTags = await TagModel.get("name = ?", ["Pay"]);
    if (payTags.isEmpty) {
      payTag = TagModel("Pay", Colors.green[700]!);
      await payTag.save();
    } else {
      payTag = payTags.first;
    }
    payTagId = payTag.id!;
  }

  /// Gets the next valid primary key for a given table
  static Future<int> getNextId(String tableName) async {
    List<Map<String, Object?>> queryResult =
        await DatabaseUtils.database.query(tableName, columns: ['id']);

    int newId = 0;

    for (Map<String, Object?> entry in queryResult) {
      int id = int.parse('${entry['id']}');
      if (id >= newId) {
        newId = id + 1;
      }
    }
    return newId;
  }

  /// Wipes the database - deletes all tables, reconfigures and recreates the db.
  static Future<void> wipeData() async {
    List<String> tables = [
      TagJoinModel.tableName,
      TagModel.tableName,
      TransactionModel.tableName
    ];

    for (String table in tables) {
      database.execute("DROP TABLE $table");
    }

    await _onConfigure(database);
    await _onCreate(database, Settings.dbSettings.dbVersion);
    await createPayTag();
    await getTotal();
  }

  /// Gets the amount of rows in a table
  static Future<int> countTable(String tableName, [String? where, List<String>? whereArgs]) async {

    String query = 'SELECT COUNT(*) FROM $tableName';
    if (where != null) {
      query = "$query WHERE $where";
    }

    return Sqflite.firstIntValue(
            await database.rawQuery(query,whereArgs)) ??
        0;
  }

  /// After sorting the rows by `orderBy`, returns the nth item of `tableName`. Useful for lazy loading.
  static Future<int> getNthItemId(String tableName, int i,
      {String? orderBy, String? where, List<String>? whereArgs}) async {
    String query = "SELECT id FROM $tableName";
    if (where != null) {
      query = "$query WHERE $where";
    }
    if (orderBy != null) {
      query = "$query ORDER BY $orderBy";
    }
    query = "$query LIMIT 1 OFFSET $i";

    List<Map<String, Object?>> queryResult = await database
        .rawQuery(query, whereArgs);
    if (queryResult.isNotEmpty) {
      return queryResult.first['id'] as int;
    } else {
      return 0;
    }
  }


  /// Calculates the total amount of money, and caches it in shared preferences.
  static Future<double> getTotal() async {
    double total = await TransactionModel.changeSum();
    SharedPrefs.setTotal(total);
    return total;
  }
}
