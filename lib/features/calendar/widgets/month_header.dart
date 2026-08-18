import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../state/calendar_providers.dart';
import '../../../state/habit_providers.dart';

/// Month & Year header with navigation chevrons and Today jump button.
class MonthHeaderWidget extends ConsumerWidget {
  const MonthHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDate = ref.watch(calendarDateProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);
    final now = DateTime.now();
    final isCurrentMonth =
        activeDate.year == now.year && activeDate.month == now.month;

    final monthTitle = DateFormat('MMMM yyyy').format(activeDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Month and Year Title
        Text(
          monthTitle,
          style: AppTextStyles.titleLarge(context).copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),

        // Controls: Today jump + Prev/Next buttons
        Row(
          children: [
            if (!isCurrentMonth)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: TextButton.icon(
                  onPressed: () {
                    ref
                        .read(habitCalendarDatesProvider.notifier)
                        .jumpToToday(selectedHabit?.id);
                  },
                  icon: const Icon(Icons.today_rounded, size: 16),
                  label: const Text('Today'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            IconButton(
              onPressed: () {
                ref
                    .read(habitCalendarDatesProvider.notifier)
                    .prevMonth(selectedHabit?.id);
              },
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous month',
              visualDensity: VisualDensity.compact,
              iconSize: 22,
            ),
            IconButton(
              onPressed: () {
                ref
                    .read(habitCalendarDatesProvider.notifier)
                    .nextMonth(selectedHabit?.id);
              },
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Next month',
              visualDensity: VisualDensity.compact,
              iconSize: 22,
            ),
          ],
        ),
      ],
    );
  }
}
