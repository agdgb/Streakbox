import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_entry.dart';

/// Minimalist, zero-scroll GitHub-style 365-day Activity Heatmap with clean dropdowns,
/// single-letter month headers, and dynamic screen-fitting micro-cells.
class ContributionHeatmapWidget extends StatefulWidget {
  final List<Habit> habits;
  final List<HabitEntry> allEntries;

  const ContributionHeatmapWidget({
    super.key,
    required this.habits,
    required this.allEntries,
  });

  @override
  State<ContributionHeatmapWidget> createState() =>
      _ContributionHeatmapWidgetState();
}

class _ContributionHeatmapWidgetState extends State<ContributionHeatmapWidget> {
  late int _selectedYear;
  String? _selectedHabitFilter; // null = all habits

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  /// Extracts available years from entry history (always includes current year)
  List<int> _getAvailableYears() {
    final currentYear = DateTime.now().year;
    final years = <int>{currentYear, currentYear - 1};
    for (final entry in widget.allEntries) {
      if (entry.date.length >= 4) {
        final yr = int.tryParse(entry.date.substring(0, 4));
        if (yr != null) years.add(yr);
      }
    }
    final sorted = years.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  /// Groups entries by dateKey: `Map<String, List<HabitEntry>>`
  Map<String, List<HabitEntry>> _buildEntryMap() {
    final map = <String, List<HabitEntry>>{};
    for (final entry in widget.allEntries) {
      if (_selectedHabitFilter != null &&
          entry.habitId != _selectedHabitFilter) {
        continue;
      }
      map.putIfAbsent(entry.date, () => []).add(entry);
    }
    return map;
  }

  void _showDayDetails(
    BuildContext context,
    DateTime date,
    List<HabitEntry> dayEntries,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormatted = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final habitMap = {for (final h in widget.habits) h.id: h};

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormatted,
                            style: AppTextStyles.labelBold(context).copyWith(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${dayEntries.length} ${dayEntries.length == 1 ? "habit" : "habits"} completed',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: dayEntries.isNotEmpty
                                  ? AppColors.primary
                                  : AppColors.darkTextMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                if (dayEntries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No check-ins recorded for this day',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                  )
                else
                  ...dayEntries.map((entry) {
                    final habit = habitMap[entry.habitId];
                    final habitName = habit?.name ?? 'Habit';
                    final habitColor = habit?.color ?? AppColors.primary;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.12),
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(
                          color: habitColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: habitColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habitName,
                                  style: AppTextStyles.labelBold(context),
                                ),
                                if (entry.notes.isNotEmpty)
                                  Text(
                                    entry.notes,
                                    style: AppTextStyles.bodySmall(context),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableYears = _getAvailableYears();
    final entryMap = _buildEntryMap();

    // Determine base theme color for heatmap cells
    Color accentColor = AppColors.primary;
    String selectedHabitName = 'All Habits';
    if (_selectedHabitFilter != null) {
      final filteredHabit =
          widget.habits.where((h) => h.id == _selectedHabitFilter).firstOrNull;
      if (filteredHabit != null) {
        accentColor = filteredHabit.color;
        selectedHabitName = filteredHabit.name;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean Minimalist Header: Title + Minimal Dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity Heatmap',
                  style: AppTextStyles.titleLarge(context).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                // Compact Dropdown Menus (Habit & Year)
                Row(
                  children: [
                    // Habit Filter Dropdown
                    if (widget.habits.length > 1)
                      PopupMenuButton<String?>(
                        initialValue: _selectedHabitFilter,
                        tooltip: 'Filter habit',
                        onSelected: (val) {
                          setState(() => _selectedHabitFilter = val);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: null,
                            child: Text('All Habits', style: TextStyle(fontSize: 12)),
                          ),
                          ...widget.habits.map((h) {
                            return PopupMenuItem(
                              value: h.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: h.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(h.name, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            );
                          }),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedHabitName.length > 10
                                    ? '${selectedHabitName.substring(0, 9)}…'
                                    : selectedHabitName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 16),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),

                    // Year Selector Dropdown
                    PopupMenuButton<int>(
                      initialValue: _selectedYear,
                      tooltip: 'Select Year',
                      onSelected: (val) {
                        setState(() => _selectedYear = val);
                      },
                      itemBuilder: (context) => availableYears.map((yr) {
                        return PopupMenuItem(
                          value: yr,
                          child: Text('$yr', style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_selectedYear',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Dynamic Screen-Fitting Heatmap Matrix (Zero-Scroll!)
            LayoutBuilder(
              builder: (context, constraints) {
                return _buildZeroScrollHeatmapGrid(
                  context,
                  isDark: isDark,
                  year: _selectedYear,
                  entryMap: entryMap,
                  accentColor: accentColor,
                  containerWidth: constraints.maxWidth,
                );
              },
            ),
            const SizedBox(height: 10),

            // Minimal Footer Legend: Less ⬜ 🟩 🟩 🟩 🟩 More
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tap day to inspect',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Less',
                      style: AppTextStyles.bodySmall(context).copyWith(fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(5, (level) {
                      return Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _getCellColor(
                            level: level,
                            accentColor: accentColor,
                            isDark: isDark,
                          ),
                          borderRadius: BorderRadius.circular(1.5),
                          border: level == 0
                              ? Border.all(
                                  color: (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder)
                                      .withValues(alpha: 0.5),
                                  width: 0.5,
                                )
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      'More',
                      style: AppTextStyles.bodySmall(context).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a responsive, zero-scroll 53-week matrix fitting dynamically within containerWidth
  Widget _buildZeroScrollHeatmapGrid(
    BuildContext context, {
    required bool isDark,
    required int year,
    required Map<String, List<HabitEntry>> entryMap,
    required Color accentColor,
    required double containerWidth,
  }) {
    // Generate 53 weeks starting from first Monday on or before Jan 1 of selected year
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysToSubtract = (firstDayOfYear.weekday - DateTime.monday + 7) % 7;
    final startMonday = firstDayOfYear.subtract(Duration(days: daysToSubtract));

    const totalWeeks = 53;
    final List<List<DateTime>> weeks = [];
    final List<String?> singleLetterMonthLabels = [];

    int? lastMonth;

    // Single-letter month initial lookup
    const monthInitials = ['', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

    for (int w = 0; w < totalWeeks; w++) {
      final List<DateTime> weekDays = [];
      for (int d = 0; d < 7; d++) {
        weekDays.add(startMonday.add(Duration(days: w * 7 + d)));
      }
      weeks.add(weekDays);

      // Anchor single-letter initial at the start of each month
      final firstDayInSelectedYear =
          weekDays.where((date) => date.year == year).firstOrNull;
      if (firstDayInSelectedYear != null &&
          firstDayInSelectedYear.month != lastMonth) {
        lastMonth = firstDayInSelectedYear.month;
        singleLetterMonthLabels.add(monthInitials[lastMonth]);
      } else {
        singleLetterMonthLabels.add(null);
      }
    }

    // Dynamic cell sizing to guarantee 100% zero-scroll fit on any screen size
    const leftLabelWidth = 20.0;
    final availableGridWidth = containerWidth - leftLabelWidth;
    const double cellGap = 1.3;
    final double cellSize =
        ((availableGridWidth - (totalWeeks - 1) * cellGap) / totalWeeks)
            .clamp(4.0, 9.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Single-Letter Month Initial Labels Row (J F M A M J J A S O N D)
        Row(
          children: [
            const SizedBox(width: leftLabelWidth),
            ...List.generate(totalWeeks, (w) {
              final label = singleLetterMonthLabels[w];
              return Container(
                width: cellSize + (w < totalWeeks - 1 ? cellGap : 0),
                alignment: Alignment.centerLeft,
                child: label != null
                    ? Text(
                        label,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      )
                    : null,
              );
            }),
          ],
        ),
        const SizedBox(height: 3),

        // Grid Matrix: M / W / F row labels + 53 week columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left row labels (M, W, F)
            SizedBox(
              width: leftLabelWidth,
              child: Column(
                children: [
                  _buildWeekdayLabel('M', cellSize, cellGap),
                  SizedBox(height: cellSize + cellGap),
                  _buildWeekdayLabel('W', cellSize, cellGap),
                  SizedBox(height: cellSize + cellGap),
                  _buildWeekdayLabel('F', cellSize, cellGap),
                ],
              ),
            ),

            // 53 Columns of 7 days
            ...List.generate(totalWeeks, (w) {
              final week = weeks[w];
              return Padding(
                padding: EdgeInsets.only(right: w < totalWeeks - 1 ? cellGap : 0),
                child: Column(
                  children: List.generate(7, (d) {
                    final date = week[d];
                    final isCurrentYear = date.year == year;

                    if (!isCurrentYear) {
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        margin: EdgeInsets.only(bottom: d < 6 ? cellGap : 0),
                      );
                    }

                    final dateKey = AppDateUtils.formatDateKey(date);
                    final dayEntries = entryMap[dateKey] ?? [];
                    final count = dayEntries.length;

                    // Calculate intensity level (0..4)
                    int level = 0;
                    if (count >= 4) {
                      level = 4;
                    } else if (count == 3) {
                      level = 3;
                    } else if (count == 2) {
                      level = 2;
                    } else if (count == 1) {
                      level = 1;
                    }

                    final cellColor = _getCellColor(
                      level: level,
                      accentColor: accentColor,
                      isDark: isDark,
                    );

                    return GestureDetector(
                      onTap: () => _showDayDetails(context, date, dayEntries),
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        margin: EdgeInsets.only(bottom: d < 6 ? cellGap : 0),
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(1.5),
                          border: level == 0
                              ? Border.all(
                                  color: (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder)
                                      .withValues(alpha: 0.35),
                                  width: 0.5,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayLabel(String text, double size, double gap) {
    return SizedBox(
      height: size,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextMuted,
        ),
      ),
    );
  }

  Color _getCellColor({
    required int level,
    required Color accentColor,
    required bool isDark,
  }) {
    if (level == 0) {
      return isDark
          ? AppColors.darkCardElevated.withValues(alpha: 0.5)
          : AppColors.lightBackground;
    } else if (level == 1) {
      return accentColor.withValues(alpha: isDark ? 0.30 : 0.35);
    } else if (level == 2) {
      return accentColor.withValues(alpha: isDark ? 0.55 : 0.60);
    } else if (level == 3) {
      return accentColor.withValues(alpha: isDark ? 0.80 : 0.82);
    } else {
      return accentColor;
    }
  }
}
