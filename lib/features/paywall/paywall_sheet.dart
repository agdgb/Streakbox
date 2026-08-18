import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_preset.dart';
import '../../state/pro_entitlement_provider.dart';
import '../../state/theme_preset_provider.dart';

/// Ultra-Premium, High-Converting Paywall Modal Sheet for Streakbox PRO.
class PaywallSheet extends ConsumerStatefulWidget {
  final String trigger;

  const PaywallSheet({
    super.key,
    this.trigger = 'General',
  });

  /// Displays the Paywall as a modal bottom sheet.
  static Future<void> show(BuildContext context, {String trigger = 'General'}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallSheet(trigger: trigger),
    );
  }

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  ProPlanType _selectedPlan = ProPlanType.annual;
  bool _isProcessing = false;

  String get _triggerHeadline {
    switch (widget.trigger) {
      case 'Theme Studio':
        return 'Unlock Signature Neumorphic Themes';
      case 'Streak Freeze':
        return 'Protect Your Streak with Pro Shields';
      case 'Cloud Sync':
        return 'Sync Seamlessly Across All Devices';
      case 'Trend Radar':
        return 'Unlock Deep Rhythm & Velocity Analytics';
      case 'Smart Nudges':
        return 'Supercharge Habits with Psychology Nudges';
      default:
        return 'Unlock the Full Power of Streakbox';
    }
  }

  String get _triggerSubhead {
    switch (widget.trigger) {
      case 'Theme Studio':
        return 'Experience Nordic Noir, Ember Sunset, OLED Cyber, and all future luxury themes.';
      case 'Streak Freeze':
        return 'Never lose your hard-earned progress during sickness, vacations, or busy sprints.';
      case 'Cloud Sync':
        return 'Realtime encrypted sync across iOS, Android, and Desktop with zero data loss.';
      case 'Trend Radar':
        return 'Discover your peak days, completion velocity, and correlation insights.';
      default:
        return 'Everything you need to build unbreakable habits with pure focus and luxury design.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themePreset.isDark;
    final proState = ref.watch(proEntitlementProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: themePreset.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: themePreset.textSecondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    // Ambient Hero Crown Banner
                    _buildHeroBanner(context, isDark, themePreset),
                    const SizedBox(height: 16),

                    // Context Trigger Header
                    Text(
                      _triggerHeadline,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2(context).copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _triggerSubhead,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: themePreset.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Value Proposition Feature Grid
                    _buildFeatureMatrix(context, isDark, themePreset),
                    const SizedBox(height: 22),

                    // Interactive Subscription Plan Cards
                    _buildPlanSelector(context, isDark, themePreset),
                    const SizedBox(height: 20),

                    // Primary Action Button (Subscribe / Start Trial)
                    _buildPrimaryCtaButton(context, isDark, themePreset),
                    const SizedBox(height: 12),

                    // 1-Tap 48-Hour Free Test Drive Button (if not already trial active)
                    if (!proState.isPro) ...[
                      _buildTrialTestDriveButton(context, isDark, themePreset),
                      const SizedBox(height: 14),
                    ],

                    // Trust & Compliance Legal Footer
                    _buildComplianceFooter(context, isDark, themePreset),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Ambient Hero Crown Banner
  // ---------------------------------------------------------------------------
  Widget _buildHeroBanner(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.18 : 0.12),
            const Color(0xFFEF4444).withValues(alpha: isDark ? 0.12 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 32,
              color: Colors.black,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1.05, 1.05),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'STREAKBOX',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Value Proposition Feature Grid
  // ---------------------------------------------------------------------------
  Widget _buildFeatureMatrix(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
  ) {
    final features = [
      (Icons.palette_rounded, 'Signature Themes', 'Nordic Noir, Ember Sunset & OLED Cyber'),
      (Icons.shield_rounded, 'Unlimited Streak Freezes', 'Vacation shields so progress never resets'),
      (Icons.alt_route_rounded, 'Habit Stacking & Chains', 'Link triggers (Habit A triggers Habit B)'),
      (Icons.cloud_sync_rounded, 'Realtime Cloud Sync', 'Encrypted multi-device sync across all phones'),
      (Icons.psychology_rounded, 'Behavioral Psychology', 'Momentum boosters & loss aversion nudges'),
      (Icons.radar_rounded, 'Deep Trend Radar', 'Rhythm analysis & Year-in-Review Wrapped'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: themePreset.neumorphicCard(
        radius: 18,
        customColor: isDark ? themePreset.cardColor : AppColors.lightSurface,
      ),
      child: Column(
        children: [
          for (int i = 0; i < features.length; i++) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    features[i].$1,
                    size: 16,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        features[i].$2,
                        style: AppTextStyles.labelBold(context).copyWith(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        features[i].$3,
                        style: AppTextStyles.caption(context).copyWith(
                          color: themePreset.textSecondaryColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
              ],
            ),
            if (i < features.length - 1)
              Divider(
                height: 16,
                color: themePreset.borderColor.withValues(alpha: 0.3),
              ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Interactive Subscription Plan Cards
  // ---------------------------------------------------------------------------
  Widget _buildPlanSelector(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
  ) {
    return Column(
      children: [
        // Annual Flagship (Recommended)
        _buildPlanCard(
          context,
          plan: ProPlanType.annual,
          title: 'Annual Flagship',
          price: '\$19.99 / year',
          subtext: '\$1.66 / mo • Includes 7-Day Free Trial',
          badgeText: 'BEST VALUE • SAVE 44%',
          badgeColor: const Color(0xFF10B981),
          isDark: isDark,
          themePreset: themePreset,
        ),
        const SizedBox(height: 10),

        // Lifetime Founder
        _buildPlanCard(
          context,
          plan: ProPlanType.lifetime,
          title: 'Lifetime Founder',
          price: '\$49.99 one-time',
          subtext: 'Pay once, own all future features forever',
          badgeText: 'LIMITED EDITION',
          badgeColor: const Color(0xFFF59E0B),
          isDark: isDark,
          themePreset: themePreset,
        ),
        const SizedBox(height: 10),

        // Monthly Sprint
        _buildPlanCard(
          context,
          plan: ProPlanType.monthly,
          title: 'Monthly Sprint',
          price: '\$2.99 / month',
          subtext: 'Flexible goal sprint • Cancel anytime',
          badgeText: null,
          badgeColor: null,
          isDark: isDark,
          themePreset: themePreset,
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required ProPlanType plan,
    required String title,
    required String price,
    required String subtext,
    required String? badgeText,
    required Color? badgeColor,
    required bool isDark,
    required AppThemePreset themePreset,
  }) {
    final isSelected = _selectedPlan == plan;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF282E3A) : Colors.white)
              : (isDark ? themePreset.cardColor : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : themePreset.borderColor.withValues(alpha: 0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : themePreset.textSecondaryColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Plan Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelBold(context).copyWith(
                          fontSize: 14,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor!.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.5),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: badgeColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: AppTextStyles.caption(context).copyWith(
                      color: themePreset.textSecondaryColor,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              price,
              style: AppTextStyles.labelBold(context).copyWith(
                fontSize: 14,
                color: isSelected ? const Color(0xFFF59E0B) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Primary CTA Button
  // ---------------------------------------------------------------------------
  Widget _buildPrimaryCtaButton(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
  ) {
    String buttonText;
    switch (_selectedPlan) {
      case ProPlanType.annual:
        buttonText = 'Start 7-Day Free Trial';
        break;
      case ProPlanType.lifetime:
        buttonText = 'Unlock Lifetime Access';
        break;
      case ProPlanType.monthly:
        buttonText = 'Continue with Monthly Sprint';
        break;
      default:
        buttonText = 'Unlock Streakbox PRO';
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isProcessing
            ? null
            : () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                setState(() => _isProcessing = true);
                await Future.delayed(const Duration(milliseconds: 600));
                ref
                    .read(proEntitlementProvider.notifier)
                    .activatePlan(_selectedPlan);
                if (!mounted) return;
                setState(() => _isProcessing = false);
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.black, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Streakbox PRO Activated! Welcome aboard.',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFF59E0B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.5),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. 1-Tap 48-Hour Free Test Drive Button
  // ---------------------------------------------------------------------------
  Widget _buildTrialTestDriveButton(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(proEntitlementProvider.notifier).start48HourTrial();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '48-Hour Free Test Drive Activated! Enjoy PRO.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.timer_rounded, size: 18),
        label: const Text(
          'Or Start Instant 48-Hour Test Drive (1-Tap)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: themePreset.textPrimaryColor,
          side: BorderSide(
            color: themePreset.borderColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Trust & Compliance Legal Footer
  // ---------------------------------------------------------------------------
  Widget _buildComplianceFooter(
    BuildContext context,
    bool isDark,
    AppThemePreset themePreset,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final restored = await ref
                    .read(proEntitlementProvider.notifier)
                    .restorePurchases();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      restored
                          ? 'Purchases restored successfully!'
                          : 'No prior purchases found to restore.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  fontSize: 11,
                  color: themePreset.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(
                color: themePreset.textSecondaryColor.withValues(alpha: 0.5),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 11,
                  color: themePreset.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(
                color: themePreset.textSecondaryColor.withValues(alpha: 0.5),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 11,
                  color: themePreset.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Cancel anytime in Google Play / App Store subscriptions. Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9.5,
            color: themePreset.textSecondaryColor.withValues(alpha: 0.6),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
