import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// Database manager for SQLite persistence across Web, Mobile, Desktop, and Tests.
class AppDatabase {
  static const String _databaseName = 'streakbox.db';
  static const int _databaseVersion = 1;

  static AppDatabase? _instance;
  sqflite.Database? _db;
  final bool _isInMemory;

  AppDatabase._({this._isInMemory = false});

  /// Default singleton instance for application use.
  static AppDatabase get instance => _instance ??= AppDatabase._();

  /// Factory constructor for creating isolated in-memory instances (ideal for unit tests).
  static AppDatabase inMemory() => AppDatabase._(isInMemory: true);

  /// Returns the open database instance, initializing it if needed.
  Future<sqflite.Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<sqflite.Database> _initDatabase() async {
    sqflite.Database db;
    if (_isInMemory || kIsWeb) {
      db = await sqflite.openDatabase(
        sqflite.inMemoryDatabasePath,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    } else {
      final dbPath = await _resolveDatabasePath();
      db = await sqflite.openDatabase(
        dbPath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
      );
    }

    // Ensure all tables and indices exist across any environment / browser storage state
    await _createTables(db);
    return db;
  }

  static Future<String> _resolveDatabasePath() async {
    if (kIsWeb) {
      return _databaseName;
    }
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final appSupportDir = await getApplicationSupportDirectory();
      return p.join(appSupportDir.path, 'Streakbox', _databaseName);
    }
    final documentsDirectory = await sqflite.getDatabasesPath();
    return p.join(documentsDirectory, _databaseName);
  }

  static Future<void> _onConfigure(sqflite.Database db) async {
    if (!kIsWeb) {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  static Future<void> _onCreate(sqflite.Database db, int version) async {
    await _createTables(db);
  }

  static Future<void> _createTables(sqflite.Database db) async {
    // Table: habits
    await db.execute('''
      CREATE TABLE IF NOT EXISTS habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL DEFAULT 57686,
        created_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        target_days_per_week INTEGER NOT NULL DEFAULT 7,
        frequency_type TEXT NOT NULL DEFAULT 'daily',
        target_days_of_week TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Safe column migrations for existing databases
    try {
      await db.execute('ALTER TABLE habits ADD COLUMN target_days_per_week INTEGER NOT NULL DEFAULT 7');
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE habits ADD COLUMN frequency_type TEXT NOT NULL DEFAULT 'daily'");
    } catch (_) {}
    try {
      await db.execute("ALTER TABLE habits ADD COLUMN target_days_of_week TEXT NOT NULL DEFAULT ''");
    } catch (_) {}

    // Table: habit_entries
    await db.execute('''
      CREATE TABLE IF NOT EXISTS habit_entries (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        date TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        notes TEXT DEFAULT '',
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE (habit_id, date)
      )
    ''');

    // Table: settings
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Indices for instant lookup in calendar month matrices & stats
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_habit_entries_habit_date ON habit_entries (habit_id, date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_habit_entries_date ON habit_entries (date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_habits_is_archived ON habits (is_archived, sort_order)',
    );
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
