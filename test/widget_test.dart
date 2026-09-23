import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:streakbox/app.dart';
import 'package:streakbox/state/auth_provider.dart';
import 'package:streakbox/data/repositories/fake_auth_repository.dart';
import 'package:streakbox/data/db/app_database.dart';
import 'package:streakbox/data/repositories/habit_repository.dart';
import 'package:streakbox/state/repository_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  GoogleFonts.config.allowRuntimeFetching = false;

  late AppDatabase db;
  late HabitRepository repository;

  setUp(() {
    db = AppDatabase.inMemory();
    repository = HabitRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('StreakboxApp renders navigation shell and switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const StreakboxApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify initial Calendar tab state
    expect(find.text('Streakbox'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.byIcon(Icons.insights_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // Tap Analytics tab
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Analytics screen is active
    expect(find.text('Analytics & Overview'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);

    // Tap Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Settings screen is active
    expect(find.text('Settings & Vault'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
