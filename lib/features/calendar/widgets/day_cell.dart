import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_preset.dart';
import '../../../core/utils/date_utils.dart';
import '../../../state/settings_provider.dart';

/// Interactive calendar cell widget for a single day with true Neumorphic depth,
/// glowing radiant pills, sunken inset grooves, visible day numbers,
/// custom emoji stickers, and customizable checkmarks.
class DayCellWidget extends StatelessWidget {
  final CalendarDayCell cell;
  final bool isChecked;
  final String? emoji;
  final String defaultCheckSymbol;
  final TodayIndicatorStyle todayStyle;
  final CalendarFillStyle fillStyle;
  final AppThemePreset themePreset;
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
    this.themePreset = AppThemePreset.obsidian,
    required this.habitColor,
    required this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themePreset.isDark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cellDate = DateTime(cell.date.year, cell.date.month, cell.date.day);
    final isFuture = cellDate.isAfter(today);

    final primaryAccent = themePreset.primaryColor;

    // -------------------------------------------------------------------------
    // True Neumorphic & Standard Box Decorations
    // -------------------------------------------------------------------------
    BoxDecoration decoration;

    if (isChecked) {
      if (cell.isToday && themePreset.activePillGradient != null && fillStyle == CalendarFillStyle.pureMinimal) {
        // 🌟 Radiant Glowing Neumorphic Convex Pill (Active / Today)
        decoration = themePreset.neumorphicGlowingPill(radius: 12);
        if (todayStyle == TodayIndicatorStyle.ringBorder) {
          decoration = decoration.copyWith(
            border: Border.all(color: Colors.white, width: 2.0),
          );
        }
      } else if (fillStyle == CalendarFillStyle.solidFill) {
        // Saturated fill: adapts dynamically to the active theme's primary color unless user customized habit color
        final isDefaultHabitColor = habitColor.toARGB32() == 0xFF10B981;
        final fillColor = isDefaultHabitColor ? primaryAccent : habitColor;
        final grad = (isDefaultHabitColor && themePreset.activePillGradient != null && cell.isToday)
            ? themePreset.activePillGradient
            : null;

        decoration = BoxDecoration(
          color: grad == null ? fillColor : null,
          gradient: grad,
          borderRadius: BorderRadius.circular(12),
          border: cell.isToday && todayStyle == TodayIndicatorStyle.ringBorder
              ? Border.all(color: Colors.white, width: 2.0)
              : null,
          boxShadow: [
            BoxShadow(
              color: fillColor.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      } else if (themePreset.isNeumorphic) {
        // Neumorphic tactile raised cell for completed past days
        decoration = themePreset.neumorphicCard(radius: 12).copyWith(
          border: Border.all(
            color: primaryAccent.withValues(alpha: 0.75),
            width: 1.2,
          ),
        );
      } else {
        // Standard Pure Minimal tile
        decoration = BoxDecoration(
          color: themePreset.cardElevatedColor,
          borderRadius: BorderRadius.circular(12),
          border: cell.isToday && todayStyle == TodayIndicatorStyle.ringBorder
              ? Border.all(color: isDark ? Colors.white : AppColors.darkTextPrimary, width: 2.0)
              : Border.all(color: primaryAccent.withValues(alpha: isDark ? 0.8 : 0.7), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: primaryAccent.withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      }
    } else if (cell.isToday) {
      // Unchecked Today
      if (themePreset.isNeumorphic) {
        decoration = themePreset.neumorphicInset(radius: 12).copyWith(
          border: Border.all(color: primaryAccent, width: 1.8),
        );
      } else {
        decoration = BoxDecoration(
          color: themePreset.cardElevatedColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryAccent, width: 1.8),
        );
      }
    } else if (isFuture) {
      // Future dates
      decoration = BoxDecoration(
        color: themePreset.backgroundColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themePreset.borderColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      );
    } else if (cell.isCurrentMonth) {
      // Unchecked current month day
      if (themePreset.isNeumorphic) {
        decoration = themePreset.neumorphicInset(radius: 12);
      } else {
        decoration = BoxDecoration(
          color: themePreset.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themePreset.borderColor, width: 0.8),
        );
      }
    } else {
      // Adjacent month day
      decoration = BoxDecoration(
        color: themePreset.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themePreset.borderColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Text & Checkmark Colors
    // -------------------------------------------------------------------------
    Color textColor;
    Color checkColor;

    if (isChecked) {
      if (cell.isToday && themePreset.activePillGradient != null || fillStyle == CalendarFillStyle.solidFill) {
        textColor = Colors.white;
        checkColor = Colors.white;
      } else {
        textColor = isDark ? Colors.white : themePreset.textPrimaryColor;
        checkColor = primaryAccent;
      }
    } else if (cell.isToday) {
      textColor = primaryAccent;
      checkColor = primaryAccent;
    } else if (isFuture) {
      textColor = themePreset.textSecondaryColor.withValues(alpha: 0.3);
      checkColor = primaryAccent;
    } else if (cell.isCurrentMonth) {
      textColor = themePreset.textPrimaryColor;
      checkColor = primaryAccent;
    } else {
      textColor = themePreset.textSecondaryColor.withValues(alpha: 0.3);
      checkColor = primaryAccent;
    }

    final hasCustomEmoji = emoji != null && emoji!.isNotEmpty;
    final semanticLabel =
        'Day ${cell.dayNumber}${cell.isToday ? ", Today" : ""}${isChecked ? ", Completed" : ", Not completed"}${isFuture ? ", Future date" : ""}';

    // Base cell content
    Widget cellContent = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: decoration,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
                            color: checkColor,
                            size: 15,
                          )
                        : (defaultCheckSymbol == '❌'
                            ? Icon(
                                Icons.close_rounded,
                                color: (cell.isToday && themePreset.activePillGradient != null) ||
                                        fillStyle == CalendarFillStyle.solidFill
                                    ? Colors.white
                                    : AppColors.error,
                                size: 15,
                              )
                            : Text(
                                defaultCheckSymbol,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (cell.isToday && themePreset.activePillGradient != null) ||
                                          fillStyle == CalendarFillStyle.solidFill
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),

          // Today Indicator: Corner Dot option
          if (cell.isToday &&
              (!isChecked || todayStyle == TodayIndicatorStyle.cornerDot))
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isChecked ? Colors.white : primaryAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryAccent.withValues(alpha: 0.6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    // Today Indicator: Ambient Pulse option
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
              borderRadius: BorderRadius.circular(12),
              child: cellContent,
            ),
          ),
        ),
      ),
    );
  }
}
