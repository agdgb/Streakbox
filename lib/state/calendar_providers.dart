import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/date_utils.dart';
import 'habit_providers.dart';
import 'settings_provider.dart';

/// Base index constant for PageView month calculations (represents current month)
const int kMonthPageBaseIndex = 2400;

/// Maps a month DateTime to a PageView index relative to base reference.
int monthToPageIndex(DateTime date, DateTime baseMonth) {
  final yearDiff = date.year - baseMonth.year;
  final monthDiff = date.month - baseMonth.month;
  return kMonthPageBaseIndex + (yearDiff * 12 + monthDiff);
}

/// Maps a PageView index back to a month DateTime.
DateTime pageIndexToMonth(int index, DateTime baseMonth) {
  final monthOffset = index - kMonthPageBaseIndex;
  return DateTime(baseMonth.year, baseMonth.month + monthOffset, 1);
}

/// Manages a Map of habitId -> DateTime viewed month,
/// ensuring each habit retains its own calendar view date independently.
class HabitCalendarDatesNotifier extends Notifier<Map<String, DateTime>> {
  static final DateTime referenceMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Map<String, DateTime> build() {
    return {};
  }

  /// Returns the stored viewing month for a habit, or the current real-world month if not visited.
  DateTime getDateForHabit(String? habitId) {
    if (habitId == null) return referenceMonth;
    return state[habitId] ?? referenceMonth;
  }

  /// Sets the viewed month for a specific habit.
  void setDateForHabit(String habitId, DateTime date) {
    final cleanDate = DateTime(date.year, date.month, 1);
    if (state[habitId] != cleanDate) {
      state = {...state, habitId: cleanDate};
    }
  }

  /// Advances viewing date for active habit.
  void nextMonth(String? habitId) {
    final current = getDateForHabit(habitId);
    final next = DateTime(current.year, current.month + 1, 1);
    if (habitId != null) {
      setDateForHabit(habitId, next);
    }
  }

  /// Rewinds viewing date for active habit.
  void prevMonth(String? habitId) {
    final current = getDateForHabit(habitId);
    final prev = DateTime(current.year, current.month - 1, 1);
    if (habitId != null) {
      setDateForHabit(habitId, prev);
    }
  }

  /// Resets viewing date to today's real-world month for active habit.
  void jumpToToday(String? habitId) {
    if (habitId != null) {
      setDateForHabit(habitId, referenceMonth);
    }
  }
}

/// Provider managing per-habit calendar viewing dates.
final habitCalendarDatesProvider =
    NotifierProvider<HabitCalendarDatesNotifier, Map<String, DateTime>>(
  HabitCalendarDatesNotifier.new,
);

/// Active viewing date for the currently selected habit tab.
final calendarDateProvider = Provider<DateTime>((ref) {
  final selectedHabit = ref.watch(selectedHabitProvider);
  final habitDates = ref.watch(habitCalendarDatesProvider);
  final refMonth = HabitCalendarDatesNotifier.referenceMonth;

  if (selectedHabit == null) return refMonth;
  return habitDates[selectedHabit.id] ?? refMonth;
});

/// Computed provider returning the full list of grid day cells
/// for the currently active month and preferred first day of the week.
final monthGridCellsProvider = Provider<List<CalendarDayCell>>((ref) {
  final activeDate = ref.watch(calendarDateProvider);
  final firstDay = ref.watch(firstDayOfWeekProvider);
  return AppDateUtils.generateMonthGrid(
    activeDate.year,
    activeDate.month,
    firstDayOfWeek: firstDay,
  );
});
