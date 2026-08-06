import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/growth_provider.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final growthData = ref.watch(growthAnalyticsProvider);

    final pieColors = [
      const Color(0xFF0F5132),
      const Color(0xFF0D6EFD),
      const Color(0xFF198754),
      const Color(0xFFFFC107),
      const Color(0xFFDC3545),
      const Color(0xFF6f42c1),
      const Color(0xFFfd7e14),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Growth Analyzer"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: "Net Profit",
                    value: Formatters.formatCurrency(growthData.netProfit),
                    subtitle: "Revenue minus Expenses",
                    icon: Icons.show_chart,
                    iconColor: const Color(0xFF0F5132),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: "Total Patients",
                    value: "${growthData.totalPatients}",
                    subtitle: "Top: ${growthData.topReferralSource}",
                    icon: Icons.groups,
                    iconColor: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Revenue vs Expense Trend Chart Section
            const Text(
              "Financial Performance Trend",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: const Color(0xFF0F5132)),
                            const SizedBox(width: 6),
                            const Text("Revenue", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            Container(width: 12, height: 12, color: Colors.redAccent),
                            const SizedBox(width: 6),
                            const Text("Expenses", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          "Total: ${Formatters.formatCurrency(growthData.totalRevenue)}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          titlesData: const FlTitlesData(
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Revenue Line
                            LineChartBarData(
                              spots: growthData.dailyRevenue.isEmpty
                                  ? [const FlSpot(1, 0), const FlSpot(31, 0)]
                                  : growthData.dailyRevenue.entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                                      .toList(),
                              isCurved: true,
                              color: const Color(0xFF0F5132),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF0F5132).withOpacity(0.1),
                              ),
                            ),
                            // Expense Line
                            LineChartBarData(
                              spots: growthData.dailyExpenses.isEmpty
                                  ? [const FlSpot(1, 0), const FlSpot(31, 0)]
                                  : growthData.dailyExpenses.entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                                      .toList(),
                              isCurved: true,
                              color: Colors.redAccent,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Referral Sources Pie Chart
            const Text(
              "Patient Referral Sources",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: growthData.referralSources.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text("Register patients to see referral source insights.")),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: growthData.referralSources.entries.toList().asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  final color = pieColors[idx % pieColors.length];
                                  return PieChartSectionData(
                                    color: color,
                                    value: item.value.toDouble(),
                                    title: '${item.value}',
                                    radius: 45,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: growthData.referralSources.entries.toList().asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              final color = pieColors[idx % pieColors.length];
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 10, height: 10, color: color),
                                  const SizedBox(width: 6),
                                  Text("${item.key} (${item.value})", style: const TextStyle(fontSize: 12)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 22),

            // Disease Analytics Distribution
            const Text(
              "Top Diseases & Cases Tracked",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: growthData.diseaseDistribution.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text("Register patient diseases to see analytics.")),
                      )
                    : Column(
                        children: growthData.diseaseDistribution.entries.map((e) {
                          final count = e.value;
                          final total = growthData.totalPatients;
                          final pct = total > 0 ? (count / total) : 0.0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    CustomBadge(label: "$count patients (${(pct * 100).toStringAsFixed(0)}%)", color: const Color(0xFF0F5132)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F5132)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
