import 'package:flutter_test/flutter_test.dart';
import 'package:streakbox/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils - Formatting and Parsing', () {
    test('formatDateKey formats DateTime correctly as yyyy-MM-dd', () {
      final date = DateTime(2026, 8, 17, 14, 30);
      expect(AppDateUtils.formatDateKey(date), '2026-08-17');
    });

    test('parseDateKey parses yyyy-MM-dd into DateTime', () {
      final parsed = AppDateUtils.parseDateKey('2026-08-17');
      expect(parsed.year, 2026);
      expect(parsed.month, 8);
      expect(parsed.day, 17);
    });

    test('isSameDay correctly identifies identical and different calendar days', () {
      final a = DateTime(2026, 8, 17, 9, 0);
      final b = DateTime(2026, 8, 17, 23, 59);
      final c = DateTime(2026, 8, 18, 0, 1);

      expect(AppDateUtils.isSameDay(a, b), isTrue);
      expect(AppDateUtils.isSameDay(a, c), isFalse);
    });
  });

  group('AppDateUtils - Month Grid Generator', () {
    test('August 2026 grid starts on Monday and ends on full week multiple of 7', () {
      // Aug 1, 2026 is Saturday -> requires 5 leading days (Mon Jul 27 - Fri Jul 31)
      // Aug has 31 days. 5 + 31 = 36 days -> requires 6 trailing days to reach 42
      final grid = AppDateUtils.generateMonthGrid(
        2026,
        8,
        today: DateTime(2026, 8, 17),
      );

      expect(grid.length, 42); // 6 rows x 7 days
      expect(grid.first.dateKey, '2026-07-27');
      expect(grid.first.isCurrentMonth, isFalse);

      final aug1 = grid.firstWhere((c) => c.dateKey == '2026-08-01');
      expect(aug1.isCurrentMonth, isTrue);
      expect(aug1.dayNumber, 1);

      final aug17 = grid.firstWhere((c) => c.dateKey == '2026-08-17');
      expect(aug17.isToday, isTrue);

      expect(grid.last.dateKey, '2026-09-06');
      expect(grid.last.isCurrentMonth, isFalse);
    });

    test('February 2024 (Leap Year) has 29 days', () {
      final grid = AppDateUtils.generateMonthGrid(
        2024,
        2,
        today: DateTime(2024, 2, 29),
      );

      final leapDay = grid.firstWhere((c) => c.dateKey == '2024-02-29');
      expect(leapDay.isCurrentMonth, isTrue);
      expect(leapDay.isToday, isTrue);
    });
  });

  group('AppDateUtils - Current Streak Algorithm', () {
    final today = DateTime(2026, 8, 17);

    test('returns 0 when no entries exist', () {
      expect(AppDateUtils.calculateCurrentStreak({}, today: today), 0);
    });

    test('returns 1 when only today is checked', () {
      final keys = {'2026-08-17'};
      expect(AppDateUtils.calculateCurrentStreak(keys, today: today), 1);
    });

    test('returns 1 when today is not checked yet, but yesterday is checked', () {
      final keys = {'2026-08-16'};
      expect(AppDateUtils.calculateCurrentStreak(keys, today: today), 1);
    });

    test('returns 5 consecutive days ending today', () {
      final keys = {
        '2026-08-13',
        '2026-08-14',
        '2026-08-15',
        '2026-08-16',
        '2026-08-17',
      };
      expect(AppDateUtils.calculateCurrentStreak(keys, today: today), 5);
    });

    test('returns 4 consecutive days ending yesterday (today pending)', () {
      final keys = {
        '2026-08-13',
        '2026-08-14',
        '2026-08-15',
        '2026-08-16',
      };
      expect(AppDateUtils.calculateCurrentStreak(keys, today: today), 4);
    });

    test('breaks streak when a day is missing', () {
      final keys = {
        '2026-08-10',
        '2026-08-11',
        // 2026-08-12 missing
        '2026-08-13',
        '2026-08-14',
        '2026-08-15',
        '2026-08-16',
        '2026-08-17',
      };
      expect(AppDateUtils.calculateCurrentStreak(keys, today: today), 5);
    });

    test('returns 0 when last checked day was 2 days ago', () {
      final keys = {
        '2026-08-14',
        '2026-08-15',
      };
      expect(AppDateUtils.calculateCurrentStreak(keys, today: today), 0);
    });

    test('handles month boundary correctly across July and August', () {
      final keys = {
        '2026-07-30',
        '2026-07-31',
        '2026-08-01',
        '2026-08-02',
      };
      final refDate = DateTime(2026, 8, 2);
      expect(AppDateUtils.calculateCurrentStreak(keys, today: refDate), 4);
    });
  });

  group('AppDateUtils - Best Streak Algorithm', () {
    test('returns 0 for empty entries', () {
      expect(AppDateUtils.calculateBestStreak({}), 0);
    });

    test('finds longest streak from disjoint ranges', () {
      final keys = {
        // Run 1: 3 days
        '2026-01-01', '2026-01-02', '2026-01-03',
        // Gap
        // Run 2: 7 days (Best)
        '2026-02-10', '2026-02-11', '2026-02-12', '2026-02-13',
        '2026-02-14', '2026-02-15', '2026-02-16',
        // Gap
        // Run 3: 2 days
        '2026-03-01', '2026-03-02',
      };
      expect(AppDateUtils.calculateBestStreak(keys), 7);
    });

    test('works with unordered keys input', () {
      final keys = {
        '2026-05-04',
        '2026-05-01',
        '2026-05-03',
        '2026-05-02',
      };
      expect(AppDateUtils.calculateBestStreak(keys), 4);
    });
  });

  group('AppDateUtils - Completion Rate', () {
    test('calculates 100% when all days in range are checked', () {
      final keys = {'2026-08-01', '2026-08-02', '2026-08-03', '2026-08-04'};
      final rate = AppDateUtils.calculateCompletionRate(
        keys,
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 4),
      );
      expect(rate, 1.0);
    });

    test('calculates 50% when half days in range are checked', () {
      final keys = {'2026-08-01', '2026-08-03'};
      final rate = AppDateUtils.calculateCompletionRate(
        keys,
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 4),
      );
      expect(rate, 0.5);
    });

    test('returns 0% when no days in range are checked', () {
      final keys = {'2026-07-01'};
      final rate = AppDateUtils.calculateCompletionRate(
        keys,
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 10),
      );
      expect(rate, 0.0);
    });
  });
}
