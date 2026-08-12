import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/expense_provider.dart';
import 'add_expense_dialog.dart';
import 'edit_expense_dialog.dart';

/// Category icons, so a row can be identified without reading its label.
IconData expenseCategoryIcon(String category) => switch (category) {
      'Rent' => Icons.home_outlined,
      'Electricity' => Icons.bolt_outlined,
      'Staff Salary' => Icons.badge_outlined,
      'Medicine Purchase' => Icons.medication_outlined,
      'Furniture' => Icons.chair_outlined,
      'Marketing' => Icons.campaign_outlined,
      'Camp' => Icons.festival_outlined,
      'Internet' => Icons.wifi,
      'Travel' => Icons.directions_car_outlined,
      'Personal' => Icons.person_outline,
      _ => Icons.receipt_outlined,
    };

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  void _openAddExpense(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddExpenseDialog());
  }

  static const _categories = [
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
    'Personal',
    'Miscellaneous',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final selectedCategory = ref.watch(expenseCategoryFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddExpense(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading expenses: $err')),
        data: (expenses) {
          final total =
              expenses.fold<double>(0, (sum, e) => sum + e.expense.amount);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.md,
                  Spacing.lg,
                  Spacing.sm,
                ),
                child: _SummaryTile(
                  label: 'Expenses Recorded',
                  value: Formatters.formatCurrency(total),
                  caption: '${expenses.length} '
                      '${expenses.length == 1 ? 'item' : 'items'}',
                  fg: theme.colorScheme.error,
                  bg: theme.colorScheme.errorContainer,
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: Spacing.sm),
                  itemBuilder: (context, i) {
                    final c = _categories[i];
                    return ChoiceChip(
                      label: Text(c),
                      selected: selectedCategory == c,
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: Radii.mdAll,
                        side: BorderSide(
                          color: selectedCategory == c
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      onSelected: (_) => ref
                          .read(expenseCategoryFilterProvider.notifier)
                          .state = c,
                    );
                  },
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Expanded(
                child: expenses.isEmpty
                    ? EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: selectedCategory == 'All'
                            ? 'No expenses yet'
                            : 'Nothing under $selectedCategory',
                        message: 'Log a clinic cost and it will appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: expenses.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: Spacing.lg),
                        itemBuilder: (context, i) =>
                            _ExpenseRow(item: expenses[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExpenseRow extends ConsumerWidget {
  final ExpenseWithClinic item;

  const _ExpenseRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final expense = item.expense;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      leading: CircleAvatar(
        backgroundColor: scheme.errorContainer.withValues(alpha: 0.5),
        child: Icon(expenseCategoryIcon(expense.category), color: scheme.error),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              expense.category,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Amount on the right, matching the memo list, so both sides of the
          // Finances tab read the same way.
          Text(
            Formatters.formatCurrency(expense.amount),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.error,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                [
                  if (expense.subcategory != null &&
                      expense.subcategory!.isNotEmpty)
                    expense.subcategory!,
                  item.clinic.name,
                  Formatters.formatDate(expense.date),
                ].join(' · '),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
            if (expense.isRecurring) ...[
              const SizedBox(width: Spacing.sm),
              Icon(Icons.repeat, size: 13, color: scheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              showDialog(
                context: context,
                builder: (_) => EditExpenseDialog(expense: expense),
              );
            case 'delete':
              _confirmDelete(context, ref);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Delete'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense'),
        content: Text(
          'This ${Formatters.formatCurrency(item.expense.amount)} '
          '${item.expense.category} entry stops counting toward totals. The '
          'record '
          'is kept in the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () async {
              await ref
                  .read(expenseNotifierProvider.notifier)
                  .archiveExpense(item.expense.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color fg;
  final Color bg;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: theme.textTheme.titleLarge
                ?.copyWith(color: fg, fontWeight: FontWeight.w700),
          ),
          Text(caption, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
