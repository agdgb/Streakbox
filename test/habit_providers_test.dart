import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:streakbox/core/utils/date_utils.dart';
import 'package:streakbox/data/db/app_database.dart';
import 'package:streakbox/data/models/habit.dart';
import 'package:streakbox/data/repositories/habit_repository.dart';
import 'package:streakbox/state/calendar_providers.dart';
import 'package:streakbox/state/habit_providers.dart';
import 'package:streakbox/state/repository_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;
  late HabitRepository repository;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.inMemory();
    repository = HabitRepository(database: db);
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Calendar Providers', () {
    test('habitCalendarDatesProvider advances, rewinds, and sets month per habit', () {
      final notifier = container.read(habitCalendarDatesProvider.notifier);

      notifier.setDateForHabit('h1', DateTime(2026, 8, 1));
      expect(notifier.getDateForHabit('h1'), DateTime(2026, 8, 1));

      notifier.nextMonth('h1');
      expect(notifier.getDateForHabit('h1'), DateTime(2026, 9, 1));

      notifier.prevMonth('h1');
      expect(notifier.getDateForHabit('h1'), DateTime(2026, 8, 1));
    });
  });

  group('Habit Providers - CRUD & Selection', () {
    test('adds, updates, deletes, and selects habits', () async {
      final habit1 = Habit(
        id: 'h1',
        name: 'Morning Routine',
        colorValue: 0xFF10B981,
        createdAt: DateTime.now(),
      );

      final habit2 = Habit(
        id: 'h2',
        name: 'Read 20 Mins',
        colorValue: 0xFF8B5CF6,
        createdAt: DateTime.now(),
      );

      final habitsNotifier = container.read(habitsProvider.notifier);

      // Add habit1
      await habitsNotifier.addHabit(habit1);
      var habits = await container.read(habitsProvider.future);
      expect(habits.length, 1);
      expect(container.read(selectedHabitProvider)?.name, 'Morning Routine');

      // Add habit2
      await habitsNotifier.addHabit(habit2);
      habits = await container.read(habitsProvider.future);
      expect(habits.length, 2);

      // Switch selection to habit1
      container.read(selectedHabitIdProvider.notifier).select('h1');
      expect(container.read(selectedHabitProvider)?.id, 'h1');

      // Delete habit1
      await habitsNotifier.deleteHabit('h1');
      habits = await container.read(habitsProvider.future);
      expect(habits.length, 1);
      expect(habits.first.id, 'h2');
      expect(container.read(selectedHabitProvider)?.id, 'h2');
    });
  });

  group('Habit Providers - Entries & Computed Streaks', () {
    test('toggles check-ins and updates streaks and completion rate reactively', () async {
      final habit = Habit(
        id: 'h1',
        name: 'Daily Meditation',
        colorValue: 0xFF10B981,
        createdAt: DateTime(2026, 8, 1),
      );

      final habitsNotifier = container.read(habitsProvider.notifier);
      await habitsNotifier.addHabit(habit);

      // Set viewing calendar to August 2026 for habit
      container
          .read(habitCalendarDatesProvider.notifier)
          .setDateForHabit('h1', DateTime(2026, 8, 1));

      final entriesNotifier = container.read(selectedHabitEntriesProvider.notifier);

      // Initially no check-ins
      var entries = await container.read(selectedHabitEntriesProvider.future);
      expect(entries.isEmpty, isTrue);

      final todayKey = AppDateUtils.formatDateKey(DateTime.now());
      final yesterdayKey = AppDateUtils.formatDateKey(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      // Toggle check-in today and yesterday
      await entriesNotifier.toggleEntry(yesterdayKey);
      await entriesNotifier.toggleEntry(todayKey);

      entries = await container.read(selectedHabitEntriesProvider.future);
      expect(entries.contains(todayKey), isTrue);
      expect(entries.contains(yesterdayKey), isTrue);

      // Verify computed streak provider
      expect(container.read(currentStreakProvider), 2);
      expect(container.read(bestStreakProvider), 2);

      // Untoggle today
      await entriesNotifier.toggleEntry(todayKey);
      entries = await container.read(selectedHabitEntriesProvider.future);
      expect(entries.contains(todayKey), isFalse);

      // Still streak of 1 since yesterday was checked in
      expect(container.read(currentStreakProvider), 1);
    });
  });
}
