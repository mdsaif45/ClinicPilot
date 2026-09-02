import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/providers/period_provider.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/period_selector.dart';
import '../providers/clinic_comparison_provider.dart';

class ClinicComparisonScreen extends ConsumerWidget {
  const ClinicComparisonScreen({super.key});

  static const double _rowHeight = 44.0;
  static const double _headerHeight = 46.0;
  static const double _metricColumnWidth = 145.0;
  static const double _clinicColumnWidth = 150.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(clinicComparisonProvider);
    final periodState = ref.watch(periodProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Clinic Comparison (${periodState.filter.label})'),
      ),
      body: comparisonAsync.when(
        data: (metricsList) {
          if (metricsList.isEmpty) {
            return const Column(
              children: [
                PeriodSelector(),
                Expanded(
                  child: EmptyState.clinics(
                    title: 'No clinics to compare',
                    message:
                        'Add clinics to compare their performance side by side.',
                  ),
                ),
              ],
            );
          }

          final isMonthFilter =
              periodState.filter == PeriodFilter.thisMonth ||
              periodState.filter == PeriodFilter.lastMonth;

          final metricLabels = [
            'Net Profit (Headline)',
            'Total Revenue',
            'Variable Expenses',
            isMonthFilter ? 'Monthly Fixed Rent' : 'Rent (Prorated)',
            'New Patients',
            'Repeat Patients',
            'Total Visits',
            'Avg Revenue / Visit',
            'Avg Patients / Day',
            'Growth vs Prev',
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
            children: [
              const PeriodSelector(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.md,
                  Spacing.lg,
                  Spacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Side-by-Side Performance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${metricsList.length} ${metricsList.length == 1 ? 'Clinic' : 'Clinics'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: Radii.mdAll,
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. STICKY FIRST COLUMN (Parameter / Metric Names)
                      Container(
                        width: _metricColumnWidth,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          border: Border(
                            right: BorderSide(
                              color: scheme.outlineVariant.withValues(
                                alpha: 0.6,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Cell
                            Container(
                              height: _headerHeight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                              ),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.6),
                                border: Border(
                                  bottom: BorderSide(
                                    color: scheme.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Metric',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // Data Metric Rows
                            for (var i = 0; i < metricLabels.length; i++)
                              Container(
                                height: _rowHeight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.sm,
                                ),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color:
                                      i == 0
                                          ? scheme.primaryContainer.withValues(
                                            alpha: 0.2,
                                          )
                                          : (i % 2 == 1
                                              ? scheme.surfaceContainerLow
                                                  .withValues(alpha: 0.5)
                                              : null),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: scheme.outlineVariant.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  metricLabels[i],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight:
                                        i == 0
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                    fontSize: 11.5,
                                    color:
                                        i == 0
                                            ? scheme.primary
                                            : scheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // 2. HORIZONTALLY SCROLLABLE CLINIC DATA COLUMNS
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final m in metricsList)
                                Container(
                                  width: _clinicColumnWidth,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: scheme.outlineVariant.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header Cell (Clinic Name)
                                      Container(
                                        height: _headerHeight,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Spacing.sm,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: scheme.surfaceContainerHighest
                                              .withValues(alpha: 0.3),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: scheme.outlineVariant
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          m.clinic.name,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: scheme.primary,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Row 0: Net Profit
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        isHeadline: true,
                                        child: Text(
                                          Formatters.formatCurrency(
                                            m.netProfit,
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color:
                                                    m.netProfit >= 0
                                                        ? scheme.primary
                                                        : scheme.error,
                                              ),
                                        ),
                                      ),
                                      // Row 1: Total Revenue
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        isAlternate: true,
                                        child: Text(
                                          Formatters.formatCurrency(m.revenue),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                                color: scheme.primary,
                                              ),
                                        ),
                                      ),
                                      // Row 2: Variable Expenses
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        child: Text(
                                          Formatters.formatCurrency(
                                            m.variableExpenses,
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 11.5,
                                                color: scheme.error,
                                              ),
                                        ),
                                      ),
                                      // Row 3: Rent
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        isAlternate: true,
                                        child: Text(
                                          Formatters.formatCurrency(m.rent),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 11.5),
                                        ),
                                      ),
                                      // Row 4: New Patients
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        child: Text(
                                          '${m.newPatients}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                              ),
                                        ),
                                      ),
                                      // Row 5: Repeat Patients
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        isAlternate: true,
                                        child: Text(
                                          '${m.repeatPatients}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                              ),
                                        ),
                                      ),
                                      // Row 6: Total Visits
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        child: Text(
                                          '${m.totalVisits}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                              ),
                                        ),
                                      ),
                                      // Row 7: Avg Revenue / Visit
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        isAlternate: true,
                                        child: Text(
                                          Formatters.formatCurrency(
                                            m.avgRevenuePerVisit,
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 11.5),
                                        ),
                                      ),
                                      // Row 8: Avg Patients / Day
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        child: Text(
                                          m.avgPatientsPerClinicDay
                                              .toStringAsFixed(1),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 11.5),
                                        ),
                                      ),
                                      // Row 9: Growth vs Prev
                                      _dataCell(
                                        context,
                                        height: _rowHeight,
                                        isAlternate: true,
                                        child: Text(
                                          '${m.growthPercentageVsPrev >= 0 ? "+" : ""}${m.growthPercentageVsPrev.toStringAsFixed(1)}%',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11.5,
                                                color:
                                                    m.growthPercentageVsPrev >=
                                                            0
                                                        ? scheme.primary
                                                        : scheme.error,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _dataCell(
    BuildContext context, {
    required double height,
    required Widget child,
    bool isHeadline = false,
    bool isAlternate = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color:
            isHeadline
                ? scheme.primaryContainer.withValues(alpha: 0.2)
                : (isAlternate
                    ? scheme.surfaceContainerLow.withValues(alpha: 0.5)
                    : null),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: child,
    );
  }
}
