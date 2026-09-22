import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

/// Data Access Object for persisting key-value settings in SQLite.
class SettingsDao {
  final AppDatabase _appDatabase;

  SettingsDao([AppDatabase? appDatabase])
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  /// Retrieves a string setting by key.
  Future<String?> getSetting(String key) async {
    final db = await _db;
    final results = await db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }

  /// Sets a string setting by key.
  Future<void> setSetting(String key, String value) async {
    final db = await _db;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves an integer setting by key.
  Future<int?> getInt(String key) async {
    final strVal = await getSetting(key);
    if (strVal != null) {
      return int.tryParse(strVal);
    }
    return null;
  }

  /// Sets an integer setting by key.
  Future<void> setInt(String key, int value) async {
    await setSetting(key, value.toString());
  }

  /// Retrieves a boolean setting by key.
  Future<bool?> getBool(String key) async {
    final strVal = await getSetting(key);
    if (strVal != null) {
      return strVal == '1' || strVal == 'true';
    }
    return null;
  }

  /// Sets a boolean setting by key.
  Future<void> setBool(String key, bool value) async {
    await setSetting(key, value ? '1' : '0');
  }

  /// Deletes a setting by key.
  Future<void> deleteSetting(String key) async {
    final db = await _db;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  /// Retrieves all settings as a key-value Map.
  Future<Map<String, String>> getAllSettings() async {
    final db = await _db;
    final results = await db.query('settings');
    final map = <String, String>{};
    for (final row in results) {
      final k = row['key'] as String?;
      final v = row['value'] as String?;
      if (k != null && v != null) {
        map[k] = v;
      }
    }
    return map;
  }
}
