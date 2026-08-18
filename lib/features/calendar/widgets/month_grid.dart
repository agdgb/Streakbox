import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/habit_entry.dart';
import '../../../state/calendar_providers.dart';
import '../../../state/habit_providers.dart';
import '../../../state/settings_provider.dart';
import '../../../state/theme_preset_provider.dart';
import 'day_cell.dart';
import 'day_detail_sheet.dart';
import 'weekday_header.dart';

/// Interactive month grid with physical swipe overlapping page transitions,
/// per-habit viewing date memory, tap protection, and emoji reactions.
class MonthGridWidget extends ConsumerStatefulWidget {
  const MonthGridWidget({super.key});

  @override
  ConsumerState<MonthGridWidget> createState() => _MonthGridWidgetState();
}

class _MonthGridWidgetState extends ConsumerState<MonthGridWidget> {
  late PageController _pageController;
  late int _currentPage;
  final DateTime _referenceMonth = HabitCalendarDatesNotifier.referenceMonth;

  @override
  void initState() {
    super.initState();
    final activeDate = ref.read(calendarDateProvider);
    _currentPage = monthToPageIndex(activeDate, _referenceMonth);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static String _extractLeadingEmoji(String notes) {
    if (notes.isEmpty) return '';
    final words = notes.split(' ');
    if (words.isNotEmpty) {
      final first = words.first;
      final runes = first.runes.toList();
      if (runes.isNotEmpty && (runes.first > 0x2000 || first.length <= 4)) {
        return first;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final activeDate = ref.watch(calendarDateProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);
    final entriesAsync = ref.watch(selectedHabitEntriesProvider);
    final entryMapAsync = ref.watch(selectedHabitEntryMapProvider);
    final defaultCheckSymbol = ref.watch(defaultCheckMarkProvider);
    final requireDoubleTap = ref.watch(tapProtectionProvider);
    final firstDay = ref.watch(firstDayOfWeekProvider);

    final checkedKeys = entriesAsync.asData?.value ?? {};
    final entryMap = entryMapAsync.asData?.value ?? {};
    final habitColor = selectedHabit?.color ?? AppColors.primary;

    // Sync PageController if activeDate was changed externally (header chevron, Today jump, or habit tab switch)
    final targetPage = monthToPageIndex(activeDate, _referenceMonth);
    if (_pageController.hasClients && _currentPage != targetPage) {
      _currentPage = targetPage;
      final pageDiff = (_pageController.page?.round() ?? _currentPage) - targetPage;
      if (pageDiff.abs() == 1) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        _pageController.jumpToPage(targetPage);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WeekdayHeader(),
        SizedBox(
          height: 290,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (pageIndex) {
              _currentPage = pageIndex;
              final newMonth = pageIndexToMonth(pageIndex, _referenceMonth);
              if (selectedHabit != null) {
                ref
                    .read(habitCalendarDatesProvider.notifier)
                    .setDateForHabit(selectedHabit.id, newMonth);
              }
            },
            itemBuilder: (context, pageIndex) {
              final pageMonth = pageIndexToMonth(pageIndex, _referenceMonth);
              final cells = AppDateUtils.generateMonthGrid(
                pageMonth.year,
                pageMonth.month,
                firstDayOfWeek: firstDay,
              );

              return _buildMonthMatrix(
                context: context,
                cells: cells,
                selectedHabit: selectedHabit,
                checkedKeys: checkedKeys,
                entryMap: entryMap,
                habitColor: habitColor,
                defaultCheckSymbol: defaultCheckSymbol,
                requireDoubleTap: requireDoubleTap,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthMatrix({
    required BuildContext context,
    required List<CalendarDayCell> cells,
    required Habit? selectedHabit,
    required Set<String> checkedKeys,
    required Map<String, HabitEntry> entryMap,
    required Color habitColor,
    required String defaultCheckSymbol,
    required bool requireDoubleTap,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) {
        final cell = cells[index];
        final isChecked = checkedKeys.contains(cell.dateKey);
        final entry = entryMap[cell.dateKey];
        final emoji = entry != null ? _extractLeadingEmoji(entry.notes) : null;

        void toggleAction() {
          if (selectedHabit != null) {
            ref
                .read(selectedHabitEntriesProvider.notifier)
                .toggleEntry(cell.dateKey);
          }
        }

        final todayStyle = ref.watch(todayIndicatorStyleProvider);
        final fillStyle = ref.watch(calendarFillStyleProvider);
        final themePreset = ref.watch(themePresetProvider);

        return DayCellWidget(
          key: ValueKey('${selectedHabit?.id}_${cell.dateKey}'),
          cell: cell,
          isChecked: isChecked,
          emoji: emoji,
          defaultCheckSymbol: defaultCheckSymbol,
          todayStyle: todayStyle,
          fillStyle: fillStyle,
          themePreset: themePreset,
          habitColor: habitColor,
          onTap: () {
            if (!requireDoubleTap) {
              toggleAction();
            } else {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Double-tap to mark this day'),
                  duration: Duration(milliseconds: 900),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onDoubleTap: requireDoubleTap ? toggleAction : null,
          onLongPress: () {
            if (selectedHabit != null) {
              DayDetailSheet.show(
                context,
                habit: selectedHabit,
                date: cell.date,
                currentEntry: entry,
              );
            }
          },
        );
      },
    );
  }
}
