import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';

/// Fast, high-speed 1-tap curated icon picker solving cognitive bloat (Attack #6).
class CuratedIconPicker extends StatefulWidget {
  final int selectedCodePoint;
  final Color activeColor;
  final ValueChanged<int> onIconSelected;
  final VoidCallback onOpenFullEmojiKeyboard;

  const CuratedIconPicker({
    super.key,
    required this.selectedCodePoint,
    required this.activeColor,
    required this.onIconSelected,
    required this.onOpenFullEmojiKeyboard,
  });

  @override
  State<CuratedIconPicker> createState() => _CuratedIconPickerState();
}

class _CuratedIconPickerState extends State<CuratedIconPicker> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Fitness', 'Mind', 'Health', 'Discipline'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredIcons = _selectedCategory == 'All'
        ? AppIcons.habitIcons
        : AppIcons.habitIcons.where((i) => i.category == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    }
                  },
                  selectedColor: widget.activeColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? widget.activeColor : null,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? widget.activeColor
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Quick-Pick Grid
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: filteredIcons.map((option) {
            final isSelected = option.codePoint == widget.selectedCodePoint;

            return Tooltip(
              message: '${option.name} (${option.category})',
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onIconSelected(option.codePoint);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.activeColor.withValues(alpha: isDark ? 0.25 : 0.15)
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(
                      color: isSelected
                          ? widget.activeColor
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: widget.activeColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    option.icon,
                    color: isSelected
                        ? widget.activeColor
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    size: 22,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // 1-Tap Toggle to full emoji keyboard
        TextButton.icon(
          onPressed: widget.onOpenFullEmojiKeyboard,
          icon: const Icon(Icons.keyboard_outlined, size: 16),
          label: const Text('Open 3,000+ Emoji Keyboard & Search', style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: widget.activeColor,
          ),
        ),
      ],
    );
  }
}
