import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/metric_strip.dart';
import '../../../core/widgets/period_selector.dart';
import '../providers/disease_analytics_provider.dart';

enum _DiseaseSort { revenue, patients, repeatRate }

class DiseaseAnalyticsScreen extends ConsumerStatefulWidget {
  const DiseaseAnalyticsScreen({super.key});

  @override
  ConsumerState<DiseaseAnalyticsScreen> createState() =>
      _DiseaseAnalyticsScreenState();
}

class _DiseaseAnalyticsScreenState
    extends ConsumerState<DiseaseAnalyticsScreen> {
  _DiseaseSort _sort = _DiseaseSort.revenue;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(diseaseAnalyticsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Disease & Condition Analytics')),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load analytics: $e')),
        data: (summary) {
          if (summary.stats.isEmpty) {
            return Column(
              children: [
                const PeriodSelector(),
                Expanded(
                  child: EmptyState.growth(
                    title: 'No condition records in period',
                    message:
                        'Record visits and cash memos to analyze disease value and repeat retention.',
                  ),
                ),
              ],
            );
          }

          final sortedList = [...summary.stats];
          switch (_sort) {
            case _DiseaseSort.revenue:
              sortedList.sort(
                (a, b) => b.totalRevenue.compareTo(a.totalRevenue),
              );
              break;
            case _DiseaseSort.patients:
              sortedList.sort(
                (a, b) => b.patientCount.compareTo(a.patientCount),
              );
              break;
            case _DiseaseSort.repeatRate:
              sortedList.sort((a, b) => b.repeatRate.compareTo(a.repeatRate));
              break;
          }

          final maxRevenue = summary.stats.fold<double>(
            0.0,
            (max, s) => s.totalRevenue > max ? s.totalRevenue : max,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
            children: [
              const PeriodSelector(),
              MetricStrip(
                metrics: [
                  Metric(
                    label: 'Conditions',
                    value: '${summary.totalConditions}',
                    icon: Icons.coronavirus_outlined,
                    color: scheme.primary,
                  ),
                  Metric(
                    label: 'Top Value',
                    value: summary.topRevenueDisease,
                    icon: Icons.monetization_on_outlined,
                    color: scheme.secondary,
                  ),
                  Metric(
                    label: 'Top Volume',
                    value: summary.topVolumeDisease,
                    icon: Icons.bar_chart_outlined,
                    color: scheme.tertiary,
                  ),
                  Metric(
                    label: 'Total Revenue',
                    value: Formatters.formatCurrency(summary.totalRevenue),
                    signedAmount: summary.totalRevenue,
                    icon: Icons.payments_outlined,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  children: [
                    Text('Rank by:', style: theme.textTheme.labelMedium),
                    const SizedBox(width: Spacing.sm),
                    FilterChip(
                      selected: _sort == _DiseaseSort.revenue,
                      label: const Text('Revenue'),
                      onSelected: (_) {
                        AppHaptics.selection();
                        setState(() => _sort = _DiseaseSort.revenue);
                      },
                    ),
                    const SizedBox(width: Spacing.xs),
                    FilterChip(
                      selected: _sort == _DiseaseSort.patients,
                      label: const Text('Patients'),
                      onSelected: (_) {
                        AppHaptics.selection();
                        setState(() => _sort = _DiseaseSort.patients);
                      },
                    ),
                    const SizedBox(width: Spacing.xs),
                    FilterChip(
                      selected: _sort == _DiseaseSort.repeatRate,
                      label: const Text('Repeat %'),
                      onSelected: (_) {
                        AppHaptics.selection();
                        setState(() => _sort = _DiseaseSort.repeatRate);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              for (final s in sortedList)
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
                                  s.disease,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  '${s.patientCount} ${s.patientCount == 1 ? 'patient' : 'patients'} • ${s.visitCount} ${s.visitCount == 1 ? 'visit' : 'visits'}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.formatCurrency(s.totalRevenue),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
                              ),
                              Text(
                                'Avg ${Formatters.formatCurrency(s.avgRevenuePerPatient)}/pt',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: Radii.pillAll,
                              child: LinearProgressIndicator(
                                value:
                                    maxRevenue > 0
                                        ? (s.totalRevenue / maxRevenue).clamp(
                                          0.0,
                                          1.0,
                                        )
                                        : 0.0,
                                minHeight: 6,
                                backgroundColor: scheme.surfaceContainerHighest,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Text(
                            '${s.repeatRate.toStringAsFixed(0)}% repeat',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  s.repeatRate >= 50
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                            ),
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
