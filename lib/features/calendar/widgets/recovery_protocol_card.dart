import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_preset.dart';
import '../../../core/utils/date_utils.dart';
import '../../../state/habit_providers.dart';
import '../../../state/theme_preset_provider.dart';

/// Empowering Anti-Churn Card triggered when yesterday was missed.
/// Implements James Clear's "Never Miss Twice" behavioral recovery rule.
class RecoveryProtocolCard extends ConsumerWidget {
  const RecoveryProtocolCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consistency = ref.watch(consistencyMetricsProvider);
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;

    if (!consistency.isRecoveryModeActive || consistency.isTodayCompleted) {
      return const SizedBox.shrink();
    }

    final todayKey = AppDateUtils.formatDateKey(DateTime.now());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.20 : 0.12),
            const Color(0xFFD97706).withValues(alpha: isDark ? 0.12 : 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'RECOVERY PROTOCOL',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEVER MISS TWICE',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Streaks pause, but consistency endures. Complete today to protect your ${consistency.formattedPercentage} rating!',
                      style: AppTextStyles.caption(context).copyWith(
                        color: themePreset.textSecondaryColor,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: FilledButton.icon(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await ref
                    .read(selectedHabitEntriesProvider.notifier)
                    .toggleEntry(todayKey);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Colors.black, size: 18),
                          SizedBox(width: 8),
                          Text(
                            '🔥 Recovery Complete! Momentum Reclaimed.',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                          ),
                        ],
                      ),
                      backgroundColor: Color(0xFFF59E0B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.black),
              label: const Text(
                'Complete Today & Reclaim Momentum',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}
