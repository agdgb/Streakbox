import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme_preset.dart';
import 'state/theme_preset_provider.dart';

/// Root application widget for Streakbox with dynamic preset theming.
class StreakboxApp extends ConsumerWidget {
  const StreakboxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themePreset = ref.watch(themePresetProvider);

    return MaterialApp.router(
      title: 'Streakbox',
      debugShowCheckedModeBanner: false,
      theme: themePreset.toThemeData(),
      darkTheme: themePreset.toThemeData(),
      themeMode: themePreset.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
