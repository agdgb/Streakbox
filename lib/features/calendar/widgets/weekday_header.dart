import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../state/settings_provider.dart';

/// Dynamic 7-day column header adapting to the user's preferred first day of the week.
class WeekdayHeader extends ConsumerWidget {
  const WeekdayHeader({super.key});

  static List<String> _getWeekdayLabels(int firstDayOfWeek) {
    if (firstDayOfWeek == DateTime.sunday) {
      return ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    } else if (firstDayOfWeek == DateTime.saturday) {
      return ['S', 'S', 'M', 'T', 'W', 'T', 'F'];
    } else {
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }
  }

  static bool _isWeekendIndex(int index, int firstDayOfWeek) {
    if (firstDayOfWeek == DateTime.sunday) {
      return index == 0 || index == 6; // Sunday & Saturday
    } else if (firstDayOfWeek == DateTime.saturday) {
      return index == 0 || index == 1; // Saturday & Sunday
    } else {
      return index >= 5; // Saturday & Sunday
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstDay = ref.watch(firstDayOfWeekProvider);
    final weekdayLabels = _getWeekdayLabels(firstDay);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: List.generate(7, (index) {
          final isWeekend = _isWeekendIndex(index, firstDay);
          final textColor = isWeekend
              ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

          return Expanded(
            child: Center(
              child: Text(
                weekdayLabels[index],
                style: AppTextStyles.labelBold(
                  context,
                  color: textColor,
                ).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
