import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme_preset.dart';
import 'pro_entitlement_provider.dart';

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
// 2. Pro Trial State Delegator (bridges to ProEntitlementProvider)
// -----------------------------------------------------------------------------
final proTrialProvider = Provider<ProTierState>((ref) {
  return ref.watch(proEntitlementProvider);
});
