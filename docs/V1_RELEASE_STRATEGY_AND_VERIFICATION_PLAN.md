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

## 🧪 The 8-Stage V1 Hardening Protocol

Rather than adding more features, Streakbox enters the **V1 Hardening Phase** to rigorously validate stability, compliance, and edge cases before public launch.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       8-STAGE V1 HARDENING PIPELINE                         │
├───────────────┬─────────────────────────────────────────────────────────────┤
│ 🧪 Stage 1   │ Domain Engine Adversarial QA (Streaks, Consistency, Sched.)  │
│ 🗄️ Stage 2   │ Disaster Testing (Wipe ➔ Reinstall ➔ Corrupted JSON tests)  │
│ 💳 Stage 3   │ Google Play Billing State Machine (Trial, Cancel, Expire)   │
│ 📱 Stage 4   │ Device Resilience (Force kill, Low storage, Process death)  │
│ 👥 Stage 5   │ Blind UX Testing (Zero-instruction first-time user test)     │
│ 📜 Stage 6   │ Store Compliance (Data Safety, Accurate Privacy, Screenshots)│
│ 🔒 Stage 7   │ Google Play Closed Testing (Real hardware beta testing)      │
│ 🚀 Stage 8   │ Staged Production Rollout (10% ➔ 50% ➔ 100%)                │
└───────────────┴─────────────────────────────────────────────────────────────┘
```

---

## 📋 1. Comprehensive V1 Adversarial Testing & Verification Matrix

Before publishing to production on Google Play / App Store, every item in this matrix must be tested and verified:

### 📅 A. Calendar & Streak Engine Adversarial Edge Cases
| Test ID | Scenario | Expected Behavior |
| :--- | :--- | :--- |
| **TC-CAL-01** | Checking today's habit | Streak increments by 1; Consistency score updates based on scheduled opportunities. |
| **TC-CAL-02** | Unchecking today's habit (Undo) | Streak decrements back; Entry removed from SQLite. |
| **TC-CAL-03** | Yesterday was checked, today is pending | Streak is maintained (alive); Recovery mode is NOT active. |
| **TC-CAL-04** | Yesterday was missed, today is pending | Current streak pauses; **Never Miss Twice Recovery Protocol** activates. |
| **TC-CAL-05** | Yesterday was missed, user completes today | Recovery protocol completes; Streak is reclaimed. |
| **TC-CAL-06** | Habit created mid-month | Consistency % calculates starting from habit `createdAt` date, not penalizing prior uncreated days. |
| **TC-CAL-07** | Specific weekday schedule (e.g. Mon/Wed/Fri) | Consistency % evaluates only scheduled MWF opportunities (e.g. 12/14 = 85.7% with `12 of 14 planned days` label). |
| **TC-CAL-08** | Month boundaries (e.g. Aug 31 ➔ Sep 1) | Streak continues seamlessly across month boundaries. |
| **TC-CAL-09** | Leap years (e.g. Feb 29) | 29-day February grid generated accurately. |
| **TC-CAL-10** | Device date/time change or timezone shift | Date key parser handles local time without skipping days or throwing exceptions. |

### 🗄️ B. Persistence, Lifecycle & Disaster Backup Verification
| Test ID | Scenario | Expected Behavior |
| :--- | :--- | :--- |
| **TC-DAT-01** | App force-close & restart | All habits, check-ins, and active theme remain intact. |
| **TC-DAT-02** | 20+ habits logged simultaneously | Smooth 60/120 FPS scrolling on physical hardware with zero stutter. |
| **TC-DAT-03** | Habit archiving | Habit disappears from active calendar, remains stored in SQLite, and is viewable in Archive settings. |
| **TC-DAT-04** | Permanent habit deletion | All associated date entries are pruned cleanly from the database. |
| **TC-DAT-05** | **Disaster Test**: Export ➔ Wipe App ➔ Reinstall ➔ Import | 100% of habits, date logs, notes, and timestamps restored cleanly via deterministic JSON schema. |
| **TC-DAT-06** | Malformed / Corrupted JSON import attempt | Handled gracefully with error SnackBar; does not corrupt or wipe SQLite. |
| **TC-DAT-07** | Force kill during database write | SQLite transaction rollbacks prevent corrupt database headers. |

### 💳 C. PRO Entitlement & Google Play Billing State Machine
| Test ID | Scenario | Expected Behavior |
| :--- | :--- | :--- |
| **TC-PRO-01** | Free user core loop | 100% uninhibited daily habit logging, calendar check-in, and local backup. |
| **TC-PRO-02** | 48-Hour Instant Test Drive | Unlocks signature themes (Nordic Noir, Ember Sunset, OLED Cyber) with live countdown timer. |
| **TC-PRO-03** | 7-Day Free Trial on Annual Plan | Clear billing disclosures, 7 days free, cancel anytime in Google Play settings. |
| **TC-PRO-04** | Offline entitlement check | Pro state cached locally so airplane mode does not lock user out of Pro features. |
| **TC-PRO-05** | Purchase restoration across devices | Restores subscription state from Google Play Billing cache. |
| **TC-PRO-06** | Subscription Cancellation / Expiration | User retains Pro until period end date; cleanly reverts to Free tier thereafter. |

---

## 🚢 2. Google Play Production Readiness & Compliance

Prior to production launch on the Google Play Console:

1. **Defensible Privacy Policy**:
   - Accurately state: *"Streakbox V1 stores all habit data locally on your device in SQLite. No tracking SDKs, no advertising trackers, and no external data servers are utilized."*
   - Avoid over-promising permanent statements (e.g. avoid saying *"Streakbox will never have cloud servers"*, instead specify *"In Streakbox V1, 100% of habit data is stored locally on your device"*).
2. **Google Play Data Safety Form**:
   - Declare local-only storage; No data collected or shared with third parties for V1.
3. **Store Visuals & Narrative Assets**:
   - **Screenshot 1**: *BUILD THE HABIT. KEEP THE STREAK.* (Calendar + Today's check-in).
   - **Screenshot 2**: *MISS A DAY? DON'T MISS TWICE.* (Never Miss Twice Recovery Card).
   - **Screenshot 3**: *SEE YOUR REAL CONSISTENCY.* (Dual-Metric Consistency Rate + Planned Days).
   - **Screenshot 4**: *UNDERSTAND YOUR RHYTHM.* (Peak Power vs Risk Day Insights).
   - **Screenshot 5**: *MAKE YOUR PROGRESS YOURS.* (Nordic Noir & 4K Identity Share Cards).
4. **Release Keystore & Bundle**:
   - Android App Bundle (`.aab`) signed with production upload key.
   - Core library desugaring verified (`desugar_jdk_libs:2.1.4`).

---

## 🔮 3. Post-Launch Phased Roadmap

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

## 🏁 4. V1 Release Gate Status Summary

| Area | Status | Release Requirement |
| :--- | :---: | :--- |
| **Core habit loop** | 🟢 | Complete & verified on hardware. |
| **Onboarding** | 🟢 | Complete (Starter packs + Day 1 Check-in). |
| **Streak engine** | 🟡 | Adversarial date & schedule test suite. |
| **Consistency engine** | 🟢 | Scheduled opportunity calculation + Planned days subtitle. |
| **Recovery mechanism** | 🟢 | Never Miss Twice recovery card. |
| **Analytics & Rhythm** | 🟢 | Peak day vs Risk day diagnostics. |
| **Local persistence** | 🟡 | Disaster test suite execution. |
| **Backup / Restore** | 🟡 | JSON corrupted/empty/duplicate import test. |
| **Notifications** | 🟡 | 1 daily reminder + permission flow. |
| **PRO UI & Paywall** | 🟢 | 3-tier selector + 48h test drive. |
| **Google Play Billing** | 🔴 | Sandbox lifecycle (Purchase, Cancel, Restore). |
| **Release Build** | 🟢 | Verified release compilation & Impeller rendering. |
| **Privacy Policy** | 🔴 | Publish accurate V1 local-first declaration. |
| **Play Data Safety** | 🔴 | Complete Google Play Console submission. |
| **Store Screenshots** | 🔴 | Render 5 high-converting feature screenshots. |
| **App Icon** | 🔴 | Finalize 512×512 PNG. |

