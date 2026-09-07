import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/entitlement/entitlement_model.dart';
import '../../../../core/entitlement/entitlement_provider.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_badge.dart';

/// Modal bottom sheet presenting ClinicPilot Pro tiers, transparent pricing,
/// ethical doctor data guarantee, and access voucher code redemption.
class ProUpgradeSheet extends ConsumerStatefulWidget {
  const ProUpgradeSheet({super.key});

  /// Display the upgrade sheet modally.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProUpgradeSheet(),
    );
  }

  @override
  ConsumerState<ProUpgradeSheet> createState() => _ProUpgradeSheetState();
}

class _ProUpgradeSheetState extends ConsumerState<ProUpgradeSheet> {
  final TextEditingController _codeController = TextEditingController();
  bool _isRedeeming = false;
  bool _showCodeInput = false;
  int _selectedPlanIndex = 0; // 0 = Annual (Best Value), 1 = Monthly

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeemCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    AppHaptics.selection();
    setState(() => _isRedeeming = true);

    final messenger = ScaffoldMessenger.of(context);
    final success = await ref
        .read(entitlementControllerProvider.notifier)
        .redeemCode(code);

    if (!mounted) return;
    setState(() => _isRedeeming = false);

    if (success) {
      AppHaptics.success();
      _codeController.clear();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Voucher redeemed successfully! ClinicPilot Pro is active.',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      AppHaptics.error();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid or expired access voucher code. Please verify and try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSimulatedPurchase() async {
    AppHaptics.selection();
    final plan = _selectedPlanIndex == 0 ? 'annual_pro' : 'monthly_pro';
    final months = _selectedPlanIndex == 0 ? 12 : 1;

    await ref
        .read(entitlementControllerProvider.notifier)
        .activateSubscription(plan: plan, durationMonths: months);

    if (!mounted) return;
    AppHaptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ClinicPilot Pro activated (${_selectedPlanIndex == 0 ? "Annual Plan" : "Monthly Plan"})! Thank you for supporting independent medical software.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entitlement =
        ref.watch(entitlementStreamProvider).value ?? const EntitlementState();

    final accentColor = scheme.tertiary;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header with Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: accentColor,
                    size: 28,
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
                            'ClinicPilot Pro',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          CustomBadge(
                            label:
                                entitlement.isPro
                                    ? (entitlement.isTrial
                                        ? 'TRIAL ACTIVE'
                                        : 'ACTIVE')
                                    : 'UPGRADE',
                            color: accentColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Practice automation and prestige intelligence',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: Spacing.lg),

            // Trial status message if currently on trial
            if (entitlement.isTrial && !entitlement.isTrialExpired) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: Radii.mdAll,
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: scheme.primary),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'You have ${entitlement.daysRemainingInTrial} days remaining in your free Pro Beta Trial.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],

            // Pricing Plans
            Row(
              children: [
                // Annual Plan Card
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPlanIndex = 0),
                    borderRadius: Radii.mdAll,
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color:
                            _selectedPlanIndex == 0
                                ? accentColor.withValues(alpha: 0.08)
                                : scheme.surfaceContainerLow,
                        borderRadius: Radii.mdAll,
                        border: Border.all(
                          color:
                              _selectedPlanIndex == 0
                                  ? accentColor
                                  : scheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                          width: _selectedPlanIndex == 0 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Annual Plan',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'SAVE 17%',
                                  style: TextStyle(
                                    color: scheme.onTertiary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            '₹1,999',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color:
                                  _selectedPlanIndex == 0 ? accentColor : null,
                            ),
                          ),
                          Text(
                            'per year (~₹166/mo)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                // Monthly Plan Card
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedPlanIndex = 1),
                    borderRadius: Radii.mdAll,
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color:
                            _selectedPlanIndex == 1
                                ? accentColor.withValues(alpha: 0.08)
                                : scheme.surfaceContainerLow,
                        borderRadius: Radii.mdAll,
                        border: Border.all(
                          color:
                              _selectedPlanIndex == 1
                                  ? accentColor
                                  : scheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                          width: _selectedPlanIndex == 1 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Plan',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            '₹199',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color:
                                  _selectedPlanIndex == 1 ? accentColor : null,
                            ),
                          ),
                          Text(
                            'per month',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Spacing.lg),

            // Feature Checklist
            Text(
              'Included in ClinicPilot Pro:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            _buildCheckItem(
              theme,
              Icons.cloud_sync_outlined,
              'Automated Cloud Sync',
              'Background daily sync to your personal Google Drive or WebDAV.',
            ),
            _buildCheckItem(
              theme,
              Icons.print_outlined,
              'Branded PDF Letterheads',
              'Add your clinic logo, digital signature & credentials to printed Rx.',
            ),
            _buildCheckItem(
              theme,
              Icons.analytics_outlined,
              'Practice Intelligence',
              'Detailed tax P&L summaries and cross-clinic performance comparisons.',
            ),
            _buildCheckItem(
              theme,
              Icons.block_outlined,
              '100% Ad-Free Forever',
              'Zero banner ads, zero popups, zero marketing spyware.',
            ),

            const SizedBox(height: Spacing.md),

            // Doctor Data Guarantee Callout
            AppCard(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: scheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor Data Guarantee',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your clinical records (unlimited patients, visits, remedies, and manual backups) are 100% Free Forever on this device. We will NEVER lock your clinical data.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Spacing.md),

            // Redeem Voucher Section
            if (!_showCodeInput) ...[
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showCodeInput = true),
                  icon: const Icon(Icons.card_giftcard, size: 16),
                  label: const Text('Have a Beta Voucher or Access Code?'),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: Radii.mdAll,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Voucher Code',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'e.g. CLINICBETA2026',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        ElevatedButton(
                          onPressed: _isRedeeming ? null : _handleRedeemCode,
                          child:
                              _isRedeeming
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Redeem'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: Spacing.md),

            // Primary Action Button
            AppButton.primary(
              label:
                  entitlement.isPro && !entitlement.isTrial
                      ? 'Manage Subscription'
                      : (_selectedPlanIndex == 0
                          ? 'Upgrade to Annual Pro (₹1,999/yr)'
                          : 'Upgrade to Monthly Pro (₹199/mo)'),
              icon: Icons.workspace_premium,
              fullWidth: true,
              onPressed: _handleSimulatedPurchase,
            ),
            const SizedBox(height: Spacing.sm),
            AppButton.text(
              label: 'Continue with Free Plan',
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
