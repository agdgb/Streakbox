import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/backup/backup_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../widgets/nav_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Habit Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'calendar',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CalendarScreen(),
                ),
              ),
            ],
          ),

          // Branch 1: Analytics & Stats
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: 'stats',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: StatsScreen(),
                ),
              ),
            ],
          ),

          // Branch 2: Settings & Backup
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/backup',
                name: 'backup',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: BackupScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
