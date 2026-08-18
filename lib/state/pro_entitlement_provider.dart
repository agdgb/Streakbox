import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available subscription plan types in Streakbox PRO.
enum ProPlanType {
  none,
  trial48h,
  monthly,
  annual,
  lifetime,
}

/// Comprehensive Pro entitlement state across Streakbox.
class ProTierState {
  final bool isSubscribed;
  final ProPlanType planType;
  final DateTime? trialEnd;

  const ProTierState({
    this.isSubscribed = false,
    this.planType = ProPlanType.none,
    this.trialEnd,
  });

  /// Whether the 48-hour free test drive is currently running.
  bool get isTrialActive {
    if (trialEnd == null) return false;
    return DateTime.now().isBefore(trialEnd!);
  }

  /// True if the user is either a paid subscriber or currently enjoying the 48-hour trial.
  bool get isPro => isSubscribed || isTrialActive;

  /// Remaining trial hours (0 if expired or not started).
  int get remainingTrialHours {
    if (!isTrialActive || trialEnd == null) return 0;
    return trialEnd!.difference(DateTime.now()).inHours + 1;
  }

  /// Human-readable active plan badge label.
  String get planLabel {
    if (isTrialActive) return '48H FREE TRIAL';
    switch (planType) {
      case ProPlanType.annual:
        return 'PRO ANNUAL';
      case ProPlanType.lifetime:
        return 'PRO LIFETIME';
      case ProPlanType.monthly:
        return 'PRO MONTHLY';
      case ProPlanType.trial48h:
        return 'PRO TRIAL';
      case ProPlanType.none:
        return 'FREE TIER';
    }
  }

  // ---------------------------------------------------------------------------
  // Feature Access Permissions
  // ---------------------------------------------------------------------------
  bool get canUseProThemes => isPro;
  bool get canUseStreakFreeze => isPro;
  bool get canUseHabitStacking => isPro;
  bool get canUseCloudSync => isPro;
  bool get canUseSmartNudges => isPro;
  bool get canUseTrendRadar => isPro;
  bool get canUseYearInReview => isPro;

  ProTierState copyWith({
    bool? isSubscribed,
    ProPlanType? planType,
    DateTime? trialEnd,
  }) {
    return ProTierState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      planType: planType ?? this.planType,
      trialEnd: trialEnd ?? this.trialEnd,
    );
  }
}

/// Centralized state notifier for managing Pro entitlements, trials, and simulated IAP.
class ProEntitlementNotifier extends Notifier<ProTierState> {
  @override
  ProTierState build() {
    return const ProTierState();
  }

  /// Starts the frictionless 48-hour free trial.
  void start48HourTrial() {
    state = ProTierState(
      isSubscribed: false,
      planType: ProPlanType.trial48h,
      trialEnd: DateTime.now().add(const Duration(hours: 48)),
    );
  }

  /// Activates a purchased Pro subscription tier.
  void activatePlan(ProPlanType plan) {
    state = ProTierState(
      isSubscribed: true,
      planType: plan,
      trialEnd: null,
    );
  }

  /// Restores previous purchases (simulated for preview).
  Future<bool> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // For demo/preview, if user already had a plan or trial, it restores
    if (state.isPro) return true;
    return false;
  }

  /// Resets user back to 100% Free tier (for QA testing).
  void resetToFree() {
    state = const ProTierState();
  }
}

/// Global provider for Pro entitlement state.
final proEntitlementProvider =
    NotifierProvider<ProEntitlementNotifier, ProTierState>(
  ProEntitlementNotifier.new,
);
