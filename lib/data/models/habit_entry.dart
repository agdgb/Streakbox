/// Data model representing a single daily check-in for a habit.
class HabitEntry {
  final String id;
  final String habitId;
  final String date; // Format: 'yyyy-MM-dd'
  final DateTime completedAt;
  final String notes;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
    this.notes = '',
  });

  HabitEntry copyWith({
    String? id,
    String? habitId,
    String? date,
    DateTime? completedAt,
    String? notes,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'completed_at': completedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory HabitEntry.fromMap(Map<String, dynamic> map) {
    return HabitEntry(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      date: map['date'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
      notes: (map['notes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: json['date'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      notes: (json['notes'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          date == other.date &&
          completedAt == other.completedAt &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(id, habitId, date, completedAt, notes);
}
