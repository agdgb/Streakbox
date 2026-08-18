import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';

/// Interactive icon selector for habit icons.
class IconPickerGrid extends StatelessWidget {
  final int selectedCodePoint;
  final Color activeColor;
  final ValueChanged<int> onIconSelected;

  const IconPickerGrid({
    super.key,
    required this.selectedCodePoint,
    required this.activeColor,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppIcons.habitIcons.map((option) {
        final isSelected = option.codePoint == selectedCodePoint;

        return Tooltip(
          message: option.name,
          child: GestureDetector(
            onTap: () => onIconSelected(option.codePoint),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: isDark ? 0.25 : 0.15)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(
                  color: isSelected
                      ? activeColor
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                option.icon,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 22,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
