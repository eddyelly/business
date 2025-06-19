import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/feedback_model.dart';
import '../models/report_model.dart';
import '../models/user_preferences_model.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.localDbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.localDbVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create tables
    await _createUserPreferencesTable(db);
    await _createFeedbackTable(db);
    await _createReportsTable(db);
  }

  Future _createUserPreferencesTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        theme_mode TEXT,
        notifications_enabled INTEGER,
        auto_backup INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future _createFeedbackTable(Database db) async {
    await db.execute('''
      CREATE TABLE feedback_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT,
        rating INTEGER,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future _createReportsTable(Database db) async {
    await db.execute('''
      CREATE TABLE reports_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL,
        category TEXT,
        date TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // User Preferences CRUD
  Future<int> insertUserPreferences(UserPreferences preferences) async {
    final db = await database;
    return await db.insert('user_preferences', preferences.toMap());
  }

  Future<UserPreferences?> getUserPreferences(String userId) async {
    final db = await database;
    final maps = await db.query(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserPreferences.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserPreferences(UserPreferences preferences) async {
    final db = await database;
    return await db.update(
      'user_preferences',
      preferences.toMap(),
      where: 'user_id = ?',
      whereArgs: [preferences.userId],
    );
  }

  // Feedback CRUD
  Future<int> insertFeedback(FeedbackModel feedback) async {
    final db = await database;
    return await db.insert('feedback_local', feedback.toMap());
  }

  Future<List<FeedbackModel>> getAllFeedback() async {
    final db = await database;
    final result = await db.query('feedback_local');
    return result.map((json) => FeedbackModel.fromMap(json)).toList();
  }

  Future<List<FeedbackModel>> getUnsyncedFeedback() async {
    final db = await database;
    final result = await db.query(
      'feedback_local',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((json) => FeedbackModel.fromMap(json)).toList();
  }

  Future<int> markFeedbackAsSynced(int id) async {
    final db = await database;
    return await db.update(
      'feedback_local',
      {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reports CRUD
  Future<int> insertReport(ReportModel report) async {
    final db = await database;
    return await db.insert('reports_local', report.toMap());
  }

  Future<List<ReportModel>> getAllReports() async {
    final db = await database;
    final result = await db.query('reports_local');
    return result.map((json) => ReportModel.fromMap(json)).toList();
  }

  Future<List<ReportModel>> getUnsyncedReports() async {
    final db = await database;
    final result = await db.query(
      'reports_local',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return result.map((json) => ReportModel.fromMap(json)).toList();
  }

  Future<int> markReportAsSynced(int id) async {
    final db = await database;
    return await db.update(
      'reports_local',
      {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete(
      'reports_local',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('user_preferences');
    await db.delete('feedback_local');
    await db.delete('reports_local');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
} 