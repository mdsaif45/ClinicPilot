import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/period_selector.dart';
import '../../dashboard/presentation/widgets/clinic_health_score_card.dart';
import '../providers/growth_provider.dart';
import '../providers/profit_provider.dart';
import '../providers/review_provider.dart';

/// Landing screen for the Growth tab.
class GrowthHubScreen extends ConsumerWidget {
  const GrowthHubScreen({super.key});

  void _showGoogleReviewsSheet(
    BuildContext context,
    ReviewStats? reviews,
  ) {
    AppHaptics.selection();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = reviews?.totalReviewed ?? 0;
    final thisMonth = reviews?.thisMonthReviewed ?? 0;
    final avgRating = reviews?.averageRating ?? 0.0;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl,
          Spacing.sm,
          Spacing.xl,
          Spacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.primary,
                  child: const Icon(Icons.star, size: 22),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Reviews & Reputation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Patient ratings & Google review conversion',
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
            Row(
              children: [
                Expanded(
                  child: _ReviewStatBox(
                    label: 'Total Reviews',
                    value: '$total',
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _ReviewStatBox(
                    label: 'This Month',
                    value: '$thisMonth',
                    color: scheme.tertiary,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _ReviewStatBox(
                    label: 'Avg. Rating',
                    value: avgRating > 0 ? '${avgRating.toStringAsFixed(1)} ★' : '—',
                    color: scheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Tip: Send a review request to happy patients directly from the Patient Profile > WhatsApp quick actions after a successful consultation.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            AppButton.primary(
              label: 'Close',
              fullWidth: true,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growth = ref.watch(growthAnalyticsProvider).value;
    final profit = ref.watch(profitSummaryProvider).value;
    final reviews = ref.watch(reviewStatsProvider).value;

    final reviewCount = reviews?.totalReviewed ?? 0;
    final avgRating = reviews?.averageRating ?? 0.0;

    return ListView(
      // Standard top padding so first card never touches upper screen boundary
      padding: const EdgeInsets.fromLTRB(0, Spacing.md, 0, Spacing.xxl),
      children: [
        const ClinicHealthScoreCard(),
        const PeriodSelector(),
        _MenuCard(
          icon: Icons.trending_up,
          title: 'Growth Overview',
          subtitle: 'New and repeat patients, trend, quick stats',
          trailing: growth == null
              ? null
              : '${growth.totalNewPatients} new',
          onTap: () => context.push('/growth/overview'),
        ),
        _MenuCard(
          icon: Icons.insights_outlined,
          title: 'Practice Activity',
          subtitle: 'Hourly OPD rush, weekly targets & monthly bubble heatmap',
          onTap: () => context.push('/growth/activity'),
        ),
        _MenuCard(
          icon: Icons.auto_stories_outlined,
          title: 'Practice Journal',
          subtitle: 'Chronological consultations, pharmacy invoices & receipts',
          onTap: () => context.push('/growth/journal'),
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
        _MenuCard(
          icon: Icons.star_outline,
          title: 'Google Reviews & Reputation',
          subtitle: 'Track positive patient reviews and 5-star Google rating',
          trailing: reviewCount > 0
              ? '$reviewCount reviews • ${avgRating.toStringAsFixed(1)} ★'
              : 'View stats',
          onTap: () => _showGoogleReviewsSheet(context, reviews),
        ),
      ],
    );
  }
}

class _ReviewStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReviewStatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.mdAll,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs + 1,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: Radii.mdAll,
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Spacing.sm),
            Text(
              trailing!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
          const SizedBox(width: Spacing.xs),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
