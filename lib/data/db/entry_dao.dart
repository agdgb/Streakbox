import 'package:sqflite/sqflite.dart';
import '../models/habit_entry.dart';
import 'app_database.dart';

/// Data Access Object for `habit_entries` table operations.
class EntryDao {
  final AppDatabase _appDatabase;

  EntryDao([AppDatabase? appDatabase])
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  /// Inserts or replaces a habit entry.
  Future<void> insertEntry(HabitEntry entry) async {
    final db = await _db;
    await db.insert(
      'habit_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes a specific habit entry by habitId and date.
  Future<int> deleteEntry(String habitId, String dateKey) async {
    final db = await _db;
    return await db.delete(
      'habit_entries',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateKey],
    );
  }

  /// Toggles an entry: if it exists, deletes it and returns false.
  /// If it does not exist, inserts it and returns true.
  Future<bool> toggleEntry({
    required String habitId,
    required String dateKey,
    String? entryId,
    String notes = '',
  }) async {
    final existing = await getEntry(habitId, dateKey);
    if (existing != null) {
      await deleteEntry(habitId, dateKey);
      return false;
    } else {
      final newEntry = HabitEntry(
        id: entryId ?? '${habitId}_$dateKey',
        habitId: habitId,
        date: dateKey,
        completedAt: DateTime.now(),
        notes: notes,
      );
      await insertEntry(newEntry);
      return true;
    }
  }

  /// Retrieves an entry for a specific habit on a specific date.
  Future<HabitEntry?> getEntry(String habitId, String dateKey) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_entries',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateKey],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HabitEntry.fromMap(maps.first);
  }

  /// Retrieves all entries for a habit within a date key range (inclusive).
  Future<List<HabitEntry>> getEntriesForHabitInRange(
    String habitId,
    String startDateKey,
    String endDateKey,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_entries',
      where: 'habit_id = ? AND date >= ? AND date <= ?',
      whereArgs: [habitId, startDateKey, endDateKey],
      orderBy: 'date ASC',
    );
    return maps.map(HabitEntry.fromMap).toList();
  }

  /// Retrieves all entries for a given habit (useful for calculating lifetime streaks).
  Future<List<HabitEntry>> getEntriesForHabit(String habitId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_entries',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date ASC',
    );
    return maps.map(HabitEntry.fromMap).toList();
  }

  /// Retrieves all entries for a specific date across all habits.
  Future<List<HabitEntry>> getEntriesForDate(String dateKey) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_entries',
      where: 'date = ?',
      whereArgs: [dateKey],
    );
    return maps.map(HabitEntry.fromMap).toList();
  }

  /// Retrieves all entries across the entire database (used for backup export).
  Future<List<HabitEntry>> getAllEntries() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_entries',
      orderBy: 'date ASC',
    );
    return maps.map(HabitEntry.fromMap).toList();
  }
}
