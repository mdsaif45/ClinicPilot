import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/monthly_statement_provider.dart';
import 'sort_by_bottom_sheet.dart';
import 'transaction_detail_screen.dart';

/// Screen displaying all expenses (money spent) for a selected month with sorting (Image 3).
class MoneySpentScreen extends ConsumerStatefulWidget {
  final DateTime month;

  const MoneySpentScreen({super.key, required this.month});

  @override
  ConsumerState<MoneySpentScreen> createState() => _MoneySpentScreenState();
}

class _MoneySpentScreenState extends ConsumerState<MoneySpentScreen> {
  FinanceSortOption _sortOption = FinanceSortOption.highestFirst;

  @override
  Widget build(BuildContext context) {
    final statementAsync = ref.watch(monthlyStatementProvider(widget.month));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              Formatters.formatMonthYear(widget.month),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: statementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading expenses: $err')),
        data: (data) {
          final sortedExpenses = sortExpenses(data.expenses, _sortOption);

          if (sortedExpenses.isEmpty) {
            return const EmptyState.expenses();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sort by pill button (Matching Image 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.sm),
                child: _SortPill(
                  sortOption: _sortOption,
                  onTap: () async {
                    final selected = await showSortByBottomSheet(context, _sortOption);
                    if (selected != null && mounted) {
                      setState(() => _sortOption = selected);
                    }
                  },
                ),
              ),

              // Total spent bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Expenses (${sortedExpenses.length})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(data.totalSpent),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xs),
              const Divider(height: 1),

              // Expense List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, Spacing.xs, 0, Spacing.xxl),
                  itemCount: sortedExpenses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
                  itemBuilder: (context, index) {
                    final item = sortedExpenses[index];
                    return _ExpenseTile(item: item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  final FinanceSortOption sortOption;
  final VoidCallback onTap;

  const _SortPill({required this.sortOption, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withAlpha(140),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withAlpha(120)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort by : ${sortOption.label}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: Spacing.xxs),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseWithClinic item;

  const _ExpenseTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final exp = item.expense;

    final title = exp.notes != null && exp.notes!.trim().isNotEmpty
        ? exp.notes!
        : (exp.subcategory != null && exp.subcategory!.trim().isNotEmpty
            ? '${exp.category} (${exp.subcategory})'
            : exp.category);
    final dateStr = Formatters.formatDayMonth(exp.date);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xxs),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(expenseItem: item),
          ),
        );
      },
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: FinanceColors.redBg, // Soft red for expense
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.north_east,
          size: 20,
          color: FinanceColors.red,
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          dateStr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '- ${Formatters.formatCurrency(exp.amount)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: FinanceColors.red,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PaymentIcons.forMethod(exp.paymentMethod),
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                exp.paymentMethod,
                style: TextStyle(
                  fontSize: 10,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
