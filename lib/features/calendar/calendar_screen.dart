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
import '../onboarding/onboarding_screen.dart';
import '../social_share/social_share_sheet.dart';
import 'widgets/behavioral_coaching_banner.dart';
import 'widgets/month_grid.dart';
import 'widgets/month_header.dart';
import 'widgets/recovery_protocol_card.dart';

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
    final consistency = ref.watch(consistencyMetricsProvider);
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

                // 🛡️ Recovery Protocol Banner (Active when yesterday was missed)
                const RecoveryProtocolCard(),

                // 🧠 Behavioral Coaching & Momentum Banner
                const BehavioralCoachingBanner(),

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

                // Live Anti-Fragility Metrics Card (Streak, Consistency Rating, Best Streak)
                if (selectedHabit != null) ...[
                  Container(
                    decoration: themePreset.neumorphicCard(radius: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            context,
                            title: 'Streak',
                            value: '$currentStreak d',
                            icon: Icons.local_fire_department_rounded,
                            accentColor: const Color(0xFFFF4B72),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: isDark ? themePreset.borderColor : AppColors.lightBorder,
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            context,
                            title: 'Consistency',
                            value: consistency.formattedPercentage,
                            subtitle: '${consistency.completedDays}/${consistency.totalDays} planned',
                            icon: Icons.shield_rounded,
                            accentColor: const Color(0xFF10B981),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 44,
                          color: isDark ? themePreset.borderColor : AppColors.lightBorder,
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            context,
                            title: 'Best',
                            value: '$bestStreak d',
                            icon: Icons.emoji_events_rounded,
                            accentColor: const Color(0xFFF59E0B),
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
    return OnboardingScreen(
      onFinish: () {
        ref.invalidate(habitsProvider);
      },
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
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
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption(context).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
