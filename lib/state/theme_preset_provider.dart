import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme_preset.dart';
import 'pro_entitlement_provider.dart';
import 'repository_provider.dart';

// -----------------------------------------------------------------------------
// 1. Active Theme Preset Provider
// -----------------------------------------------------------------------------
class ThemePresetNotifier extends Notifier<AppThemePreset> {
  @override
  AppThemePreset build() {
    _load();
    return AppThemePreset.obsidian; // Default to Obsidian Dark
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final val = await repo.getSetting('theme_preset');
    if (val != null) {
      for (final preset in AppThemePreset.values) {
        if (preset.name == val) {
          state = preset;
          break;
        }
      }
    }
  }

  void setPreset(AppThemePreset preset) {
    state = preset;
    ref.read(habitRepositoryProvider).saveSetting('theme_preset', preset.name);
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
