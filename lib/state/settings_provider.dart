import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repository_provider.dart';

/// Supported emoji picker modes in Streakbox.
enum EmojiPickerStyle {
  curated,
  fullKeyboard,
}

/// Visual styles for identifying Today's date when marked/completed.
enum TodayIndicatorStyle {
  ringBorder,
  cornerDot,
  ambientPulse,
  numberUnderline,
}

/// Visual theme style for checked calendar cells.
enum CalendarFillStyle {
  pureMinimal, // Default: Pure clean dark/light theme background with crisp symbol
  solidFill, // Optional: Saturated solid habit color background
}

/// Supported checkmark / celebration symbols for single-tap marking.
class AppCheckmarkSymbols {
  AppCheckmarkSymbols._();

  static const List<String> available = [
    '✓',
    '✅',
    '❌',
    '🔥',
    '⭐',
    '✔️',
    '💯',
    '💪',
    '🎯',
  ];
}

// -----------------------------------------------------------------------------
// 1. Theme Mode Setting
// -----------------------------------------------------------------------------
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.dark; // Default to Obsidian Dark theme
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSetting('theme_mode');
    if (val != null) {
      switch (val) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'system':
          state = ThemeMode.system;
          break;
        default:
          state = ThemeMode.dark;
      }
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final strVal = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.system
            ? 'system'
            : 'dark';
    ref.read(habitRepositoryProvider).saveSetting('theme_mode', strVal);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// -----------------------------------------------------------------------------
// 2. Calendar Fill Style Setting (Pure Minimal vs Solid Fill)
// -----------------------------------------------------------------------------
class CalendarFillStyleNotifier extends Notifier<CalendarFillStyle> {
  @override
  CalendarFillStyle build() {
    _load();
    return CalendarFillStyle.pureMinimal; // Default to Pure Minimalist
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSetting('calendar_fill_style');
    if (val == 'solidFill') {
      state = CalendarFillStyle.solidFill;
    } else if (val == 'pureMinimal') {
      state = CalendarFillStyle.pureMinimal;
    }
  }

  void setStyle(CalendarFillStyle style) {
    state = style;
    ref.read(habitRepositoryProvider).saveSetting(
          'calendar_fill_style',
          style == CalendarFillStyle.solidFill ? 'solidFill' : 'pureMinimal',
        );
  }
}

final calendarFillStyleProvider =
    NotifierProvider<CalendarFillStyleNotifier, CalendarFillStyle>(
  CalendarFillStyleNotifier.new,
);

// -----------------------------------------------------------------------------
// 3. First Day of Week Setting (Monday = 1, Sunday = 7, Saturday = 6)
// -----------------------------------------------------------------------------
class FirstDayOfWeekNotifier extends Notifier<int> {
  @override
  int build() {
    _load();
    return DateTime.monday; // Default Monday start
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSettingInt('first_day_of_week');
    if (val != null && val >= 1 && val <= 7) {
      state = val;
    }
  }

  void setFirstDay(int weekday) {
    state = weekday;
    ref
        .read(habitRepositoryProvider)
        .saveSettingInt('first_day_of_week', weekday);
  }
}

final firstDayOfWeekProvider = NotifierProvider<FirstDayOfWeekNotifier, int>(
  FirstDayOfWeekNotifier.new,
);

// -----------------------------------------------------------------------------
// 4. Default Checkmark Symbol Setting
// -----------------------------------------------------------------------------
class DefaultCheckMarkNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return '✔️'; // Clear Green Checkmark out of the box!
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSetting('default_checkmark');
    if (val != null && val.isNotEmpty) {
      state = val;
    }
  }

  void setSymbol(String symbol) {
    state = symbol;
    ref.read(habitRepositoryProvider).saveSetting('default_checkmark', symbol);
  }
}

final defaultCheckMarkProvider =
    NotifierProvider<DefaultCheckMarkNotifier, String>(
  DefaultCheckMarkNotifier.new,
);

// -----------------------------------------------------------------------------
// 5. Tap Protection (Require Double-Tap to Mark) Setting
// -----------------------------------------------------------------------------
class TapProtectionNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false; // Default: Single tap to mark
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSettingBool('tap_protection');
    if (val != null) {
      state = val;
    }
  }

  void setDoubleTapRequired(bool required) {
    state = required;
    ref
        .read(habitRepositoryProvider)
        .saveSettingBool('tap_protection', required);
  }

  void toggle() {
    setDoubleTapRequired(!state);
  }
}

final tapProtectionProvider = NotifierProvider<TapProtectionNotifier, bool>(
  TapProtectionNotifier.new,
);

// -----------------------------------------------------------------------------
// 6. Today Highlight Indicator Style Setting (When Marked)
// -----------------------------------------------------------------------------
class TodayIndicatorStyleNotifier extends Notifier<TodayIndicatorStyle> {
  @override
  TodayIndicatorStyle build() {
    _load();
    return TodayIndicatorStyle.ringBorder; // Default: Crisp White Ring Border
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSetting('today_indicator_style');
    if (val != null) {
      for (final style in TodayIndicatorStyle.values) {
        if (style.name == val) {
          state = style;
          break;
        }
      }
    }
  }

  void setStyle(TodayIndicatorStyle style) {
    state = style;
    ref
        .read(habitRepositoryProvider)
        .saveSetting('today_indicator_style', style.name);
  }
}

final todayIndicatorStyleProvider =
    NotifierProvider<TodayIndicatorStyleNotifier, TodayIndicatorStyle>(
  TodayIndicatorStyleNotifier.new,
);

// -----------------------------------------------------------------------------
// 7. Emoji Picker Style Setting
// -----------------------------------------------------------------------------
class EmojiPickerStyleNotifier extends Notifier<EmojiPickerStyle> {
  @override
  EmojiPickerStyle build() {
    return EmojiPickerStyle.fullKeyboard;
  }

  void setStyle(EmojiPickerStyle style) {
    state = style;
  }

  void toggleStyle() {
    state = state == EmojiPickerStyle.curated
        ? EmojiPickerStyle.fullKeyboard
        : EmojiPickerStyle.curated;
  }
}

final emojiPickerStyleProvider =
    NotifierProvider<EmojiPickerStyleNotifier, EmojiPickerStyle>(
  EmojiPickerStyleNotifier.new,
);

// -----------------------------------------------------------------------------
// 8. First-Launch Onboarding Completed Setting
// -----------------------------------------------------------------------------
class OnboardingCompletedNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSettingBool('onboarding_completed');
    if (val != null) {
      state = val;
    }
  }

  void completeOnboarding() {
    state = true;
    ref
        .read(habitRepositoryProvider)
        .saveSettingBool('onboarding_completed', true);
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
  OnboardingCompletedNotifier.new,
);
