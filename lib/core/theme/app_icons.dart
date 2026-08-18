import 'package:flutter/material.dart';

/// Pre-registered constant icons for Habit tracker to enable full font tree-shaking.
class AppIcons {
  AppIcons._();

  static const List<HabitIconOption> habitIcons = [
    HabitIconOption('Check', Icons.check_box_outlined, 0xe156),
    HabitIconOption('Fitness', Icons.fitness_center_rounded, 0xe25a),
    HabitIconOption('Reading', Icons.menu_book_rounded, 0xe12b),
    HabitIconOption('Meditation', Icons.self_improvement_rounded, 0xe5f8),
    HabitIconOption('Water', Icons.water_drop_rounded, 0xe69f),
    HabitIconOption('Flame', Icons.local_fire_department_rounded, 0xe3f7),
    HabitIconOption('Sleep', Icons.bedtime_rounded, 0xe5be),
    HabitIconOption('Code', Icons.code_rounded, 0xe163),
    HabitIconOption('Run', Icons.directions_run_rounded, 0xe1d7),
    HabitIconOption('Art', Icons.palette_rounded, 0xe47a),
    HabitIconOption('Music', Icons.music_note_rounded, 0xe415),
    HabitIconOption('Savings', Icons.savings_rounded, 0xe556),
  ];

  static IconData getHabitIcon(int codePoint) {
    for (final opt in habitIcons) {
      if (opt.codePoint == codePoint) {
        return opt.icon;
      }
    }
    return Icons.check_box_outlined;
  }
}

class HabitIconOption {
  final String name;
  final IconData icon;
  final int codePoint;

  const HabitIconOption(this.name, this.icon, this.codePoint);
}
