import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme_preset.dart';

// -----------------------------------------------------------------------------
// 1. Active Theme Preset Provider
// -----------------------------------------------------------------------------
class ThemePresetNotifier extends Notifier<AppThemePreset> {
  @override
  AppThemePreset build() {
    return AppThemePreset.obsidian; // Default to Obsidian Dark
  }

  void setPreset(AppThemePreset preset) {
    state = preset;
  }
}

final themePresetProvider =
    NotifierProvider<ThemePresetNotifier, AppThemePreset>(
  ThemePresetNotifier.new,
);

// -----------------------------------------------------------------------------
// 2. Pro 48-Hour Free Trial State Manager
// -----------------------------------------------------------------------------
class ProTrialState {
  final bool isProPermanentlyUnlocked;
  final DateTime? trialExpiry;

  const ProTrialState({
    this.isProPermanentlyUnlocked = false,
    this.trialExpiry,
  });

  bool get isTrialActive {
    if (trialExpiry == null) return false;
    return DateTime.now().isBefore(trialExpiry!);
  }

  bool get isProAccessGranted => isProPermanentlyUnlocked || isTrialActive;

  int get remainingTrialHours {
    if (trialExpiry == null) return 0;
    final diff = trialExpiry!.difference(DateTime.now());
    return diff.inHours.clamp(0, 48);
  }

  ProTrialState copyWith({
    bool? isProPermanentlyUnlocked,
    DateTime? trialExpiry,
  }) {
    return ProTrialState(
      isProPermanentlyUnlocked:
          isProPermanentlyUnlocked ?? this.isProPermanentlyUnlocked,
      trialExpiry: trialExpiry ?? this.trialExpiry,
    );
  }
}

class ProTrialNotifier extends Notifier<ProTrialState> {
  @override
  ProTrialState build() {
    return const ProTrialState();
  }

  /// Activates the 48-Hour Pro Free Trial immediately.
  void start48HourTrial() {
    final expiry = DateTime.now().add(const Duration(hours: 48));
    state = state.copyWith(trialExpiry: expiry);
  }

  /// Permanently unlocks Pro access.
  void unlockProPermanently() {
    state = state.copyWith(isProPermanentlyUnlocked: true);
  }
}

final proTrialProvider =
    NotifierProvider<ProTrialNotifier, ProTrialState>(
  ProTrialNotifier.new,
);
