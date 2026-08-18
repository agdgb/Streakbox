import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/in_memory_habit_repository.dart';

/// Provides the global [HabitRepository] instance.
/// Uses [InMemoryHabitRepository] on Web for instant zero-dependency execution,
/// and native SQLite [HabitRepository] on Mobile and Desktop.
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  if (kIsWeb) {
    return InMemoryHabitRepository();
  }
  return HabitRepository();
});
