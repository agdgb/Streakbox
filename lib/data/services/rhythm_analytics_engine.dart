import '../models/habit_entry.dart';

/// Structured analysis of user habit rhythm, peak days, and failure vulnerabilities (Red-Team Attack #8).
class RhythmInsightReport {
  final Map<int, int> weekdayCounts; // 1 = Mon ... 7 = Sun
  final Map<int, double> weekdayPercentages;
  final int totalCheckIns;
  final String strongestDayName;
  final double strongestDayPercentage;
  final String weakestDayName;
  final double weakestDayPercentage;
  final double monthlyVelocityRate; // % change vs previous 30 days
  final String vulnerabilityWarning;
  final String actionableCoachingTip;

  const RhythmInsightReport({
    required this.weekdayCounts,
    required this.weekdayPercentages,
    required this.totalCheckIns,
    required this.strongestDayName,
    required this.strongestDayPercentage,
    required this.weakestDayName,
    required this.weakestDayPercentage,
    required this.monthlyVelocityRate,
    required this.vulnerabilityWarning,
    required this.actionableCoachingTip,
  });
}

class RhythmAnalyticsEngine {
  RhythmAnalyticsEngine._();

  static const List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static RhythmInsightReport analyze(List<HabitEntry> entries, {DateTime? now}) {
    final referenceNow = now ?? DateTime.now();
    final counts = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
    int total = 0;

    // Filter recent 90-day window
    final ninetyDaysAgo = referenceNow.subtract(const Duration(days: 90));
    final thirtyDaysAgo = referenceNow.subtract(const Duration(days: 30));
    final sixtyDaysAgo = referenceNow.subtract(const Duration(days: 60));

    int currentMonthEntries = 0;
    int previousMonthEntries = 0;

    for (final e in entries) {
      try {
        final parsed = DateTime.parse(e.date);
        if (parsed.isAfter(ninetyDaysAgo)) {
          counts[parsed.weekday] = (counts[parsed.weekday] ?? 0) + 1;
          total++;
        }
        if (parsed.isAfter(thirtyDaysAgo)) {
          currentMonthEntries++;
        } else if (parsed.isAfter(sixtyDaysAgo)) {
          previousMonthEntries++;
        }
      } catch (_) {}
    }

    int maxCount = 0;
    int minCount = 999999;
    int bestDay = 1;
    int worstDay = 7;

    for (int i = 1; i <= 7; i++) {
      final c = counts[i] ?? 0;
      if (c > maxCount) {
        maxCount = c;
        bestDay = i;
      }
      if (c < minCount) {
        minCount = c;
        worstDay = i;
      }
    }

    final Map<int, double> percentages = {};
    for (int i = 1; i <= 7; i++) {
      percentages[i] = total > 0 ? ((counts[i] ?? 0) / (total / 7.0)) * 100.0 : 100.0;
    }

    double velocity = 0.0;
    if (previousMonthEntries > 0) {
      velocity = ((currentMonthEntries - previousMonthEntries) / previousMonthEntries) * 100.0;
    } else if (currentMonthEntries > 0) {
      velocity = 100.0;
    }

    final strongDayName = dayNames[bestDay - 1];
    final weakDayName = dayNames[worstDay - 1];

    final warning = minCount == 0 && total >= 7
        ? '⚠️ High Vulnerability: $weakDayName has 0 logged check-ins. Watch out for weekend drift.'
        : '⚠️ Watch out for $weakDayName: Your completion dips on $weakDayName. Prepare your environment in advance.';

    final tip =
        '💡 Pro Tip: Anchor your $weakDayName habit directly to an existing morning routine to eliminate friction.';

    return RhythmInsightReport(
      weekdayCounts: counts,
      weekdayPercentages: percentages,
      totalCheckIns: total,
      strongestDayName: strongDayName,
      strongestDayPercentage: total > 0 ? ((maxCount / (total / 7.0)) * 100.0).clamp(0, 150) : 100.0,
      weakestDayName: weakDayName,
      weakestDayPercentage: total > 0 ? ((minCount / (total / 7.0)) * 100.0).clamp(0, 100) : 50.0,
      monthlyVelocityRate: velocity,
      vulnerabilityWarning: warning,
      actionableCoachingTip: tip,
    );
  }
}
