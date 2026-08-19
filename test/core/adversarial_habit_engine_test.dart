import 'package:flutter_test/flutter_test.dart';
import 'package:streakbox/core/utils/date_utils.dart';

void main() {
  group('Adversarial Streak Engine Tests', () {
    final today = DateTime(2026, 8, 19); // Wednesday

    test('TC-STR-01: Single check-in today produces streak = 1', () {
      final entries = {'2026-08-19'};
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 1);
      expect(AppDateUtils.calculateBestStreak(entries), 1);
    });

    test('TC-STR-02: Checked yesterday but today is still pending produces streak = 1', () {
      final entries = {'2026-08-18'};
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 1);
      expect(AppDateUtils.calculateBestStreak(entries), 1);
    });

    test('TC-STR-03: Multi-day unbroken sequence ending today calculates accurately', () {
      final entries = {
        '2026-08-15',
        '2026-08-16',
        '2026-08-17',
        '2026-08-18',
        '2026-08-19',
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 5);
      expect(AppDateUtils.calculateBestStreak(entries), 5);
    });

    test('TC-STR-04: Missed yesterday resets current streak to 0 if today is uncompleted', () {
      final entries = {
        '2026-08-15',
        '2026-08-16',
        '2026-08-17',
        // Missed 2026-08-18 (yesterday)
        // Today 2026-08-19 open
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 0);
      expect(AppDateUtils.calculateBestStreak(entries), 3);
    });

    test('TC-STR-05: Month boundary transition preserves continuous streak (e.g. Jul 30 - Aug 2)', () {
      final aug2 = DateTime(2026, 8, 2);
      final entries = {
        '2026-07-30',
        '2026-07-31',
        '2026-08-01',
        '2026-08-02',
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: aug2), 4);
      expect(AppDateUtils.calculateBestStreak(entries), 4);
    });

    test('TC-STR-06: Year boundary transition preserves streak (e.g. Dec 30 2025 - Jan 2 2026)', () {
      final jan2 = DateTime(2026, 1, 2);
      final entries = {
        '2025-12-30',
        '2025-12-31',
        '2026-01-01',
        '2026-01-02',
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: jan2), 4);
      expect(AppDateUtils.calculateBestStreak(entries), 4);
    });

    test('TC-STR-07: Leap year leap day boundary preserves streak (e.g. Feb 28 - Mar 1 2024)', () {
      final mar1 = DateTime(2024, 3, 1);
      final entries = {
        '2024-02-28',
        '2024-02-29', // Leap day
        '2024-03-01',
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: mar1), 3);
      expect(AppDateUtils.calculateBestStreak(entries), 3);
    });

    test('TC-STR-08: Future date entries do not artificially inflate streak today', () {
      final entries = {
        '2026-08-18', // Yesterday
        '2026-08-19', // Today
        '2026-08-25', // Erroneous / Future check-in
      };
      expect(AppDateUtils.calculateCurrentStreak(entries, today: today), 2);
    });
  });

  group('Adversarial Scheduled Opportunity Consistency Tests', () {
    final today = DateTime(2026, 8, 19);

    test('TC-CON-01: Daily habit evaluates 100% for all scheduled days completed', () {
      final habitCreated = today.subtract(const Duration(days: 9)); // 10 days total
      final entries = {
        for (int i = 0; i < 10; i++)
          AppDateUtils.formatDateKey(habitCreated.add(Duration(days: i)))
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
        habitCreatedAt: habitCreated,
        windowDays: 30,
      );

      expect(metrics.totalDays, 10);
      expect(metrics.completedDays, 10);
      expect(metrics.percentage, 100.0);
      expect(metrics.gradeLabel, 'LEGENDARY');
    });

    test('TC-CON-02: Habit created 3 days ago does NOT penalize 27 uncreated days of 30D window', () {
      final habitCreated = today.subtract(const Duration(days: 2)); // 3 days total: Aug 17, 18, 19
      final entries = {'2026-08-17', '2026-08-18', '2026-08-19'};

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
        habitCreatedAt: habitCreated,
        windowDays: 30,
      );

      expect(metrics.totalDays, 3);
      expect(metrics.completedDays, 3);
      expect(metrics.percentage, 100.0);
    });

    test('TC-CON-03: Specific weekday schedule (Mon, Wed, Fri) only counts MWF days in window', () {
      // 14 days window = exactly 2 weeks = 6 scheduled MWF opportunity days
      final windowStart = today.subtract(const Duration(days: 13));
      final mwf = [1, 3, 5]; // Mon, Wed, Fri

      // Completed 4 out of 6 MWF days
      final entries = {
        '2026-08-07', // Fri
        '2026-08-10', // Mon
        '2026-08-12', // Wed
        '2026-08-14', // Fri
        // Missed Mon Aug 17, Wed Aug 19
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
        habitCreatedAt: windowStart,
        windowDays: 14,
        targetDaysOfWeek: mwf,
      );

      expect(metrics.totalDays, 6);
      expect(metrics.completedDays, 4);
      expect(metrics.percentage, closeTo(66.66, 0.1));
      expect(metrics.gradeLabel, 'STEADY');
    });
  });

  group('Adversarial Recovery Protocol Tests', () {
    final today = DateTime(2026, 8, 19);

    test('TC-REC-01: Recovery protocol activates when yesterday is missed and today is open', () {
      final entries = {
        '2026-08-16',
        '2026-08-17',
        // Missed 2026-08-18 (yesterday)
        // Today 2026-08-19 open
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
      );

      expect(metrics.isRecoveryModeActive, isTrue);
      expect(metrics.isYesterdayCompleted, isFalse);
      expect(metrics.isTodayCompleted, isFalse);
    });

    test('TC-REC-02: Recovery protocol clears immediately once user completes today', () {
      final entries = {
        '2026-08-16',
        '2026-08-17',
        // Missed 2026-08-18 (yesterday)
        '2026-08-19', // Checked today!
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
      );

      expect(metrics.isTodayCompleted, isTrue);
      expect(metrics.isRecoveryModeActive, isFalse);
    });

    test('TC-REC-03: Recovery protocol is inactive if yesterday was completed and today is pending', () {
      final entries = {
        '2026-08-17',
        '2026-08-18', // Yesterday completed
        // Today 2026-08-19 pending
      };

      final metrics = AppDateUtils.calculateConsistencyMetrics(
        entries,
        today: today,
      );

      expect(metrics.isYesterdayCompleted, isTrue);
      expect(metrics.isRecoveryModeActive, isFalse);
    });
  });
}
