import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/habit.dart';
import '../../state/habit_providers.dart';
import 'widgets/color_picker_grid.dart';
import 'widgets/confirm_delete_dialog.dart';
import 'widgets/curated_icon_picker.dart';

/// Modal bottom sheet for creating or editing a habit with frequency and repetition goals.
class HabitFormSheet extends ConsumerStatefulWidget {
  final Habit? habit;

  const HabitFormSheet({super.key, this.habit});

  static Future<void> show(BuildContext context, {Habit? habit}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitFormSheet(habit: habit),
    );
  }

  @override
  ConsumerState<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends ConsumerState<HabitFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late int _selectedColorValue;
  late int _selectedIconCodePoint;
  late HabitFrequencyType _frequencyType;
  late int _targetDaysPerWeek;
  late Set<int> _selectedDaysOfWeek;

  bool get isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _descController = TextEditingController(text: h?.description ?? '');
    _selectedColorValue =
        h?.colorValue ?? AppColors.habitColors.first.color.toARGB32();
    _selectedIconCodePoint = h?.iconCodePoint ?? 0xe156;
    _frequencyType = h?.frequencyType ?? HabitFrequencyType.daily;
    _targetDaysPerWeek = h?.targetDaysPerWeek ?? 7;
    _selectedDaysOfWeek = h?.targetDaysOfWeek.isNotEmpty == true
        ? h!.targetDaysOfWeek.toSet()
        : {1, 2, 3, 4, 5, 6, 7};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descController.text.trim();

    int finalTargetDays = 7;
    if (_frequencyType == HabitFrequencyType.daily) {
      finalTargetDays = 7;
    } else if (_frequencyType == HabitFrequencyType.weeklyTarget) {
      finalTargetDays = _targetDaysPerWeek;
    } else if (_frequencyType == HabitFrequencyType.specificDays) {
      finalTargetDays = _selectedDaysOfWeek.length.clamp(1, 7);
    }

    final sortedDays = _selectedDaysOfWeek.toList()..sort();

    if (isEditing) {
      final updated = widget.habit!.copyWith(
        name: name,
        description: description,
        colorValue: _selectedColorValue,
        iconCodePoint: _selectedIconCodePoint,
        targetDaysPerWeek: finalTargetDays,
        frequencyType: _frequencyType,
        targetDaysOfWeek: _frequencyType == HabitFrequencyType.specificDays
            ? sortedDays
            : const [],
      );
      await ref.read(habitsProvider.notifier).updateHabit(updated);
    } else {
      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        colorValue: _selectedColorValue,
        iconCodePoint: _selectedIconCodePoint,
        createdAt: DateTime.now(),
        targetDaysPerWeek: finalTargetDays,
        frequencyType: _frequencyType,
        targetDaysOfWeek: _frequencyType == HabitFrequencyType.specificDays
            ? sortedDays
            : const [],
      );
      await ref.read(habitsProvider.notifier).addHabit(newHabit);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete() async {
    if (!isEditing) return;

    final confirmed = await ConfirmDeleteDialog.show(
      context,
      habitName: widget.habit!.name,
    );

    if (confirmed == true && mounted) {
      await ref.read(habitsProvider.notifier).deleteHabit(widget.habit!.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleToggleArchive() async {
    if (!isEditing) return;

    final newArchivedState = !widget.habit!.isArchived;
    await ref
        .read(habitsProvider.notifier)
        .archiveHabit(widget.habit!.id, newArchivedState);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newArchivedState
                ? 'Habit archived'
                : 'Habit unarchived and restored to active list',
          ),
        ),
      );
    }
  }

  void _showFullEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 320,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Choose Habit Icon', style: AppTextStyles.titleMedium(context)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: AppIcons.habitIcons.length,
                  itemBuilder: (context, index) {
                    final iconOpt = AppIcons.habitIcons[index];
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIconCodePoint = iconOpt.codePoint);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(iconOpt.icon, size: 22, color: Color(_selectedColorValue)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Color(_selectedColorValue);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.08),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      isEditing ? 'Edit Habit' : 'New Habit',
                      style: AppTextStyles.titleLarge(context).copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Form Body
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 24),
                children: [
                  // Habit Name Input
                  Text('Habit Name', style: AppTextStyles.labelLarge(context)),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _nameController,
                    autofocus: !isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a habit name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'e.g. Morning Workout, Daily Reading',
                      prefixIcon: Icon(
                        Icons.edit_outlined,
                        color: activeColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Optional Description / Notes
                  Text('Notes / Goal (Optional)',
                      style: AppTextStyles.labelLarge(context)),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 20 minutes before breakfast',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Target Frequency & Repetition Section
                  Text('Target Frequency',
                      style: AppTextStyles.labelLarge(context)),
                  const SizedBox(height: 4),
                  Text(
                    'How often do you want to perform this habit?',
                    style: AppTextStyles.bodySmall(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<HabitFrequencyType>(
                    segments: const [
                      ButtonSegment(
                        value: HabitFrequencyType.daily,
                        label: Text('Every Day', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: HabitFrequencyType.weeklyTarget,
                        label: Text('X / Week', style: TextStyle(fontSize: 11)),
                      ),
                      ButtonSegment(
                        value: HabitFrequencyType.specificDays,
                        label: Text('Specific Days', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    selected: {_frequencyType},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _frequencyType = newSelection.first;
                        if (_frequencyType == HabitFrequencyType.weeklyTarget &&
                            _targetDaysPerWeek >= 7) {
                          _targetDaysPerWeek = 3;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Dynamic Frequency Config Controls
                  if (_frequencyType == HabitFrequencyType.weeklyTarget)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weekly Goal',
                                  style: AppTextStyles.labelBold(context).copyWith(fontSize: 12),
                                ),
                                Text(
                                  '$_targetDaysPerWeek ${_targetDaysPerWeek == 1 ? "day" : "days"} every week',
                                  style: AppTextStyles.bodySmall(context).copyWith(
                                    color: activeColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _targetDaysPerWeek > 1
                                ? () => setState(() => _targetDaysPerWeek--)
                                : null,
                            icon: const Icon(Icons.remove, size: 16),
                            visualDensity: VisualDensity.compact,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$_targetDaysPerWeek',
                              style: AppTextStyles.titleLarge(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _targetDaysPerWeek < 6
                                ? () => setState(() => _targetDaysPerWeek++)
                                : null,
                            icon: const Icon(Icons.add, size: 16),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),

                  if (_frequencyType == HabitFrequencyType.specificDays)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          (dayIndex: 1, label: 'M'),
                          (dayIndex: 2, label: 'T'),
                          (dayIndex: 3, label: 'W'),
                          (dayIndex: 4, label: 'T'),
                          (dayIndex: 5, label: 'F'),
                          (dayIndex: 6, label: 'S'),
                          (dayIndex: 7, label: 'S'),
                        ].map((d) {
                          final isSelected = _selectedDaysOfWeek.contains(d.dayIndex);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected && _selectedDaysOfWeek.length > 1) {
                                  _selectedDaysOfWeek.remove(d.dayIndex);
                                } else {
                                  _selectedDaysOfWeek.add(d.dayIndex);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? activeColor
                                    : (isDark ? AppColors.darkCard : AppColors.lightSurface),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? activeColor
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  d.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Accent Color Palette
                  Row(
                    children: [
                      Text('Accent Color',
                          style: AppTextStyles.labelLarge(context)),
                      const Spacer(),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ColorPickerGrid(
                    selectedColorValue: _selectedColorValue,
                    onColorSelected: (colorVal) {
                      setState(() {
                        _selectedColorValue = colorVal;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Habit Icon Selector (Curated Quick-Picks)
                  Text('Habit Icon', style: AppTextStyles.labelLarge(context)),
                  const SizedBox(height: AppSpacing.sm),
                  CuratedIconPicker(
                    selectedCodePoint: _selectedIconCodePoint,
                    activeColor: activeColor,
                    onIconSelected: (codePoint) {
                      setState(() {
                        _selectedIconCodePoint = codePoint;
                      });
                    },
                    onOpenFullEmojiKeyboard: () {
                      _showFullEmojiPicker(context);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons (Save & in edit mode Archive/Delete)
                  FilledButton(
                    onPressed: _handleSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: activeColor,
                      foregroundColor:
                          activeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.roundedMd,
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Habit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  if (isEditing) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _handleToggleArchive,
                      icon: Icon(
                        widget.habit!.isArchived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        size: 18,
                      ),
                      label: Text(
                        widget.habit!.isArchived
                            ? 'Restore from Archive'
                            : 'Archive Habit',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.roundedMd,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: _handleDelete,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                      label: const Text(
                        'Delete Habit',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
