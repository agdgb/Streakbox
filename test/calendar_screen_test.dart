import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streakbox/core/utils/date_utils.dart';
import 'package:streakbox/data/models/habit.dart';
import 'package:streakbox/data/repositories/in_memory_habit_repository.dart';
import 'package:streakbox/features/calendar/calendar_screen.dart';
import 'package:streakbox/state/calendar_providers.dart';
import 'package:streakbox/state/repository_provider.dart';
import 'package:streakbox/state/auth_provider.dart';
import 'package:streakbox/data/repositories/fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late InMemoryHabitRepository repository;

  setUp(() {
    repository = InMemoryHabitRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
      child: const MaterialApp(
        home: CalendarScreen(),
      ),
    );
  }

  testWidgets('displays empty state when no habits exist', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Start Your First Habit'), findsOneWidget);
    expect(find.text('Create Custom Habit'), findsOneWidget);
  });

  testWidgets('displays calendar matrix and toggles check-in on cell tap', (tester) async {
    final habit = Habit(
      id: 'h1',
      name: 'Morning Workout',
      colorValue: 0xFF10B981,
      createdAt: DateTime(2026, 8, 1),
    );
    await repository.saveHabit(habit);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify habit tab & streak cards are displayed
    expect(find.text('Morning Workout'), findsOneWidget);
    expect(find.text('Streak'), findsWidgets);
    expect(find.text('0 d'), findsWidgets);

    // Find today's day cell
    final todayKey = AppDateUtils.formatDateKey(DateTime.now());
    final dayCellFinder = find.byKey(ValueKey('h1_$todayKey'));
    expect(dayCellFinder, findsOneWidget);

    // Tap today's cell to check in
    await tester.tap(dayCellFinder);
    await tester.pumpAndSettle();

    // Verify streak increased to 1 d
    expect(find.text('1 d'), findsWidgets);

    // Tap again to uncheck
    await tester.tap(dayCellFinder);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: dayCellFinder, matching: find.byIcon(Icons.check_rounded)),
      findsNothing,
    );
  });

  testWidgets('navigates to next and previous months', (tester) async {
    final habit = Habit(
      id: 'h1',
      name: 'Read Book',
      colorValue: 0xFF8B5CF6,
      createdAt: DateTime(2026, 8, 1),
    );
    await repository.saveHabit(habit);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            Future.microtask(() {
              ref
                  .read(habitCalendarDatesProvider.notifier)
                  .setDateForHabit('h1', DateTime(2026, 8, 1));
            });
            return const MaterialApp(home: CalendarScreen());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);

    // Tap next month
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);

    // Tap previous month
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);
  });
}
