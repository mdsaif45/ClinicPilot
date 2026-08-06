import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/expense_provider.dart';
import 'add_expense_dialog.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  void _openAddExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddExpenseDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final filteredExpensesAsync = ref.watch(filteredExpensesProvider);
    final selectedCategory = ref.watch(selectedExpenseCategoryProvider);

    final categories = ['All', 'Rent', 'Electricity', 'Medicine Purchase', 'Marketing', 'Camp', 'Other'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clinic Expense Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Expense",
            onPressed: () => _openAddExpense(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddExpense(context),
        backgroundColor: Colors.redAccent.shade700,
        icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
        label: const Text("Add Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Expense Header Summary Stat Card
            expensesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (expenses) {
                final totalExp = expenses.fold<double>(0, (sum, e) => sum + e.amount);
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Total Expenses Recorded",
                        value: Formatters.formatCurrency(totalExp),
                        subtitle: "${expenses.length} Expense Items",
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: Colors.redAccent.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),

            // Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0F5132),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) ref.read(selectedExpenseCategoryProvider.notifier).state = cat;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Expense Items List
            Expanded(
              child: filteredExpensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error loading expenses: $err")),
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.money_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No expenses recorded for '$selectedCategory'",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openAddExpense(context),
                            icon: const Icon(Icons.add),
                            label: const Text("Record New Expense"),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: expenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_downward, color: Colors.redAccent),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomBadge(label: expense.category, color: Colors.redAccent.shade700),
                              Text(
                                Formatters.formatCurrency(expense.amount),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent.shade700),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  expense.notes ?? expense.category,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  Formatters.formatDate(expense.date),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
