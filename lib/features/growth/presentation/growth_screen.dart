import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/period_selector.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/growth_provider.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(growthAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Overview')),
      body: analyticsAsync.when(
        data: (analytics) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The period control sits with the figures it scopes.
                const PeriodSelector(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'New Patients',
                        value: '${analytics.totalNewPatients}',
                        delta: analytics.newPatientGrowth,
                        tone: _Tone.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Repeat Patients',
                        value: '${analytics.totalRepeatPatients}',
                        delta: analytics.repeatPatientGrowth,
                        tone: _Tone.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'Total Patients',
                        value: '${analytics.totalPatients}',
                        tone: _Tone.neutral,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Repeat Rate',
                        value: '${analytics.repeatRate.toStringAsFixed(1)}%',
                        tone: _Tone.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),

                // Patient count per day, distinct from the money trend below.
                Text('Patient Growth Trend',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.md),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    _buildPatientChartData(context, analytics.dailyPatientMap),
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                Text('Quick Stats',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'Avg. Daily New Patients',
                        value:
                            analytics.avgDailyNewPatients.toStringAsFixed(1),
                        tone: _Tone.neutral,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Avg. Daily Revenue',
                        value: Formatters.formatCurrency(
                            analytics.avgDailyRevenue),
                        tone: _Tone.neutral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _GrowthTile(
                        label: 'Avg. Revenue / Visit',
                        value: Formatters.formatCurrency(
                            analytics.avgRevenuePerVisit),
                        tone: _Tone.neutral,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _GrowthTile(
                        label: 'Net Profit',
                        value: Formatters.formatCurrency(analytics.netProfit),
                        tone: analytics.netProfit < 0
                            ? _Tone.negative
                            : _Tone.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Financial Trend Line Chart Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revenue vs Expenses Trend',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            _buildLineChartData(context,
                                analytics.dailyRevenueMap, analytics.dailyExpenseMap),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Referral Sources Distribution
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Referral Source Distribution',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (analytics.referralSourceCount.isEmpty)
                          const Center(child: Text('No referral data available.'))
                        else
                          Column(
                            children: analytics.referralSourceCount.entries.map((e) {
                              final total = analytics.referralSourceCount.values
                                  .fold(0, (a, b) => a + b);
                              final pct = total > 0 ? e.value / total : 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(e.key),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 8,
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${(pct * 100).toStringAsFixed(0)}%'),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  /// Visits per day. Kept separate from the money chart so a busy day is not
  /// confused with a profitable one.
  LineChartData _buildPatientChartData(
      BuildContext context, Map<int, int> dailyPatients) {
    final scheme = Theme.of(context).colorScheme;
    final spots = dailyPatients.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    // Whole-number axis: half a patient is not a thing.
    final maxY = spots.isEmpty
        ? 4.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1;

    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 5,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
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
          color: scheme.tertiary,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: scheme.tertiary.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(BuildContext context,
      Map<int, double> revenueMap, Map<int, double> expenseMap) {
    final revenueSpots = revenueMap.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final expenseSpots = expenseMap.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: const FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: revenueSpots.isEmpty ? [const FlSpot(1, 0)] : revenueSpots,
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
        ),
        LineChartBarData(
          spots: expenseSpots.isEmpty ? [FlSpot(1, 0)] : expenseSpots,
          isCurved: true,
          color: Theme.of(context).colorScheme.error,
          barWidth: 3,
        ),
      ],
    );
  }
}

enum _Tone { primary, tertiary, neutral, negative }

/// Metric tile with an optional period-over-period delta badge.
class _GrowthTile extends StatelessWidget {
  final String label;
  final String value;
  final double? delta;
  final _Tone tone;

  const _GrowthTile({
    required this.label,
    required this.value,
    required this.tone,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (fg, bg) = switch (tone) {
      _Tone.primary => (scheme.primary, scheme.primaryContainer),
      _Tone.tertiary => (scheme.tertiary, scheme.tertiaryContainer),
      _Tone.negative => (scheme.error, scheme.errorContainer),
      _Tone.neutral => (scheme.onSurface, scheme.surfaceContainerHighest),
    };

    final d = delta;
    final rising = (d ?? 0) >= 0;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (d != null) ...[
                const SizedBox(width: Spacing.xs),
                Icon(
                  rising ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: rising ? scheme.primary : scheme.error,
                ),
                Text(
                  '${d.abs().toStringAsFixed(1)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: rising ? scheme.primary : scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
