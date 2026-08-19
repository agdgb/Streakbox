import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:streakbox/data/db/app_database.dart';
import 'package:streakbox/data/models/habit.dart';
import 'package:streakbox/data/models/habit_entry.dart';
import 'package:streakbox/data/repositories/habit_repository.dart';
import 'package:streakbox/data/services/cloud_vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Disaster Data Persistence & Backup Tests', () {
    late AppDatabase db;
    late HabitRepository repository;
    late CloudVaultService vaultService;

    setUp(() {
      db = AppDatabase.inMemory();
      repository = HabitRepository(database: db);
      vaultService = CloudVaultService(repository: repository);
    });

    tearDown(() async {
      await db.close();
    });

    test('TC-DAT-01: Full backup export, wipe, reinstall, and restoration without data loss', () async {
      // 1. Populate with 5 diverse habits (Active, Archived, Custom Colors)
      final habit1 = Habit(
        id: 'h1',
        name: 'Morning Workout',
        description: '30 mins HIIT',
        colorValue: 0xFFFF4B72,
        iconCodePoint: 0xe156,
        createdAt: DateTime(2026, 8, 1),
        frequencyType: HabitFrequencyType.daily,
      );
      final habit2 = Habit(
        id: 'h2',
        name: 'Read 20 Pages',
        colorValue: 0xFF00D2FF,
        createdAt: DateTime(2026, 8, 5),
        frequencyType: HabitFrequencyType.specificDays,
        targetDaysOfWeek: [1, 3, 5],
      );
      final habit3 = Habit(
        id: 'h3',
        name: 'Archived Meditation',
        colorValue: 0xFF10B981,
        createdAt: DateTime(2026, 7, 1),
        isArchived: true,
      );

      await repository.saveHabit(habit1);
      await repository.saveHabit(habit2);
      await repository.saveHabit(habit3);

      // 2. Populate 15 historical check-in entries
      for (int i = 1; i <= 10; i++) {
        final dayStr = i < 10 ? '0$i' : '$i';
        await repository.saveEntry(HabitEntry(
          id: 'e1_$i',
          habitId: 'h1',
          date: '2026-08-$dayStr',
          completedAt: DateTime(2026, 8, i, 8, 30),
        ));
      }
      for (int i = 5; i <= 9; i++) {
        final dayStr = i < 10 ? '0$i' : '$i';
        await repository.saveEntry(HabitEntry(
          id: 'e2_$i',
          habitId: 'h2',
          date: '2026-08-$dayStr',
          completedAt: DateTime(2026, 8, i, 21, 0),
        ));
      }

      // 3. Export JSON Snapshot
      final backupJson = await vaultService.createVaultSnapshot();
      expect(backupJson, isNotEmpty);
      final parsed = jsonDecode(backupJson) as Map<String, dynamic>;
      expect(parsed['habits'], hasLength(3));
      expect(parsed['entries'], hasLength(15));

      // 4. Disaster Simulation: Wipe database cleanly (simulate fresh app install)
      final rawDb = await db.database;
      await rawDb.delete('habit_entries');
      await rawDb.delete('habits');

      expect(await repository.getAllHabits(), isEmpty);
      expect(await repository.getAllEntries(), isEmpty);

      // 5. Restore from backup
      final result = await vaultService.restoreVaultSnapshot(backupJson);
      expect(result.habitsRestored, 3);
      expect(result.entriesRestored, 15);

      // 6. Verify restored integrity
      final restoredHabits = await repository.getAllHabits();
      expect(restoredHabits, hasLength(3));
      final restoredH2 = restoredHabits.firstWhere((h) => h.id == 'h2');
      expect(restoredH2.name, 'Read 20 Pages');
      expect(restoredH2.targetDaysOfWeek, [1, 3, 5]);

      final restoredH3 = restoredHabits.firstWhere((h) => h.id == 'h3');
      expect(restoredH3.isArchived, isTrue);

      final restoredEntriesH1 = await repository.getEntriesForHabit('h1');
      expect(restoredEntriesH1, hasLength(10));
    });

    test('TC-DAT-02: Corrupted / Malformed JSON import fails gracefully without corrupting database', () async {
      const corruptedJson = '{"version": 1, "habits": [{"id": "bad", broken_json...';

      expect(
        () async => await vaultService.restoreVaultSnapshot(corruptedJson),
        throwsA(isA<FormatException>()),
      );

      // Verify original repo remains unaffected
      final habits = await repository.getAllHabits();
      expect(habits, isEmpty);
    });

    test('TC-DAT-03: Empty JSON / Invalid schema import fails gracefully', () async {
      const invalidJson = '{"foo": "bar"}';

      expect(
        () async => await vaultService.restoreVaultSnapshot(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('TC-DAT-04: Duplicate record imports perform safe set-union upsert', () async {
      final habit = Habit(
        id: 'h1',
        name: 'Hydration',
        colorValue: 0xFF00D2FF,
        createdAt: DateTime(2026, 8, 1),
      );
      await repository.saveHabit(habit);
      await repository.saveEntry(HabitEntry(
        id: 'e1',
        habitId: 'h1',
        date: '2026-08-19',
        completedAt: DateTime(2026, 8, 19, 10, 0),
      ));

      final snapshot = await vaultService.createVaultSnapshot();

      // Restore same snapshot on top of existing database
      final result = await vaultService.restoreVaultSnapshot(snapshot);
      expect(result.habitsRestored, 1);
      expect(result.entriesRestored, 1);

      // Verify no duplicate records created
      final habits = await repository.getAllHabits();
      expect(habits, hasLength(1));
      final entries = await repository.getEntriesForHabit('h1');
      expect(entries, hasLength(1));
    });
  });
}
