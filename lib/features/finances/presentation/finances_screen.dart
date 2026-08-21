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
import 'payment_method_breakdown_screen.dart';

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
      labels: const ['Cash Memo', 'Expenses', 'Split'],
      children: const [
        CashMemoScreen(),
        ExpensesScreen(),
        PaymentMethodBreakdownScreen(),
      ],
      // Which columns and totals to export depends on which half is
      // showing - a memo export and an expense export answer different
      // questions, so the action itself has to switch with the section.
      trailingBuilder: (index) {
        if (index == 0) return const _CashMemoExportAction();
        if (index == 1) return const _ExpensesExportAction();
        return null;
      },
    );
  }
}

/// The PDF font has no Rupee glyph (a lesson from the cash memo receipt,
/// pdf_service.dart), so a money column renders through this in that format
/// only - CSV and XLSX keep the raw double, since a spreadsheet has its own
/// currency formatting and should get a real number to work with.
///
/// Falls back to plain text for a non-numeric cell - the totals row's own
/// label ('TOTAL') passes through columns that have no pdfFormat set, but a
/// null total for a column that does (an untotalled money column) should
/// still print blank rather than throw.
String _pdfMoney(Object? value) {
  if (value is num) return 'Rs. ${value.toStringAsFixed(2)}';
  if (value == null) return '';
  return value.toString();
}

/// Column spec for the Cash Memo export, pulled out as a plain function so
/// its output - including the totals row - can be pinned in a test.
List<ExportColumn<CashMemoWithDetails>> cashMemoExportColumns() {
  return [
    ExportColumn('Memo No.', (m) => m.memo.memoNumber),
    ExportColumn('Patient', (m) => m.patient.name),
    ExportColumn('Clinic', (m) => m.clinic.name),
    ExportColumn('Date', (m) => Formatters.formatDate(m.memo.memoDate)),
    ExportColumn('Consultation Fee', (m) => m.memo.consultationFee,
        pdfFormat: _pdfMoney),
    ExportColumn('Medicine Fee', (m) => m.memo.medicineFee,
        pdfFormat: _pdfMoney),
    ExportColumn('Other Fee', (m) => m.memo.otherFee, pdfFormat: _pdfMoney),
    ExportColumn('Discount', (m) => m.memo.discount, pdfFormat: _pdfMoney),
    ExportColumn('Total', (m) => m.memo.total, pdfFormat: _pdfMoney),
    ExportColumn('Paid', (m) => m.memo.paidAmount, pdfFormat: _pdfMoney),
    ExportColumn('Pending', (m) => m.pendingAmount, pdfFormat: _pdfMoney),
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
      title: 'Cash Memos',
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
    ExportColumn('Amount', (e) => e.expense.amount, pdfFormat: _pdfMoney),
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
      title: 'Expenses',
      rows: expenses,
      columns: expensesExportColumns(),
      totals: expensesExportTotals(),
    );
  }
}
