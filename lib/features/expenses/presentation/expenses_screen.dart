import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/stat_card.dart';
import '../providers/expense_provider.dart';
import 'add_expense_dialog.dart';
import 'edit_expense_dialog.dart';

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
    final selectedCategory = ref.watch(expenseCategoryFilterProvider);

    final categories = [
      'All',
      'Rent',
      'Electricity',
      'Staff Salary',
      'Medicine Purchase',
      'Furniture',
      'Marketing',
      'Camp',
      'Internet',
      'Travel',
      'Miscellaneous'
    ];

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
        label: const Text("Add Expense",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Expense Header Summary Stat Card
            expensesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (items) {
                final totalExp =
                    items.fold<double>(0, (sum, item) => sum + item.expense.amount);
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Total Expenses Recorded",
                        value: Formatters.formatCurrency(totalExp),
                        subtitle: "${items.length} Expense Items",
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.red,
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
                  final isSelected = (selectedCategory == null && cat == 'All') ||
                      selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0F5132),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      ref.read(expenseCategoryFilterProvider.notifier).state =
                          (cat == 'All') ? null : cat;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Expense Items List
            Expanded(
              child: expensesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text("Error loading expenses: $err")),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.money_off,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No expenses recorded for '${selectedCategory ?? 'All'}'",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500),
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
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final exp = item.expense;

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_downward,
                                color: Colors.redAccent),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomBadge(
                                  label: exp.category,
                                  color: Colors.redAccent.shade700),
                              Text(
                                Formatters.formatCurrency(exp.amount),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.redAccent.shade700),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Clinic: ${item.clinic.name}'),
                                if (exp.subcategory != null)
                                  Text('Details: ${exp.subcategory}'),
                                Text(
                                  Formatters.formatDate(exp.date),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.teal),
                                tooltip: "Edit Expense",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => EditExpenseDialog(expense: exp),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                tooltip: "Archive Expense",
                                onPressed: () =>
                                    _confirmDelete(context, ref, exp.id),
                              ),
                            ],
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

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Expense'),
        content: const Text('Are you sure you want to archive this expense entry?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref
                  .read(expenseNotifierProvider.notifier)
                  .archiveExpense(id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
