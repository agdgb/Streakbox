import 'dart:convert';
import '../../core/utils/date_utils.dart';
import '../models/habit.dart';
import '../models/habit_entry.dart';
import 'habit_repository.dart';

/// In-memory repository implementation providing instant, zero-dependency persistence for Web and testing.
class InMemoryHabitRepository implements HabitRepository {
  final Map<String, Habit> _habits = {};
  final Map<String, HabitEntry> _entries = {}; // key: "${habitId}_${dateKey}"
  final Map<String, String> _settings = {};

  InMemoryHabitRepository();

  @override
  Future<String?> getSetting(String key) async => _settings[key];

  @override
  Future<void> saveSetting(String key, String value) async {
    _settings[key] = value;
  }

  @override
  Future<int?> getSettingInt(String key) async {
    final val = _settings[key];
    return val != null ? int.tryParse(val) : null;
  }

  @override
  Future<void> saveSettingInt(String key, int value) async {
    _settings[key] = value.toString();
  }

  @override
  Future<bool?> getSettingBool(String key) async {
    final val = _settings[key];
    return val != null ? (val == '1' || val == 'true') : null;
  }

  @override
  Future<void> saveSettingBool(String key, bool value) async {
    _settings[key] = value ? '1' : '0';
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    final list = _habits.values.where((h) => !h.isArchived).toList();
    list.sort((a, b) {
      final sortComp = a.sortOrder.compareTo(b.sortOrder);
      if (sortComp != 0) return sortComp;
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final list = _habits.values.toList();
    list.sort((a, b) {
      final archComp = (a.isArchived ? 1 : 0).compareTo(b.isArchived ? 1 : 0);
      if (archComp != 0) return archComp;
      final sortComp = a.sortOrder.compareTo(b.sortOrder);
      if (sortComp != 0) return sortComp;
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    return _habits[id];
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    _habits[habit.id] = habit;
  }

  @override
  Future<void> saveEntry(HabitEntry entry) async {
    _entries['${entry.habitId}_${entry.date}'] = entry;
  }

  @override
  Future<void> deleteEntry(String habitId, String dateKey) async {
    _entries.remove('${habitId}_$dateKey');
  }

  @override
  Future<void> deleteHabit(String id) async {
    _habits.remove(id);
    _entries.removeWhere((key, entry) => entry.habitId == id);
  }

  @override
  Future<void> archiveHabit(String id, bool isArchived) async {
    final existing = _habits[id];
    if (existing != null) {
      _habits[id] = existing.copyWith(isArchived: isArchived);
    }
  }

  @override
  Future<void> reorderHabits(List<String> habitIdsInOrder) async {
    for (int i = 0; i < habitIdsInOrder.length; i++) {
      final habitId = habitIdsInOrder[i];
      final habit = _habits[habitId];
      if (habit != null) {
        _habits[habitId] = habit.copyWith(sortOrder: i);
      }
    }
  }

  @override
  Future<bool> toggleEntry({
    required String habitId,
    required String dateKey,
    String? entryId,
    String notes = '',
  }) async {
    final key = '${habitId}_$dateKey';
    if (_entries.containsKey(key)) {
      _entries.remove(key);
      return false;
    } else {
      _entries[key] = HabitEntry(
        id: entryId ?? key,
        habitId: habitId,
        date: dateKey,
        completedAt: DateTime.now(),
        notes: notes,
      );
      return true;
    }
  }

  @override
  Future<List<HabitEntry>> getEntriesForHabitInMonth(
    String habitId,
    int year,
    int month,
  ) async {
    final firstDayKey = AppDateUtils.formatDateKey(DateTime(year, month, 1));
    final lastDayKey = AppDateUtils.formatDateKey(DateTime(year, month + 1, 0));
    final list = _entries.values
        .where((e) =>
            e.habitId == habitId &&
            e.date.compareTo(firstDayKey) >= 0 &&
            e.date.compareTo(lastDayKey) <= 0)
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<List<HabitEntry>> getEntriesForHabit(String habitId) async {
    final list =
        _entries.values.where((e) => e.habitId == habitId).toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<Set<String>> getEntryDateKeysForHabit(String habitId) async {
    return _entries.values
        .where((e) => e.habitId == habitId)
        .map((e) => e.date)
        .toSet();
  }

  @override
  Future<List<HabitEntry>> getEntriesForDate(String dateKey) async {
    return _entries.values.where((e) => e.date == dateKey).toList();
  }

  @override
  Future<List<HabitEntry>> getAllEntries() async {
    final list = _entries.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<int> getCurrentStreak(String habitId, {DateTime? today}) async {
    final dateKeys = await getEntryDateKeysForHabit(habitId);
    return AppDateUtils.calculateCurrentStreak(dateKeys, today: today);
  }

  @override
  Future<int> getBestStreak(String habitId) async {
    final dateKeys = await getEntryDateKeysForHabit(habitId);
    return AppDateUtils.calculateBestStreak(dateKeys);
  }

  @override
  Future<double> getCompletionRate(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dateKeys = await getEntryDateKeysForHabit(habitId);
    return AppDateUtils.calculateCompletionRate(dateKeys, startDate, endDate);
  }

  @override
  Future<Map<String, dynamic>> exportBackup() async {
    final habits = await getAllHabits();
    final entries = _entries.values.toList()..sort((a, b) => a.date.compareTo(b.date));

    return {
      'app': 'Streakbox',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  @override
  Future<String> exportBackupJsonString() async {
    final data = await exportBackup();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  @override
  Future<BackupImportResult> importBackup(
    Map<String, dynamic> backupData, {
    bool overwrite = false,
  }) async {
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
      _habits.clear();
      _entries.clear();
    }

    for (final habit in habitsToImport) {
      await saveHabit(habit);
    }

    for (final entry in entriesToImport) {
      _entries['${entry.habitId}_${entry.date}'] = entry;
    }

    return BackupImportResult(
      habitsImported: habitsToImport.length,
      entriesImported: entriesToImport.length,
    );
  }
}
