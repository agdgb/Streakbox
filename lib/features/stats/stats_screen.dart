import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_entry.dart';
import '../../data/repositories/habit_repository.dart';
import '../../state/calendar_providers.dart';
import '../../state/habit_providers.dart';
import '../../state/repository_provider.dart';
import '../social_share/social_share_card.dart';
import '../social_share/social_share_sheet.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/milestones_ladder_card.dart';
import 'widgets/weekly_rhythm_card.dart';

/// Comprehensive Analytics & Reports screen showing GitHub contribution heatmaps,
/// weekly rhythms, 66-day milestone ladders, and multi-habit performance matrices.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final activeDate = ref.watch(calendarDateProvider);
    final repository = ref.watch(habitRepositoryProvider);

    final monthName = AppDateUtils.formatMonthYear(activeDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics & Overview',
          style: AppTextStyles.displayMedium(context).copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final selectedHabit = ref.read(selectedHabitProvider);
              if (selectedHabit != null) {
                SocialShareSheet.show(
                  context,
                  habit: selectedHabit,
                  initialCardType: ShareCardType.matrixHeatmap,
                );
              }
            },
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Share Analytics Matrix',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.paddingXl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 64,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No analytics available',
                      style: AppTextStyles.titleLarge(context),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Add habits and log check-ins to unlock 365-day heatmaps and performance reports.',
                      style: AppTextStyles.bodyMedium(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return FutureBuilder<List<HabitEntry>>(
            future: repository.getAllEntries(),
            builder: (context, snapshot) {
              final allEntries = snapshot.data ?? [];

              return ListView(
                padding: AppSpacing.paddingMd,
                children: [
                  // 1. Overall Summary Metric Cards
                  _buildOverallSummaryCards(context, ref, habits, activeDate),
                  const SizedBox(height: AppSpacing.lg),

                  // 2. GitHub-Style 365-Day Activity Heatmap
                  ContributionHeatmapWidget(
                    habits: habits,
                    allEntries: allEntries,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Weekly Rhythm & Consistency Analysis
                  WeeklyRhythmCard(
                    allEntries: allEntries,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Habit Formation Milestones Ladder
                  _buildMilestoneLadderSection(repository, habits),
                  const SizedBox(height: AppSpacing.lg),

                  // 5. Monthly Habit Performance Matrix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Performance Matrix',
                        style: AppTextStyles.titleLarge(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        monthName,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Multi-Habit Performance Rows
                  ...habits.map((habit) {
                    return _HabitPerformanceCard(
                      habit: habit,
                      activeDate: activeDate,
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading stats: $err')),
      ),
    );
  }

  Widget _buildMilestoneLadderSection(
    HabitRepository repository,
    List<Habit> habits,
  ) {
    return FutureBuilder<int>(
      future: _computeHighestBestStreak(repository, habits),
      builder: (context, snapshot) {
        final highestStreak = snapshot.data ?? 0;
        return MilestonesLadderCard(highestStreak: highestStreak);
      },
    );
  }

  Future<int> _computeHighestBestStreak(
    HabitRepository repository,
    List<Habit> habits,
  ) async {
    int maxStreak = 0;
    for (final h in habits) {
      final best = await repository.getBestStreak(h.id);
      if (best > maxStreak) maxStreak = best;
    }
    return maxStreak;
  }

  Widget _buildOverallSummaryCards(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
    DateTime activeDate,
  ) {
    final repository = ref.watch(habitRepositoryProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _computeOverallMetrics(repository, habits, activeDate),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {
          'completionRate': 0.0,
          'totalCheckins': 0,
          'bestOverallStreak': 0,
        };

        final rate = (data['completionRate'] as double).round();
        final totalCheckins = data['totalCheckins'] as int;
        final bestStreak = data['bestOverallStreak'] as int;

        return Row(
          children: [
            Expanded(
              child: _SummaryMetricTile(
                title: 'Monthly Rate',
                value: '$rate%',
                icon: Icons.donut_large_rounded,
                accentColor: AppColors.primary,
                subtitle: 'All habits avg',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SummaryMetricTile(
                title: 'Total Checks',
                value: '$totalCheckins',
                icon: Icons.check_circle_outline_rounded,
                accentColor: AppColors.secondary,
                subtitle: 'This month',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SummaryMetricTile(
                title: 'Best Streak',
                value: '$bestStreak d',
                icon: Icons.local_fire_department_rounded,
                accentColor: AppColors.accent,
                subtitle: 'Active peak',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _computeOverallMetrics(
    HabitRepository repository,
    List<Habit> habits,
    DateTime activeDate,
  ) async {
    if (habits.isEmpty) {
      return {
        'completionRate': 0.0,
        'totalCheckins': 0,
        'bestOverallStreak': 0,
      };
    }

    final startOfMonth = DateTime(activeDate.year, activeDate.month, 1);
    final endOfMonth = DateTime(activeDate.year, activeDate.month + 1, 0);

    double totalRate = 0;
    int totalCheckins = 0;
    int bestStreak = 0;

    for (final habit in habits) {
      final entries = await repository.getEntriesForHabitInMonth(
        habit.id,
        activeDate.year,
        activeDate.month,
      );
      totalCheckins += entries.length;

      final rate = await repository.getCompletionRate(
        habit.id,
        startOfMonth,
        endOfMonth,
      );
      totalRate += rate;

      final currentStreak = await repository.getCurrentStreak(habit.id);
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    }

    return {
      'completionRate': (totalRate / habits.length) * 100,
      'totalCheckins': totalCheckins,
      'bestOverallStreak': bestStreak,
    };
  }
}

class _SummaryMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String subtitle;

  const _SummaryMetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, size: 16, color: accentColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.titleLarge(context).copyWith(
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall(context).copyWith(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitPerformanceCard extends ConsumerWidget {
  final Habit habit;
  final DateTime activeDate;

  const _HabitPerformanceCard({
    required this.habit,
    required this.activeDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(habitRepositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final startOfMonth = DateTime(activeDate.year, activeDate.month, 1);
    final endOfMonth = DateTime(activeDate.year, activeDate.month + 1, 0);

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchHabitStats(repository, startOfMonth, endOfMonth),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {
          'rate': 0.0,
          'checkins': 0,
          'currentStreak': 0,
          'bestStreak': 0,
          'daysInMonth': endOfMonth.day,
        };

        final rate = (data['rate'] as double);
        final ratePercent = (rate * 100).round();
        final checkins = data['checkins'] as int;
        final daysInMonth = data['daysInMonth'] as int;
        final currentStreak = data['currentStreak'] as int;
        final bestStreak = data['bestStreak'] as int;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: habit.color.withValues(alpha: 0.15),
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: Icon(
                        habit.icon,
                        color: habit.color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: AppTextStyles.labelBold(context).copyWith(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$checkins / $daysInMonth days completed',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$ratePercent%',
                      style: AppTextStyles.titleMedium(context).copyWith(
                        fontWeight: FontWeight.w800,
                        color: habit.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: rate,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? AppColors.darkCardElevated
                        : AppColors.lightCardElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Streak: $currentStreak d',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Best: $bestStreak d',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchHabitStats(
    HabitRepository repository,
    DateTime start,
    DateTime end,
  ) async {
    final entries = await repository.getEntriesForHabitInMonth(
      habit.id,
      start.year,
      start.month,
    );
    final rate = await repository.getCompletionRate(habit.id, start, end);
    final currentStreak = await repository.getCurrentStreak(habit.id);
    final bestStreak = await repository.getBestStreak(habit.id);

    return {
      'rate': rate,
      'checkins': entries.length,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'daysInMonth': end.day,
    };
  }
}
