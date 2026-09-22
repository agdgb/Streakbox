import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/habit.dart';
import '../../state/calendar_providers.dart';
import '../../state/habit_providers.dart';
import '../../state/theme_preset_provider.dart';
import '../habits/habit_form_sheet.dart';
import '../habits/habit_tabs.dart';
import '../social_share/social_share_sheet.dart';
import 'widgets/behavioral_coaching_banner.dart';
import 'widgets/month_grid.dart';
import 'widgets/month_header.dart';
import 'widgets/recovery_protocol_card.dart';

/// Main Calendar and Habit tracking screen supporting responsive landscape and portrait layouts.
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
      backgroundColor: themePreset.backgroundColor,
      appBar: AppBar(
        backgroundColor: themePreset.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
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
                color: themePreset.textPrimaryColor,
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
            return _buildEmptyState(
              context,
              ref,
              themePreset: themePreset,
              isDark: isDark,
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > 580;

              if (isLandscape) {
                return _buildLandscapeLayout(
                  context,
                  ref,
                  selectedHabit: selectedHabit,
                  currentStreak: currentStreak,
                  bestStreak: bestStreak,
                  consistency: consistency,
                  themePreset: themePreset,
                  isDark: isDark,
                  maxWidth: constraints.maxWidth,
                );
              }

              return _buildPortraitLayout(
                context,
                ref,
                selectedHabit: selectedHabit,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                consistency: consistency,
                themePreset: themePreset,
                isDark: isDark,
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: themePreset.primaryColor),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading habits: $err',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context),
                ),
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

  Widget _buildPortraitLayout(
    BuildContext context,
    WidgetRef ref, {
    required Habit? selectedHabit,
    required int currentStreak,
    required int bestStreak,
    required ConsistencyMetrics consistency,
    required AppThemePreset themePreset,
    required bool isDark,
  }) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HabitTabsWidget(
            onAddHabit: () => _showAddHabitSheet(context),
          ),
          const SizedBox(height: AppSpacing.md),

          const RecoveryProtocolCard(),
          const BehavioralCoachingBanner(),

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
                    color: isDark
                        ? themePreset.borderColor
                        : AppColors.lightBorder,
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      context,
                      title: 'Consistency',
                      value: consistency.formattedPercentage,
                      subtitle:
                          '${consistency.completedDays}/${consistency.totalDays} planned',
                      icon: Icons.shield_rounded,
                      accentColor: const Color(0xFF10B981),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: isDark
                        ? themePreset.borderColor
                        : AppColors.lightBorder,
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

            if (selectedHabit.frequencyType != HabitFrequencyType.daily) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildTargetGoalBadge(
                context,
                selectedHabit: selectedHabit,
                isDark: isDark,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref, {
    required Habit? selectedHabit,
    required int currentStreak,
    required int bestStreak,
    required ConsistencyMetrics consistency,
    required AppThemePreset themePreset,
    required bool isDark,
    required double maxWidth,
  }) {
    final leftPaneWidth = maxWidth > 840 ? 340.0 : 300.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📱 Master Control Panel (Left Pane)
          SizedBox(
            width: leftPaneWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitTabsWidget(
                    onAddHabit: () => _showAddHabitSheet(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (selectedHabit != null) ...[
                    Container(
                      decoration: themePreset.neumorphicCard(radius: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
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
                            height: 38,
                            color: isDark
                                ? themePreset.borderColor
                                : AppColors.lightBorder,
                          ),
                          Expanded(
                            child: _buildMetricItem(
                              context,
                              title: 'Consistency',
                              value: consistency.formattedPercentage,
                              subtitle:
                                  '${consistency.completedDays}/${consistency.totalDays} planned',
                              icon: Icons.shield_rounded,
                              accentColor: const Color(0xFF10B981),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 38,
                            color: isDark
                                ? themePreset.borderColor
                                : AppColors.lightBorder,
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
                    if (selectedHabit.frequencyType !=
                        HabitFrequencyType.daily) ...[
                      const SizedBox(height: AppSpacing.xs + 2),
                      _buildTargetGoalBadge(
                        context,
                        selectedHabit: selectedHabit,
                        isDark: isDark,
                      ),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.xs + 2),
                  const RecoveryProtocolCard(),
                  const BehavioralCoachingBanner(),
                ],
              ),
            ),
          ),

          // 📅 Interactive Calendar Grid (Right Detail Pane)
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: themePreset.neumorphicCard(radius: 20),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MonthHeaderWidget(),
                    SizedBox(height: AppSpacing.sm),
                    MonthGridWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetGoalBadge(
    BuildContext context, {
    required Habit selectedHabit,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: selectedHabit.color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: selectedHabit.color.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.track_changes_rounded,
            size: 16,
            color: selectedHabit.color,
          ),
          const SizedBox(width: 8),
          Text(
            'Target: ',
            style: AppTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              selectedHabit.frequencyLabel,
              style: AppTextStyles.labelBold(context).copyWith(
                color: selectedHabit.color,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref, {
    required AppThemePreset themePreset,
    required bool isDark,
  }) {
    final starterHabits = [
      (
        title: '20-Min Workout',
        category: 'FITNESS',
        icon: Icons.fitness_center_rounded,
        codePoint: 0xe25a,
        color: const Color(0xFFFF4B72),
      ),
      (
        title: 'Read 10 Pages',
        category: 'MIND',
        icon: Icons.menu_book_rounded,
        codePoint: 0xe12b,
        color: const Color(0xFF00D2FF),
      ),
      (
        title: 'Drink 2L Water',
        category: 'HEALTH',
        icon: Icons.water_drop_rounded,
        codePoint: 0xe69f,
        color: const Color(0xFF3B82F6),
      ),
      (
        title: '10-Min Meditation',
        category: 'MINDFULNESS',
        icon: Icons.self_improvement_rounded,
        codePoint: 0xe5f8,
        color: const Color(0xFFA855F7),
      ),
      (
        title: 'Deep Work Block',
        category: 'FOCUS',
        icon: Icons.laptop_mac_rounded,
        codePoint: 0xe360,
        color: const Color(0xFFF59E0B),
      ),
      (
        title: 'Daily Gratitude',
        category: 'SELF-CARE',
        icon: Icons.edit_note_rounded,
        codePoint: 0xe226,
        color: const Color(0xFF10B981),
      ),
    ];

    Future<void> quickStartHabit(
      String title,
      int codePoint,
      Color color,
    ) async {
      final habitId = DateTime.now().millisecondsSinceEpoch.toString();
      final habit = Habit(
        id: habitId,
        name: title,
        colorValue: color.toARGB32(),
        iconCodePoint: codePoint,
        createdAt: DateTime.now(),
        frequencyType: HabitFrequencyType.daily,
      );

      await ref.read(habitsProvider.notifier).addHabit(habit);
      ref.read(selectedHabitIdProvider.notifier).select(habit.id);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 580;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start Your First Habit',
                style: AppTextStyles.displayLarge(context).copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: themePreset.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a starter routine to ignite your streak, or build a custom habit.',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: themePreset.textSecondaryColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (isLandscape)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: starterHabits.length,
                  itemBuilder: (context, index) {
                    final item = starterHabits[index];
                    return _buildStarterCard(
                      context,
                      themePreset: themePreset,
                      isDark: isDark,
                      title: item.title,
                      category: item.category,
                      icon: item.icon,
                      color: item.color,
                      onTap: () => quickStartHabit(
                        item.title,
                        item.codePoint,
                        item.color,
                      ),
                    );
                  },
                )
              else
                Column(
                  children: starterHabits.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildStarterCard(
                        context,
                        themePreset: themePreset,
                        isDark: isDark,
                        title: item.title,
                        category: item.category,
                        icon: item.icon,
                        color: item.color,
                        onTap: () => quickStartHabit(
                          item.title,
                          item.codePoint,
                          item.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showAddHabitSheet(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Custom Habit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: themePreset.textPrimaryColor,
                  side: BorderSide(
                    color: isDark
                        ? themePreset.borderColor
                        : AppColors.lightBorder,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStarterCard(
    BuildContext context, {
    required AppThemePreset themePreset,
    required bool isDark,
    required String title,
    required String category,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191D24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: themePreset.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
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
