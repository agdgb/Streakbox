import 'package:flutter/material.dart';

/// Available curated aesthetic themes in Streakbox.
enum AppThemePreset {
  obsidian,
  paperLight,
  nordicNoir,
  emberSunset,
  cyberpunk,
}

extension AppThemePresetExtension on AppThemePreset {
  String get displayName {
    switch (this) {
      case AppThemePreset.obsidian:
        return 'Obsidian Dark';
      case AppThemePreset.paperLight:
        return 'Paper Clean';
      case AppThemePreset.nordicNoir:
        return 'Nordic Noir';
      case AppThemePreset.emberSunset:
        return 'Ember Sunset';
      case AppThemePreset.cyberpunk:
        return 'OLED Cyber';
    }
  }

  String get subtitle {
    switch (this) {
      case AppThemePreset.obsidian:
        return 'Deep Slate Minimalist';
      case AppThemePreset.paperLight:
        return 'Crisp Paper Daylight';
      case AppThemePreset.nordicNoir:
        return 'Tactile Slate & Cyan Glow';
      case AppThemePreset.emberSunset:
        return 'Velvet Matte & Coral Ember';
      case AppThemePreset.cyberpunk:
        return 'Neon Amber & Violet';
    }
  }

  bool get isPro {
    switch (this) {
      case AppThemePreset.obsidian:
      case AppThemePreset.paperLight:
        return false;
      case AppThemePreset.nordicNoir:
      case AppThemePreset.emberSunset:
      case AppThemePreset.cyberpunk:
        return true;
    }
  }

  bool get isNeumorphic {
    return this == AppThemePreset.nordicNoir ||
        this == AppThemePreset.emberSunset;
  }

  bool get isDark {
    return this != AppThemePreset.paperLight;
  }

  Color get backgroundColor {
    switch (this) {
      case AppThemePreset.obsidian:
        return const Color(0xFF0F1216);
      case AppThemePreset.paperLight:
        return const Color(0xFFF8FAFC);
      case AppThemePreset.nordicNoir:
        return const Color(0xFF1B1E24); // Matte Nordic Slate
      case AppThemePreset.emberSunset:
        return const Color(0xFF15171B); // Velvet Matte Charcoal
      case AppThemePreset.cyberpunk:
        return const Color(0xFF0B0D12);
    }
  }

  Color get surfaceColor {
    switch (this) {
      case AppThemePreset.obsidian:
        return const Color(0xFF171B22);
      case AppThemePreset.paperLight:
        return const Color(0xFFFFFFFF);
      case AppThemePreset.nordicNoir:
        return const Color(0xFF1F232A);
      case AppThemePreset.emberSunset:
        return const Color(0xFF181B20);
      case AppThemePreset.cyberpunk:
        return const Color(0xFF131720);
    }
  }

  Color get cardColor {
    switch (this) {
      case AppThemePreset.obsidian:
        return const Color(0xFF1F242D);
      case AppThemePreset.paperLight:
        return const Color(0xFFF1F5F9);
      case AppThemePreset.nordicNoir:
        return const Color(0xFF1F232A);
      case AppThemePreset.emberSunset:
        return const Color(0xFF191C22);
      case AppThemePreset.cyberpunk:
        return const Color(0xFF1B212D);
    }
  }

  Color get cardElevatedColor {
    switch (this) {
      case AppThemePreset.obsidian:
        return const Color(0xFF282F3B);
      case AppThemePreset.paperLight:
        return const Color(0xFFFFFFFF);
      case AppThemePreset.nordicNoir:
        return const Color(0xFF252A33);
      case AppThemePreset.emberSunset:
        return const Color(0xFF1E222A);
      case AppThemePreset.cyberpunk:
        return const Color(0xFF242C3D);
    }
  }

  Color get borderColor {
    switch (this) {
      case AppThemePreset.obsidian:
        return const Color(0xFF2B3340);
      case AppThemePreset.paperLight:
        return const Color(0xFFE2E8F0);
      case AppThemePreset.nordicNoir:
        return const Color(0xFF2A303C);
      case AppThemePreset.emberSunset:
        return const Color(0xFF242832);
      case AppThemePreset.cyberpunk:
        return const Color(0xFF2E384D);
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppThemePreset.obsidian:
      case AppThemePreset.paperLight:
        return const Color(0xFF10B981); // Emerald Green
      case AppThemePreset.nordicNoir:
        return const Color(0xFF00D2FF); // Electric Cyan
      case AppThemePreset.emberSunset:
        return const Color(0xFFFF4B72); // Sunset Coral / Flame Red
      case AppThemePreset.cyberpunk:
        return const Color(0xFFF59E0B); // Neon Amber
    }
  }

  Color get textPrimaryColor {
    switch (this) {
      case AppThemePreset.obsidian:
      case AppThemePreset.nordicNoir:
      case AppThemePreset.emberSunset:
      case AppThemePreset.cyberpunk:
        return const Color(0xFFF8FAFC);
      case AppThemePreset.paperLight:
        return const Color(0xFF0F172A);
    }
  }

  Color get textSecondaryColor {
    switch (this) {
      case AppThemePreset.obsidian:
      case AppThemePreset.nordicNoir:
      case AppThemePreset.cyberpunk:
        return const Color(0xFF94A3B8);
      case AppThemePreset.emberSunset:
        return const Color(0xFFA0A6B5);
      case AppThemePreset.paperLight:
        return const Color(0xFF475569);
    }
  }

  LinearGradient? get activePillGradient {
    switch (this) {
      case AppThemePreset.nordicNoir:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF00D2FF), // Electric Cyan
            Color(0xFF5352ED), // Radiant Indigo
          ],
        );
      case AppThemePreset.emberSunset:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF3366), // Radiant Coral Crimson
            Color(0xFFFF7733), // Sunset Amber Tangerine
          ],
        );
      case AppThemePreset.cyberpunk:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF59E0B), // Neon Amber
            Color(0xFF8B5CF6), // Vivid Violet
          ],
        );
      case AppThemePreset.obsidian:
      case AppThemePreset.paperLight:
        return null;
    }
  }

  /// Neumorphic Convex Molded Card Decoration (Molded out of the surface with dual shadows)
  BoxDecoration neumorphicCard({double radius = 20, Color? customColor}) {
    if (!isNeumorphic) {
      return BoxDecoration(
        color: customColor ?? cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 0.8),
      );
    }

    return BoxDecoration(
      color: customColor ?? cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.05),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.04), // Top-left soft ambient highlight
          offset: const Offset(-3, -3),
          blurRadius: 6,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.65), // Bottom-right deep cast shadow
          offset: const Offset(4, 4),
          blurRadius: 10,
        ),
      ],
    );
  }

  /// Neumorphic Inset / Sunken Trough Decoration (For calendar cells & recessed slots)
  BoxDecoration neumorphicInset({double radius = 14}) {
    if (!isNeumorphic) {
      return BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 0.8),
      );
    }

    return BoxDecoration(
      color: backgroundColor.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.black.withValues(alpha: 0.45),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.03),
          offset: const Offset(-1, -1),
          blurRadius: 2,
        ),
      ],
    );
  }

  /// Neumorphic Radiant Glowing Pill Decoration (For selected/active items & buttons)
  BoxDecoration neumorphicGlowingPill({double radius = 14}) {
    final grad = activePillGradient ??
        LinearGradient(colors: [primaryColor, primaryColor]);

    return BoxDecoration(
      gradient: grad,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.55),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.3),
          offset: const Offset(-1, -1),
          blurRadius: 3,
        ),
      ],
    );
  }

  /// Generates the complete Flutter ThemeData for this preset.
  ThemeData toThemeData() {
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: primaryColor,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimaryColor),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textPrimaryColor,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryColor.withValues(alpha: isDark ? 0.22 : 0.15),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primaryColor : textSecondaryColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? primaryColor : textSecondaryColor,
            size: 22,
          );
        }),
      ),
    );
  }
}
