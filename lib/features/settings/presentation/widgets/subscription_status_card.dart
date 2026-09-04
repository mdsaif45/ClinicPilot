import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/entitlement/entitlement_model.dart';
import '../../../../core/entitlement/entitlement_provider.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pro_badge.dart';
import 'pro_upgrade_sheet.dart';

/// Prominent card in Settings reflecting the doctor's current entitlement tier,
/// trial countdown progress bar, and 1-tap upgrade entry.
class SubscriptionStatusCard extends ConsumerWidget {
  const SubscriptionStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entitlement =
        ref.watch(entitlementStreamProvider).value ?? const EntitlementState();

    final accentColor = scheme.tertiary;

    final bool isTrial = entitlement.isTrial && !entitlement.isTrialExpired;
    final bool isProActive = entitlement.tier == SubscriptionTier.proActive;

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      onTap: () => ProUpgradeSheet.show(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.xs + 2),
                decoration: BoxDecoration(
                  color:
                      isProActive
                          ? scheme.primaryContainer
                          : accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isProActive ? Icons.verified : Icons.workspace_premium,
                  color: isProActive ? scheme.primary : accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isProActive
                              ? 'ClinicPilot Pro'
                              : (isTrial ? 'Pro Beta Trial' : 'Free Plan'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        ProBadge(
                          label:
                              isProActive
                                  ? 'PRO'
                                  : (isTrial ? 'TRIAL' : 'FREE'),
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isProActive
                          ? 'All automated features unlocked'
                          : (isTrial
                              ? '${entitlement.daysRemainingInTrial} days remaining • All Pro perks unlocked'
                              : 'Core clinical records free forever'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),

          // Visual progress bar for trial countdown
          if (isTrial) ...[
            const SizedBox(height: Spacing.md),
            ClipRRect(
              borderRadius: Radii.pillAll,
              child: LinearProgressIndicator(
                value: entitlement.trialRemainingFraction,
                minHeight: 5,
                backgroundColor: accentColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
