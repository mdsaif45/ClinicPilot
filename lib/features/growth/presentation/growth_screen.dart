import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/period_selector.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/growth_provider.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(growthAnalyticsProvider);

    return Scaffold(
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
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/comparison'),
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Compare both clinics'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'New Patients',
                        value: '${analytics.totalNewPatients}',
                        icon: Icons.person_add,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Repeat Patients',
                        value: '${analytics.totalRepeatPatients}',
                        icon: Icons.repeat,
                        color: Theme.of(context).colorScheme.tertiary,
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
