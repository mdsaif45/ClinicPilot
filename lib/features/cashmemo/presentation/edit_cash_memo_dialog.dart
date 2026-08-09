import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
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

  @override
  void initState() {
    super.initState();
    _consultationFeeController = TextEditingController(text: widget.memo.consultationFee.toString());
    _medicineFeeController = TextEditingController(text: widget.memo.medicineFee.toString());
    _otherFeeController = TextEditingController(text: widget.memo.otherFee.toString());
    _discountController = TextEditingController(text: widget.memo.discount.toString());
    _paidAmountController = TextEditingController(text: widget.memo.paidAmount.toString());
    _notesController = TextEditingController(text: widget.memo.notes ?? '');
    _paymentMethod = widget.memo.paymentMethod;
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
    return AlertDialog(
      title: Text('Edit Cash Memo (${widget.memo.memoNumber})'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _consultationFeeController,
                decoration: const InputDecoration(labelText: 'Consultation Fee (Rs)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _medicineFeeController,
                decoration: const InputDecoration(labelText: 'Medicine Fee (Rs)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _otherFeeController,
                decoration: const InputDecoration(labelText: 'Other Fee (Rs)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Discount (Rs)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _paidAmountController,
                decoration: const InputDecoration(labelText: 'Paid Amount (Rs)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: ['Cash', 'UPI', 'Card', 'Bank Transfer'].contains(_paymentMethod)
                    ? _paymentMethod
                    : 'Cash',
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['Cash', 'UPI', 'Card', 'Bank Transfer']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final consult = double.tryParse(_consultationFeeController.text.trim()) ?? 0.0;
    final med = double.tryParse(_medicineFeeController.text.trim()) ?? 0.0;
    final other = double.tryParse(_otherFeeController.text.trim()) ?? 0.0;
    final disc = double.tryParse(_discountController.text.trim()) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text.trim()) ?? 0.0;

    await ref.read(cashMemoNotifierProvider.notifier).updateCashMemo(
          id: widget.memo.id,
          consultationFee: consult,
          medicineFee: med,
          otherFee: other,
          discount: disc,
          paidAmount: paid,
          paymentMethod: _paymentMethod,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cash Memo updated successfully')),
      );
    }
  }
}
