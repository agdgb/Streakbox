import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/date_utils.dart';
import '../data/models/habit.dart';
import '../data/models/habit_entry.dart';
import 'calendar_providers.dart';
import 'repository_provider.dart';

// -----------------------------------------------------------------------------
// 1. Habits List State
// -----------------------------------------------------------------------------

/// Notifier managing active habits list with full CRUD & reordering.
class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() async {
    final repository = ref.watch(habitRepositoryProvider);
    return await repository.getActiveHabits();
  }

  /// Adds a new habit and refreshes active habits list.
  Future<void> addHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
    await future;
    // Select newly added habit
    ref.read(selectedHabitIdProvider.notifier).select(habit.id);
  }

  /// Updates an existing habit.
  Future<void> updateHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
    await future;
  }

  /// Soft-archives or un-archives a habit.
  Future<void> archiveHabit(String habitId, bool isArchived) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.archiveHabit(habitId, isArchived);
    ref.invalidateSelf();
    await future;
  }

  /// Deletes a habit and all associated logs permanently.
  Future<void> deleteHabit(String habitId) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(habitId);
    ref.invalidateSelf();
    await future;
  }

  /// Reorders habits by ID list.
  Future<void> reorderHabits(List<String> habitIdsInOrder) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.reorderHabits(habitIdsInOrder);
    ref.invalidateSelf();
    await future;
  }
}

/// Provider for the list of active habits.
final habitsProvider =
    AsyncNotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

// -----------------------------------------------------------------------------
// 2. Selected Habit State
// -----------------------------------------------------------------------------

class SelectedHabitIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String habitId) {
    state = habitId;
  }

  void clear() {
    state = null;
  }
}

/// Provider holding the explicitly selected habit ID (null means default to first habit).
final selectedHabitIdProvider =
    NotifierProvider<SelectedHabitIdNotifier, String?>(
  SelectedHabitIdNotifier.new,
);

/// Computed provider resolving the currently selected [Habit] object.
/// If no explicit selection is made, defaults to the first active habit.
final selectedHabitProvider = Provider<Habit?>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  final habits = habitsAsync.asData?.value ?? [];
  if (habits.isEmpty) return null;

  final explicitId = ref.watch(selectedHabitIdProvider);
  if (explicitId != null) {
    final match = habits.where((h) => h.id == explicitId);
    if (match.isNotEmpty) return match.first;
  }

  return habits.first;
});

// -----------------------------------------------------------------------------
// 3. Selected Habit Entries (Check-ins) & Toggle State
// -----------------------------------------------------------------------------

/// Notifier managing check-in date keys ('yyyy-MM-dd') for the currently selected habit.
class SelectedHabitEntriesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final selectedHabit = ref.watch(selectedHabitProvider);
    if (selectedHabit == null) return {};

    final repository = ref.watch(habitRepositoryProvider);
    return await repository.getEntryDateKeysForHabit(selectedHabit.id);
  }

  /// Optimistically toggles a check-in date for the active habit.
  Future<bool> toggleEntry(String dateKey, {String notes = ''}) async {
    final selectedHabit = ref.read(selectedHabitProvider);
    if (selectedHabit == null) return false;

    final habitId = selectedHabit.id;
    final repository = ref.read(habitRepositoryProvider);
    final previousState = state.asData?.value ?? {};
    final isCurrentlyChecked = previousState.contains(dateKey);

    // Optimistic UI update
    final newSet = Set<String>.from(previousState);
    if (isCurrentlyChecked) {
      newSet.remove(dateKey);
    } else {
      newSet.add(dateKey);
    }
    state = AsyncData(newSet);

    try {
      final isChecked = await repository.toggleEntry(
        habitId: habitId,
        dateKey: dateKey,
        notes: notes,
      );
      ref.invalidate(selectedHabitEntryMapProvider);
      return isChecked;
    } catch (e, st) {
      // Revert on failure
      state = AsyncData(previousState);
      state = AsyncError(e, st);
      return isCurrentlyChecked;
    }
  }

  /// Sets custom entry details (notes, emoji) or clears check-in.
  Future<void> setEntryDetails({
    required String dateKey,
    required bool isChecked,
    String notes = '',
  }) async {
    final selectedHabit = ref.read(selectedHabitProvider);
    if (selectedHabit == null) return;

    final habitId = selectedHabit.id;
    final repository = ref.read(habitRepositoryProvider);

    if (isChecked) {
      final entry = HabitEntry(
        id: '${habitId}_$dateKey',
        habitId: habitId,
        date: dateKey,
        completedAt: DateTime.now(),
        notes: notes,
      );
      await repository.saveEntry(entry);
    } else {
      await repository.deleteEntry(habitId, dateKey);
    }

    ref.invalidateSelf();
    ref.invalidate(selectedHabitEntryMapProvider);
  }
}

/// Provider for all check-in date keys of the currently active habit.
final selectedHabitEntriesProvider =
    AsyncNotifierProvider<SelectedHabitEntriesNotifier, Set<String>>(
  SelectedHabitEntriesNotifier.new,
);

/// Provider resolving a map of dateKey -> HabitEntry with notes/emojis for the selected habit.
final selectedHabitEntryMapProvider =
    FutureProvider<Map<String, HabitEntry>>((ref) async {
  final selectedHabit = ref.watch(selectedHabitProvider);
  if (selectedHabit == null) return {};

  final repository = ref.watch(habitRepositoryProvider);
  final entries = await repository.getEntriesForHabit(selectedHabit.id);
  return {for (final e in entries) e.date: e};
});

// -----------------------------------------------------------------------------
// 4. Computed Statistics Providers (Streaks & Completion)
// -----------------------------------------------------------------------------

/// Current active streak for the selected habit.
final currentStreakProvider = Provider<int>((ref) {
  final entriesAsync = ref.watch(selectedHabitEntriesProvider);
  final entries = entriesAsync.asData?.value ?? {};
  return AppDateUtils.calculateCurrentStreak(entries);
});

/// Best lifetime streak for the selected habit.
final bestStreakProvider = Provider<int>((ref) {
  final entriesAsync = ref.watch(selectedHabitEntriesProvider);
  final entries = entriesAsync.asData?.value ?? {};
  return AppDateUtils.calculateBestStreak(entries);
});

/// Monthly completion rate (%) for the selected habit in the currently viewed month.
final monthlyCompletionRateProvider = Provider<double>((ref) {
  final entriesAsync = ref.watch(selectedHabitEntriesProvider);
  final entries = entriesAsync.asData?.value ?? {};
  final activeDate = ref.watch(calendarDateProvider);

  final firstDayOfMonth = DateTime(activeDate.year, activeDate.month, 1);
  final lastDayOfMonth = DateTime(activeDate.year, activeDate.month + 1, 0);

  return AppDateUtils.calculateCompletionRate(
    entries,
    firstDayOfMonth,
    lastDayOfMonth,
  );
});

/// Dual-Metric 30-Day Consistency Score & Recovery Protocol status for active habit.
final consistencyMetricsProvider = Provider<ConsistencyMetrics>((ref) {
  final entriesAsync = ref.watch(selectedHabitEntriesProvider);
  final entries = entriesAsync.asData?.value ?? {};
  final selectedHabit = ref.watch(selectedHabitProvider);

  return AppDateUtils.calculateConsistencyMetrics(
    entries,
    habitCreatedAt: selectedHabit?.createdAt,
    windowDays: 30,
  );
});
