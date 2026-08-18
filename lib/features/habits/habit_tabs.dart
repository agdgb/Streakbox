import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../data/models/habit.dart';
import '../../state/habit_providers.dart';
import '../../state/theme_preset_provider.dart';
import 'habit_form_sheet.dart';

/// Horizontal switcher bar for active habits with direct Add and Edit support.
class HabitTabsWidget extends ConsumerWidget {
  final VoidCallback onAddHabit;

  const HabitTabsWidget({
    super.key,
    required this.onAddHabit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...habits.map((habit) {
                      final isSelected = habit.id == selectedHabit?.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _HabitTabItem(
                          habit: habit,
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(selectedHabitIdProvider.notifier)
                                .select(habit.id);
                          },
                          onLongPress: () {
                            HabitFormSheet.show(context, habit: habit);
                          },
                          onEdit: () {
                            HabitFormSheet.show(context, habit: habit);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: onAddHabit,
              icon: const Icon(Icons.add_rounded, size: 20),
              tooltip: 'Add new habit',
              style: IconButton.styleFrom(
                backgroundColor: themePreset.primaryColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                minimumSize: const Size(36, 36),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 36,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _HabitTabItem extends ConsumerWidget {
  final Habit habit;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;

  const _HabitTabItem({
    required this.habit,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;
    final isDefaultColor = habit.colorValue == 0xFF10B981;
    final habitColor = isDefaultColor ? themePreset.primaryColor : habit.color;

    BoxDecoration decoration;
    if (themePreset.isNeumorphic) {
      if (isSelected) {
        decoration = themePreset.neumorphicCard(
          radius: 20,
          customColor: themePreset.cardElevatedColor,
        ).copyWith(
          border: Border.all(
            color: themePreset.primaryColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themePreset.primaryColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      } else {
        decoration = themePreset.neumorphicInset(radius: 20);
      }
    } else {
      decoration = BoxDecoration(
        color: isSelected
            ? habitColor.withValues(alpha: isDark ? 0.25 : 0.18)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(
          color: isSelected
              ? habitColor
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.5 : 1.0,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppSpacing.roundedFull,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.only(
            left: 12,
            right: isSelected ? 8 : 14,
            top: 6,
            bottom: 6,
          ),
          decoration: decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.getHabitIcon(habit.iconCodePoint),
                size: 16,
                color: habitColor,
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  habit.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelBold(
                    context,
                    color: isSelected ? habitColor : null,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 12,
                      color: habitColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
