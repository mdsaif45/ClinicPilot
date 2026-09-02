import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../finances/presentation/monthly_statement_screen.dart';
import '../../finances/presentation/transaction_detail_screen.dart';
import '../providers/expense_provider.dart';
import 'add_expense_dialog.dart';
import 'edit_expense_dialog.dart';

/// Category icons, so a row can be identified without reading its label.
IconData expenseCategoryIcon(String category) => switch (category) {
      'All' => Icons.tune_rounded,
      'Rent' => Icons.home_outlined,
      'Electricity' || 'Utilities' => Icons.bolt_outlined,
      'Staff Salary' || 'Assistant Salary' => Icons.badge_outlined,
      'Medicine Purchase' || 'Medicine' => Icons.medication_outlined,
      'Packaging & Dispensing' || 'Packaging' => Icons.inventory_2_outlined,
      'Furniture' => Icons.chair_outlined,
      'Marketing' => Icons.campaign_outlined,
      'Camp' || 'Camp Expense' => Icons.festival_outlined,
      'Equipment' => Icons.medical_services_outlined,
      'Maintenance' => Icons.build_outlined,
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
    'Medicine Purchase',
    'Packaging & Dispensing',
    'Staff Salary',
    'Rent',
    'Camp',
    'Marketing',
    'Equipment',
    'Utilities',
    'Maintenance',
    'Electricity',
    'Furniture',
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

    final total = expensesAsync.asData?.value.fold<double>(
          0,
          (sum, e) => sum + e.expense.amount,
        ) ??
        0.0;
    final count = expensesAsync.asData?.value.length ?? 0;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddExpense(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: Column(
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
              caption: '$count ${count == 1 ? 'item' : 'items'}',
              fg: theme.colorScheme.error,
              bg: theme.colorScheme.errorContainer,
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
              itemBuilder: (context, i) {
                final c = _categories[i];
                final isSelected = c == 'All'
                    ? (selectedCategory == null || selectedCategory == 'All')
                    : selectedCategory == c;
                final icon = expenseCategoryIcon(c);

                return Material(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: Radii.pillAll,
                  child: InkWell(
                    borderRadius: Radii.pillAll,
                    onTap: () {
                      AppHaptics.selection();
                      ref.read(expenseCategoryFilterProvider.notifier).state =
                          c == 'All' ? null : c;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: Radii.pillAll,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 15,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading expenses: $err')),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return EmptyState.expenses(
                    title: selectedCategory == 'All'
                        ? 'No expenses recorded'
                        : 'Nothing under $selectedCategory',
                    message: 'Track clinic supplies, rent, and travel costs here.',
                    onAction: () => showDialog(
                      context: context,
                      builder: (_) => const AddExpenseDialog(),
                    ),
                  );
                }

                final monthGroups = _groupExpensesByMonth(expenses);

                return CustomScrollView(
                  slivers: [
                    for (final group in monthGroups)
                      SliverMainAxisGroup(
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyExpenseMonthHeaderDelegate(
                                group: group),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = group.items[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ExpenseRow(item: item),
                                    if (index < group.items.length - 1)
                                      const Divider(
                                          height: 1, indent: Spacing.lg),
                                  ],
                                );
                              },
                              childCount: group.items.length,
                            ),
                          ),
                        ],
                      ),
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 96),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseMonthGroup {
  final DateTime month;
  final double total;
  final List<ExpenseWithClinic> items;

  const _ExpenseMonthGroup({
    required this.month,
    required this.total,
    required this.items,
  });
}

List<_ExpenseMonthGroup> _groupExpensesByMonth(List<ExpenseWithClinic> list) {
  final map = <DateTime, List<ExpenseWithClinic>>{};
  for (final item in list) {
    final m = DateTime(item.expense.date.year, item.expense.date.month, 1);
    map.putIfAbsent(m, () => []).add(item);
  }
  final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return sortedKeys.map((m) {
    final items = map[m]!;
    final sum = items.fold<double>(0, (s, e) => s + e.expense.amount);
    return _ExpenseMonthGroup(month: m, total: sum, items: items);
  }).toList();
}

class _StickyExpenseMonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final _ExpenseMonthGroup group;

  _StickyExpenseMonthHeaderDelegate({required this.group});

  @override
  double get minExtent => 42.0;

  @override
  double get maxExtent => 42.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final monthTitle = Formatters.formatMonthYear(group.month);

    return Material(
      color: scheme.surface,
      elevation: overlapsContent ? 1.5 : 0,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MonthlyStatementScreen(
                initialMonth: group.month,
              ),
            ),
          );
        },
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest
                .withAlpha(overlapsContent ? 250 : 180),
            border: Border(
              top: BorderSide(color: theme.dividerColor.withAlpha(80)),
              bottom: BorderSide(color: theme.dividerColor.withAlpha(80)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    monthTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.formatCurrency(group.total),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 35,
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: scheme.error,
                      ),
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

  @override
  bool shouldRebuild(covariant _StickyExpenseMonthHeaderDelegate oldDelegate) {
    return oldDelegate.group.month != group.month ||
        oldDelegate.group.total != group.total ||
        oldDelegate.group.items.length != group.items.length;
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(expenseItem: item),
          ),
        );
      },
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
        padding: const EdgeInsets.only(top: Spacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(
                Formatters.formatDayMonth(expense.date),
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
