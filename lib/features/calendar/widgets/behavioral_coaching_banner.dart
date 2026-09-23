import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_preset.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/services/behavioral_coaching_engine.dart';
import '../../../state/habit_providers.dart';
import '../../../state/theme_preset_provider.dart';

/// Dynamic behavioral psychology coaching banner (Red-Team Attacks #1 & #12).
class BehavioralCoachingBanner extends ConsumerWidget {
  const BehavioralCoachingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHabit = ref.watch(selectedHabitProvider);
    final currentStreak = ref.watch(currentStreakProvider);
    final bestStreak = ref.watch(bestStreakProvider);
    final consistency = ref.watch(consistencyMetricsProvider);
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;

    if (selectedHabit == null) return const SizedBox.shrink();

    final nudge = BehavioralCoachingEngine.evaluate(
      habit: selectedHabit,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      consistency: consistency,
    );

    if (nudge == null) return const SizedBox.shrink();

    final todayKey = AppDateUtils.formatDateKey(DateTime.now());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? nudge.accentColor.withValues(alpha: 0.12)
            : nudge.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: nudge.accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: nudge.accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  nudge.icon,
                  size: 16,
                  color: nudge.accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nudge.title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: nudge.accentColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nudge.message,
                      style: AppTextStyles.caption(context).copyWith(
                        color: themePreset.textSecondaryColor,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!consistency.isTodayCompleted) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  await ref
                      .read(selectedHabitEntriesProvider.notifier)
                      .toggleEntry(todayKey);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: nudge.accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          nudge.actionableButtonLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
