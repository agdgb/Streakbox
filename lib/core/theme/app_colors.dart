import 'package:flutter/material.dart';

/// Centralized color tokens and curated habit accent palettes for Streakbox.
class AppColors {
  AppColors._();

  // Dark Theme Palette (Obsidian / Slate)
  static const Color darkBackground = Color(0xFF0F1216);
  static const Color darkSurface = Color(0xFF171B22);
  static const Color darkCard = Color(0xFF1F242D);
  static const Color darkCardElevated = Color(0xFF282F3B);
  static const Color darkBorder = Color(0xFF2B3340);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Palette (Crisp Clean)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightCardElevated = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Brand Primary (Emerald / Mint) & Secondary
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF59E0B);

  // Status & Utility Colors
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // Curated Habit Color Palette (rich, vibrant, high-contrast)
  static const List<HabitColorOption> habitColors = [
    HabitColorOption('Emerald', Color(0xFF10B981), Color(0xFF064E3B)),
    HabitColorOption('Violet', Color(0xFF8B5CF6), Color(0xFF4C1D95)),
    HabitColorOption('Amber', Color(0xFFF59E0B), Color(0xFF78350F)),
    HabitColorOption('Rose', Color(0xFFF43F5E), Color(0xFF881337)),
    HabitColorOption('Sapphire', Color(0xFF3B82F6), Color(0xFF1E3A8A)),
    HabitColorOption('Coral', Color(0xFFFF6B6B), Color(0xFF7F1D1D)),
    HabitColorOption('Cyan', Color(0xFF06B6D4), Color(0xFF164E63)),
    HabitColorOption('Lime', Color(0xFF84CC16), Color(0xFF365314)),
    HabitColorOption('Indigo', Color(0xFF6366F1), Color(0xFF312E81)),
    HabitColorOption('Orange', Color(0xFFFB923C), Color(0xFF7C2D12)),
  ];

  static HabitColorOption getHabitColor(int colorValue) {
    return habitColors.firstWhere(
      (c) => c.color.toARGB32() == colorValue,
      orElse: () => habitColors.first,
    );
  }
}

class HabitColorOption {
  final String name;
  final Color color;
  final Color darkShade;

  const HabitColorOption(this.name, this.color, this.darkShade);
}
