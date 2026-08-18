import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../data/models/habit.dart';

/// Available social card formats.
enum ShareAspectRatio {
  story,  // 9:16 Instagram Story / WhatsApp Status
  square, // 1:1 Square Post (Twitter / Feed)
}

/// Available celebration themes for share cards.
enum ShareCardType {
  streakMilestone,
  matrixHeatmap,
  achievementBadge,
}

/// High-res, ultra-aesthetic social celebration card rendered for RepaintBoundary.
class SocialShareCardWidget extends StatelessWidget {
  final Habit habit;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final Set<String> checkedDates;
  final AppThemePreset themePreset;
  final ShareAspectRatio aspectRatio;
  final ShareCardType cardType;
  final bool isProUser;

  const SocialShareCardWidget({
    super.key,
    required this.habit,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompletions,
    required this.checkedDates,
    required this.themePreset,
    this.aspectRatio = ShareAspectRatio.story,
    this.cardType = ShareCardType.streakMilestone,
    this.isProUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isStory = aspectRatio == ShareAspectRatio.story;
    final isDark = themePreset.isDark;
    final primaryAccent = themePreset.primaryColor;
    final habitColor = habit.colorValue == 0xFF10B981 ? primaryAccent : habit.color;

    return AspectRatio(
      aspectRatio: isStory ? 9 / 16 : 1.0,
      child: Container(
        padding: EdgeInsets.all(isStory ? 28 : 20),
        decoration: BoxDecoration(
          color: themePreset.backgroundColor,
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.4,
            colors: [
              primaryAccent.withValues(alpha: isDark ? 0.18 : 0.12),
              themePreset.backgroundColor,
            ],
          ),
          borderRadius: BorderRadius.circular(isStory ? 32 : 24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.lightBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header: App Logo & Pro Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: themePreset.activePillGradient ??
                            LinearGradient(colors: [primaryAccent, primaryAccent]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'STREAKBOX',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: themePreset.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                if (isProUser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 11, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'VERIFIED PRO',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Main Body based on Card Type
            Expanded(
              child: Center(
                child: _buildCardContent(context, isStory, isDark, primaryAccent, habitColor),
              ),
            ),

            // Footer: Tagline & Motivation
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Text(
                        'Consistency is my superpower',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: themePreset.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'streakbox.app',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: themePreset.textSecondaryColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    bool isStory,
    bool isDark,
    Color primaryAccent,
    Color habitColor,
  ) {
    switch (cardType) {
      case ShareCardType.streakMilestone:
        return _buildStreakContent(isStory, isDark, primaryAccent, habitColor);
      case ShareCardType.matrixHeatmap:
        return _buildMatrixContent(isStory, isDark, primaryAccent, habitColor);
      case ShareCardType.achievementBadge:
        return _buildBadgeContent(isStory, isDark, primaryAccent, habitColor);
    }
  }

  // ---------------------------------------------------------------------------
  // 1. Streak Flame Celebration Content
  // ---------------------------------------------------------------------------
  Widget _buildStreakContent(
    bool isStory,
    bool isDark,
    Color primaryAccent,
    Color habitColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing Habit Icon Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: habitColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: habitColor.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.getHabitIcon(habit.iconCodePoint), size: 18, color: habitColor),
              const SizedBox(width: 8),
              Text(
                habit.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: habitColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isStory ? 24 : 14),

        // Glowing Flame Icon
        Container(
          padding: EdgeInsets.all(isStory ? 20 : 14),
          decoration: BoxDecoration(
            gradient: themePreset.activePillGradient ??
                const LinearGradient(
                  colors: [Color(0xFFFF4B72), Color(0xFFFF884B)],
                ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (themePreset.activePillGradient != null
                        ? primaryAccent
                        : const Color(0xFFFF4B72))
                    .withValues(alpha: 0.5),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.local_fire_department_rounded,
            size: isStory ? 48 : 36,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isStory ? 16 : 10),

        // Big Streak Number
        Text(
          '$currentStreak',
          style: TextStyle(
            fontSize: isStory ? 68 : 52,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.0,
            height: 1.0,
            color: themePreset.textPrimaryColor,
          ),
        ),
        Text(
          currentStreak == 1 ? 'DAY STREAK' : 'DAYS STREAK',
          style: TextStyle(
            fontSize: isStory ? 16 : 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            color: primaryAccent,
          ),
        ),
        SizedBox(height: isStory ? 20 : 12),

        // Best Streak & Total Check-ins Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMiniMetric('BEST STREAK', '$bestStreak Days', Icons.emoji_events_rounded, primaryAccent),
            const SizedBox(width: 16),
            _buildMiniMetric('TOTAL DONE', '$totalCompletions Days', Icons.task_alt_rounded, const Color(0xFF10B981)),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. 12-Month Matrix Content
  // ---------------------------------------------------------------------------
  Widget _buildMatrixContent(
    bool isStory,
    bool isDark,
    Color primaryAccent,
    Color habitColor,
  ) {
    final now = DateTime.now();
    final daysInPastYear = 365;
    final startDate = now.subtract(Duration(days: daysInPastYear - 1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          habit.name,
          style: TextStyle(
            fontSize: isStory ? 20 : 16,
            fontWeight: FontWeight.w900,
            color: themePreset.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '12-MONTH CONSISTENCY MATRIX',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: primaryAccent,
          ),
        ),
        SizedBox(height: isStory ? 20 : 12),

        // Mini Matrix Grid (52 weeks x 7 days)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1F26) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.lightBorder,
            ),
          ),
          child: SizedBox(
            height: isStory ? 140 : 100,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: 364,
              itemBuilder: (context, index) {
                final cellDate = startDate.add(Duration(days: index));
                final key = '${cellDate.year}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}';
                final isDone = checkedDates.contains(key);

                return Container(
                  decoration: BoxDecoration(
                    color: isDone
                        ? habitColor
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: isStory ? 20 : 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMiniMetric('COMPLETED', '$totalCompletions Days', Icons.check_circle_rounded, habitColor),
            const SizedBox(width: 16),
            _buildMiniMetric('CONSISTENCY', '${((totalCompletions / 365) * 100).toStringAsFixed(1)}%', Icons.pie_chart_rounded, primaryAccent),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Achievement Badge Content
  // ---------------------------------------------------------------------------
  Widget _buildBadgeContent(
    bool isStory,
    bool isDark,
    Color primaryAccent,
    Color habitColor,
  ) {
    String milestoneTitle = '7-Day Explorer';
    if (currentStreak >= 100) {
      milestoneTitle = '100-Day Centurion';
    } else if (currentStreak >= 30) {
      milestoneTitle = '30-Day Master';
    } else if (currentStreak >= 21) {
      milestoneTitle = '21-Day Habit Former';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isStory ? 24 : 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.military_tech_rounded,
            size: isStory ? 54 : 40,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isStory ? 18 : 10),

        Text(
          'MILESTONE UNLOCKED',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          milestoneTitle,
          style: TextStyle(
            fontSize: isStory ? 26 : 20,
            fontWeight: FontWeight.w900,
            color: themePreset.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'for habit "${habit.name}"',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: themePreset.textSecondaryColor,
          ),
        ),
        SizedBox(height: isStory ? 20 : 12),

        _buildMiniMetric('CURRENT STREAK', '$currentStreak Days', Icons.local_fire_department_rounded, const Color(0xFFFF4B72)),
      ],
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: themePreset.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themePreset.borderColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: themePreset.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: themePreset.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
