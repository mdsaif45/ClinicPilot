import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/providers/period_provider.dart';
import '../providers/clinic_comparison_provider.dart';

class ClinicComparisonScreen extends ConsumerWidget {
  const ClinicComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(clinicComparisonProvider);
    final periodState = ref.watch(periodProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Clinic Comparison (${periodState.filter.label})'),
      ),
      body: comparisonAsync.when(
        data: (metricsList) {
          if (metricsList.isEmpty) {
            return const Center(
              child: Text('No clinic metrics available for selected period.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Side-by-Side Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: [
                          const DataColumn(
                              label: Text('Metric',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          ...metricsList.map((m) => DataColumn(
                                label: Text(
                                  m.clinic.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary),
                                ),
                              )),
                        ],
                        rows: [
                          // Headline Net Profit
                          DataRow(cells: [
                            DataCell(Text('Net Profit (Headline)',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                            ...metricsList.map((m) => DataCell(
                                  Text(
                                    Formatters.formatCurrency(m.netProfit),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: m.netProfit >= 0
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Total Revenue')),
                            ...metricsList.map((m) => DataCell(
                                  Text(Formatters.formatCurrency(m.revenue)),
                                )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('Variable Expenses')),
                            ...metricsList.map((m) => DataCell(
                                  Text(Formatters.formatCurrency(
                                      m.variableExpenses)),
                                )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              periodState.filter == PeriodFilter.thisMonth ||
                                      periodState.filter == PeriodFilter.lastMonth
                                  ? 'Monthly Fixed Rent'
                                  : 'Rent (prorated)',
                            )),
                            ...metricsList.map((m) => DataCell(
                                  Text(Formatters.formatCurrency(m.rent)),
                                )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('New Patients')),
                            ...metricsList.map((m) => DataCell(
                                  Text('${m.newPatients}'),
                                )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('Repeat Patients')),
                            ...metricsList.map((m) => DataCell(
                                  Text('${m.repeatPatients}'),
                                )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('Total Visits')),
                            ...metricsList.map((m) => DataCell(
                                  Text('${m.totalVisits}'),
                                )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('Avg Revenue / Visit')),
                            ...metricsList.map((m) => DataCell(
                                  Text(Formatters.formatCurrency(
                                      m.avgRevenuePerVisit)),
                                )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('Avg Patients / Clinic Day')),
                            ...metricsList.map((m) => DataCell(
                                  Text(m.avgPatientsPerClinicDay
                                      .toStringAsFixed(1)),
                                )),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text('Growth vs Prev Period')),
                            ...metricsList.map((m) => DataCell(
                                  Text(
                                    '${m.growthPercentageVsPrev >= 0 ? "+" : ""}${m.growthPercentageVsPrev.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: m.growthPercentageVsPrev >= 0
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          ]),
                        ],
                      ),
                    ),
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
}
