import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/stat_card.dart';
import '../../cashmemo/presentation/new_cash_memo_dialog.dart';
import '../../expenses/presentation/add_expense_dialog.dart';
import '../../patients/presentation/add_patient_dialog.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final now = DateTime.now();

    final goalProgress = (stats.monthlyRevenue / stats.monthlyGoal).clamp(0.0, 1.0);
    final goalPercent = (goalProgress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clinic Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Greeting Card
              Card(
                color: const Color(0xFF0F5132),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Good Day, Dr. Zaid 👋",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Dr Zaid's Clinic • ${Formatters.formatDate(now)}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Section Title: Today's Overview
              const Text(
                "Today's Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
              ),
              const SizedBox(height: 10),

              // Today's Stats Grid
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: "Today's Revenue",
                      value: Formatters.formatCurrency(stats.todayRevenue),
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF0F5132),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: "Today's Expense",
                      value: Formatters.formatCurrency(stats.todayExpense),
                      icon: Icons.trending_down,
                      iconColor: Colors.redAccent.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: "Today's Net Profit",
                      value: Formatters.formatCurrency(stats.todayNetProfit),
                      icon: Icons.account_balance,
                      iconColor: const Color(0xFF0D6EFD),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: "Today's Patients",
                      value: "${stats.todayPatients}",
                      icon: Icons.people,
                      iconColor: const Color(0xFF198754),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Section Title: Monthly Goal Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Monthly Goal (${Formatters.formatMonthYear(now)})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                  ),
                  Text(
                    "$goalPercent% Achieved",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Monthly Revenue Goal Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Monthly Revenue",
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Formatters.formatCurrency(stats.monthlyRevenue),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Revenue Target",
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Formatters.formatCurrency(stats.monthlyGoal),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF212529)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: goalProgress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F5132)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Monthly Expenses: ${Formatters.formatCurrency(stats.monthlyExpense)}", style: const TextStyle(fontSize: 13)),
                          Text(
                            "Net Profit: ${Formatters.formatCurrency(stats.monthlyNetProfit)}",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Section Title: Quick Actions
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const NewCashMemoDialog());
                      },
                      icon: const Icon(Icons.receipt_long, color: Color(0xFF0F5132)),
                      label: const Text("Cash Memo", style: TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const AddPatientDialog());
                      },
                      icon: const Icon(Icons.person_add, color: Color(0xFF0D6EFD)),
                      label: const Text("Add Patient", style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const AddExpenseDialog());
                      },
                      icon: const Icon(Icons.add_card, color: Colors.redAccent),
                      label: const Text("Add Expense", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
