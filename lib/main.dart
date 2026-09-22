import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/in_memory_habit_repository.dart';
import '../state/repository_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite desktop factory on desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Create repository instance (In-Memory for instant Web, SQLite for Mobile/Desktop)
  final repository = kIsWeb ? InMemoryHabitRepository() : HabitRepository();

  runApp(
    ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
      child: const StreakboxApp(),
    ),
  );
}
