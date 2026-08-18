import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/habit.dart';
import '../../state/habit_providers.dart';
import '../../state/settings_provider.dart';
import '../../state/theme_preset_provider.dart';

/// Preset habit template for quick 1-tap onboarding selection.
class StarterHabitTemplate {
  final String title;
  final String category;
  final int iconCodePoint;
  final Color color;
  final String defaultTime;

  const StarterHabitTemplate({
    required this.title,
    required this.category,
    required this.iconCodePoint,
    required this.color,
    required this.defaultTime,
  });
}

const List<StarterHabitTemplate> kStarterHabits = [
  StarterHabitTemplate(
    title: '20-Min Workout',
    category: 'FITNESS',
    iconCodePoint: 0xe25a, // fitness_center
    color: Color(0xFFFF4B72),
    defaultTime: 'Morning 🌅',
  ),
  StarterHabitTemplate(
    title: 'Read 10 Pages',
    category: 'MIND',
    iconCodePoint: 0xe3e0, // menu_book
    color: Color(0xFF00D2FF),
    defaultTime: 'Evening 🌙',
  ),
  StarterHabitTemplate(
    title: 'Drink 2L Water',
    category: 'HEALTH',
    iconCodePoint: 0xe6e8, // water_drop
    color: Color(0xFF3B82F6),
    defaultTime: 'All Day 💧',
  ),
  StarterHabitTemplate(
    title: '10-Min Meditation',
    category: 'MINDFULNESS',
    iconCodePoint: 0xe5aa, // self_improvement
    color: Color(0xFFA855F7),
    defaultTime: 'Morning 🌅',
  ),
  StarterHabitTemplate(
    title: 'Daily Gratitude',
    category: 'SELF-CARE',
    iconCodePoint: 0xe156, // create / edit_note
    color: Color(0xFF10B981),
    defaultTime: 'Evening 🌙',
  ),
  StarterHabitTemplate(
    title: 'Deep Work Block',
    category: 'FOCUS',
    iconCodePoint: 0xe1d6, // laptop / computer
    color: Color(0xFFF59E0B),
    defaultTime: 'Morning 🌅',
  ),
];

/// 30-Second Fast-Track Onboarding & First-Launch Experience.
/// Solves the Cold Start Problem (Red-Team Attack #9) by delivering Day 1 Dopamine immediately.
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.onFinish,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0; // 0: Select Habit, 1: Set Anchor, 2: Day 1 Check-In
  StarterHabitTemplate _selectedTemplate = kStarterHabits.first;
  late TextEditingController _nameController;
  String _selectedAnchorTime = 'Morning 🌅';
  bool _isDayOneChecked = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _selectedTemplate.title);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectTemplate(StarterHabitTemplate template) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTemplate = template;
      _nameController.text = template.title;
      _selectedAnchorTime = template.defaultTime;
      _currentStep = 1;
    });
  }

  Future<void> _completeDayOneCheckIn() async {
    if (_isDayOneChecked || _isCreating) return;
    setState(() => _isCreating = true);

    try {
      HapticFeedback.heavyImpact();
      final habitId = DateTime.now().millisecondsSinceEpoch.toString();
      final habit = Habit(
        id: habitId,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : _selectedTemplate.title,
        colorValue: _selectedTemplate.color.toARGB32(),
        iconCodePoint: _selectedTemplate.iconCodePoint,
        createdAt: DateTime.now(),
        frequencyType: HabitFrequencyType.daily,
      );

      // Save habit to SQLite database
      await ref.read(habitsProvider.notifier).addHabit(habit);
      ref.read(selectedHabitIdProvider.notifier).select(habit.id);

      // Toggle Today's entry for instant streak ignition
      final todayKey = AppDateUtils.formatDateKey(DateTime.now());
      await ref.read(selectedHabitEntriesProvider.notifier).toggleEntry(todayKey);

      setState(() {
        _isDayOneChecked = true;
        _isCreating = false;
      });
    } catch (e) {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;

    return Scaffold(
      backgroundColor: themePreset.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar & Progress Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: themePreset.activePillGradient ??
                              LinearGradient(colors: [themePreset.primaryColor, themePreset.primaryColor]),
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
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index <= _currentStep;
                      return Container(
                        margin: const EdgeInsets.only(left: 6),
                        width: index == _currentStep ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? themePreset.primaryColor
                              : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: AnimatedSwitcher(
                duration: 300.ms,
                child: _buildCurrentStepView(context, isDark, themePreset),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(BuildContext context, bool isDark, AppThemePreset themePreset) {
    switch (_currentStep) {
      case 0:
        return _buildStep1SelectHabit(context, isDark, themePreset);
      case 1:
        return _buildStep2AnchorRhythm(context, isDark, themePreset);
      case 2:
      default:
        return _buildStep3DayOneIgnition(context, isDark, themePreset);
    }
  }

  // ---------------------------------------------------------------------------
  // Step 1: Choose Starter Habit
  // ---------------------------------------------------------------------------
  Widget _buildStep1SelectHabit(BuildContext context, bool isDark, AppThemePreset themePreset) {
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      children: [
        Text(
          'What habit do you want\nto master first?',
          style: AppTextStyles.displayLarge(context).copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick one foundational habit. Consistency beats intensity every single time.',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: themePreset.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 24),

        // Starter Cards Grid
        ...kStarterHabits.map((template) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1F26) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _selectTemplate(template),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: template.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          AppIcons.getHabitIcon(template.iconCodePoint),
                          color: template.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: template.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              template.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: themePreset.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: themePreset.textSecondaryColor.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Set Anchor Rhythm
  // ---------------------------------------------------------------------------
  Widget _buildStep2AnchorRhythm(BuildContext context, bool isDark, AppThemePreset themePreset) {
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _currentStep = 0),
                icon: const Icon(Icons.arrow_back_rounded),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                'Customize & Anchor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: themePreset.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Anchor your habit rhythm',
            style: AppTextStyles.displayLarge(context).copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Habits stick when attached to a specific time of day.',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: themePreset.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Name Input
          Text(
            'HABIT NAME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: themePreset.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: themePreset.textPrimaryColor,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF1B1F26) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightBorder,
                ),
              ),
              prefixIcon: Icon(
                AppIcons.getHabitIcon(_selectedTemplate.iconCodePoint),
                color: _selectedTemplate.color,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Anchor Time Segment
          Text(
            'WHEN WILL YOU DO THIS?',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: themePreset.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Morning 🌅', 'Afternoon ☀️', 'Evening 🌙'].map((time) {
              final isSelected = _selectedAnchorTime == time;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedAnchorTime = time);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedTemplate.color.withValues(alpha: 0.15)
                            : (isDark ? const Color(0xFF1B1F26) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _selectedTemplate.color
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? _selectedTemplate.color : themePreset.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _currentStep = 2);
              },
              style: FilledButton.styleFrom(
                backgroundColor: themePreset.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Continue to Day 1 Check-In ➔',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Day 1 Dopamine Ignition
  // ---------------------------------------------------------------------------
  Widget _buildStep3DayOneIgnition(BuildContext context, bool isDark, AppThemePreset themePreset) {
    return Padding(
      key: const ValueKey(2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Celebration Icon Hero
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: _isDayOneChecked
                  ? const LinearGradient(colors: [Color(0xFFFF4B72), Color(0xFFFF884B)])
                  : LinearGradient(colors: [_selectedTemplate.color, _selectedTemplate.color.withValues(alpha: 0.7)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isDayOneChecked ? const Color(0xFFFF4B72) : _selectedTemplate.color)
                      .withValues(alpha: 0.5),
                  blurRadius: 36,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              _isDayOneChecked ? Icons.local_fire_department_rounded : Icons.check_circle_outline_rounded,
              size: 56,
              color: Colors.white,
            ),
          ).animate(target: _isDayOneChecked ? 1 : 0).scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          Text(
            _isDayOneChecked ? '🔥 Day 1 Streak Started!' : 'Ready for Day 1?',
            style: AppTextStyles.displayLarge(context).copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isDayOneChecked
                ? 'Your journey for "${_nameController.text}" begins right now. Tomorrow, protect your streak!'
                : 'Complete your very first check-in today to ignite your streak momentum.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: themePreset.textSecondaryColor,
            ),
          ),

          const Spacer(),

          // Check-In / Finish Action
          if (!_isDayOneChecked)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _completeDayOneCheckIn,
                icon: const Icon(Icons.touch_app_rounded, color: Colors.black),
                label: const Text(
                  'Tap to Complete Day 1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedTemplate.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
                  widget.onFinish();
                },
                icon: const Icon(Icons.rocket_launch_rounded, color: Colors.black),
                label: const Text(
                  'Enter My Habit Vault 🚀',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ).animate().fadeIn().scale(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
