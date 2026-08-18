import 'package:flutter/material.dart';

/// Pre-registered constant icons for Habit tracker to enable full font tree-shaking.
class AppIcons {
  AppIcons._();

  static const List<HabitIconOption> habitIcons = [
    // 🏋️ Fitness & Movement
    HabitIconOption('Fitness', Icons.fitness_center_rounded, 0xe25a, category: 'Fitness'),
    HabitIconOption('Run', Icons.directions_run_rounded, 0xe1d7, category: 'Fitness'),
    HabitIconOption('Cycle', Icons.directions_bike_rounded, 0xe1d4, category: 'Fitness'),
    HabitIconOption('Walk', Icons.directions_walk_rounded, 0xe1d8, category: 'Fitness'),
    HabitIconOption('Swim', Icons.pool_rounded, 0xe4d3, category: 'Fitness'),
    HabitIconOption('Stretch', Icons.accessibility_new_rounded, 0xe014, category: 'Fitness'),

    // 🧠 Mind & Growth
    HabitIconOption('Reading', Icons.menu_book_rounded, 0xe12b, category: 'Mind'),
    HabitIconOption('Journal', Icons.edit_note_rounded, 0xe226, category: 'Mind'),
    HabitIconOption('Work', Icons.laptop_mac_rounded, 0xe360, category: 'Mind'),
    HabitIconOption('Brain', Icons.psychology_rounded, 0xe4f7, category: 'Mind'),
    HabitIconOption('Code', Icons.code_rounded, 0xe163, category: 'Mind'),
    HabitIconOption('Art', Icons.palette_rounded, 0xe47a, category: 'Mind'),

    // 🥗 Health & Self-Care
    HabitIconOption('Water', Icons.water_drop_rounded, 0xe69f, category: 'Health'),
    HabitIconOption('Sleep', Icons.bedtime_rounded, 0xe5be, category: 'Health'),
    HabitIconOption('Nutrition', Icons.restaurant_rounded, 0xe532, category: 'Health'),
    HabitIconOption('Meditation', Icons.self_improvement_rounded, 0xe5f8, category: 'Health'),
    HabitIconOption('Sunlight', Icons.wb_sunny_rounded, 0xe6c8, category: 'Health'),
    HabitIconOption('Heart', Icons.favorite_rounded, 0xe25b, category: 'Health'),

    // ⚡ Discipline & Lifestyle
    HabitIconOption('Flame', Icons.local_fire_department_rounded, 0xe3f7, category: 'Discipline'),
    HabitIconOption('Savings', Icons.savings_rounded, 0xe556, category: 'Discipline'),
    HabitIconOption('Music', Icons.music_note_rounded, 0xe415, category: 'Discipline'),
    HabitIconOption('Clean', Icons.cleaning_services_rounded, 0xe158, category: 'Discipline'),
    HabitIconOption('Time', Icons.alarm_rounded, 0xe072, category: 'Discipline'),
    HabitIconOption('Goal', Icons.star_rounded, 0xe5f9, category: 'Discipline'),
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
  final String category;

  const HabitIconOption(this.name, this.icon, this.codePoint, {this.category = 'General'});
}
