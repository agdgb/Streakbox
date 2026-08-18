import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../state/settings_provider.dart';

/// Interactive calendar cell widget for a single day with visible day numbers,
/// custom emoji stickers, customizable default checkmarks, double-tap protection,
/// selectable Today highlight indicator styles, future-date safeguards,
/// and support for Pure Minimalist (Theme Native ✅ / ❌) vs Solid Fill styles.
class DayCellWidget extends StatelessWidget {
  final CalendarDayCell cell;
  final bool isChecked;
  final String? emoji;
  final String defaultCheckSymbol;
  final TodayIndicatorStyle todayStyle;
  final CalendarFillStyle fillStyle;
  final Color habitColor;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const DayCellWidget({
    super.key,
    required this.cell,
    required this.isChecked,
    this.emoji,
    this.defaultCheckSymbol = '✓',
    this.todayStyle = TodayIndicatorStyle.ringBorder,
    this.fillStyle = CalendarFillStyle.pureMinimal,
    required this.habitColor,
    required this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cellDate = DateTime(cell.date.year, cell.date.month, cell.date.day);
    final isFuture = cellDate.isAfter(today);

    // Background & border styling depending on state and fill style
    Color cellBgColor;
    Border? border;

    if (isChecked) {
      if (fillStyle == CalendarFillStyle.solidFill) {
        // Vibrant solid fill style
        cellBgColor = habitColor;
        if (cell.isToday && todayStyle == TodayIndicatorStyle.ringBorder) {
          border = Border.all(
            color: Colors.white,
            width: 2.0,
          );
        }
      } else {
        // Pure Minimalist style (adheres strictly to dark/light theme defaults)
        cellBgColor = isDark
            ? AppColors.darkCardElevated
            : AppColors.lightSurface;

        if (cell.isToday && todayStyle == TodayIndicatorStyle.ringBorder) {
          border = Border.all(
            color: isDark ? Colors.white : AppColors.darkTextPrimary,
            width: 2.0,
          );
        } else {
          border = Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.75)
                : AppColors.primary.withValues(alpha: 0.85),
            width: 1.4,
          );
        }
      }
    } else if (cell.isToday) {
      cellBgColor = isDark
          ? AppColors.darkCardElevated
          : AppColors.lightCardElevated;
      border = Border.all(
        color: AppColors.primary,
        width: 1.8,
      );
    } else if (isFuture) {
      // Future dates: visually disabled & non-interactive
      cellBgColor = isDark
          ? AppColors.darkBackground.withValues(alpha: 0.15)
          : AppColors.lightBackground.withValues(alpha: 0.3);
      border = Border.all(
        color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
            .withValues(alpha: 0.25),
        width: 0.5,
      );
    } else if (cell.isCurrentMonth) {
      cellBgColor = isDark
          ? AppColors.darkCard
          : AppColors.lightSurface;
      border = Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 0.8,
      );
    } else {
      // Adjacent month dates: visibly dimmed
      cellBgColor = isDark
          ? AppColors.darkBackground.withValues(alpha: 0.2)
          : AppColors.lightBackground.withValues(alpha: 0.4);
      border = Border.all(
        color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
            .withValues(alpha: 0.25),
        width: 0.5,
      );
    }

    // Text color depending on state & fill style
    Color textColor;
    if (isChecked) {
      if (fillStyle == CalendarFillStyle.solidFill) {
        textColor = Colors.white;
      } else {
        textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
      }
    } else if (cell.isToday) {
      textColor = AppColors.primary;
    } else if (isFuture) {
      textColor = (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
          .withValues(alpha: 0.35);
    } else if (cell.isCurrentMonth) {
      textColor = isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
    } else {
      // Dim adjacent month date numbers
      textColor = (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
          .withValues(alpha: 0.35);
    }

    final hasCustomEmoji = emoji != null && emoji!.isNotEmpty;
    final semanticLabel =
        'Day ${cell.dayNumber}${cell.isToday ? ", Today" : ""}${isChecked ? ", Completed" : ", Not completed"}${isFuture ? ", Future date" : ""}';

    // Base cell content
    Widget cellContent = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cellBgColor,
        borderRadius: AppSpacing.roundedMd,
        border: border,
        boxShadow: isChecked
            ? [
                BoxShadow(
                  color: (fillStyle == CalendarFillStyle.solidFill
                          ? habitColor
                          : AppColors.primary)
                      .withValues(alpha: isDark ? 0.25 : 0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Content: Day Number and Checkmark/Emoji
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasCustomEmoji)
                Text(
                  emoji!,
                  style: const TextStyle(fontSize: 12),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      duration: 150.ms,
                      curve: Curves.easeOutBack,
                    )
              else if (isChecked)
                (defaultCheckSymbol == '✓' || defaultCheckSymbol == '✔️'
                        ? Icon(
                            Icons.check_rounded,
                            color: fillStyle == CalendarFillStyle.solidFill
                                ? Colors.white
                                : AppColors.primary,
                            size: 15,
                          )
                        : (defaultCheckSymbol == '❌'
                            ? Icon(
                                Icons.close_rounded,
                                color: fillStyle == CalendarFillStyle.solidFill
                                    ? Colors.white
                                    : AppColors.error,
                                size: 15,
                              )
                            : Text(
                                defaultCheckSymbol,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: fillStyle == CalendarFillStyle.solidFill
                                      ? Colors.white
                                      : null,
                                  fontWeight: FontWeight.w800,
                                ),
                              )))
                    .animate()
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      duration: 150.ms,
                      curve: Curves.easeOutBack,
                    ),
              Text(
                '${cell.dayNumber}',
                style: AppTextStyles.calendarDay(
                  context,
                  color: textColor,
                  isToday: cell.isToday,
                ).copyWith(
                  fontWeight: isChecked
                      ? FontWeight.w800
                      : (cell.isToday ? FontWeight.w700 : FontWeight.w500),
                  fontSize: isChecked ? 12 : 13,
                ),
              ),

              // Today Indicator: Underline option
              if (cell.isToday &&
                  isChecked &&
                  todayStyle == TodayIndicatorStyle.numberUnderline)
                Container(
                  width: 14,
                  height: 2,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: fillStyle == CalendarFillStyle.solidFill
                        ? Colors.white
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),

          // Today Indicator: Corner Dot option (active when unchecked OR checked with cornerDot style)
          if (cell.isToday &&
              (!isChecked || todayStyle == TodayIndicatorStyle.cornerDot))
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: (isChecked && fillStyle == CalendarFillStyle.solidFill)
                      ? Colors.white
                      : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: isChecked
                      ? const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 2,
                          )
                        ]
                      : null,
                ),
              ),
            ),
        ],
      ),
    );

    // Today Indicator: Ambient Pulse option (breathing animation)
    if (cell.isToday &&
        isChecked &&
        todayStyle == TodayIndicatorStyle.ambientPulse) {
      cellContent = cellContent
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1.04, 1.04),
            duration: 1100.ms,
            curve: Curves.easeInOut,
          );
    }

    return Semantics(
      label: semanticLabel,
      button: !isFuture,
      toggled: isChecked,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isFuture ? null : onTap,
              onDoubleTap: isFuture ? null : onDoubleTap,
              onLongPress: isFuture ? null : onLongPress,
              borderRadius: AppSpacing.roundedMd,
              child: cellContent,
            ),
          ),
        ),
      ),
    );
  }
}
