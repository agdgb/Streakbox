import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:streakbox/data/db/app_database.dart';
import 'package:streakbox/data/models/habit.dart';
import 'package:streakbox/data/repositories/habit_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;
  late HabitRepository repository;

  setUp(() {
    db = AppDatabase.inMemory();
    repository = HabitRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('HabitRepository - Habit CRUD', () {
    test('creates, retrieves, updates, and deletes habits', () async {
      final habit1 = Habit(
        id: 'h1',
        name: 'Morning Workout',
        description: '30 mins cardio',
        colorValue: 0xFF10B981,
        iconCodePoint: 0xe156,
        createdAt: DateTime(2026, 8, 1),
        sortOrder: 0,
      );

      final habit2 = Habit(
        id: 'h2',
        name: 'Read Books',
        colorValue: 0xFF8B5CF6,
        createdAt: DateTime(2026, 8, 2),
        sortOrder: 1,
      );

      await repository.saveHabit(habit1);
      await repository.saveHabit(habit2);

      // Verify active habits
      final active = await repository.getActiveHabits();
      expect(active.length, 2);
      expect(active[0].name, 'Morning Workout');
      expect(active[1].name, 'Read Books');

      // Update habit
      final updated = habit1.copyWith(name: 'Intense Workout');
      await repository.saveHabit(updated);
      final retrieved = await repository.getHabitById('h1');
      expect(retrieved?.name, 'Intense Workout');

      // Archive habit
      await repository.archiveHabit('h1', true);
      final activeAfterArchive = await repository.getActiveHabits();
      expect(activeAfterArchive.length, 1);
      expect(activeAfterArchive.first.id, 'h2');

      final allHabits = await repository.getAllHabits();
      expect(allHabits.length, 2);

      // Delete habit
      await repository.deleteHabit('h2');
      final remaining = await repository.getAllHabits();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'h1');
    });

    test('reorders habits correctly', () async {
      final habit1 = Habit(
        id: 'h1',
        name: 'Habit 1',
        colorValue: 0xFF10B981,
        createdAt: DateTime.now(),
        sortOrder: 0,
      );
      final habit2 = Habit(
        id: 'h2',
        name: 'Habit 2',
        colorValue: 0xFF8B5CF6,
        createdAt: DateTime.now(),
        sortOrder: 1,
      );

      await repository.saveHabit(habit1);
      await repository.saveHabit(habit2);

      // Reverse order
      await repository.reorderHabits(['h2', 'h1']);

      final ordered = await repository.getActiveHabits();
      expect(ordered.first.id, 'h2');
      expect(ordered.last.id, 'h1');
    });
  });

  group('HabitRepository - Entry Toggling and Queries', () {
    test('toggles check-in state on and off', () async {
      final habit = Habit(
        id: 'h1',
        name: 'Daily Meditation',
        colorValue: 0xFF10B981,
        createdAt: DateTime(2026, 8, 1),
      );
      await repository.saveHabit(habit);

      // Toggle ON
      final added = await repository.toggleEntry(
        habitId: 'h1',
        dateKey: '2026-08-17',
      );
      expect(added, isTrue);

      var keys = await repository.getEntryDateKeysForHabit('h1');
      expect(keys.contains('2026-08-17'), isTrue);

      // Toggle OFF
      final removed = await repository.toggleEntry(
        habitId: 'h1',
        dateKey: '2026-08-17',
      );
      expect(removed, isFalse);

      keys = await repository.getEntryDateKeysForHabit('h1');
      expect(keys.contains('2026-08-17'), isFalse);
    });

    test('calculates streaks via repository', () async {
      final habit = Habit(
        id: 'h1',
        name: 'Streak Habit',
        colorValue: 0xFF10B981,
        createdAt: DateTime(2026, 8, 1),
      );
      await repository.saveHabit(habit);

      await repository.toggleEntry(habitId: 'h1', dateKey: '2026-08-15');
      await repository.toggleEntry(habitId: 'h1', dateKey: '2026-08-16');
      await repository.toggleEntry(habitId: 'h1', dateKey: '2026-08-17');

      final currentStreak = await repository.getCurrentStreak(
        'h1',
        today: DateTime(2026, 8, 17),
      );
      expect(currentStreak, 3);

      final bestStreak = await repository.getBestStreak('h1');
      expect(bestStreak, 3);
    });
  });

  group('HabitRepository - Backup Export & Import', () {
    test('exports and restores complete JSON backup', () async {
      final habit = Habit(
        id: 'h1',
        name: 'Backup Habit',
        colorValue: 0xFF10B981,
        createdAt: DateTime(2026, 8, 1),
      );
      await repository.saveHabit(habit);
      await repository.toggleEntry(habitId: 'h1', dateKey: '2026-08-10');
      await repository.toggleEntry(habitId: 'h1', dateKey: '2026-08-11');

      final backupData = await repository.exportBackup();
      expect(backupData['app'], 'Streakbox');
      expect((backupData['habits'] as List).length, 1);
      expect((backupData['entries'] as List).length, 2);

      // Create a second clean repository and import the backup
      final db2 = AppDatabase.inMemory();
      final repository2 = HabitRepository(database: db2);

      final importResult = await repository2.importBackup(backupData);
      expect(importResult.habitsImported, 1);
      expect(importResult.entriesImported, 2);

      final restoredHabits = await repository2.getActiveHabits();
      expect(restoredHabits.length, 1);
      expect(restoredHabits.first.name, 'Backup Habit');

      final restoredKeys = await repository2.getEntryDateKeysForHabit('h1');
      expect(restoredKeys, containsAll(['2026-08-10', '2026-08-11']));

      await db2.close();
    });
  });
}
