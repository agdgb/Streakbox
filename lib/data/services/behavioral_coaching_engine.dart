import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../../core/utils/date_utils.dart';

/// Categories of behavioral psychology nudges (Red-Team Attacks #1 & #12).
enum BehavioralNudgeType {
  lossAversion,
  neverMissTwice,
  milestoneCountdown,
  morningIntention,
  eveningCloser,
  momentumPraise,
}

/// Structured behavioral nudge content.
class BehavioralNudge {
  final BehavioralNudgeType type;
  final String title;
  final String message;
  final String actionableButtonLabel;
  final IconData icon;
  final Color accentColor;

  const BehavioralNudge({
    required this.type,
    required this.title,
    required this.message,
    required this.actionableButtonLabel,
    required this.icon,
    required this.accentColor,
  });
}

/// Intelligent Behavioral Psychology Coaching Engine.
/// Generates non-generic, high-converting nudges based on user habit state.
class BehavioralCoachingEngine {
  BehavioralCoachingEngine._();

  static BehavioralNudge? evaluate({
    required Habit? habit,
    required int currentStreak,
    required int bestStreak,
    required ConsistencyMetrics consistency,
    DateTime? now,
  }) {
    if (habit == null) return null;

    final currentTime = now ?? DateTime.now();
    final hour = currentTime.hour;

    // 1. Recovery Protocol: "Never Miss Twice" (Highest priority if yesterday missed)
    if (consistency.isRecoveryModeActive && !consistency.isTodayCompleted) {
      return const BehavioralNudge(
        type: BehavioralNudgeType.neverMissTwice,
        title: '🛡️ NEVER MISS TWICE PROTOCOL',
        message:
            'Yesterday slipped by. James Clear Rule: A missed day is an accident; two in a row is the start of a new habit. Complete today to stay on track!',
        actionableButtonLabel: 'Reclaim Momentum Today',
        icon: Icons.shield_rounded,
        accentColor: Color(0xFFF59E0B),
      );
    }

    // 2. Evening Closer: Loss Aversion (If today is uncompleted after 18:00 and streak >= 3)
    if (!consistency.isTodayCompleted && hour >= 18 && currentStreak >= 3) {
      return BehavioralNudge(
        type: BehavioralNudgeType.lossAversion,
        title: '🔥 PROTECT YOUR $currentStreak-DAY STREAK',
        message:
            'You have built serious momentum for "${habit.name}". Do not let it reset at midnight!',
        actionableButtonLabel: 'Check In & Save Streak',
        icon: Icons.local_fire_department_rounded,
        accentColor: const Color(0xFFFF4B72),
      );
    }

    // 3. Milestone Countdown: Near a milestone (e.g. 6/7, 13/14, 20/21, 29/30, 99/100)
    final nextMilestone = _calculateNextMilestone(currentStreak);
    if (nextMilestone != null && (nextMilestone - currentStreak) <= 2 && currentStreak > 0) {
      final daysLeft = nextMilestone - currentStreak;
      return BehavioralNudge(
        type: BehavioralNudgeType.milestoneCountdown,
        title: '⚡ $nextMilestone-DAY MILESTONE IN SIGHT',
        message:
            'Just $daysLeft ${daysLeft == 1 ? "day" : "days"} away from unlocking the $nextMilestone-Day Milestone Badge. Stay relentless!',
        actionableButtonLabel: 'Lock In Today',
        icon: Icons.emoji_events_rounded,
        accentColor: const Color(0xFF10B981),
      );
    }

    // 4. Morning Intention Trigger (06:00 - 11:00)
    if (!consistency.isTodayCompleted && hour >= 6 && hour < 12) {
      return BehavioralNudge(
        type: BehavioralNudgeType.morningIntention,
        title: '🌅 MORNING MOMENTUM ANCHOR',
        message:
            'Win the morning, win the day. Complete "${habit.name}" early to trigger Day-long momentum.',
        actionableButtonLabel: 'Complete Morning Check-In',
        icon: Icons.wb_sunny_rounded,
        accentColor: const Color(0xFF00D2FF),
      );
    }

    // 5. Momentum Praise (If today is already completed!)
    if (consistency.isTodayCompleted) {
      return BehavioralNudge(
        type: BehavioralNudgeType.momentumPraise,
        title: '💪 MOMENTUM LOCKED FOR TODAY',
        message:
            'Great execution! Your consistency score is sitting strong at ${consistency.formattedPercentage} (${consistency.gradeLabel}).',
        actionableButtonLabel: 'View Rhythm Analytics',
        icon: Icons.check_circle_rounded,
        accentColor: const Color(0xFF10B981),
      );
    }

    return null;
  }

  static int? _calculateNextMilestone(int currentStreak) {
    const milestones = [7, 14, 21, 30, 50, 75, 100, 150, 200, 365];
    for (final m in milestones) {
      if (currentStreak < m) return m;
    }
    return null;
  }
}
