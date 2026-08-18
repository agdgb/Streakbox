import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:streakbox/core/utils/date_utils.dart';
import 'package:streakbox/data/db/app_database.dart';
import 'package:streakbox/data/models/habit.dart';
import 'package:streakbox/data/models/habit_entry.dart';
import 'package:streakbox/data/repositories/habit_repository.dart';
import 'package:streakbox/data/services/cloud_vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  group('Core Streak Engine Tests', () {
    final today = DateTime(2026, 8, 18);

    test('1. Streak is 0 when no entries exist', () {
      expect(AppDateUtils.calculateCurrentStreak({}, today: today), 0);
    });

    test('2. Streak is 1 when checked today', () {
      final entries = {'2026-08-18'};
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 1);
    });

    test('3. Streak is 1 when checked yesterday and today is still open', () {
      final entries = {'2026-08-17'};
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 1);
    });

    test('4. Streak increments consecutively across days', () {
      final entries = {
        '2026-08-14',
        '2026-08-15',
        '2026-08-16',
        '2026-08-17',
        '2026-08-18',
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 5);
      expect(AppDateUtils.calculateBestStreak(entries), 5);
    });

    test('5. Missed day resets current streak but preserves best streak', () {
      final entries = {
        '2026-08-10',
        '2026-08-11',
        '2026-08-12',
        '2026-08-13',
        // Missed 2026-08-14, 15, 16, 17
        '2026-08-18', // Checked today
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 1);
      expect(AppDateUtils.calculateBestStreak(entries), 4);
    });
  });

  group('Scheduled Opportunity Consistency Engine Tests', () {
    final today = DateTime(2026, 8, 18); // Tuesday

    test('1. Evaluates 100% for habit created 5 days ago with 5 check-ins', () {
      final createdAt = today.subtract(const Duration(days: 4)); // 5 days total
      final entries = {
        '2026-08-14',
        '2026-08-15',
        '2026-08-16',
        '2026-08-17',
        '2026-08-18',
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
        habitCreatedAt: createdAt,
        windowDays: 30,
      );

      expect(metrics.totalDays, 5);
      expect(metrics.completedDays, 5);
      expect(metrics.percentage, 100.0);
      expect(metrics.gradeLabel, 'LEGENDARY');
    });

    test('2. Only evaluates scheduled opportunity days for specific weekday habits (e.g. Mon, Wed, Fri)', () {
      // 14 days window (2 full weeks = exactly 6 scheduled MWF opportunities)
      final windowStart = today.subtract(const Duration(days: 13));
      final mwfSchedule = [1, 3, 5]; // Mon, Wed, Fri

      // User checked in 5 out of the 6 scheduled MWF days
      final entries = {
        '2026-08-05', // Wed
        '2026-08-07', // Fri
        '2026-08-10', // Mon
        '2026-08-12', // Wed
        '2026-08-14', // Fri
        // Missed 2026-08-17 Mon
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
        habitCreatedAt: windowStart,
        windowDays: 14,
        targetDaysOfWeek: mwfSchedule,
      );

      expect(metrics.totalDays, 6);
      expect(metrics.completedDays, 5);
      expect(metrics.percentage, closeTo(83.33, 0.1));
      expect(metrics.gradeLabel, 'STRONG');
    });
  });

  group('Never Miss Twice Recovery Protocol Tests', () {
    final today = DateTime(2026, 8, 18);

    test('1. Recovery mode is active when yesterday was missed and today is open', () {
      final entries = {
        '2026-08-15',
        '2026-08-16',
        // Missed 2026-08-17 (yesterday)
        // Today 2026-08-18 not done yet
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
      );

      expect(metrics.isRecoveryModeActive, isTrue);
      expect(metrics.isTodayCompleted, isFalse);
    });

    test('2. Recovery mode clears immediately upon completing today', () {
      final entries = {
        '2026-08-15',
        '2026-08-16',
        // Missed 2026-08-17 (yesterday)
        '2026-08-18', // Completed today
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
      );

      expect(metrics.isTodayCompleted, isTrue);
      expect(metrics.isRecoveryModeActive, isFalse);
    });
  });

  group('Zero-Knowledge Cloud Vault Roundtrip Tests', () {
    test('1. Serializes and restores habits and entries without data loss', () async {
      final db = AppDatabase.inMemory();
      final inMemoryRepo = HabitRepository(database: db);
      final vaultService = CloudVaultService(repository: inMemoryRepo);

      final habit1 = Habit(
        id: 'h1',
        name: 'Morning Workout',
        colorValue: 0xFFFF4B72,
        createdAt: DateTime(2026, 8, 1),
      );
      final habit2 = Habit(
        id: 'h2',
        name: 'Deep Reading',
        colorValue: 0xFF00D2FF,
        createdAt: DateTime(2026, 8, 5),
      );

      await inMemoryRepo.saveHabit(habit1);
      await inMemoryRepo.saveHabit(habit2);

      final entry1 = HabitEntry(
        id: 'e1',
        habitId: 'h1',
        date: '2026-08-17',
        completedAt: DateTime(2026, 8, 17, 8, 30),
      );
      final entry2 = HabitEntry(
        id: 'e2',
        habitId: 'h2',
        date: '2026-08-17',
        completedAt: DateTime(2026, 8, 17, 21, 0),
      );

      await inMemoryRepo.saveEntry(entry1);
      await inMemoryRepo.saveEntry(entry2);

      // Export JSON snapshot
      final snapshotJson = await vaultService.createVaultSnapshot();
      expect(snapshotJson, contains('Morning Workout'));
      expect(snapshotJson, contains('Deep Reading'));
      expect(snapshotJson, contains('2026-08-17'));

      // Restore into a blank repository
      final freshDb = AppDatabase.inMemory();
      final freshRepo = HabitRepository(database: freshDb);
      final freshVault = CloudVaultService(repository: freshRepo);

      final result = await freshVault.restoreVaultSnapshot(snapshotJson);
      expect(result.habitsRestored, 2);
      expect(result.entriesRestored, 2);

      final restoredHabits = await freshRepo.getAllHabits();
      expect(restoredHabits.length, 2);
      expect(restoredHabits.map((h) => h.name), containsAll(['Morning Workout', 'Deep Reading']));

      await db.close();
      await freshDb.close();
    });
  });
}
