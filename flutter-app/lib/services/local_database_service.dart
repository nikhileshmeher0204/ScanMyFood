import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:read_the_label/core/constants/database_constants.dart';
import 'package:read_the_label/models/cached_daily_intake_record.dart';
import 'package:read_the_label/models/cached_user_profile_record.dart';
import 'package:read_the_label/main.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  static const String _createUserProfileTableQuery = '''
    CREATE TABLE ${DatabaseConstants.tableUserProfile} (
      ${DatabaseConstants.columnUserId} TEXT PRIMARY KEY,
      ${DatabaseConstants.columnProfileJson} TEXT NOT NULL,
      ${DatabaseConstants.columnCachedAt} INTEGER NOT NULL
    )
  ''';

  static const String _createDailyIntakeTableQuery = '''
    CREATE TABLE ${DatabaseConstants.tableDailyIntake} (
      ${DatabaseConstants.columnUserId} TEXT NOT NULL,
      ${DatabaseConstants.columnDateKey} TEXT NOT NULL,
      ${DatabaseConstants.columnDataJson} TEXT NOT NULL,
      ${DatabaseConstants.columnCachedAt} INTEGER NOT NULL,
      PRIMARY KEY (${DatabaseConstants.columnUserId}, ${DatabaseConstants.columnDateKey})
    )
  ''';

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    logger.i('Initializing SQLite Database at: $path');
    return await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    logger.i('Creating SQLite Tables...');
    await db.execute(_createUserProfileTableQuery);
    await db.execute(_createDailyIntakeTableQuery);
  }

  // --- User Profile cache operations ---

  Future<void> saveUserProfile(CachedUserProfileRecord record) async {
    try {
      final db = await database;
      final profileJsonStr = await compute(jsonEncode, record.profile.toJson());
      
      await db.insert(
        DatabaseConstants.tableUserProfile,
        record.toDbMap(profileJsonStr),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      logger.d('Saved User Profile Cache to SQLite for: ${record.userId}');
    } catch (e) {
      logger.e('Failed to save user profile to SQLite: $e');
    }
  }

  Future<CachedUserProfileRecord?> getUserProfile(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableUserProfile,
        where: '${DatabaseConstants.columnUserId} = ?',
        whereArgs: [userId],
      );

      if (maps.isEmpty) return null;

      final dbMap = maps.first;
      final jsonStr = dbMap[DatabaseConstants.columnProfileJson] as String;
      final profileJson = await compute(jsonDecode, jsonStr) as Map<String, dynamic>;

      return CachedUserProfileRecord.fromDbMap(dbMap, profileJson);
    } catch (e) {
      logger.e('Failed to get user profile from SQLite: $e');
      return null;
    }
  }

  Future<void> clearUserProfile(String userId) async {
    try {
      final db = await database;
      await db.delete(
        DatabaseConstants.tableUserProfile,
        where: '${DatabaseConstants.columnUserId} = ?',
        whereArgs: [userId],
      );
      logger.d('Cleared User Profile Cache in SQLite for: $userId');
    } catch (e) {
      logger.e('Failed to clear user profile from SQLite: $e');
    }
  }

  // --- Daily Intake cache operations ---

  Future<void> saveDailyIntake(CachedDailyIntakeRecord record) async {
    try {
      final db = await database;
      final dataJsonStr = await compute(jsonEncode, record.data.toJson());

      await db.insert(
        DatabaseConstants.tableDailyIntake,
        record.toDbMap(dataJsonStr),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      logger.d('Saved Daily Intake Cache to SQLite for: ${record.userId} on ${record.dateKey}');
    } catch (e) {
      logger.e('Failed to save daily intake to SQLite: $e');
    }
  }

  Future<CachedDailyIntakeRecord?> getDailyIntake(String userId, String dateKey) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableDailyIntake,
        where: '${DatabaseConstants.columnUserId} = ? AND ${DatabaseConstants.columnDateKey} = ?',
        whereArgs: [userId, dateKey],
      );

      if (maps.isEmpty) return null;

      final dbMap = maps.first;
      final jsonStr = dbMap[DatabaseConstants.columnDataJson] as String;
      final dataJson = await compute(jsonDecode, jsonStr) as Map<String, dynamic>;

      return CachedDailyIntakeRecord.fromDbMap(dbMap, dataJson);
    } catch (e) {
      logger.e('Failed to get daily intake from SQLite: $e');
      return null;
    }
  }

  Future<List<CachedDailyIntakeRecord>> getAllDailyIntakes(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.tableDailyIntake,
        where: '${DatabaseConstants.columnUserId} = ?',
        whereArgs: [userId],
      );

      if (maps.isEmpty) return [];

      final List<CachedDailyIntakeRecord> records = [];
      for (final map in maps) {
        final jsonStr = map[DatabaseConstants.columnDataJson] as String;
        final dataJson = await compute(jsonDecode, jsonStr) as Map<String, dynamic>;
        records.add(CachedDailyIntakeRecord.fromDbMap(map, dataJson));
      }
      return records;
    } catch (e) {
      logger.e('Failed to get all daily intakes from SQLite: $e');
      return [];
    }
  }

  Future<void> deleteDailyIntake(String userId, String dateKey) async {
    try {
      final db = await database;
      await db.delete(
        DatabaseConstants.tableDailyIntake,
        where: '${DatabaseConstants.columnUserId} = ? AND ${DatabaseConstants.columnDateKey} = ?',
        whereArgs: [userId, dateKey],
      );
      logger.d('Deleted Daily Intake Cache in SQLite for: $userId on $dateKey');
    } catch (e) {
      logger.e('Failed to delete daily intake from SQLite: $e');
    }
  }

  Future<void> clearDailyIntakes(String userId) async {
    try {
      final db = await database;
      await db.delete(
        DatabaseConstants.tableDailyIntake,
        where: '${DatabaseConstants.columnUserId} = ?',
        whereArgs: [userId],
      );
      logger.d('Cleared All Daily Intake Cache in SQLite for: $userId');
    } catch (e) {
      logger.e('Failed to clear daily intakes from SQLite: $e');
    }
  }
}
