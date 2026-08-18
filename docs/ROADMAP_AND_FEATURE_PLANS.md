# 🗺️ Streakbox — Comprehensive Product Roadmap & Strategic Architecture

This document serves as the master architectural and behavioral blueprint for the evolution of **Streakbox** from its initial v1.0 offline preview into a flagship, high-retention habit tracking platform.

---

## 💎 1. Monetization & Tiering Strategy (85% Free / 15% Pro)

The app maintains a generous, privacy-respecting **85% Free Tier** to drive maximum word-of-mouth growth and organic app store reviews, paired with a high-conversion **15% Pro Tier** centered on luxury aesthetics, automated cloud sync, and deep behavioral coaching.

| Feature Area | 🆓 85% Free Tier (100% Ad-Free & Local) | 👑 15% Streakbox PRO Tier |
| :--- | :--- | :--- |
| **Habits & Calendar** | Unlimited habits, daily/weekly frequency, notes, emojis, single-tap check-in, **1 Free Grace Day / Month** | **Habit Stacking & Atomic Chains** (trigger habit B after habit A), **Unlimited Streak Freezes & Vacation Shields** |
| **Theme Engine** | • Obsidian Dark<br>• Paper Clean Light | • **Nordic Noir (Tactile Matte Slate & Cyan Glow)**<br>• **Ember Sunset (Velvet Charcoal & Coral Ember Glow)**<br>• **OLED Neon Cyber (Amber & Violet)**<br>• Custom App Icons & Animated Badges<br>*(Includes 48-Hour Free Trial for all users)* |
| **Analytics Matrix** | 12-Month Zero-Scroll Heatmap, Current/Best Streaks, Milestone Ladder | **Trend Radar**, Day-of-Week Rhythm Analysis, **Year-in-Review "Wrapped" Story**, PDF/CSV Export |
| **Social Sharing** | **100% Free**: High-res Instagram Story & Twitter celebration cards | Verified PRO Badge / Watermark Customization |
| **Smart Notifications** | Standard fixed daily reminders with quiet hours | **Psychological Behavioral Nudges** (Momentum protector, Loss aversion nudges, dynamic timing) |
| **Data & Storage** | **100% Local Privacy Vault**, 1-tap manual JSON export/import | **Realtime Firebase Cloud Sync** (Firestore CRDT Set-Union) with **Sign in with Google** + **Sign in with Apple** |

---

## 🎨 2. Feature 1: Theme Engine & Neumorphic Design Schemes

### Visual & Tactile Architecture
- **Matte Charcoal Slate & Velvet Backgrounds**: `#1B1E24` (Nordic) / `#15171B` (Ember Sunset).
- **Tactile Inset & Elevated Capsules**: Dual soft-light highlights (`rgba(255,255,255,0.04)`) with deep cast shadows (`rgba(0,0,0,0.65)`).
- **Radiant Convex Glow Pills**:
  - *Nordic Noir*: Electric Cyan ➔ Radiant Indigo (`#00D2FF` ➔ `#5352ED`).
  - *Ember Sunset*: Radiant Coral Crimson ➔ Sunset Tangerine (`#FF3366` ➔ `#FF7733`).
- **48-Hour Pro Trial Mode**:
  - Users can activate Pro themes instantly with a 48-hour local countdown timer with zero friction.

---

## 👑 3. Feature 2: Entitlement Engine & Paywall Architecture (Early Phase)

- **Pro State Machine (`proStateProvider`)**: Manages entitlement status, active trial timers, and feature gating flags across the app.
- **Contextual Paywall Moments**:
  1. *Theme Studio*: 1-tap 48h Pro test drive.
  2. *Streak Rescue*: Offer freeze protection upon returning after a missed day.
  3. *Milestone Celebrations*: High-energy achievement unlocked paywall.

---

## 📱 4. Feature 3: Social Media Share Cards (100% Free Growth Loop)

- High-res Instagram Story (9:16) & Twitter/WhatsApp (16:9) celebration cards.
- Rendered via `RepaintBoundary` with live habit metrics, streak fire badge, and aesthetic theme styling.
- 1-Tap native OS share sheet and local gallery saving.

---

## 🧠 5. Feature 4: Behavioral Psychology Notification Engine

- **Loss Aversion Nudge**: `"You're on day 29 of 30. Don't let your month of hard work reset tonight!"`
- **Momentum Booster**: `"Only 2 days away from crushing your all-time personal best streak!"`
- **Implementation Intentions**: Context-aware morning focus prompt matching the habit's optimal circadian rhythm.

---

## 🔥 6. Feature 5: Firebase Cloud Sync & Dual Authentication

- **Firebase Authentication**: Sign in with Google, Sign in with Apple, and Anonymous Guest account linking.
- **Cloud Firestore**: Realtime bidirectional CRDT Set-Union sync (`FieldValue.arrayUnion`) with offline persistence.
- **Firebase Cloud Messaging (FCM)**: Remote trigger-based motivation nudges.
