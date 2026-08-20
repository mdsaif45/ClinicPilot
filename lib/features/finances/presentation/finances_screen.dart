import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/list_export_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/export_action.dart';
import '../../../core/widgets/swipeable_sections.dart';
import '../../cashmemo/presentation/cash_memo_screen.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../expenses/providers/expense_provider.dart';

/// Money in and money out under one tab.
///
/// They were separate destinations, which meant two of the five nav slots went
/// to halves of the same question. Combining them frees a slot and puts income
/// beside spending, where comparing the two costs one tap instead of a trip
/// through the bar.
class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cash memo leads: recording income is the far more frequent task during
    // a clinic evening.
    return SwipeableSections(
      labels: const ['Cash Memo', 'Expenses'],
      children: const [
        CashMemoScreen(),
        ExpensesScreen(),
      ],
      // Which columns and totals to export depends on which half is
      // showing - a memo export and an expense export answer different
      // questions, so the action itself has to switch with the section.
      trailingBuilder: (index) => index == 0
          ? const _CashMemoExportAction()
          : const _ExpensesExportAction(),
    );
  }
}

/// Column spec for the Cash Memo export, pulled out as a plain function so
/// its output - including the totals row - can be pinned in a test.
List<ExportColumn<CashMemoWithDetails>> cashMemoExportColumns() {
  return [
    ExportColumn('Memo No.', (m) => m.memo.memoNumber),
    ExportColumn('Patient', (m) => m.patient.name),
    ExportColumn('Clinic', (m) => m.clinic.name),
    ExportColumn('Date', (m) => Formatters.formatDate(m.memo.memoDate)),
    ExportColumn('Consultation Fee', (m) => m.memo.consultationFee),
    ExportColumn('Medicine Fee', (m) => m.memo.medicineFee),
    ExportColumn('Other Fee', (m) => m.memo.otherFee),
    ExportColumn('Discount', (m) => m.memo.discount),
    ExportColumn('Total', (m) => m.memo.total),
    ExportColumn('Paid', (m) => m.memo.paidAmount),
    ExportColumn('Pending', (m) => m.pendingAmount),
    ExportColumn('Payment Method', (m) => m.memo.paymentMethod),
  ];
}

ExportTotals<CashMemoWithDetails> cashMemoExportTotals() {
  return ExportTotals((rows) {
    final revenue = rows.fold<double>(0, (sum, m) => sum + m.memo.total);
    final pending = rows.fold<double>(0, (sum, m) => sum + m.pendingAmount);
    // Positions line up with the columns above: Total and Pending are
    // the only two figures a summary row over memos should carry.
    return [
      'TOTAL', null, null, null, null, null, null, null,
      revenue, null, pending, null,
    ];
  });
}

class _CashMemoExportAction extends ConsumerWidget {
  const _CashMemoExportAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(cashMemosStreamProvider).value ?? const [];

    return ExportAction<CashMemoWithDetails>(
      screenSlug: 'cash-memos',
      rows: memos,
      columns: cashMemoExportColumns(),
      totals: cashMemoExportTotals(),
    );
  }
}

/// Column spec for the Expenses export, pulled out for the same reason.
List<ExportColumn<ExpenseWithClinic>> expensesExportColumns() {
  return [
    ExportColumn('Date', (e) => Formatters.formatDate(e.expense.date)),
    ExportColumn('Clinic', (e) => e.clinic.name),
    ExportColumn('Category', (e) => e.expense.category),
    ExportColumn('Subcategory', (e) => e.expense.subcategory),
    ExportColumn('Amount', (e) => e.expense.amount),
    ExportColumn('Payment Method', (e) => e.expense.paymentMethod),
  ];
}

ExportTotals<ExpenseWithClinic> expensesExportTotals() {
  return ExportTotals((rows) {
    final total = rows.fold<double>(0, (sum, e) => sum + e.expense.amount);
    return ['TOTAL', null, null, null, total, null];
  });
}

class _ExpensesExportAction extends ConsumerWidget {
  const _ExpensesExportAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesStreamProvider).value ?? const [];

    return ExportAction<ExpenseWithClinic>(
      screenSlug: 'expenses',
      rows: expenses,
      columns: expensesExportColumns(),
      totals: expensesExportTotals(),
    );
  }
}
