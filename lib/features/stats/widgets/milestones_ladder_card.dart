import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class HabitMilestone {
  final int days;
  final String title;
  final String description;
  final String iconEmoji;
  final Color color;

  const HabitMilestone({
    required this.days,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.color,
  });
}

/// Habit Formation Milestones Ladder based on behavioral psychology (66-day rule).
class MilestonesLadderCard extends StatelessWidget {
  final int highestStreak;

  const MilestonesLadderCard({
    super.key,
    required this.highestStreak,
  });

  static const List<HabitMilestone> milestones = [
    HabitMilestone(
      days: 7,
      title: '7-Day Spark',
      description: 'Initial momentum ignited',
      iconEmoji: '⚡',
      color: Color(0xFFFBBF24), // Amber
    ),
    HabitMilestone(
      days: 21,
      title: '21-Day Habit Loop',
      description: 'Neurological loop built',
      iconEmoji: '🔥',
      color: Color(0xFFF97316), // Orange
    ),
    HabitMilestone(
      days: 66,
      title: '66-Day Anchor (Science-Backed)',
      description: 'Full automaticity reached',
      iconEmoji: '⚓',
      color: Color(0xFF10B981), // Emerald
    ),
    HabitMilestone(
      days: 100,
      title: '100-Day Centurion',
      description: 'Unshakable discipline',
      iconEmoji: '💯',
      color: Color(0xFF8B5CF6), // Purple
    ),
    HabitMilestone(
      days: 365,
      title: '365-Day Master',
      description: 'One full year of mastery',
      iconEmoji: '👑',
      color: Color(0xFFEC4899), // Pink
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find next upcoming milestone
    HabitMilestone? nextMilestone;
    for (final m in milestones) {
      if (highestStreak < m.days) {
        nextMilestone = m;
        break;
      }
    }

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
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Habit Formation Milestones',
                      style: AppTextStyles.titleLarge(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.roundedFull,
                  ),
                  child: Text(
                    'Best: $highestStreak Days',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Research shows habits reach neurological automaticity at 66 days:',
              style: AppTextStyles.bodySmall(context),
            ),
            const SizedBox(height: AppSpacing.md),

            // Milestones Ladder
            ...milestones.map((milestone) {
              final isUnlocked = highestStreak >= milestone.days;
              final isTarget = nextMilestone == milestone;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? milestone.color.withValues(alpha: isDark ? 0.15 : 0.10)
                        : (isTarget
                            ? AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05)
                            : (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated)),
                    borderRadius: AppSpacing.roundedSm,
                    border: Border.all(
                      color: isUnlocked
                          ? milestone.color.withValues(alpha: 0.4)
                          : (isTarget
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                      width: isUnlocked || isTarget ? 1.5 : 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        milestone.iconEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${milestone.title} (${milestone.days}d)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelBold(context).copyWith(
                                fontSize: 13,
                                color: isUnlocked
                                    ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              milestone.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall(context).copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: milestone.color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        )
                      else if (isTarget)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${milestone.days - highestStreak}d left',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            SizedBox(
                              width: 50,
                              height: 4,
                              child: LinearProgressIndicator(
                                value: (highestStreak / milestone.days).clamp(0.0, 1.0),
                                backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        )
                      else
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                              .withValues(alpha: 0.5),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
