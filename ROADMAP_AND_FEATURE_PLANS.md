# 🗺️ Streakbox — Comprehensive Product Roadmap & Feature Plans

This document serves as the master architectural and behavioral blueprint for the evolution of **Streakbox** from its initial v1.0 offline preview into a flagship, high-retention habit tracking platform.

---

## 💎 1. Monetization & Tiering Strategy (85% Free / 15% Pro)

The app maintains a generous, privacy-respecting **85% Free Tier** to drive maximum word-of-mouth growth and organic app store reviews, paired with a high-conversion **15% Pro Tier** centered on luxury aesthetics, automated cloud sync, and deep behavioral coaching.

| Feature Area | 🆓 85% Free Tier | 👑 15% Streakbox PRO Tier |
| :--- | :--- | :--- |
| **Habits & Calendar** | Unlimited habits, daily/weekly frequency, notes, emojis, single-tap check-in | **Habit Stacking & Atomic Chains** (trigger habit B after habit A), Streak Freeze / Vacation Shields |
| **Theme Engine** | • Obsidian Dark<br>• Paper Clean Light | • **Nordic Noir (Tactile Matte & Cyan Glow)**<br>• **OLED Neon Violet**<br>• **Midnight Gold / Champagne**<br>• Custom App Icons & Animated Badges<br>*(Includes 48-Hour Free Trial for all users)* |
| **Analytics Matrix** | 12-Month Zero-Scroll Heatmap, Current/Best Streaks, Milestone Ladder | **Trend Radar**, Day-of-Week Rhythm Analysis, Year-in-Review Wrapped, PDF/CSV Export |
| **Social Sharing** | **100% Free**: High-res Instagram Story & Twitter celebration cards | Custom Pro Badge / Verified Streak Sticker |
| **Smart Notifications** | Standard fixed daily reminders | **Psychological Behavioral Nudges** (Momentum protector, Loss aversion nudges, dynamic timing) |
| **Data & Storage** | **100% Local Privacy Vault**, 1-tap manual JSON export/import | **Automatic Google Drive / Encrypted Cloud Sync** across multiple devices & instant restore |

---

## 🎨 2. Feature 1: Theme Engine & Neumorphic Design Schemes

### Visual Inspiration
Inspired by tactile dark neumorphism (*Nordic Noir*):
- **Matte Charcoal Slate Background**: `#1F242B` / `#232830`.
- **Tactile Inset & Elevated Capsules**: Dual soft-light highlights (`rgba(255,255,255,0.06)`) with deep cast shadows (`rgba(0,0,0,0.55)`).
- **Electric Cyan-to-Indigo Glow Pill**: Radiantly glowing physical pill (`#00D2FF` ➔ `#5352ED`) on active / today cells.
- **Theme Preset Engine**:
  - `ThemePreset.obsidian` (Default Dark)
  - `ThemePreset.paperLight` (Default Light)
  - `ThemePreset.nordicNoir` (Neumorphic Matte & Cyan Glow — PRO)
  - `ThemePreset.cyberpunk` (OLED Neon Amber & Violet — PRO)
- **48-Hour Pro Trial Mode**:
  - Users can activate Pro themes instantly with a 48-hour local countdown timer without upfront payments.

---

## 🧠 3. Feature 2: Behavioral Psychology Notification Engine

Notifications designed based on cognitive psychology principles rather than annoying spam:

1. **Loss Aversion Nudge (Tversky & Kahneman)**:
   - *Trigger*: Unlogged streak on Day 15+ at 8:30 PM.
   - *Message*: *"You're on day 21 of Meditation. Don't let 3 weeks of momentum reset tonight. 1 tap to check in."*
2. **Milestone Momentum Booster (Goal Gradient Effect)**:
   - *Trigger*: 1 to 2 days before breaking all-time personal record or achieving a 30/66/100-day milestone.
   - *Message*: *"Only 2 days until you reach your 66-Day Habit Formation Milestone! You're in the home stretch."*
3. **Implementation Intentions (Peter Gollwitzer)**:
   - *Trigger*: Morning contextual reminder at the user's preferred habit time.
   - *Message*: *"When it is 7:00 AM, I will Read for 15 minutes."*
4. **Smart Anti-Fatigue Cap**:
   - Maximum 1 notification per day per habit; automatic quiet hours suppression.

---

## 📱 4. Feature 3: Social Media Share Cards (100% Free)

A viral sharing engine generating pixel-perfect snapshot cards for social platforms:
- **Card Formats**:
  - `9:16` Story Format (Instagram Stories, TikTok, WhatsApp Status).
  - `16:9` / `1:1` Post Format (Twitter/X, LinkedIn, Threads).
- **Share Types**:
  1. *Streak Celebration Card* ("🔥 30 Days Unbroken — Streakbox").
  2. *12-Month Performance Heatmap* ("My 2026 Habit Matrix").
  3. *Milestone Badge Card* ("Unlocked: 66-Day Habit Master").
- **Implementation**: Off-screen `RepaintBoundary` rendering with native share sheet integration (`share_plus`).

---

## ☁️ 5. Feature 4: Cloud Sync & Account Storage

An opt-in cloud sync system that preserves the 100% offline local privacy architecture while enabling multi-device sync:
1. **Google Sign-In**:
   - OAuth 2.0 integration via Google Play Services / Firebase Auth.
2. **Encrypted Google Drive App Data Folder**:
   - User database synced to their personal private Google Drive hidden app folder (`drive.appdata`), ensuring the developer never sees their private data.
3. **Conflict Resolution**:
   - CRDT / Timestamp-based merging to prevent data overwrites when tracking offline across multiple devices.

---

## 📊 6. Feature 5: Advanced Analytics & Habit Stacking

1. **Habit Stacking (James Clear / BJ Fogg)**:
   - Ability to link habits into a sequential chain: `Wake Up` ➔ `Drink Water` ➔ `Workout` ➔ `Cold Shower`.
2. **Trend Radar & Rhythm Matrix**:
   - Success rate by Day-of-Week (e.g. identify if weekends are the highest failure point).
   - Monthly completion radar and long-term consistency curves.
