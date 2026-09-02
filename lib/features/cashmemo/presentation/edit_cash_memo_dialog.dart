import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/choice_chip_field.dart';
import '../../../core/widgets/date_field.dart';
import '../providers/cash_memo_provider.dart';

class EditCashMemoDialog extends ConsumerStatefulWidget {
  final CashMemo memo;

  const EditCashMemoDialog({super.key, required this.memo});

  @override
  ConsumerState<EditCashMemoDialog> createState() => _EditCashMemoDialogState();
}

class _EditCashMemoDialogState extends ConsumerState<EditCashMemoDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _consultationFeeController;
  late TextEditingController _medicineFeeController;
  late TextEditingController _otherFeeController;
  late TextEditingController _discountController;
  late TextEditingController _paidAmountController;
  late TextEditingController _notesController;

  late String _paymentMethod;
  late DateTime _memoDate;

  // Guards against a queued tap re-running _saveChanges before the first
  // write finishes and the dialog closes.
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _consultationFeeController = TextEditingController(
      text: widget.memo.consultationFee.toString(),
    );
    _medicineFeeController = TextEditingController(
      text: widget.memo.medicineFee.toString(),
    );
    _otherFeeController = TextEditingController(
      text: widget.memo.otherFee.toString(),
    );
    _discountController = TextEditingController(
      text: widget.memo.discount.toString(),
    );
    _paidAmountController = TextEditingController(
      text: widget.memo.paidAmount.toString(),
    );
    _notesController = TextEditingController(text: widget.memo.notes ?? '');
    _paymentMethod = widget.memo.paymentMethod;
    _memoDate = widget.memo.memoDate;
  }

  @override
  void dispose() {
    _consultationFeeController.dispose();
    _medicineFeeController.dispose();
    _otherFeeController.dispose();
    _discountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Edit Cash Memo (${widget.memo.memoNumber})',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _saveChanges,
          child:
              _submitting
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Save Changes'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateField(
              label: 'Date',
              value: _memoDate,
              onChanged: (d) => setState(() => _memoDate = d),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _consultationFeeController,
              decoration: const InputDecoration(
                labelText: 'Consultation Fee (Rs)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _medicineFeeController,
              decoration: const InputDecoration(labelText: 'Medicine Fee (Rs)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _otherFeeController,
              decoration: const InputDecoration(labelText: 'Other Fee (Rs)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _discountController,
              decoration: const InputDecoration(labelText: 'Discount (Rs)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _paidAmountController,
              decoration: const InputDecoration(labelText: 'Paid Amount (Rs)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Spacing.md),
            ChoiceChipField<String>(
              label: 'Payment Method',
              options: const ['Cash', 'UPI', 'Card', 'Bank Transfer'],
              // Fall back to Cash if a memo carries a method no longer offered.
              value:
                  const [
                        'Cash',
                        'UPI',
                        'Card',
                        'Bank Transfer',
                      ].contains(_paymentMethod)
                      ? _paymentMethod
                      : 'Cash',
              labelOf: (m) => m,
              iconOf: PaymentIcons.forMethod,
              onChanged: (m) => setState(() => _paymentMethod = m),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final consult =
        double.tryParse(_consultationFeeController.text.trim()) ?? 0.0;
    final med = double.tryParse(_medicineFeeController.text.trim()) ?? 0.0;
    final other = double.tryParse(_otherFeeController.text.trim()) ?? 0.0;
    final disc = double.tryParse(_discountController.text.trim()) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text.trim()) ?? 0.0;

    try {
      await ref
          .read(cashMemoNotifierProvider.notifier)
          .updateCashMemo(
            id: widget.memo.id,
            consultationFee: consult,
            medicineFee: med,
            otherFee: other,
            discount: disc,
            paidAmount: paid,
            paymentMethod: _paymentMethod,
            memoDate: _memoDate,
            notes:
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not update memo: \$e')));
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash Memo updated successfully')),
      );
    }
  }
}
