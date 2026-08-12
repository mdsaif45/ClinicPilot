import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/period_selector.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/profit_provider.dart';

class ProfitSummaryScreen extends ConsumerWidget {
  const ProfitSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(profitSummaryProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profit Summary')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (s) => ListView(
          padding: const EdgeInsets.only(bottom: Spacing.xxl),
          children: [
            const PeriodSelector(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: _Tile(
                      label: 'Total Income',
                      value: Formatters.formatCurrency(s.totalIncome),
                      fg: scheme.primary,
                      bg: scheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: _Tile(
                      label: 'Total Expenses',
                      value: Formatters.formatCurrency(s.totalExpenses),
                      fg: scheme.error,
                      bg: scheme.errorContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: _Tile(
                label: 'Net Profit',
                value: Formatters.formatCurrency(s.netProfit),
                caption: '${s.margin.toStringAsFixed(1)}% margin',
                fg: s.netProfit < 0 ? scheme.error : scheme.primary,
                bg: s.netProfit < 0
                    ? scheme.errorContainer
                    : scheme.primaryContainer,
                large: true,
              ),
            ),

            const SectionHeader(title: 'Profit Trend'),
            if (s.dailyProfit.isEmpty)
              const EmptyState(
                icon: Icons.show_chart,
                title: 'No activity in this period',
                message: 'Record a cash memo or an expense to see the trend.',
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: SizedBox(
                  height: 200,
                  child: LineChart(_chart(context, s.dailyProfit)),
                ),
              ),

            if (s.collectionByMethod.isNotEmpty) ...[
              const SectionHeader(title: 'Collection by Method'),
              for (final e in (s.collectionByMethod.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value))))
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    0,
                    Spacing.lg,
                    Spacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(_methodIcon(e.key),
                          size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: Spacing.md),
                      Expanded(child: Text(e.key,
                          style: theme.textTheme.bodyMedium)),
                      Text(
                        '${(e.value / s.totalIncome * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(width: Spacing.md),
                      SizedBox(
                        width: 84,
                        child: Text(
                          Formatters.formatCurrency(e.value),
                          textAlign: TextAlign.right,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SectionHeader(title: 'Quick Summary'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: _Tile(
                      label: 'Daily Avg Profit',
                      value: Formatters.formatCurrency(s.avgDailyProfit),
                      fg: scheme.onSurface,
                      bg: scheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: _Tile(
                      label: 'Best Day',
                      value: s.bestDay == null
                          ? '—'
                          : Formatters.formatDate(s.bestDay!),
                      fg: scheme.onSurface,
                      bg: scheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: _Tile(
                label: 'Highest Profit in a Day',
                value: Formatters.formatCurrency(s.bestDayProfit),
                fg: scheme.primary,
                bg: scheme.surfaceContainerHighest,
              ),
            ),

            const SizedBox(height: Spacing.lg),
            AppCard(
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Text(
                      // The clinics open on alternate evenings, so dividing by
                      // calendar days would understate every average.
                      'Averages use the ${s.daysWithActivity} '
                      '${s.daysWithActivity == 1 ? 'day' : 'days'} with '
                      'activity, not every calendar day.',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _methodIcon(String method) => switch (method.toLowerCase()) {
        'cash' => Icons.payments_outlined,
        'upi' => Icons.qr_code_2,
        'card' => Icons.credit_card,
        _ => Icons.account_balance_outlined,
      };

  LineChartData _chart(BuildContext context, Map<int, double> daily) {
    final scheme = Theme.of(context).colorScheme;
    final spots = daily.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 5,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots.isEmpty ? [const FlSpot(1, 0)] : spots,
          isCurved: true,
          color: scheme.primary,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: scheme.primary.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final Color fg;
  final Color bg;
  final bool large;

  const _Tile({
    required this.label,
    required this.value,
    required this.fg,
    required this.bg,
    this.caption,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: Spacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: (large
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.titleLarge)
                  ?.copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(caption!, style: theme.textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}
