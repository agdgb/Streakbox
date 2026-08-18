import 'package:flutter/material.dart';
import '../../core/theme/app_icons.dart';

/// Supported frequency types for habit repetition goals.
enum HabitFrequencyType {
  daily,
  weeklyTarget,
  specificDays,
}

/// Data model representing a user habit with flexible repetition goals.
class Habit {
  final String id;
  final String name;
  final String description;
  final int colorValue;
  final int iconCodePoint;
  final DateTime createdAt;
  final bool isArchived;
  final int sortOrder;
  final int targetDaysPerWeek; // e.g. 7, 3, 5
  final HabitFrequencyType frequencyType;
  final List<int> targetDaysOfWeek; // 1 = Mon, 7 = Sun (e.g. [1, 3, 5])

  const Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.colorValue,
    this.iconCodePoint = 0xe156, // Default check_box icon
    required this.createdAt,
    this.isArchived = false,
    this.sortOrder = 0,
    this.targetDaysPerWeek = 7,
    this.frequencyType = HabitFrequencyType.daily,
    this.targetDaysOfWeek = const [],
  });

  Color get color => Color(colorValue);
  IconData get icon => AppIcons.getHabitIcon(iconCodePoint);

  /// Human-readable frequency label (e.g. "Every day", "3 days / week", "Mon, Wed, Fri")
  String get frequencyLabel {
    switch (frequencyType) {
      case HabitFrequencyType.weeklyTarget:
        return '$targetDaysPerWeek days / week';
      case HabitFrequencyType.specificDays:
        if (targetDaysOfWeek.isEmpty) return 'Every day';
        const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final days = targetDaysOfWeek.map((d) => dayNames[(d - 1).clamp(0, 6)]).join(', ');
        return days;
      case HabitFrequencyType.daily:
        return 'Every day';
    }
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    int? iconCodePoint,
    DateTime? createdAt,
    bool? isArchived,
    int? sortOrder,
    int? targetDaysPerWeek,
    HabitFrequencyType? frequencyType,
    List<int>? targetDaysOfWeek,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      frequencyType: frequencyType ?? this.frequencyType,
      targetDaysOfWeek: targetDaysOfWeek ?? this.targetDaysOfWeek,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color_value': colorValue,
      'icon_code_point': iconCodePoint,
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
      'sort_order': sortOrder,
      'target_days_per_week': targetDaysPerWeek,
      'frequency_type': frequencyType.name,
      'target_days_of_week': targetDaysOfWeek.join(','),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    HabitFrequencyType freqType = HabitFrequencyType.daily;
    if (map['frequency_type'] != null) {
      final str = map['frequency_type'] as String;
      freqType = HabitFrequencyType.values.firstWhere(
        (e) => e.name == str,
        orElse: () => HabitFrequencyType.daily,
      );
    }

    List<int> days = [];
    if (map['target_days_of_week'] != null) {
      final str = map['target_days_of_week'] as String;
      if (str.isNotEmpty) {
        days = str.split(',').map((e) => int.tryParse(e) ?? 1).toList();
      }
    }

    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      colorValue: map['color_value'] as int,
      iconCodePoint: (map['icon_code_point'] as int?) ?? 0xe156,
      createdAt: DateTime.parse(map['created_at'] as String),
      isArchived: (map['is_archived'] as int) == 1,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      targetDaysPerWeek: (map['target_days_per_week'] as int?) ?? 7,
      frequencyType: freqType,
      targetDaysOfWeek: days,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
      'sortOrder': sortOrder,
      'targetDaysPerWeek': targetDaysPerWeek,
      'frequencyType': frequencyType.name,
      'targetDaysOfWeek': targetDaysOfWeek,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    HabitFrequencyType freqType = HabitFrequencyType.daily;
    if (json['frequencyType'] != null) {
      final str = json['frequencyType'] as String;
      freqType = HabitFrequencyType.values.firstWhere(
        (e) => e.name == str,
        orElse: () => HabitFrequencyType.daily,
      );
    }

    List<int> days = [];
    if (json['targetDaysOfWeek'] != null) {
      if (json['targetDaysOfWeek'] is List) {
        days = (json['targetDaysOfWeek'] as List).map((e) => (e as num).toInt()).toList();
      }
    }

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      colorValue: json['colorValue'] as int,
      iconCodePoint: (json['iconCodePoint'] as int?) ?? 0xe156,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isArchived: (json['isArchived'] as bool?) ?? false,
      sortOrder: (json['sortOrder'] as int?) ?? 0,
      targetDaysPerWeek: (json['targetDaysPerWeek'] as int?) ?? 7,
      frequencyType: freqType,
      targetDaysOfWeek: days,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          colorValue == other.colorValue &&
          iconCodePoint == other.iconCodePoint &&
          createdAt == other.createdAt &&
          isArchived == other.isArchived &&
          sortOrder == other.sortOrder &&
          targetDaysPerWeek == other.targetDaysPerWeek &&
          frequencyType == other.frequencyType;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        colorValue,
        iconCodePoint,
        createdAt,
        isArchived,
        sortOrder,
        targetDaysPerWeek,
        frequencyType,
      );
}
