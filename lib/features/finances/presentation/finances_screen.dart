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
import '../providers/payment_method_breakdown_provider.dart';
import 'payment_method_breakdown_screen.dart';

/// Money in, money out, and payment channel split under one tab.
class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SwipeableSections(
      labels: const ['Cash Memo', 'Expenses', 'Split'],
      children: const [
        CashMemoScreen(),
        ExpensesScreen(),
        PaymentMethodBreakdownScreen(),
      ],
      trailingBuilder: (index) {
        if (index == 0) return const _CashMemoExportAction();
        if (index == 1) return const _ExpensesExportAction();
        if (index == 2) return const _SplitExportAction();
        return null;
      },
    );
  }
}

String _pdfMoney(Object? value) {
  if (value is num) return 'Rs. ${value.toStringAsFixed(2)}';
  if (value == null) return '';
  return value.toString();
}

/// Complete column spec for Cash Memo export.
List<ExportColumn<CashMemoWithDetails>> cashMemoExportColumns() {
  return [
    ExportColumn('Memo No.', (m) => m.memo.memoNumber),
    ExportColumn('Date', (m) => Formatters.formatDate(m.memo.memoDate)),
    ExportColumn('Serial No.', (m) => m.patient.serialNo),
    ExportColumn('Patient Code', (m) => m.patient.patientCode),
    ExportColumn('Patient Name', (m) => m.patient.name),
    ExportColumn('Phone', (m) => m.patient.phone),
    ExportColumn('Area', (m) => m.patient.area ?? ''),
    ExportColumn('Clinic', (m) => m.clinic.name),
    ExportColumn('Disease', (m) => m.visit?.disease ?? m.patient.primaryDisease ?? ''),
    ExportColumn('Consultation Mode', (m) => m.visit?.consultationType ?? 'Clinic'),
    ExportColumn('Visit Type', (m) => m.visit?.visitType ?? ''),
    ExportColumn('Consultation Fee', (m) => m.memo.consultationFee, pdfFormat: _pdfMoney),
    ExportColumn('Medicine Fee', (m) => m.memo.medicineFee, pdfFormat: _pdfMoney),
    ExportColumn('Other Fee', (m) => m.memo.otherFee, pdfFormat: _pdfMoney),
    ExportColumn('Discount', (m) => m.memo.discount, pdfFormat: _pdfMoney),
    ExportColumn('Total', (m) => m.memo.total, pdfFormat: _pdfMoney),
    ExportColumn('Paid', (m) => m.memo.paidAmount, pdfFormat: _pdfMoney),
    ExportColumn('Pending', (m) => m.pendingAmount, pdfFormat: _pdfMoney),
    ExportColumn('Payment Status', (m) => m.isFullyPaid ? 'Fully Paid' : (m.memo.paidAmount > 0 ? 'Partially Paid' : 'Unpaid')),
    ExportColumn('Payment Method', (m) => m.memo.paymentMethod),
    ExportColumn('Notes', (m) => m.memo.notes ?? ''),
    ExportColumn('Entry Date', (m) => Formatters.formatDate(m.memo.createdAt)),
  ];
}

ExportTotals<CashMemoWithDetails> cashMemoExportTotals() {
  return ExportTotals((rows) {
    final consult = rows.fold<double>(0, (sum, m) => sum + m.memo.consultationFee);
    final med = rows.fold<double>(0, (sum, m) => sum + m.memo.medicineFee);
    final other = rows.fold<double>(0, (sum, m) => sum + m.memo.otherFee);
    final discount = rows.fold<double>(0, (sum, m) => sum + m.memo.discount);
    final revenue = rows.fold<double>(0, (sum, m) => sum + m.memo.total);
    final paid = rows.fold<double>(0, (sum, m) => sum + m.memo.paidAmount);
    final pending = rows.fold<double>(0, (sum, m) => sum + m.pendingAmount);

    return [
      'TOTAL', null, null, null, null, null, null, null, null, null, null,
      consult, med, other, discount, revenue, paid, pending, null, null, null, null,
    ];
  });
}

List<ExportColumn<CashMemoWithDetails>> cashMemoPdfColumns() {
  return [
    ExportColumn('Memo No.', (m) => m.memo.memoNumber),
    ExportColumn('Date', (m) => Formatters.formatDate(m.memo.memoDate)),
    ExportColumn('Code', (m) => m.patient.patientCode),
    ExportColumn('Patient', (m) => m.patient.name),
    ExportColumn('Phone', (m) => m.patient.phone),
    ExportColumn('Clinic', (m) => m.clinic.name),
    ExportColumn('Total', (m) => m.memo.total, pdfFormat: _pdfMoney),
    ExportColumn('Paid', (m) => m.memo.paidAmount, pdfFormat: _pdfMoney),
    ExportColumn('Pending', (m) => m.pendingAmount, pdfFormat: _pdfMoney),
    ExportColumn('Method', (m) => m.memo.paymentMethod),
    ExportColumn('Status', (m) => m.isFullyPaid ? 'Paid' : (m.memo.paidAmount > 0 ? 'Partial' : 'Due')),
  ];
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
      pdfColumns: cashMemoPdfColumns(),
      totals: cashMemoExportTotals(),
    );
  }
}

/// Complete column spec for Expenses export.
List<ExportColumn<ExpenseWithClinic>> expensesExportColumns() {
  return [
    ExportColumn('Date', (e) => Formatters.formatDate(e.expense.date)),
    ExportColumn('Clinic', (e) => e.clinic.name),
    ExportColumn('Category', (e) => e.expense.category),
    ExportColumn('Subcategory', (e) => e.expense.subcategory ?? ''),
    ExportColumn('Nature', (e) => e.expense.isRecurring ? 'Recurring (Fixed Overhead)' : 'One-time (Variable Spend)'),
    ExportColumn('Amount', (e) => e.expense.amount, pdfFormat: _pdfMoney),
    ExportColumn('Payment Method', (e) => e.expense.paymentMethod),
    ExportColumn('Notes / Vendor', (e) => e.expense.notes ?? ''),
    ExportColumn('Entry Date', (e) => Formatters.formatDate(e.expense.createdAt)),
  ];
}

ExportTotals<ExpenseWithClinic> expensesExportTotals() {
  return ExportTotals((rows) {
    final total = rows.fold<double>(0, (sum, e) => sum + e.expense.amount);
    return ['TOTAL', null, null, null, null, total, null, null, null];
  });
}

List<ExportColumn<ExpenseWithClinic>> expensesPdfColumns() {
  return [
    ExportColumn('Date', (e) => Formatters.formatDate(e.expense.date)),
    ExportColumn('Clinic', (e) => e.clinic.name),
    ExportColumn('Category', (e) => e.expense.category),
    ExportColumn('Subcategory', (e) => e.expense.subcategory ?? ''),
    ExportColumn('Nature', (e) => e.expense.isRecurring ? 'Fixed' : 'Variable'),
    ExportColumn('Amount', (e) => e.expense.amount, pdfFormat: _pdfMoney),
    ExportColumn('Method', (e) => e.expense.paymentMethod),
    ExportColumn('Notes', (e) => e.expense.notes ?? ''),
  ];
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
      pdfColumns: expensesPdfColumns(),
      totals: expensesExportTotals(),
    );
  }
}

/// Column spec for Payment Method Split export.
List<ExportColumn<PaymentMethodStat>> splitExportColumns() {
  return [
    ExportColumn('Payment Method', (s) => s.method),
    ExportColumn('Total Collected (Rs.)', (s) => s.totalCollected, pdfFormat: _pdfMoney),
    ExportColumn('Total Billed (Rs.)', (s) => s.totalBilled, pdfFormat: _pdfMoney),
    ExportColumn('Transaction Count', (s) => s.count),
    ExportColumn('Share of Collections (%)', (s) => '${s.percentage.toStringAsFixed(1)}%'),
  ];
}

ExportTotals<PaymentMethodStat> splitExportTotals() {
  return ExportTotals((rows) {
    final collected = rows.fold<double>(0, (sum, s) => sum + s.totalCollected);
    final billed = rows.fold<double>(0, (sum, s) => sum + s.totalBilled);
    final count = rows.fold<int>(0, (sum, s) => sum + s.count);
    return ['TOTAL', collected, billed, count, '100.0%'];
  });
}

class _SplitExportAction extends ConsumerWidget {
  const _SplitExportAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(paymentBreakdownProvider).value;
    final methods = breakdown?.methods ?? const [];

    return ExportAction<PaymentMethodStat>(
      screenSlug: 'payment-methods-split',
      title: 'Payment Method Breakdown',
      rows: methods,
      columns: splitExportColumns(),
      totals: splitExportTotals(),
    );
  }
}
