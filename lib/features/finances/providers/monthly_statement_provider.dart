import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../expenses/providers/expense_provider.dart';

enum FinanceSortOption {
  recents('Recents'),
  oldest('Oldest'),
  highestFirst('Highest first'),
  lowestFirst('Lowest first');

  final String label;
  const FinanceSortOption(this.label);
}

class MonthlyStatementData {
  final DateTime month;
  final double totalSpent;
  final double totalReceived;
  final double totalBilled;
  final double netCashFlow;
  final List<ExpenseWithClinic> expenses;
  final List<CashMemoWithDetails> cashMemos;
  final String? topExpenseCategory;
  final double topExpenseAmount;

  const MonthlyStatementData({
    required this.month,
    required this.totalSpent,
    required this.totalReceived,
    required this.totalBilled,
    required this.netCashFlow,
    required this.expenses,
    required this.cashMemos,
    this.topExpenseCategory,
    this.topExpenseAmount = 0.0,
  });
}

/// Active selected month for statement drilldowns (defaults to current month).
final selectedStatementMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

/// Current sort option for financial drilldown lists.
final financeSortOptionProvider = StateProvider<FinanceSortOption>((ref) {
  return FinanceSortOption.highestFirst;
});

/// Computes all inflow/outflow metrics and transactions for a specific month.
final monthlyStatementProvider =
    Provider.family<AsyncValue<MonthlyStatementData>, DateTime>((ref, monthDate) {
  final memosAsync = ref.watch(cashMemosStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);

  if (memosAsync is AsyncLoading || expensesAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  if (memosAsync.hasError) {
    return AsyncError(memosAsync.error!, memosAsync.stackTrace!);
  }
  if (expensesAsync.hasError) {
    return AsyncError(expensesAsync.error!, expensesAsync.stackTrace!);
  }

  final allMemos = memosAsync.value ?? const [];
  final allExpenses = expensesAsync.value ?? const [];

  final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
  final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);

  // Filter expenses by month
  var monthExpenses = allExpenses.where((e) {
    final d = e.expense.date;
    return !d.isBefore(startOfMonth) && !d.isAfter(endOfMonth);
  }).toList();

  // Filter cash memos by month
  var monthMemos = allMemos.where((m) {
    final d = m.memo.memoDate;
    return !d.isBefore(startOfMonth) && !d.isAfter(endOfMonth);
  }).toList();

  // Compute totals
  final totalSpent = monthExpenses.fold<double>(0, (sum, e) => sum + e.expense.amount);
  final totalReceived = monthMemos.fold<double>(0, (sum, m) => sum + m.memo.paidAmount);
  final totalBilled = monthMemos.fold<double>(0, (sum, m) => sum + m.memo.total);
  final netCashFlow = totalReceived - totalSpent;

  // Find top expense category
  final categoryTotals = <String, double>{};
  for (final e in monthExpenses) {
    categoryTotals[e.expense.category] =
        (categoryTotals[e.expense.category] ?? 0) + e.expense.amount;
  }
  String? topCategory;
  double topAmount = 0.0;
  if (categoryTotals.isNotEmpty) {
    final topEntry = categoryTotals.entries.reduce((a, b) => a.value >= b.value ? a : b);
    topCategory = topEntry.key;
    topAmount = topEntry.value;
  }

  return AsyncData(
    MonthlyStatementData(
      month: startOfMonth,
      totalSpent: totalSpent,
      totalReceived: totalReceived,
      totalBilled: totalBilled,
      netCashFlow: netCashFlow,
      expenses: monthExpenses,
      cashMemos: monthMemos,
      topExpenseCategory: topCategory,
      topExpenseAmount: topAmount,
    ),
  );
});

/// Sorter helper functions
List<ExpenseWithClinic> sortExpenses(
  List<ExpenseWithClinic> items,
  FinanceSortOption sortOption,
) {
  final copy = List<ExpenseWithClinic>.from(items);
  switch (sortOption) {
    case FinanceSortOption.recents:
      copy.sort((a, b) => b.expense.date.compareTo(a.expense.date));
      break;
    case FinanceSortOption.oldest:
      copy.sort((a, b) => a.expense.date.compareTo(b.expense.date));
      break;
    case FinanceSortOption.highestFirst:
      copy.sort((a, b) => b.expense.amount.compareTo(a.expense.amount));
      break;
    case FinanceSortOption.lowestFirst:
      copy.sort((a, b) => a.expense.amount.compareTo(b.expense.amount));
      break;
  }
  return copy;
}

List<CashMemoWithDetails> sortCashMemos(
  List<CashMemoWithDetails> items,
  FinanceSortOption sortOption,
) {
  final copy = List<CashMemoWithDetails>.from(items);
  switch (sortOption) {
    case FinanceSortOption.recents:
      copy.sort((a, b) => b.memo.memoDate.compareTo(a.memo.memoDate));
      break;
    case FinanceSortOption.oldest:
      copy.sort((a, b) => a.memo.memoDate.compareTo(b.memo.memoDate));
      break;
    case FinanceSortOption.highestFirst:
      copy.sort((a, b) => b.memo.paidAmount.compareTo(a.memo.paidAmount));
      break;
    case FinanceSortOption.lowestFirst:
      copy.sort((a, b) => a.memo.paidAmount.compareTo(b.memo.paidAmount));
      break;
  }
  return copy;
}
