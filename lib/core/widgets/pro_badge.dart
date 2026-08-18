import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/paywall/paywall_sheet.dart';
import '../../state/pro_entitlement_provider.dart';

/// Elegant gold/emerald PRO badge for labeling premium features.
class ProBadge extends StatelessWidget {
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final bool isGold;

  const ProBadge({
    super.key,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.isGold = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isGold
        ? const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          )
        : const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: (isGold ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
                .withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 10,
            color: Colors.black,
          ),
          const SizedBox(width: 3),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Universal 1-line gating guard for protecting Pro features.
class ProGate {
  ProGate._();

  /// Guards a feature execution. If the user has active Pro access, [onAllowed] is invoked.
  /// If the user is on the Free tier, [PaywallSheet] is automatically presented with the given [trigger] context.
  static void guard(
    BuildContext context,
    WidgetRef ref, {
    required String trigger,
    required VoidCallback onAllowed,
  }) {
    final proState = ref.read(proEntitlementProvider);
    if (proState.isPro) {
      onAllowed();
    } else {
      PaywallSheet.show(context, trigger: trigger);
    }
  }
}
