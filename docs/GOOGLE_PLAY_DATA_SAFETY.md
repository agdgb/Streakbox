# Google Play Console — Data Safety Form Guide

Use this guide to complete the **Data Safety** questionnaire in Google Play Console for Streakbox V1.0.

---

## 1. Overview & Data Collection Summary

| Question in Play Console | Answer | Reason / Explanation |
| :--- | :---: | :--- |
| **Does your app collect or share any of the required user data types?** | **No** | Streakbox V1 stores all habit data locally on the user's device in SQLite. No data is transmitted to external servers. |
| **Is all of the user data collected by your app encrypted in transit?** | **N/A (No data transmitted)** | The app does not transmit data over the network. |
| **Do you provide a way for users to request that their data be deleted?** | **Yes** | Users can permanently delete individual habits or wipe all data in-app with 1-tap. |

---

## 2. In-App Purchase & Financial Information

| Category | Answer | Note |
| :--- | :---: | :--- |
| **Financial info (Credit card, bank account)** | **No** | Handled 100% by Google Play Billing library. App does not access financial data. |
| **Purchase history** | **Handled by Google Play** | Handled natively by Play Billing for entitlement verification. |

---

## 3. Advertising & Analytics

| Category | Answer | Note |
| :--- | :---: | :--- |
| **Advertising ID** | **No** | No advertising SDKs (AdMob, Unity Ads, etc.) are bundled in V1.0. |
| **Analytics / Diagnostics** | **No** | No third-party analytics (Firebase Analytics, Mixpanel, AppsFlyer) in V1.0. |

---

## 4. App Permissions Justification

| Permission | Justification for Google Play Review |
| :--- | :--- |
| `android.permission.POST_NOTIFICATIONS` | Required to deliver scheduled local habit reminders and streak milestone alerts to the user. |
| `android.permission.SCHEDULE_EXACT_ALARM` | Required to trigger local alarms accurately at the user's designated morning/evening anchor times. |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Required to reschedule active local habit notification alarms when the device reboots. |
