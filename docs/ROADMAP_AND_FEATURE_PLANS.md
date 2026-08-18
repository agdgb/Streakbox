# 🗺️ Streakbox — Master Roadmap & Anti-Fragility Architecture

This document serves as the master architectural and behavioral blueprint for the evolution of **Streakbox** from its initial v1.0 offline preview into a flagship, high-retention habit engine.

> **Master Red-Team Audit & Action Matrix**:  
> See [`docs/RED_TEAM_CRITIQUE_AND_ACTION_MATRIX.md`](file:///c:/Users/User/source/repos/Streakbox/docs/RED_TEAM_CRITIQUE_AND_ACTION_MATRIX.md) for the complete 12-vector vulnerability audit and anti-churn roadmap.

---

## 💎 1. Monetization & Tiering Strategy (85% Free / 15% Pro)

The app maintains a generous, privacy-respecting **85% Free Tier** to drive maximum word-of-mouth growth and organic app store reviews, paired with a high-conversion **15% Pro Tier** centered on intelligent behavioral coaching, automated cloud sync, and luxury aesthetics.

| Feature Area | 🆓 85% Free Tier (100% Ad-Free & Local) | 👑 15% Streakbox PRO Tier |
| :--- | :--- | :--- |
| **Habits & Calendar** | Unlimited habits, daily/weekly frequency, notes, emojis, single-tap check-in, **Dual Consistency Score (% + Flame)**, **1 Free Grace Day / Month** | **Habit Stacking & Atomic Chains** (trigger habit B after habit A), **Unlimited Streak Freezes & Vacation Shields** |
| **Theme Engine** | • Obsidian Dark<br>• Paper Clean Light | • **Nordic Noir (Tactile Matte Slate & Cyan Glow)**<br>• **Ember Sunset (Velvet Charcoal & Coral Ember Glow)**<br>• **OLED Neon Cyber (Amber & Violet)**<br>• Custom App Icons & Animated Badges<br>*(Includes 48-Hour Free Trial for all users)* |
| **Analytics Matrix** | 12-Month Zero-Scroll Heatmap, Current/Best Streaks, Milestone Ladder, Consistency Score | **Smart Rhythm Analytics**, Weakest/Best Day-of-Week Insights, **Year-in-Review "Wrapped" Story**, PDF/CSV Export |
| **Social Sharing** | **100% Free**: Identity-First Instagram Story & Twitter celebration cards (*"100 DAYS RUNNING — I DIDN'T QUIT"*) | Verified PRO Badge / Watermark Customization |
| **Smart Notifications** | Standard fixed daily reminders with quiet hours | **Psychological Behavioral Nudges** (Momentum protector, Loss aversion nudges, dynamic predictive timing) |
| **Data & Storage** | **100% Local Privacy Vault**, 1-tap manual JSON export/import | **Zero-Knowledge Firebase Cloud Sync** (Firestore CRDT Set-Union) with **Sign in with Google** + **Sign in with Apple** |

---

## 🛡️ 2. Core Anti-Fragility Foundations (Addressing Red-Team Vectors)

### 1. Dual-Metric Engine & "Never Miss Twice" Recovery Mode (Attack #2)
- **Consistency Score**: Tracks completion percentage over 30/90/365 days (e.g. `96.4%`). One missed day drops score to `94.6%` rather than resetting the user's hard work to `0`.
- **Never Miss Twice Protocol**: Renders an empowering amber recovery glow on days following a missed check-in: *"Streaks pause, habits endure. Check in today to initiate the Recovery Protocol."*

### 2. 30-Second Fast-Track Onboarding (Attack #9)
- Guided 3-step first launch: Select curated starter habit bundle ➔ Set anchor time ➔ Instant Day 1 check-in with haptic dopamine feedback.

### 3. Curated Quick-Picks Icon Matrix (Attack #6)
- 24 essential habit icons categorized by Health, Fitness, Mind, and Work for 1-tap creation without emoji hunting.

---

## 🎨 3. Completed Features (Verified on Device)

1. **Theme Engine & Neumorphic Design Schemes**:
   - 5 Presets: Obsidian Dark, Paper Clean, Nordic Noir (PRO), Ember Sunset (PRO), OLED Cyber (PRO).
   - Dual-shadow lighting, sunken capsule troughs, dynamic theme-adaptive Solid Fill and Pure Minimal styles.
2. **Pro Entitlement Engine & Paywall Showcase**:
   - Centralized `proEntitlementProvider`, universal `ProGate.guard`, glowing crown paywall with 3-tier selector and 1-tap 48h test drive.
3. **Social Media Share Cards (100% Free)**:
   - High-res Instagram Story (9:16) & Square Post (1:1) celebration cards with 3 templates (Streak Flame, 12-Month Matrix, Milestone Seal).

---

## 🚀 4. Phased Release Roadmap

> **V1 Feature Freeze**: Major new feature development for V1 is now **FROZEN**. All effort is dedicated to release verification, reliability, and edge case testing.

### 🔴 Version 1.0 (Production Release)
- **Status**: **Feature Complete & In Final Verification**.
- **Scope**: Core Habit Loop + Dual-Metric Consistency + "Never Miss Twice" Recovery + 30s Fast-Track Onboarding + Rhythm Analytics + 4K Share Cards + Local-First SQLite & JSON Backup Vault + Pro Paywall (Annual 7-Day Trial / Lifetime / Monthly).
- **Core Document**: [`docs/V1_RELEASE_STRATEGY_AND_VERIFICATION_PLAN.md`](file:///c:/Users/User/source/repos/Streakbox/docs/V1_RELEASE_STRATEGY_AND_VERIFICATION_PLAN.md).

### 🟡 Version 1.1 (Data-Informed Refinements)
- User retention analytics & funnel optimization (Day 2, Day 7, Day 30).
- Data-driven notification timing adjustments based on actual habit check-in distribution.
- Additional starter habit templates based on popular user creations.

### 🟠 Version 2.0 (Cloud Sync & Behavioral Coaching)
- Zero-Knowledge Cloud Vault Sync (Google Sign-In & Apple Sign-In).
- Conflict-free CRDT Set-Union ledger for multi-device sync across phones and tablets.
- Adaptive Behavioral Coaching & Day-of-Week failure pattern diagnostics.

### 🔵 Version 3.0 (Ecosystem & Integrations)
- Wear OS / Apple Watch 1-tap check-in companion app.
- Google Health Connect / Apple Health integration.
- Desktop Web Dashboard.
