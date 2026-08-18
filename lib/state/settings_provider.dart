import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  solidFill,   // Optional: Saturated solid habit color background
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
    return ThemeMode.dark; // Default to Obsidian Dark theme
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
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
    return CalendarFillStyle.pureMinimal; // Default to Pure Minimalist
  }

  void setStyle(CalendarFillStyle style) {
    state = style;
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
    return DateTime.monday; // Default Monday start
  }

  void setFirstDay(int weekday) {
    state = weekday;
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
    return '✔️'; // Clear Green Checkmark out of the box!
  }

  void setSymbol(String symbol) {
    state = symbol;
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
    return false; // Default: Single tap to mark
  }

  void setDoubleTapRequired(bool required) {
    state = required;
  }

  void toggle() {
    state = !state;
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
    return TodayIndicatorStyle.ringBorder; // Default: Crisp White Ring Border
  }

  void setStyle(TodayIndicatorStyle style) {
    state = style;
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
    return false;
  }

  void completeOnboarding() {
    state = true;
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
  OnboardingCompletedNotifier.new,
);

