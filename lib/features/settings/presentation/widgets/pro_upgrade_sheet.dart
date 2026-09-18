import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/entitlement/entitlement_model.dart';
import '../../../../core/entitlement/entitlement_provider.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../providers/doctor_profile_provider.dart';

/// Modal bottom sheet presenting either:
/// 1. Enterprise Subscription & License Management (for Active Pro subscribers)
/// 2. Transparent pricing tiers, feature comparison, and Doctor Data Guarantee (for Free & Trial)
class ProUpgradeSheet extends ConsumerStatefulWidget {
  const ProUpgradeSheet({super.key});

  /// Display the upgrade or subscription management sheet modally.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
          content: const Text(
            'Voucher redeemed successfully! ClinicPilot Pro license is active.',
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
          'ClinicPilot Pro activated (${_selectedPlanIndex == 0 ? "Annual Plan" : "Monthly Plan"}).',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _showSwitchPlanDialog(
    BuildContext context,
    String targetPlan,
  ) async {
    final isTargetAnnual = targetPlan == 'annual_pro';
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              isTargetAnnual
                  ? 'Switch to Annual Plan?'
                  : 'Switch to Monthly Plan?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              isTargetAnnual
                  ? 'Your subscription will switch to Annual Pro (₹1,999/year). You save 17% compared to monthly billing.'
                  : 'Your subscription will switch to Monthly Pro (₹199/month).',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Confirm Switch'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      AppHaptics.selection();
      await ref
          .read(entitlementControllerProvider.notifier)
          .changePlan(targetPlan);

      if (!mounted) return;
      AppHaptics.success();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Subscription switched to ${isTargetAnnual ? "Annual Plan" : "Monthly Plan"}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showTaxReceiptDialog(
    BuildContext context,
    EntitlementState entitlement,
  ) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final doctorProfile =
        ref.read(doctorProfileStreamProvider).value ?? const DoctorProfile();

    final doctorName =
        doctorProfile.firstName.isNotEmpty
            ? 'Dr. ${doctorProfile.firstName} ${doctorProfile.lastName}'.trim()
            : (doctorProfile.name.isNotEmpty
                ? doctorProfile.name
                : 'Registered Practitioner');
    final specialty = doctorProfile.specialty.label;

    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final receiptId =
        'CP-REC-${now.year}${now.month.toString().padLeft(2, '0')}-${(entitlement.planName ?? 'PRO').replaceAll('_', '').toUpperCase().substring(0, 3)}-${now.day.toString().padLeft(2, '0')}';

    final isMonthly = entitlement.planName == 'monthly_pro';
    final subtotal = isMonthly ? '₹168.64' : '₹1,694.07';
    final gst = isMonthly ? '₹30.36' : '₹304.93';
    final total = isMonthly ? '₹199.00' : '₹1,999.00';

    await showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.lg,
              Spacing.lg,
              Spacing.sm,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            title: Row(
              children: [
                Icon(Icons.receipt_long, color: scheme.primary),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Practice Tax Receipt',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CustomBadge(label: 'PAID', color: scheme.primary),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: Radii.smAll,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receipt #: $receiptId',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Date: $dateStr',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Issued To: $doctorName ($specialty)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Plan: ${entitlement.formattedPlanName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taxable Subtotal:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(subtotal, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GST (18%):',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(gst, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const Divider(height: Spacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        total,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Payment Mode: In-App Billing / Digital Payment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Protected under ClinicPilot Doctor Data Guarantee. 100% offline clinical records.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  final text =
                      'ClinicPilot Tax Receipt\nReceipt #: $receiptId\nDate: $dateStr\nIssued To: $doctorName\nPlan: ${entitlement.formattedPlanName}\nTotal: $total (PAID)\nStatus: Active Pro';
                  Clipboard.setData(ClipboardData(text: text));
                  AppHaptics.selection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tax receipt summary copied to clipboard.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _showCancelSubscriptionDialog(
    BuildContext context,
    EntitlementState entitlement,
  ) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: scheme.error),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Cancel Subscription?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: Radii.smAll,
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: scheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: Spacing.sm),
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
                                'Zero clinical data loss. Unlimited patients, visit notes, homeopathic repertorizations, and local backups remain 100% free and permanently accessible on this device.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'If you cancel, your practice will transition to the Free Plan (1 primary clinic, manual backups, standard letterhead).',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Keep My Subscription'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                child: const Text('Confirm Cancellation'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      AppHaptics.selection();
      await ref
          .read(entitlementControllerProvider.notifier)
          .cancelSubscription();

      if (!mounted) return;
      AppHaptics.medium();
      nav.pop(); // Close sheet

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription cancelled. Your practice has transitioned to the Free Plan with zero clinical data loss.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final entitlement =
        ref.watch(entitlementStreamProvider).value ?? const EntitlementState();

    final isProActiveSubscriber = entitlement.isPro && !entitlement.isTrial;

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
        child:
            isProActiveSubscriber
                ? _buildActiveSubscriptionView(
                  context,
                  theme,
                  scheme,
                  entitlement,
                )
                : _buildUpgradeView(context, theme, scheme, entitlement),
      ),
    );
  }

  /// Enterprise Subscription & License Management for active Pro subscribers.
  Widget _buildActiveSubscriptionView(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    EntitlementState entitlement,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
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
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: scheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: Spacing.sm,
                    runSpacing: Spacing.xs,
                    children: [
                      Text(
                        'Subscription & License',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CustomBadge(label: 'ACTIVE', color: scheme.primary),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ClinicPilot Enterprise & Practice Management',
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

        // Plan Overview Card
        AppCard(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: scheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Expanded(
                          child: Text(
                            entitlement.formattedPlanName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: Radii.pillAll,
                    ),
                    child: Text(
                      entitlement.formattedBillingCycle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              const Divider(height: 1),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Status: Active • Auto-renewing',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Renewal / Expiry: ${entitlement.formattedExpiryDescription}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (entitlement.redeemedCode != null) ...[
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.vpn_key_outlined,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'License Key: ${entitlement.redeemedCode}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: Spacing.md),

        // Active Entitlements Summary
        Text(
          'Active Enterprise Entitlements:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        _buildActiveBenefitItem(
          theme,
          scheme,
          Icons.local_hospital_outlined,
          'Multi-Clinic Practice',
          'Manage 2+ locations & side-by-side branch comparison',
        ),
        _buildActiveBenefitItem(
          theme,
          scheme,
          Icons.cloud_sync_outlined,
          'Automated Cloud Sync',
          'Daily encrypted sync to personal Google Drive / WebDAV',
        ),
        _buildActiveBenefitItem(
          theme,
          scheme,
          Icons.print_outlined,
          'Custom Branded Rx Letterheads',
          'Clinic logo, doctor digital signature & credentials',
        ),
        _buildActiveBenefitItem(
          theme,
          scheme,
          Icons.analytics_outlined,
          'Tax & Yearly P&L Analytics',
          'Practice tax breakdowns and revenue performance',
        ),
        _buildActiveBenefitItem(
          theme,
          scheme,
          Icons.grid_on_outlined,
          'Audit-Ready Excel (XLSX) Export',
          'Comprehensive multi-sheet audit spreadsheets',
        ),
        _buildActiveBenefitItem(
          theme,
          scheme,
          Icons.block_outlined,
          '100% Ad-Free Forever',
          'Zero ads, zero data tracking, zero third-party telemetry',
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
                      'Your patient records, clinical cases, remedies, and local backups are 100% free and permanently accessible on this device. ClinicPilot will NEVER lock your clinical data.',
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

        // Subscription Management Actions
        Text(
          'Manage Plan & Billing:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),

        // Switch plan action
        if (entitlement.planName == 'monthly_pro')
          _buildActionTile(
            theme: theme,
            scheme: scheme,
            icon: Icons.swap_horiz_rounded,
            title: 'Switch to Annual Plan (Save 17%)',
            subtitle: '₹1,999/year (~₹166/month)',
            onTap: () => _showSwitchPlanDialog(context, 'annual_pro'),
          )
        else if (entitlement.planName == 'annual_pro')
          _buildActionTile(
            theme: theme,
            scheme: scheme,
            icon: Icons.swap_horiz_rounded,
            title: 'Switch to Monthly Plan',
            subtitle: '₹199/month (flexible monthly billing)',
            onTap: () => _showSwitchPlanDialog(context, 'monthly_pro'),
          ),

        // View GST Tax Receipt
        _buildActionTile(
          theme: theme,
          scheme: scheme,
          icon: Icons.receipt_long_outlined,
          title: 'View Tax Receipt / Invoice',
          subtitle: 'Audit-ready GST receipt for practice tax filing',
          onTap: () => _showTaxReceiptDialog(context, entitlement),
        ),

        // Redeem voucher code
        if (!_showCodeInput)
          _buildActionTile(
            theme: theme,
            scheme: scheme,
            icon: Icons.card_giftcard_outlined,
            title: 'Redeem Voucher or Extension Code',
            subtitle: 'Extend or activate partner licenses',
            onTap: () => setState(() => _showCodeInput = true),
          )
        else
          _buildVoucherInputField(theme, scheme),

        // Cancel Subscription
        _buildActionTile(
          theme: theme,
          scheme: scheme,
          icon: Icons.cancel_outlined,
          iconColor: scheme.error,
          title: 'Cancel Subscription',
          subtitle: 'Revert to Free tier with zero clinical data loss',
          onTap: () => _showCancelSubscriptionDialog(context, entitlement),
        ),

        const SizedBox(height: Spacing.md),

        // Store billing notice
        Text(
          'Subscriptions initiated through Google Play or Apple App Store are managed by your store account. You can also view or modify billing directly in store Subscriptions.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: Spacing.md),

        // Done button
        AppButton.tonal(
          label: 'Done',
          fullWidth: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Upgrade & transparent pricing sheet for Free & Trial users.
  Widget _buildUpgradeView(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    EntitlementState entitlement,
  ) {
    final accentColor = scheme.tertiary;

    return Column(
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
                            entitlement.isTrial && !entitlement.isTrialExpired
                                ? 'TRIAL ACTIVE'
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
              border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
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
                              : scheme.outlineVariant.withValues(alpha: 0.5),
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
                          color: _selectedPlanIndex == 0 ? accentColor : null,
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
                              : scheme.outlineVariant.withValues(alpha: 0.5),
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
                          color: _selectedPlanIndex == 1 ? accentColor : null,
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
          Icons.local_hospital_outlined,
          'Multi-Clinic Practice',
          'Manage 2+ clinics with independent rosters and side-by-side comparison.',
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
          Icons.grid_on_outlined,
          'Bulk Excel (XLSX) Export',
          'Export comprehensive audit-ready spreadsheets for tax and practice analysis.',
        ),
        _buildCheckItem(
          theme,
          Icons.block_outlined,
          '100% Ad-Free Forever',
          'Zero banner ads, zero popups, zero marketing spyware.',
        ),

        const SizedBox(height: Spacing.sm),

        // Free vs Pro Comparison Expander
        Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: Spacing.sm),
            leading: Icon(
              Icons.compare_arrows_rounded,
              size: 20,
              color: scheme.primary,
            ),
            title: Text(
              'Compare Free vs. Pro Plans',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            children: [
              _buildComparisonHeader(theme, scheme),
              const Divider(height: 1),
              _buildComparisonRow(
                theme,
                scheme,
                'Unlimited Patients & Cases',
                free: true,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                '17-Section Homeopathic Engine',
                free: true,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Medicine Inventory & Alerts',
                free: true,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Cash Memos & Thermal Print',
                free: true,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Encrypted Local Backups',
                free: true,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Primary Clinic (1 Location)',
                free: true,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Multi-Clinic (2+ Locations)',
                free: false,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Clinic Comparison Analytics',
                free: false,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Custom Rx Logo & Signature',
                free: false,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Automated Daily Cloud Sync',
                free: false,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Yearly Tax & P&L Intelligence',
                free: false,
                pro: true,
              ),
              _buildComparisonRow(
                theme,
                scheme,
                'Audit-Ready Excel (.xlsx)',
                free: false,
                pro: true,
              ),
            ],
          ),
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
          _buildVoucherInputField(theme, scheme),
        ],

        const SizedBox(height: Spacing.md),

        // Primary Action Button
        AppButton.primary(
          label:
              _selectedPlanIndex == 0
                  ? 'Upgrade to Annual Pro (₹1,999/yr)'
                  : 'Upgrade to Monthly Pro (₹199/mo)',
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
    );
  }

  Widget _buildVoucherInputField(ThemeData theme, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Redeem'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBenefitItem(
    ThemeData theme,
    ColorScheme scheme,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: scheme.primary),
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
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required ThemeData theme,
    required ColorScheme scheme,
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 2,
        ),
        leading: Icon(icon, color: iconColor ?? scheme.primary, size: 22),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: iconColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 18,
          color: scheme.onSurfaceVariant,
        ),
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
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

  Widget _buildComparisonHeader(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Feature / Capability',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Center(
              child: Text(
                'Free',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Center(
              child: Text(
                'Pro',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    ThemeData theme,
    ColorScheme scheme,
    String title, {
    required bool free,
    required bool pro,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Center(
              child:
                  free
                      ? Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: scheme.primary,
                      )
                      : Icon(
                        Icons.remove,
                        size: 16,
                        color: scheme.outlineVariant,
                      ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Center(
              child:
                  pro
                      ? Icon(
                        Icons.check_circle,
                        size: 16,
                        color: scheme.primary,
                      )
                      : Icon(
                        Icons.remove,
                        size: 16,
                        color: scheme.outlineVariant,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
