import 'package:intl/intl.dart';

/// Representation of a single day cell in a calendar month grid.
class CalendarDayCell {
  final DateTime date;
  final String dateKey; // Format: 'yyyy-MM-dd'
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isToday;

  const CalendarDayCell({
    required this.date,
    required this.dateKey,
    required this.dayNumber,
    required this.isCurrentMonth,
    required this.isToday,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDayCell &&
          runtimeType == other.runtimeType &&
          dateKey == other.dateKey &&
          isCurrentMonth == other.isCurrentMonth;

  @override
  int get hashCode => Object.hash(dateKey, isCurrentMonth);
}

/// Core date utilities and streak computation algorithms.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  /// Converts a DateTime into a standardized 'yyyy-MM-dd' date key.
  static String formatDateKey(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formats date to 'MMMM yyyy' (e.g. "August 2026").
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Parses a 'yyyy-MM-dd' string into a DateTime (at 00:00:00).
  static DateTime parseDateKey(String key) {
    return _dateFormat.parseStrict(key);
  }

  /// Returns true if two DateTimes represent the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Truncates time components to 00:00:00.000.
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Generates a calendar month grid (typically 35 or 42 cells)
  /// based on the selected [firstDayOfWeek] (e.g. Monday, Sunday, Saturday).
  static List<CalendarDayCell> generateMonthGrid(
    int year,
    int month, {
    DateTime? today,
    int firstDayOfWeek = DateTime.monday,
  }) {
    final effectiveToday = startOfDay(today ?? DateTime.now());
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Offset based on firstDayOfWeek
    final leadingDaysCount = (firstDayOfMonth.weekday - firstDayOfWeek + 7) % 7;

    final List<CalendarDayCell> cells = [];

    // 1. Leading days from previous month
    if (leadingDaysCount > 0) {
      final prevMonthLastDay = DateTime(year, month, 0);
      final prevMonthDays = prevMonthLastDay.day;
      for (int i = leadingDaysCount - 1; i >= 0; i--) {
        final date = DateTime(prevMonthLastDay.year, prevMonthLastDay.month, prevMonthDays - i);
        cells.add(
          CalendarDayCell(
            date: date,
            dateKey: formatDateKey(date),
            dayNumber: date.day,
            isCurrentMonth: false,
            isToday: isSameDay(date, effectiveToday),
          ),
        );
      }
    }

    // 2. Days in current month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      cells.add(
        CalendarDayCell(
          date: date,
          dateKey: formatDateKey(date),
          dayNumber: day,
          isCurrentMonth: true,
          isToday: isSameDay(date, effectiveToday),
        ),
      );
    }

    // 3. Trailing days from next month to complete the row (multiples of 7)
    final remainder = cells.length % 7;
    if (remainder != 0) {
      final trailingDaysCount = 7 - remainder;
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextMonthYear = month == 12 ? year + 1 : year;
      for (int day = 1; day <= trailingDaysCount; day++) {
        final date = DateTime(nextMonthYear, nextMonth, day);
        cells.add(
          CalendarDayCell(
            date: date,
            dateKey: formatDateKey(date),
            dayNumber: day,
            isCurrentMonth: false,
            isToday: isSameDay(date, effectiveToday),
          ),
        );
      }
    }

    return cells;
  }

  /// Calculates the current active streak count.
  /// 
  /// Logic:
  /// - A streak is active if today OR yesterday is checked in.
  /// - If today is checked, counts back consecutively starting from today.
  /// - If today is NOT checked, but yesterday is checked, the streak is still alive and counts back from yesterday.
  /// - If neither today nor yesterday is checked, current streak is 0.
  static int calculateCurrentStreak(
    Set<String> entryDateKeys, {
    DateTime? today,
  }) {
    if (entryDateKeys.isEmpty) return 0;

    final referenceToday = startOfDay(today ?? DateTime.now());
    final todayKey = formatDateKey(referenceToday);
    final yesterday = DateTime(referenceToday.year, referenceToday.month, referenceToday.day - 1);
    final yesterdayKey = formatDateKey(yesterday);

    DateTime checkDate;
    if (entryDateKeys.contains(todayKey)) {
      checkDate = referenceToday;
    } else if (entryDateKeys.contains(yesterdayKey)) {
      checkDate = yesterday;
    } else {
      // Check if user has logged future dates (e.g. timezone difference or advance logging)
      final futureKeys = entryDateKeys.where((k) => k.compareTo(todayKey) > 0).toList()..sort();
      if (futureKeys.isNotEmpty) {
        checkDate = parseDateKey(futureKeys.last);
      } else {
        return 0;
      }
    }

    int streak = 0;
    while (entryDateKeys.contains(formatDateKey(checkDate))) {
      streak++;
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }

    return streak;
  }

  /// Calculates the best (longest) streak across all check-in dates in history.
  static int calculateBestStreak(Set<String> entryDateKeys) {
    if (entryDateKeys.isEmpty) return 0;

    // Parse and sort unique dates chronologically
    final List<DateTime> sortedDates = entryDateKeys
        .map((k) => startOfDay(parseDateKey(k)))
        .toList()
      ..sort();

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? previousDate;

    for (final date in sortedDates) {
      if (previousDate == null) {
        currentStreak = 1;
      } else {
        final dayDiff = date.difference(previousDate).inDays;
        if (dayDiff == 1) {
          currentStreak++;
        } else if (dayDiff > 1) {
          currentStreak = 1;
        }
      }
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
      previousDate = date;
    }

    return maxStreak;
  }

  /// Calculates the completion ratio (0.0 to 1.0) within a given date range.
  static double calculateCompletionRate(
    Set<String> entryDateKeys,
    DateTime startDate,
    DateTime endDate,
  ) {
    final start = startOfDay(startDate);
    final end = startOfDay(endDate);

    if (end.isBefore(start)) return 0.0;

    final totalDays = end.difference(start).inDays + 1;
    if (totalDays <= 0) return 0.0;

    int completedCount = 0;
    DateTime cursor = start;
    while (!cursor.isAfter(end)) {
      final key = formatDateKey(cursor);
      if (entryDateKeys.contains(key)) {
        completedCount++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return (completedCount / totalDays).clamp(0.0, 1.0);
  }
}
