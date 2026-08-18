# Streakbox — Flutter Habit Tracker
## Project Plan & Session Roadmap

A free, local-first, offline habit tracker for personal use, built with Flutter so the same codebase ships to Android now and iOS later. Inspired by "Check Calendar", named **Streakbox**.

---

## 1. Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter (Dart) | One codebase, Android now, iOS later, no Mac needed until final iOS build |
| State management | Riverpod | Testable, no BuildContext plumbing, scales cleanly as features grow |
| Local storage | sqflite (SQLite) | Habit check-ins accumulate forever — a real embedded DB keeps month/streak queries fast, unlike a growing JSON blob |
| Navigation | go_router | Standard, deep-link ready if you ever add widgets/notifications |
| Backup format | JSON export/import | Human-readable, easy to validate, easy to hand-restore |
| iOS builds (no Mac) | Codemagic (free tier) | Cloud Mac minutes to build & sign IPAs without owning Apple hardware |

## 2. App Architecture

```
lib/
  main.dart
  app.dart                 # MaterialApp, theme, router
  core/
    theme/                 # colors, text styles, spacing tokens
    utils/
      date_utils.dart       # month grid generator, streak algorithms
  data/
    models/
      habit.dart
      habit_entry.dart
    db/
      app_database.dart     # sqflite open/migrate
      habit_dao.dart
      entry_dao.dart
    repositories/
      habit_repository.dart # DAO + backup/export logic behind one interface
  state/
    habit_providers.dart    # Riverpod notifiers (habits list, active habit, entries)
    calendar_providers.dart # active month/year state
  features/
    calendar/
      calendar_screen.dart
      widgets/month_grid.dart
      widgets/day_cell.dart
    habits/
      habit_tabs.dart
      habit_form_sheet.dart # add/edit bottom sheet, color+icon picker
    stats/
      stats_panel.dart      # streaks, completion rate
      overview_heatmap.dart # all-habits compact view
    backup/
      backup_screen.dart    # export/import UI
  widgets/                 # shared buttons, dialogs, empty states
test/
  date_utils_test.dart      # streak math is the one place bugs hide — unit test it hard
  habit_repository_test.dart
```

Repository pattern means the UI never talks to sqflite directly — it talks to `HabitRepository`, which makes later features (widgets, notifications, cloud sync if you ever want it) additive, not rewrites.

## 3. Session Roadmap

Each session is scoped to be a self-contained chat/coding session with a runnable result at the end.

- [x] **Session 1 — Scaffolding & theme**
  Flutter project init (app name: **Streakbox**), dependencies, folder structure above, app theme (colors/type), empty navigation shell with placeholder screens. Runs on device/emulator showing a blank but styled app with the Streakbox name/branding in place.

- [x] **Session 2 — Data layer**
  `Habit` and `HabitEntry` models, sqflite schema + migrations, DAOs, `date_utils.dart` (month matrix generator, current/best streak algorithms, completion rate) with unit tests.

- [x] **Session 3 — State management**
  Riverpod providers wired to the repository: habits list, active habit, month entries, CRUD notifiers. No UI yet beyond debug print/test screen — this is the wiring session.

- [x] **Session 4 — Calendar grid UI**
  Month matrix widget (Mon–Sun), day cell tap-to-toggle with the habit's color fill + check icon, month/year pager, "Today" jump button.

- [x] **Session 5 — Habit management UI**
  Add/Edit bottom sheet (name, curated color palette picker, icon selector, optional notes), archive flow, delete confirmation dialog.

- [x] **Session 6 — Stats & analytics**
  Current streak / best streak / completion-rate cards, "All Habits" overview screen with a compact multi-row heatmap.

- [x] **Session 7 — Backup & restore**
  JSON export (write file), JSON import (read + parse + validate + merge/overwrite SQLite), privacy-first on-device message.

- [x] **Session 8 — Polish**
  Empty states, micro-animations on check/streak with flutter_animate, accessibility (contrast, tap targets, screen-reader semantics), app icon & splash screen.

- [x] **Session 9 — Build & install**
  Android APK/AAB build configuration, Codemagic CI/CD workflow, production Web release.

## 4. Notes for future sessions

- We'll pick up wherever the checklist above left off — just tell me the session number or say "continue" and paste/reference this file if it's a new chat.
- Nothing here is locked in: if a session turns out to need splitting further (e.g. Session 5 into "form" and "switcher"), we split it there.