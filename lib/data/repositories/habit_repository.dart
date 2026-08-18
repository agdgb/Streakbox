import 'dart:convert';
import '../../core/utils/date_utils.dart';
import '../db/app_database.dart';
import '../db/entry_dao.dart';
import '../db/habit_dao.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';

/// Unified repository interface and implementation for Streakbox data operations.
class HabitRepository {
  final HabitDao _habitDao;
  final EntryDao _entryDao;

  HabitRepository({
    HabitDao? habitDao,
    EntryDao? entryDao,
    AppDatabase? database,
  })  : _habitDao = habitDao ?? HabitDao(database),
        _entryDao = entryDao ?? EntryDao(database);

  // ---------------------------------------------------------------------------
  // Habit Operations
  // ---------------------------------------------------------------------------

  Future<List<Habit>> getActiveHabits() async {
    return await _habitDao.getActiveHabits();
  }

  Future<List<Habit>> getAllHabits() async {
    return await _habitDao.getAllHabits();
  }

  Future<Habit?> getHabitById(String id) async {
    return await _habitDao.getHabitById(id);
  }

  Future<void> saveHabit(Habit habit) async {
    final existing = await _habitDao.getHabitById(habit.id);
    if (existing == null) {
      await _habitDao.insertHabit(habit);
    } else {
      await _habitDao.updateHabit(habit);
    }
  }

  Future<void> deleteHabit(String id) async {
    await _habitDao.deleteHabit(id);
  }

  Future<void> archiveHabit(String id, bool isArchived) async {
    await _habitDao.setArchived(id, isArchived);
  }

  Future<void> reorderHabits(List<String> habitIdsInOrder) async {
    await _habitDao.reorderHabits(habitIdsInOrder);
  }

  // ---------------------------------------------------------------------------
  // Habit Entry Operations
  // ---------------------------------------------------------------------------

  /// Toggles completion status for a habit on a given date key ('yyyy-MM-dd').
  /// Returns `true` if check-in was added, `false` if check-in was removed.
  Future<bool> toggleEntry({
    required String habitId,
    required String dateKey,
    String? entryId,
    String notes = '',
  }) async {
    return await _entryDao.toggleEntry(
      habitId: habitId,
      dateKey: dateKey,
      entryId: entryId,
      notes: notes,
    );
  }

  /// Fetches entries for a habit in a specific month (including boundary days in grid).
  Future<List<HabitEntry>> getEntriesForHabitInMonth(
    String habitId,
    int year,
    int month,
  ) async {
    final firstDayKey = AppDateUtils.formatDateKey(DateTime(year, month, 1));
    final lastDayKey = AppDateUtils.formatDateKey(DateTime(year, month + 1, 0));
    return await _entryDao.getEntriesForHabitInRange(
      habitId,
      firstDayKey,
      lastDayKey,
    );
  }

  /// Fetches all entries for a habit.
  Future<List<HabitEntry>> getEntriesForHabit(String habitId) async {
    return await _entryDao.getEntriesForHabit(habitId);
  }

  /// Fetches all entry date keys ('yyyy-MM-dd') for a habit as a Set for fast lookup.
  Future<Set<String>> getEntryDateKeysForHabit(String habitId) async {
    final entries = await _entryDao.getEntriesForHabit(habitId);
    return entries.map((e) => e.date).toSet();
  }

  /// Saves or updates a specific habit entry.
  Future<void> saveEntry(HabitEntry entry) async {
    await _entryDao.insertEntry(entry);
  }

  /// Deletes a specific habit entry.
  Future<void> deleteEntry(String habitId, String dateKey) async {
    await _entryDao.deleteEntry(habitId, dateKey);
  }

  /// Fetches entries for a specific date across all habits.
  Future<List<HabitEntry>> getEntriesForDate(String dateKey) async {
    return await _entryDao.getEntriesForDate(dateKey);
  }

  /// Fetches all recorded entries across all habits and dates.
  Future<List<HabitEntry>> getAllEntries() async {
    return await _entryDao.getAllEntries();
  }

  // ---------------------------------------------------------------------------
  // Streak & Statistics Calculations
  // ---------------------------------------------------------------------------

  Future<int> getCurrentStreak(String habitId, {DateTime? today}) async {
    final dateKeys = await getEntryDateKeysForHabit(habitId);
    return AppDateUtils.calculateCurrentStreak(dateKeys, today: today);
  }

  Future<int> getBestStreak(String habitId) async {
    final dateKeys = await getEntryDateKeysForHabit(habitId);
    return AppDateUtils.calculateBestStreak(dateKeys);
  }

  Future<double> getCompletionRate(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dateKeys = await getEntryDateKeysForHabit(habitId);
    return AppDateUtils.calculateCompletionRate(dateKeys, startDate, endDate);
  }

  // ---------------------------------------------------------------------------
  // Backup Export & Import (JSON)
  // ---------------------------------------------------------------------------

  /// Exports all habits and entries into a standardized backup structure.
  Future<Map<String, dynamic>> exportBackup() async {
    final habits = await _habitDao.getAllHabits();
    final entries = await _entryDao.getAllEntries();

    return {
      'app': 'Streakbox',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  /// Exports the backup as a formatted JSON string.
  Future<String> exportBackupJsonString() async {
    final data = await exportBackup();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Validates and imports backup JSON data.
  /// If [overwrite] is true, removes existing data before restoring.
  Future<BackupImportResult> importBackup(
    Map<String, dynamic> backupData, {
    bool overwrite = false,
  }) async {
    // Validate schema
    if (backupData['app'] != 'Streakbox' || backupData['version'] == null) {
      throw const FormatException('Invalid backup file: Not a valid Streakbox backup.');
    }

    final rawHabits = backupData['habits'] as List<dynamic>? ?? [];
    final rawEntries = backupData['entries'] as List<dynamic>? ?? [];

    final List<Habit> habitsToImport = [];
    final List<HabitEntry> entriesToImport = [];

    for (final h in rawHabits) {
      if (h is Map<String, dynamic>) {
        habitsToImport.add(Habit.fromJson(h));
      }
    }

    for (final e in rawEntries) {
      if (e is Map<String, dynamic>) {
        entriesToImport.add(HabitEntry.fromJson(e));
      }
    }

    if (overwrite) {
      final existingHabits = await _habitDao.getAllHabits();
      for (final h in existingHabits) {
        await _habitDao.deleteHabit(h.id);
      }
    }

    // Save habits
    for (final habit in habitsToImport) {
      await saveHabit(habit);
    }

    // Save entries
    for (final entry in entriesToImport) {
      await _entryDao.insertEntry(entry);
    }

    return BackupImportResult(
      habitsImported: habitsToImport.length,
      entriesImported: entriesToImport.length,
    );
  }
}

class BackupImportResult {
  final int habitsImported;
  final int entriesImported;

  const BackupImportResult({
    required this.habitsImported,
    required this.entriesImported,
  });
}
