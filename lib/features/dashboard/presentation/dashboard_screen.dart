import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/stat_card.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../patients/presentation/add_patient_dialog.dart';
import '../../cashmemo/presentation/new_cash_memo_dialog.dart';
import '../../expenses/presentation/add_expense_dialog.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activeClinic = ref.watch(activeClinicProvider);

    return Scaffold(
      body: statsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Greeting Header Card
                Card(
                  elevation: 2,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Day, Dr. Zaid 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Active: ${activeClinic?.name ?? "Dr Zaid's Clinic"}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.medical_services,
                              color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Today's Performance Stat Grid
                const Text(
                  "Today's Performance Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      title: "Today's Revenue",
                      value: Formatters.formatCurrency(stats.todayRevenue),
                      icon: Icons.payments,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    StatCard(
                      title: "Today's Expenses",
                      value: Formatters.formatCurrency(stats.todayExpense),
                      icon: Icons.money_off,
                      color: Colors.red,
                    ),
                    StatCard(
                      title: "Today's Net Profit",
                      value: Formatters.formatCurrency(stats.todayNetProfit),
                      icon: Icons.account_balance,
                      color: stats.todayNetProfit >= 0
                          ? Colors.teal
                          : Colors.deepOrange,
                    ),
                    StatCard(
                      title: "Today's Patients",
                      value: '${stats.todayPatients}',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Monthly Revenue Goal Target Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Monthly Revenue Target Goal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${(stats.revenueGoalProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: stats.revenueGoalProgress,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${Formatters.formatCurrency(stats.monthlyRevenue)} earned of ${Formatters.formatCurrency(stats.monthlyRevenueGoal)} target',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Action Buttons
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddPatientDialog(),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Patient'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const NewCashMemoDialog(),
                          );
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Create Memo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddExpenseDialog(),
                      );
                    },
                    icon: const Icon(Icons.money_off),
                    label: const Text('Log Expense Entry'),
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
