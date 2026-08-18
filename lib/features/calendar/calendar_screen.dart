import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../data/models/habit.dart';
import '../../state/calendar_providers.dart';
import '../../state/habit_providers.dart';
import '../../state/theme_preset_provider.dart';
import '../habits/habit_form_sheet.dart';
import '../habits/habit_tabs.dart';
import '../social_share/social_share_sheet.dart';
import 'widgets/month_grid.dart';
import 'widgets/month_header.dart';

/// Main Calendar and Habit tracking screen.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  void _showAddHabitSheet(BuildContext context) {
    HabitFormSheet.show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);
    final currentStreak = ref.watch(currentStreakProvider);
    final bestStreak = ref.watch(bestStreakProvider);
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: AppSpacing.roundedSm,
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.check_box_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Text(
              'Streakbox',
              style: AppTextStyles.displayMedium(context).copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          if (selectedHabit != null)
            IconButton(
              onPressed: () {
                SocialShareSheet.show(context, habit: selectedHabit);
              },
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: 'Share Celebration Card',
            ),
          IconButton(
            onPressed: () {
              ref
                  .read(habitCalendarDatesProvider.notifier)
                  .jumpToToday(ref.read(selectedHabitProvider)?.id);
            },
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Jump to Today',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return SingleChildScrollView(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal Habit Switcher Tabs
                HabitTabsWidget(
                  onAddHabit: () => _showAddHabitSheet(context),
                ),
                const SizedBox(height: AppSpacing.md),

                // Calendar Container Card
                Container(
                  decoration: themePreset.neumorphicCard(radius: 20),
                  padding: AppSpacing.paddingMd,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonthHeaderWidget(),
                      SizedBox(height: AppSpacing.md),
                      MonthGridWidget(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Live Streaks Quick Metrics Card (Current & Best Streak)
                if (selectedHabit != null) ...[
                  Container(
                    decoration: themePreset.neumorphicCard(radius: 18),
                    padding: AppSpacing.paddingMd,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            context,
                            title: 'Current Streak',
                            value:
                                '$currentStreak ${currentStreak == 1 ? "Day" : "Days"}',
                            icon: Icons.local_fire_department_rounded,
                            accentColor: themePreset.primaryColor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: isDark
                              ? themePreset.borderColor
                              : AppColors.lightBorder,
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            context,
                            title: 'Best Streak',
                            value:
                                '$bestStreak ${bestStreak == 1 ? "Day" : "Days"}',
                            icon: Icons.emoji_events_rounded,
                            accentColor: themePreset.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dedicated Target Goal banner if habit frequency is not everyday
                  if (selectedHabit.frequencyType != HabitFrequencyType.daily) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selectedHabit.color
                            .withValues(alpha: isDark ? 0.12 : 0.08),
                        borderRadius: AppSpacing.roundedMd,
                        border: Border.all(
                          color: selectedHabit.color
                              .withValues(alpha: isDark ? 0.35 : 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.track_changes_rounded,
                            size: 18,
                            color: selectedHabit.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Target Goal: ',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              selectedHabit.frequencyLabel,
                              style: AppTextStyles.labelBold(context).copyWith(
                                color: selectedHabit.color,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading habits: $err',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(context)),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(habitsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.track_changes_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No habits tracked yet',
              style: AppTextStyles.titleLarge(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create your first habit to start logging your streaks.',
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final defaultHabit = Habit(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: 'Daily Tracker',
                      colorValue: AppColors.habitColors.first.color.toARGB32(),
                      createdAt: DateTime.now(),
                    );
                    await ref.read(habitsProvider.notifier).addHabit(defaultHabit);
                  },
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text('Quick Start (✅ / ❌)'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedLg,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => _showAddHabitSheet(context),
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Custom Habit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedLg,
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

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 4),
            Text(title, style: AppTextStyles.bodySmall(context)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleLarge(context).copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
