import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../cashmemo/presentation/edit_cash_memo_dialog.dart';
import '../../cashmemo/presentation/receipt_preview_dialog.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../expenses/presentation/edit_expense_dialog.dart';
import '../../expenses/providers/expense_provider.dart';

// Full transaction detail voucher screen aligned with ClinicPilot clinical ERP design system.
class TransactionDetailScreen extends ConsumerStatefulWidget {
  final CashMemoWithDetails? memoItem;
  final ExpenseWithClinic? expenseItem;

  const TransactionDetailScreen({
    super.key,
    this.memoItem,
    this.expenseItem,
  }) : assert(memoItem != null || expenseItem != null, 'Either memo or expense must be provided');

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  void _shareVoucher(String title, double amount, String dateStr, String? clinicName, bool isExpense, String paymentMethod) {
    final shareText = isExpense
        ? 'Expense Voucher: $title\n'
          'Amount: ${Formatters.formatCurrency(amount)}\n'
          'Paid Via: $paymentMethod\n'
          'Date: $dateStr\n'
          'Clinic: ${clinicName ?? "ClinicPilot"}'
        : 'Cash Memo Receipt: $title\n'
          'Amount Paid: ${Formatters.formatCurrency(amount)}\n'
          'Payment Mode: $paymentMethod\n'
          'Date: $dateStr\n'
          'Clinic: ${clinicName ?? "ClinicPilot"}';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isExpense = widget.expenseItem != null;

    final memo = widget.memoItem?.memo;
    final patient = widget.memoItem?.patient;
    final clinic = widget.memoItem?.clinic ?? widget.expenseItem?.clinic;
    final exp = widget.expenseItem?.expense;

    final date = isExpense ? exp!.date : memo!.memoDate;
    final timeStr = TimeOfDay.fromDateTime(isExpense ? exp!.createdAt : memo!.createdAt).format(context);
    final dateStr = Formatters.formatDate(date);
    final amount = isExpense ? exp!.amount : memo!.paidAmount;

    final title = isExpense
        ? (exp!.notes != null && exp.notes!.trim().isNotEmpty
            ? exp.notes!
            : (exp.subcategory != null && exp.subcategory!.trim().isNotEmpty
                ? '${exp.category} (${exp.subcategory})'
                : exp.category))
        : patient!.name;

    final subtitle = isExpense
        ? exp!.category
        : (patient!.phone.isNotEmpty ? '+91 ${patient.phone}' : patient.patientCode);

    final paymentMethod = isExpense ? exp!.paymentMethod : memo!.paymentMethod;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isExpense ? 'Expense Voucher' : 'Cash Memo Record',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$dateStr · $timeStr',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Voucher',
            onPressed: () => _shareVoucher(title, amount, dateStr, clinic?.name, isExpense, paymentMethod),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
        children: [
          // 1. Hero Practice Voucher Card
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withAlpha(90),
              borderRadius: Radii.lgAll,
              border: Border.all(color: theme.dividerColor.withAlpha(80)),
            ),
            child: Column(
              children: [
                // Top Header: Entity Avatar + Title + Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isExpense
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isExpense
                              ? const Color(0xFFFFCDD2)
                              : const Color(0xFFC8E6C9),
                        ),
                      ),
                      child: Icon(
                        isExpense ? Icons.north_east : Icons.south_west,
                        color: isExpense
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF2E7D32),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isExpense
                            ? const Color(0xFFFFEBEE)
                            : const Color(0xFFE8F5E9),
                        borderRadius: Radii.pillAll,
                        border: Border.all(
                          color: isExpense
                              ? const Color(0xFFE57373)
                              : const Color(0xFF81C784),
                        ),
                      ),
                      child: Text(
                        isExpense ? 'Expense' : 'Paid',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isExpense
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Spacing.lg),

                // Amount Figure Hero
                Text(
                  isExpense
                      ? '- ${Formatters.formatCurrency(amount)}'
                      : '+ ${Formatters.formatCurrency(amount)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isExpense
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF2E7D32),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),

                // Payment Settlement Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PaymentIcons.forMethod(paymentMethod),
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Settled via $paymentMethod',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // 2. Structured Ledger Specifications Card
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withAlpha(50),
              borderRadius: Radii.mdAll,
              border: Border.all(color: theme.dividerColor.withAlpha(70)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fact_check_outlined, size: 18, color: scheme.primary),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Voucher Specifications',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                const Divider(height: 1),
                const SizedBox(height: Spacing.sm),

                _DetailRow(
                  label: 'Payment Method',
                  value: paymentMethod,
                  trailingIcon: PaymentIcons.forMethod(paymentMethod),
                ),
                if (clinic != null)
                  _DetailRow(label: 'Clinic / Branch', value: clinic.name),

                if (!isExpense && memo != null) ...[
                  _DetailRow(label: 'Memo Number', value: memo.memoNumber),
                  if (patient != null) ...[
                    _DetailRow(label: 'Patient Code', value: patient.patientCode),
                    if (patient.serialNo.isNotEmpty)
                      _DetailRow(label: 'Serial No', value: '#${patient.serialNo}'),
                    if (patient.area != null && patient.area!.isNotEmpty)
                      _DetailRow(label: 'Area / Location', value: patient.area!),
                  ],
                  if (memo.consultationFee > 0)
                    _DetailRow(
                      label: 'Consultation Fee',
                      value: Formatters.formatCurrency(memo.consultationFee),
                    ),
                  if (memo.medicineFee > 0)
                    _DetailRow(
                      label: 'Medicine Fee',
                      value: Formatters.formatCurrency(memo.medicineFee),
                    ),
                  if (memo.otherFee > 0)
                    _DetailRow(
                      label: 'Other Charges',
                      value: Formatters.formatCurrency(memo.otherFee),
                    ),
                  if (memo.discount > 0)
                    _DetailRow(
                      label: 'Discount Given',
                      value: '- ${Formatters.formatCurrency(memo.discount)}',
                    ),
                  _DetailRow(
                    label: 'Total Bill Amount',
                    value: Formatters.formatCurrency(memo.total),
                    isBold: true,
                  ),
                  _DetailRow(
                    label: 'Amount Paid',
                    value: Formatters.formatCurrency(memo.paidAmount),
                    isBold: true,
                  ),
                  if (memo.total - memo.paidAmount > 0)
                    _DetailRow(
                      label: 'Pending Balance',
                      value: Formatters.formatCurrency(memo.total - memo.paidAmount),
                      valueColor: theme.colorScheme.error,
                      isBold: true,
                    ),
                ],
                if (isExpense && exp != null) ...[
                  _DetailRow(label: 'Category', value: exp.category),
                  if (exp.subcategory != null && exp.subcategory!.isNotEmpty)
                    _DetailRow(label: 'Subcategory', value: exp.subcategory!),
                  _DetailRow(
                    label: 'Nature',
                    value: exp.isRecurring
                        ? 'Recurring (Monthly Fixed)'
                        : 'One-time (Variable)',
                  ),
                  if (exp.notes != null && exp.notes!.isNotEmpty)
                    _DetailRow(label: 'Notes / Recipient', value: exp.notes!),
                ],
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // 3. Action Toolbar (Cohesive ClinicPilot Buttons)
          if (!isExpense && widget.memoItem != null) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ReceiptPreviewDialog(
                    cashMemo: widget.memoItem!.memo,
                    patient: widget.memoItem!.patient,
                    clinicName: widget.memoItem!.clinic.name,
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long_outlined, size: 20),
              label: const Text('View Formal Receipt'),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditCashMemoDialog(memo: memo!),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Memo'),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
                    ),
                    onPressed: () => _shareVoucher(title, amount, dateStr, clinic?.name, isExpense, paymentMethod),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share Record'),
                  ),
                ),
              ],
            ),
          ],

          if (isExpense && widget.expenseItem != null) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => EditExpenseDialog(expense: exp!),
                );
              },
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Edit Expense'),
            ),
            const SizedBox(height: Spacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: Radii.smAll),
              ),
              onPressed: () => _shareVoucher(title, amount, dateStr, clinic?.name, isExpense, paymentMethod),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Share Expense Record'),
            ),
          ],

          const SizedBox(height: Spacing.xl),

          // 4. Practice Audit Stamp Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withAlpha(40),
              borderRadius: Radii.smAll,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_outlined, size: 16, color: scheme.primary),
                const SizedBox(width: Spacing.xs),
                Text(
                  'Verified Practice Record • ClinicPilot Accounting System',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? trailingIcon;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.trailingIcon,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingIcon != null) ...[
                Icon(trailingIcon, size: 14, color: scheme.primary),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor ?? scheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

