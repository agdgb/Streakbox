import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/habit_entry.dart';

/// Weekly Rhythm Card analyzing completion consistency across Monday through Sunday.
class WeeklyRhythmCard extends StatelessWidget {
  final List<HabitEntry> allEntries;

  const WeeklyRhythmCard({
    super.key,
    required this.allEntries,
  });

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _shortDayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  Map<int, int> _computeWeekdayDistribution() {
    final counts = <int, int>{
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
      7: 0,
    };

    for (final entry in allEntries) {
      try {
        final parsed = DateTime.parse(entry.date);
        counts[parsed.weekday] = (counts[parsed.weekday] ?? 0) + 1;
      } catch (_) {}
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counts = _computeWeekdayDistribution();

    // Find max count for relative bar scaling
    int maxCount = 0;
    int peakDayIndex = 1;
    int minCount = 999999;
    int recoveryDayIndex = 7;

    for (int i = 1; i <= 7; i++) {
      final c = counts[i] ?? 0;
      if (c > maxCount) {
        maxCount = c;
        peakDayIndex = i;
      }
      if (c < minCount) {
        minCount = c;
        recoveryDayIndex = i;
      }
    }

    if (maxCount == 0) maxCount = 1;

    final peakDayName = _dayNames[peakDayIndex - 1];
    final recoveryDayName = _dayNames[recoveryDayIndex - 1];

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
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Rhythm & Consistency',
                      style: AppTextStyles.titleLarge(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Habit check-in distribution across each day of the week:',
              style: AppTextStyles.bodySmall(context),
            ),
            const SizedBox(height: AppSpacing.md),

            // 7 Weekday Horizontal Bars
            ...List.generate(7, (index) {
              final weekday = index + 1;
              final count = counts[weekday] ?? 0;
              final fraction = count / maxCount;
              final isPeak = weekday == peakDayIndex && count > 0;
              final isWeekend = weekday >= 6;

              final barColor = isPeak
                  ? AppColors.primary
                  : (isWeekend
                      ? AppColors.secondary
                      : (isDark
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : AppColors.primary.withValues(alpha: 0.6)));

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text(
                        _shortDayNames[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isPeak ? FontWeight.w800 : FontWeight.w600,
                          color: isPeak
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(
                              height: 16,
                              color: isDark
                                  ? AppColors.darkCardElevated
                                  : AppColors.lightCardElevated,
                            ),
                            FractionallySizedBox(
                              widthFactor: fraction.clamp(0.02, 1.0),
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '$count checks',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isPeak ? FontWeight.w800 : FontWeight.w500,
                          color: isPeak
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Peak Day & Recovery Day Badges
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Peak Day',
                                style: AppTextStyles.bodySmall(context).copyWith(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                peakDayName,
                                style: AppTextStyles.labelBold(context).copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.nightlight_round,
                          color: AppColors.secondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rest / Recovery Day',
                                style: AppTextStyles.bodySmall(context).copyWith(
                                  fontSize: 10,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                recoveryDayName,
                                style: AppTextStyles.labelBold(context).copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
