import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/habit.dart';
import '../../state/habit_providers.dart';
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitColor = habit.color;

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
          decoration: BoxDecoration(
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
          ),
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
