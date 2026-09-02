import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../expenses/providers/expense_provider.dart';

/// Unified model for a transaction (Cash Memo or Expense) in the History stream.
class FinanceTransactionItem {
  final String id;
  final DateTime date;
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final String paymentMethod;
  final String clinicName;
  final ExpenseWithClinic? expenseItem;
  final CashMemoWithDetails? memoItem;

  const FinanceTransactionItem({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.paymentMethod,
    required this.clinicName,
    this.expenseItem,
    this.memoItem,
  });
}

/// A collection of transactions belonging to a single calendar month.
class MonthTransactionGroup {
  final DateTime month;
  final double totalExpenses;
  final double totalCollections;
  final double netCashFlow;
  final List<FinanceTransactionItem> items;

  const MonthTransactionGroup({
    required this.month,
    required this.totalExpenses,
    required this.totalCollections,
    required this.netCashFlow,
    required this.items,
  });
}

/// Search filter for the unified transaction history feed.
final transactionSearchQueryProvider = StateProvider<String>((ref) => '');

/// Stream provider for all transactions grouped chronologically by month.
final transactionHistoryGroupsProvider =
    Provider<AsyncValue<List<MonthTransactionGroup>>>((ref) {
  final memosAsync = ref.watch(cashMemosStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final searchQuery = ref.watch(transactionSearchQueryProvider).trim().toLowerCase();

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

  final List<FinanceTransactionItem> unifiedList = [];

  // 1. Process Expenses (Money Out / Debits)
  for (final expWithClinic in allExpenses) {
    final exp = expWithClinic.expense;

    final noteTitle = exp.notes != null && exp.notes!.trim().isNotEmpty
        ? exp.notes!
        : (exp.subcategory != null && exp.subcategory!.trim().isNotEmpty
            ? '${exp.category} (${exp.subcategory})'
            : exp.category);

    final title = noteTitle;
    final subtitle = exp.paymentMethod;

    // Search filter match
    if (searchQuery.isNotEmpty) {
      final matches = title.toLowerCase().contains(searchQuery) ||
          subtitle.toLowerCase().contains(searchQuery) ||
          exp.category.toLowerCase().contains(searchQuery) ||
          (exp.notes?.toLowerCase().contains(searchQuery) ?? false);
      if (!matches) continue;
    }

    unifiedList.add(
      FinanceTransactionItem(
        id: 'exp_${exp.id}',
        date: exp.date,
        title: title,
        subtitle: subtitle,
        amount: exp.amount,
        isExpense: true,
        paymentMethod: exp.paymentMethod,
        clinicName: expWithClinic.clinic.name,
        expenseItem: expWithClinic,
      ),
    );
  }

  // 2. Process Cash Memos (Money In / Credits)
  for (final memoWithDetails in allMemos) {
    final memo = memoWithDetails.memo;

    final patient = memoWithDetails.patient;
    final disease = memoWithDetails.visit?.disease ?? patient.primaryDisease;
    final title = patient.name;
    final subtitle = memo.paymentMethod;

    // Search filter match
    if (searchQuery.isNotEmpty) {
      final matches = title.toLowerCase().contains(searchQuery) ||
          subtitle.toLowerCase().contains(searchQuery) ||
          patient.name.toLowerCase().contains(searchQuery) ||
          patient.patientCode.toLowerCase().contains(searchQuery) ||
          patient.phone.toLowerCase().contains(searchQuery) ||
          memo.memoNumber.toLowerCase().contains(searchQuery) ||
          (disease != null && disease.toLowerCase().contains(searchQuery));
      if (!matches) continue;
    }

    unifiedList.add(
      FinanceTransactionItem(
        id: 'memo_${memo.id}',
        date: memo.memoDate,
        title: title,
        subtitle: subtitle,
        amount: memo.paidAmount,
        isExpense: false,
        paymentMethod: memo.paymentMethod,
        clinicName: memoWithDetails.clinic.name,
        memoItem: memoWithDetails,
      ),
    );
  }

  // Sort overall newest first
  unifiedList.sort((a, b) => b.date.compareTo(a.date));

  // Group by Month (Year + Month)
  final Map<DateTime, List<FinanceTransactionItem>> groupedMap = {};
  for (final item in unifiedList) {
    final monthKey = DateTime(item.date.year, item.date.month, 1);
    groupedMap.putIfAbsent(monthKey, () => []).add(item);
  }

  final List<MonthTransactionGroup> resultGroups = [];
  for (final entry in groupedMap.entries) {
    final items = entry.value;
    final totalExpenses = items
        .where((i) => i.isExpense)
        .fold<double>(0, (sum, i) => sum + i.amount);
    final totalCollections = items
        .where((i) => !i.isExpense)
        .fold<double>(0, (sum, i) => sum + i.amount);
    final netCashFlow = totalCollections - totalExpenses;

    resultGroups.add(
      MonthTransactionGroup(
        month: entry.key,
        totalExpenses: totalExpenses,
        totalCollections: totalCollections,
        netCashFlow: netCashFlow,
        items: items,
      ),
    );
  }

  // Sort groups newest month first
  resultGroups.sort((a, b) => b.month.compareTo(a.month));

  return AsyncData(resultGroups);
});
