import 'package:sqflite/sqflite.dart';
import '../models/habit.dart';
import 'app_database.dart';

/// Data Access Object for `habits` table operations.
class HabitDao {
  final AppDatabase _appDatabase;

  HabitDao([AppDatabase? appDatabase])
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  /// Inserts a new habit.
  Future<void> insertHabit(Habit habit) async {
    final db = await _db;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing habit.
  Future<int> updateHabit(Habit habit) async {
    final db = await _db;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// Deletes a habit and all of its associated entries (via CASCADE).
  Future<int> deleteHabit(String habitId) async {
    final db = await _db;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  /// Archives or un-archives a habit.
  Future<int> setArchived(String habitId, bool isArchived) async {
    final db = await _db;
    return await db.update(
      'habits',
      {'is_archived': isArchived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  /// Retrieves a habit by ID.
  Future<Habit?> getHabitById(String habitId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [habitId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Habit.fromMap(maps.first);
  }

  /// Retrieves all active (non-archived) habits ordered by sort_order and created_at.
  Future<List<Habit>> getActiveHabits() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return maps.map(Habit.fromMap).toList();
  }

  /// Retrieves all habits including archived ones.
  Future<List<Habit>> getAllHabits() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      orderBy: 'is_archived ASC, sort_order ASC, created_at ASC',
    );
    return maps.map(Habit.fromMap).toList();
  }

  /// Reorders habits by updating their `sort_order`.
  Future<void> reorderHabits(List<String> habitIdsInOrder) async {
    final db = await _db;
    final batch = db.batch();
    for (int i = 0; i < habitIdsInOrder.length; i++) {
      batch.update(
        'habits',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [habitIdsInOrder[i]],
      );
    }
    await batch.commit(noResult: true);
  }
}
