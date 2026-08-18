import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streakbox/core/theme/app_colors.dart';
import 'package:streakbox/core/theme/app_theme.dart';
import 'package:streakbox/data/models/habit.dart';
import 'package:streakbox/data/repositories/in_memory_habit_repository.dart';
import 'package:streakbox/features/habits/habit_form_sheet.dart';
import 'package:streakbox/features/habits/widgets/confirm_delete_dialog.dart';
import 'package:streakbox/state/repository_provider.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestableApp({required InMemoryHabitRepository repository, Habit? initialHabit}) {
    return ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  HabitFormSheet.show(context, habit: initialHabit);
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('HabitFormSheet creates a new habit when filled and saved', (tester) async {
    final repo = InMemoryHabitRepository();

    await tester.pumpWidget(buildTestableApp(repository: repo));
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify sheet title
    expect(find.text('New Habit'), findsOneWidget);
    expect(find.text('Create Habit'), findsOneWidget);

    // Enter name
    await tester.enterText(find.byType(TextFormField).first, 'Morning Jog');
    await tester.pump();

    // Save
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();

    // Verify habit was persisted
    final habits = await repo.getActiveHabits();
    expect(habits.length, 1);
    expect(habits.first.name, 'Morning Jog');
  });

  testWidgets('HabitFormSheet validates empty habit name', (tester) async {
    final repo = InMemoryHabitRepository();

    await tester.pumpWidget(buildTestableApp(repository: repo));
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Tap save with empty text
    await tester.tap(find.text('Create Habit'));
    await tester.pumpAndSettle();

    // Verify validation error
    expect(find.text('Please enter a habit name'), findsOneWidget);
    final habits = await repo.getActiveHabits();
    expect(habits.isEmpty, true);
  });

  testWidgets('HabitFormSheet edits an existing habit', (tester) async {
    final repo = InMemoryHabitRepository();
    final existing = Habit(
      id: 'h1',
      name: 'Reading',
      colorValue: AppColors.habitColors.first.color.toARGB32(),
      createdAt: DateTime.now(),
    );
    await repo.saveHabit(existing);

    await tester.pumpWidget(buildTestableApp(repository: repo, initialHabit: existing));
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Habit'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Change name
    await tester.enterText(find.byType(TextFormField).first, 'Deep Reading');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    final habits = await repo.getActiveHabits();
    expect(habits.first.name, 'Deep Reading');
  });

  testWidgets('ConfirmDeleteDialog cancels deletion or confirms', (tester) async {
    bool? confirmed;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                confirmed = await ConfirmDeleteDialog.show(context, habitName: 'Running');
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Habit?'), findsOneWidget);
    expect(find.textContaining('Running'), findsOneWidget);

    // Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(confirmed, false);

    // Confirm
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Permanently'));
    await tester.pumpAndSettle();
    expect(confirmed, true);
  });
}
