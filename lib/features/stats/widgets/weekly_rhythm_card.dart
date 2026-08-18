import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/habit_entry.dart';
import '../../../data/services/rhythm_analytics_engine.dart';

/// Smart Habit Rhythm & Vulnerability Shield Card (Red-Team Attack #8).
class WeeklyRhythmCard extends StatelessWidget {
  final List<HabitEntry> allEntries;

  const WeeklyRhythmCard({
    super.key,
    required this.allEntries,
  });

  static const List<String> _shortDayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final report = RhythmAnalyticsEngine.analyze(allEntries);

    // Max count for relative bar scaling
    int maxCount = 0;
    for (int i = 1; i <= 7; i++) {
      final c = report.weekdayCounts[i] ?? 0;
      if (c > maxCount) maxCount = c;
    }
    if (maxCount == 0) maxCount = 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Habit Rhythm & Vulnerability',
                      style: AppTextStyles.titleMedium(context).copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (report.monthlyVelocityRate != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: report.monthlyVelocityRate >= 0
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFFF4B72).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${report.monthlyVelocityRate >= 0 ? "+" : ""}${report.monthlyVelocityRate.toStringAsFixed(1)}% velocity',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: report.monthlyVelocityRate >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFF4B72),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Strongest vs Weakest Day Matrix
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'PEAK DAY',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.strongestDayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4B72).withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF4B72).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFF4B72)),
                            SizedBox(width: 4),
                            Text(
                              'RISK DAY',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Color(0xFFFF4B72),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.weakestDayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday Frequency Bar Chart
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final weekday = index + 1;
                  final count = report.weekdayCounts[weekday] ?? 0;
                  final fraction = (count / maxCount).clamp(0.08, 1.0);
                  final isPeak = report.strongestDayName == RhythmAnalyticsEngine.dayNames[index];
                  final isRisk = report.weakestDayName == RhythmAnalyticsEngine.dayNames[index] &&
                      allEntries.length >= 7;

                  final barColor = isPeak
                      ? const Color(0xFF10B981)
                      : (isRisk ? const Color(0xFFFF4B72) : const Color(0xFF3B82F6));

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 60 * fraction,
                            decoration: BoxDecoration(
                              color: barColor.withValues(alpha: isDark ? 0.8 : 0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _shortDayNames[index],
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isPeak || isRisk ? FontWeight.w800 : FontWeight.w600,
                              color: isPeak
                                  ? const Color(0xFF10B981)
                                  : (isRisk ? const Color(0xFFFF4B72) : (isDark ? Colors.white70 : Colors.black87)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Vulnerability Warning Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.vulnerabilityWarning,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.actionableCoachingTip,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
