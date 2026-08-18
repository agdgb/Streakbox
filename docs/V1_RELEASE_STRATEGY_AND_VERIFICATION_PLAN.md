# 🚀 Streakbox — V1 Release Strategy & Launch Verification Master Plan

> **Product Principle & Core Thesis:**
> *"Streakbox is a local-first habit engine designed around one core behavior: helping users show up consistently, track progress cleanly, and recover quickly when they miss."*

---

## 🎯 The V1 Feature Freeze Boundary

As established in the Red-Team Audit and Release Strategy, **all major new feature additions for V1 are strictly FROZEN**. 

The goal for V1 is not to add more features, but to **prove that everything already built is rock-solid, intuitive, reliable, and worth returning to daily**.

```
                         STREAKBOX ARCHITECTURE
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
             🔴 V1 (PRODUCTION)             🔮 FUTURE VERSIONS
                    │                               │
        ┌───────────┼───────────┐                   │
        │           │           │                   │
    1. TRACK   2. UNDERSTAND 3. RECOVER             │
        │           │           │                   │
     Habits     Analytics    Never Miss             │
     Calendar   Heatmap        Twice                │
     Streaks    Rhythm                              │
        │           │           │                   │
        └───────────┼───────────┘                   │
                    │                               │
            RETURN TOMORROW                         │
                    │                               │
                    └───────────────┬───────────────┘
                                    │
                                 V1 PRO
                                    │
                            Premium + Lifetime
                                    │
                                    ▼
                                 🟡 V1.1
                                    │
                           Coaching + Insights
                                    │
                                    ▼
                                 🟠 V2
                                    │
                            Cloud + Cross-Device
                                    │
                                    ▼
                                 🔵 V3
                                    │
                         Ecosystem & Integrations
```

---

## 🔴 1. V1 Scope: What Must Exist Before Launch

### A. The Sacred Core Habit Loop (Release Blocker)
*User Flow: Open app ➔ See today's habits ➔ Tap check-in (Haptic + Visual glow) ➔ See progress update ➔ Close app in < 5 seconds.*

- [x] **Habit Creation & Customization**: Name, notes, color palette, curated 24-icon quick picker, custom goals.
- [x] **Habit Management**: Edit, Archive (soft-delete), Restore, Permanent Delete with double-confirmation dialog.
- [x] **Interactive Calendar Grid**: Instant 1-tap check-in, undo accidental check-in, month switcher.
- [x] **Frequency & Repetition Rules**: Every day, X days per week, specific weekdays (Mon/Wed/Fri).
- [x] **Dual-Metric Engine**: Current Streak Days 🔥 + Scheduled Opportunity Consistency Score % 🛡️ + Best Streak 🏆.
- [x] **Never Miss Twice Recovery Protocol**: Encouraging recovery card when yesterday was missed to prevent streak abandonment.
- [x] **30-Second Fast-Track Onboarding**: Instant starter pack selection + Day 1 dopamine ignition check-in.
- [x] **Rhythm Analytics**: Mon–Sun weekday breakdown, peak performance day, and weakest risk day diagnostic.
- [x] **High-Res Share Cards**: 100% free organic identity cards (*"100 DAYS RUNNING — I DIDN'T QUIT"*).
- [x] **Local-First Privacy & Backup Vault**: SQLite offline persistence + JSON export/import for zero data loss.
- [x] **PRO Entitlements & 7-Day Free Trial**: 3-tier subscription model (Annual with 7-Day Trial, Lifetime, Monthly) + 1-Tap 48h feature test drive.

---

## 📋 2. Comprehensive V1 Edge Case & Quality Verification Matrix

Before publishing to production on Google Play / App Store, every item in this matrix must be tested and verified:

### 📅 A. Calendar & Date Calculation Edge Cases
| Test ID | Scenario | Expected Behavior |
| :--- | :--- | :--- |
| **TC-CAL-01** | Checking today's habit | Streak increments by 1; Consistency score updates based on scheduled opportunities. |
| **TC-CAL-02** | Unchecking today's habit (Undo) | Streak decrements back; Entry removed from SQLite. |
| **TC-CAL-03** | Yesterday was checked, today is pending | Streak is maintained (alive); Recovery mode is NOT active. |
| **TC-CAL-04** | Yesterday was missed, today is pending | Current streak pauses; **Never Miss Twice Recovery Protocol** activates. |
| **TC-CAL-05** | Yesterday was missed, user completes today | Recovery protocol completes; Streak is reclaimed. |
| **TC-CAL-06** | Habit created mid-month | Consistency % calculates starting from habit `createdAt` date, not penalizing prior uncreated days. |
| **TC-CAL-07** | Specific weekday schedule (e.g. Mon/Wed/Fri) | Consistency % evaluates only scheduled MWF opportunities (e.g. 12/14 = 85.7%). |
| **TC-CAL-08** | Month boundaries (e.g. Aug 31 ➔ Sep 1) | Streak continues seamlessly across month boundaries. |
| **TC-CAL-09** | Leap years (e.g. Feb 29) | 29-day February grid generated accurately. |
| **TC-CAL-10** | Device date/time change or timezone shift | Date key parser handles local time without skipping days. |

### 🗄️ B. Persistence, Lifecycle & Backup Verification
| Test ID | Scenario | Expected Behavior |
| :--- | :--- | :--- |
| **TC-DAT-01** | App force-close & restart | All habits, check-ins, and active theme remain intact. |
| **TC-DAT-02** | 20+ habits logged simultaneously | Smooth 60/120 FPS scrolling on physical hardware with zero stutter. |
| **TC-DAT-03** | Habit archiving | Habit disappears from active calendar, remains stored in SQLite, and is viewable in Archive settings. |
| **TC-DAT-04** | Permanent habit deletion | All associated date entries are pruned cleanly from the database. |
| **TC-DAT-05** | Backup Export ➔ Reinstall ➔ Import | 100% of habits, date logs, notes, and timestamps restored cleanly via deterministic JSON schema. |
| **TC-DAT-06** | Malformed JSON import attempt | Handled gracefully with error SnackBar; does not crash database. |

### 💳 C. PRO Entitlement & Paywall Verification
| Test ID | Scenario | Expected Behavior |
| :--- | :--- | :--- |
| **TC-PRO-01** | Free user core loop | 100% uninhibited daily habit logging, calendar check-in, and local backup. |
| **TC-PRO-02** | 48-Hour Instant Test Drive | Unlocks signature themes (Nordic Noir, Ember Sunset, OLED Cyber) with live countdown timer. |
| **TC-PRO-03** | 7-Day Free Trial on Annual Plan | Clear billing disclosures, 7 days free, cancel anytime in Google Play settings. |
| **TC-PRO-04** | Offline entitlement check | Pro state cached locally so airplane mode does not lock user out of Pro features. |

---

## 🚢 3. Google Play Production Readiness Checklist

Prior to production launch on the Google Play Console:

1. **Store Listing Assets**:
   - [ ] High-resolution App Icon (512×512 PNG).
   - [ ] Feature Graphic (1024×500 PNG) highlighting *"Never Miss Twice"*.
   - [ ] 5–8 Screenshot mockups (Pixel / Galaxy aspect ratios) demonstrating the Neumorphic calendar, 4K Share cards, and Rhythm Analytics.
2. **Legal & Compliance**:
   - [ ] Hosted Privacy Policy URL (declaring 100% local-first privacy, zero data sales).
   - [ ] Completed Google Play Data Safety Form.
   - [ ] Target SDK level updated to Android 14 / 15 requirements.
3. **Release Build & Signing**:
   - [ ] Android App Bundle (`.aab`) compiled with release keystore signing.
   - [ ] Core library desugaring verified (`desugar_jdk_libs:2.1.4`).
   - [ ] Internal Testing track verification on real physical hardware.

---

## 🔮 4. Post-Launch Phased Roadmap

```
┌────────────────────────────────────────────────────────────────────────┐
│ 🟡 V1.1 — Post-Launch Refinements (Data-Informed Iteration)            │
├────────────────────────────────────────────────────────────────────────┤
│ • Analyze real user Day 2, Day 7, and Day 30 retention curves.         │
│ • Refine Notification timing based on actual completion rates.         │
│ • Expand Starter Habit Templates based on most popular created habits. │
│ • Add custom sticker themes to 4K Share Cards.                         │
└────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 🟠 V2 — Cloud Sync & Advanced Behavioral Coaching                      │
├────────────────────────────────────────────────────────────────────────┤
│ • Zero-Knowledge Firebase Dual Auth (Google / Apple Sign-In).          │
│ • Deterministic Cloud Vault Sync (CRDT Set-Union conflict resolution). │
│ • Adaptive Behavioral Coaching: Failure pattern & time-of-day prompts. │
│ • Multi-device real-time sync across phones, tablets & desktop.        │
└────────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ 🔵 V3 — Ecosystem & Wearable Integrations                              │
├────────────────────────────────────────────────────────────────────────┤
│ • Smartwatch companion app (Wear OS / Apple Watch 1-tap check-in).     │
│ • Apple Health / Google Health Connect sync.                           │
│ • Web desktop dashboard.                                               │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🏁 5. V1 Success Metrics Definition

| Dimension | Target KPI |
| :--- | :--- |
| **Acquisition** | Organic installs via Google Play Store & 4K Social Share cards. |
| **Activation** | User creates first habit & completes Day 1 check-in in `< 60 seconds`. |
| **D7 Retention** | $> 40\%$ of activated users return on Day 7 (industry top quartile). |
| **D30 Retention** | $> 25\%$ of users maintaining at least one active streak at Day 30. |
| **Anti-Fragility** | $> 50\%$ of users who miss 1 day recover on Day 2 via the "Never Miss Twice" protocol. |
| **Monetization** | Healthy conversion to Annual 7-Day Trial & Lifetime Pro upgrades without disruptive ads. |
