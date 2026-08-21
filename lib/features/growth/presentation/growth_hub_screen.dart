import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/period_selector.dart';
import '../providers/growth_provider.dart';
import '../providers/profit_provider.dart';

/// Landing screen for the Growth tab.
///
/// The four analytics views answer different questions and each is dense
/// enough to want a full screen, so this presents them as a menu rather than
/// stacking everything into one long scroll.
class GrowthHubScreen extends ConsumerWidget {
  const GrowthHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growth = ref.watch(growthAnalyticsProvider).value;
    final profit = ref.watch(profitSummaryProvider).value;

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xxl),
      children: [
        const PeriodSelector(),
        _MenuCard(
          icon: Icons.trending_up,
          title: 'Growth Overview',
          subtitle: 'New and repeat patients, trend, quick stats',
          // A preview value on each card means the menu itself answers
          // something, rather than being a list of doors.
          trailing: growth == null
              ? null
              : '${growth.totalNewPatients} new',
          onTap: () => context.push('/growth/overview'),
        ),
        _MenuCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Profit Summary',
          subtitle: 'Income, expenses, profit trend, best day',
          trailing: profit == null
              ? null
              : Formatters.formatCurrency(profit.netProfit),
          onTap: () => context.push('/growth/profit'),
        ),
        _MenuCard(
          icon: Icons.compare_arrows,
          title: 'Clinic Comparison',
          subtitle: 'Revenue, profit and patients per clinic',
          onTap: () => context.push('/comparison'),
        ),
        _MenuCard(
          icon: Icons.share_outlined,
          title: 'Referral Source',
          subtitle: 'Where patients come from, and what each is worth',
          onTap: () => context.push('/growth/referral'),
        ),
        _MenuCard(
          icon: Icons.campaign_outlined,
          title: 'Camp Manager & ROI',
          subtitle: 'Free camp tracking, costs and patient follow-up revenue ROI',
          onTap: () => context.push('/growth/camps'),
        ),
        _MenuCard(
          icon: Icons.medical_services_outlined,
          title: 'Disease Analytics',
          subtitle: 'Revenue per condition, patient volume and repeat retention',
          onTap: () => context.push('/growth/diseases'),
        ),
        _MenuCard(
          icon: Icons.store_outlined,
          title: 'Referral Partner CRM',
          subtitle: 'Pharmacies, labs, physios & local healthcare partner outreach',
          onTap: () => context.push('/growth/referral-crm'),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.md,
      ),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: Radii.lgAll,
              border: Border.all(color: scheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: Radii.mdAll,
                  ),
                  child: Icon(icon, color: scheme.primary),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: Spacing.sm),
                  Text(
                    trailing!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(width: Spacing.xs),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
