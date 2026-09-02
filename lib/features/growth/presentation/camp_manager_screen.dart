import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/metric_strip.dart';
import '../../../core/widgets/period_selector.dart';
import '../providers/camp_provider.dart';
import 'add_edit_camp_dialog.dart';

class CampManagerScreen extends ConsumerWidget {
  const CampManagerScreen({super.key});

  void _openAddEditCamp(BuildContext context, [CampWithAnalytics? camp]) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditCampDialog(existingCamp: camp?.camp),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CampWithAnalytics camp,
  ) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Camp?'),
            content: Text(
              'Are you sure you want to delete "${camp.camp.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref
                      .read(campNotifierProvider.notifier)
                      .deleteCamp(camp.camp.id);
                  AppHaptics.success();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campsAsync = ref.watch(campsStreamProvider);
    final statsAsync = ref.watch(campStatsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Camp Manager & ROI')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditCamp(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Camp'),
      ),
      body: campsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load camps: $e')),
        data: (camps) {
          if (camps.isEmpty) {
            return Column(
              children: [
                const PeriodSelector(),
                Expanded(
                  child: EmptyState.growth(
                    title: 'No health camps logged',
                    message:
                        'Record your free eye, pediatric, or general health check-up camps to measure long-term patient conversion and follow-up ROI.',
                    actionLabel: 'Log First Camp',
                    onAction: () => _openAddEditCamp(context),
                  ),
                ),
              ],
            );
          }

          final stats = statsAsync.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              0,
              Spacing.sm,
              0,
              Spacing.xxl * 2,
            ),
            children: [
              const PeriodSelector(),
              if (stats != null)
                MetricStrip(
                  metrics: [
                    Metric(
                      label: 'Camps',
                      value: '${stats.totalCamps}',
                      icon: Icons.festival_outlined,
                      color: scheme.primary,
                    ),
                    Metric(
                      label: 'Total Cost',
                      value: Formatters.formatCurrency(stats.totalCost),
                      icon: Icons.money_off_csred_outlined,
                      color: scheme.error,
                    ),
                    Metric(
                      label: 'Follow-up Rev',
                      value: Formatters.formatCurrency(
                        stats.totalFollowUpRevenue,
                      ),
                      signedAmount: stats.totalFollowUpRevenue,
                      icon: Icons.account_balance_wallet_outlined,
                      color: scheme.secondary,
                    ),
                    Metric(
                      label: 'Net ROI',
                      value:
                          '${stats.aggregateRoi >= 0 ? '+' : ''}${stats.aggregateRoi.toStringAsFixed(0)}%',
                      signedAmount: stats.totalNetProfit,
                      icon: Icons.trending_up_rounded,
                      color: scheme.tertiary,
                    ),
                  ],
                ),
              const SizedBox(height: Spacing.md),
              for (final c in camps)
                AppCard(
                  margin: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    0,
                    Spacing.lg,
                    Spacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.camp.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  '${Formatters.formatDate(c.camp.date)}${c.camp.location != null ? ' • ${c.camp.location}' : ''}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomBadge(
                            label:
                                '${c.roi >= 0 ? '+' : ''}${c.roi.toStringAsFixed(0)}% ROI',
                            color: c.roi >= 0 ? scheme.primary : scheme.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      Row(
                        children: [
                          _FactCell(
                            label: 'Camp Cost',
                            value: Formatters.formatCurrency(c.camp.cost),
                          ),
                          _FactCell(
                            label: 'Follow-up Rev',
                            value: Formatters.formatCurrency(c.followUpRevenue),
                            color: scheme.primary,
                          ),
                          _FactCell(
                            label: 'Patients',
                            value: '${c.patientsAcquiredCount}',
                          ),
                          if (c.camp.attendance > 0)
                            _FactCell(
                              label: 'Attendance',
                              value: '${c.camp.attendance}',
                            ),
                        ],
                      ),
                      if (c.camp.notes != null && c.camp.notes!.isNotEmpty) ...[
                        const SizedBox(height: Spacing.sm),
                        Text(
                          c.camp.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: Spacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit Camp',
                            onPressed: () => _openAddEditCamp(context, c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            tooltip: 'Delete Camp',
                            onPressed: () => _confirmDelete(context, ref, c),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FactCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _FactCell({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color ?? scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
