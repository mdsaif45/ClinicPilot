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
        data:
            (s) => ListView(
              padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
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
                    bg:
                        s.netProfit < 0
                            ? scheme.errorContainer
                            : scheme.primaryContainer,
                    large: true,
                  ),
                ),

                const SectionHeader(title: 'Profit Trend'),
                if (s.dailyProfit.isEmpty)
                  EmptyState.growth(
                    title: 'No activity in this period',
                    message:
                        'Record a cash memo or an expense to see the trend.',
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
                  for (final e
                      in (s.collectionByMethod.entries.toList()
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
                          Icon(
                            PaymentIcons.forMethod(e.key),
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Text(
                              e.key,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
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
                          value:
                              s.bestDay == null
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

  LineChartData _chart(BuildContext context, Map<int, double> daily) {
    final scheme = Theme.of(context).colorScheme;
    final spots =
        daily.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    final values = spots.map((s) => s.y).toList();
    final minY =
        values.isEmpty
            ? 0.0
            : (values.reduce((a, b) => a < b ? a : b) < 0
                ? values.reduce((a, b) => a < b ? a : b) * 1.15
                : 0.0);
    final maxY =
        values.isEmpty
            ? 1000.0
            : (values.reduce((a, b) => a > b ? a : b) * 1.15);

    return LineChartData(
      minY: minY,
      maxY: maxY > minY ? maxY : minY + 100,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine:
            (value) => FlLine(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
      ),
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => scheme.inverseSurface,
          tooltipRoundedRadius: 8,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          getTooltipItems:
              (touchedSpots) =>
                  touchedSpots.map((s) {
                    final isPositive = s.y >= 0;
                    return LineTooltipItem(
                      'Day ${s.x.toInt()}: ${Formatters.formatCurrency(s.y)}',
                      TextStyle(
                        color:
                            isPositive
                                ? scheme.primaryContainer
                                : scheme.errorContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (v, _) {
              if (v == 0)
                return Text('0', style: Theme.of(context).textTheme.labelSmall);
              final isNeg = v < 0;
              final absV = v.abs();
              final k =
                  absV >= 1000
                      ? '${(absV / 1000).toStringAsFixed(absV % 1000 == 0 ? 0 : 1)}k'
                      : absV.toInt().toString();
              return Text(
                '${isNeg ? "-" : ""}₹$k',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 5,
            getTitlesWidget:
                (v, _) => Text(
                  v.toInt().toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots.isEmpty ? [const FlSpot(1, 0)] : spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: scheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter:
                (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: scheme.primary,
                  strokeWidth: 2,
                  strokeColor: scheme.surface,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.primary.withValues(alpha: 0.25),
                scheme.primary.withValues(alpha: 0.0),
              ],
            ),
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
