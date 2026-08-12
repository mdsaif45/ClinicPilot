import 'package:flutter/material.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/choice_chip_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/expense_provider.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedClinicId;
  String _category = 'Medicine Purchase';
  String _paymentMethod = 'Cash';
  bool _isRecurring = false;
  DateTime _date = DateTime.now();

  final List<String> _categories = [
    'Rent',
    'Electricity',
    'Staff Salary',
    'Medicine Purchase',
    'Furniture',
    'Marketing',
    'Camp',
    'Internet',
    'Travel',
    'Personal',
    'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _selectedClinicId = ref.read(activeClinicIdProvider);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _subcategoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final clinics = clinicsAsync.value ?? [];

    return AlertDialog(
      title: const Text('Add Expense Entry'),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Without this the column centres its children. Text fields fill
            // the width so they look correct either way, but anything
            // narrower - chips, checkboxes - drifts to the middle.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PickerField<String>(
                label: 'Clinic',
                prefixIcon: Icons.local_hospital,
                value: _selectedClinicId,
                options: clinics
                    .map((c) => PickerOption(
                          value: c.id,
                          label: c.name,
                          subtitle: c.address,
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedClinicId = val),
              ),
              const SizedBox(height: 12),
              PickerField<String>(
                label: 'Expense Category',
                prefixIcon: Icons.category,
                value: _category,
                options: _categories
                    .map((c) => PickerOption(value: c, label: c))
                    .toList(),
                onChanged: (val) => setState(() => _category = val),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _subcategoryController,
                label: 'Subcategory / Details (e.g. Camp Name)',
                prefixIcon: Icons.subtitles,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _amountController,
                label: 'Amount (Rs)',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Valid amount' : null,
              ),
              const SizedBox(height: 12),
              // The field was already being saved but had no control, so every
              // expense recorded as Cash whatever it actually was.
              ChoiceChipField<String>(
                label: 'Payment Method',
                options: const ['Cash', 'UPI', 'Card', 'Bank Transfer'],
                value: _paymentMethod,
                labelOf: (m) => m,
                iconOf: _paymentIcon,
                onChanged: (m) => setState(() => _paymentMethod = m),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Recurring Fixed Cost (e.g. Rent)'),
                value: _isRecurring,
                onChanged: (val) => setState(() => _isRecurring = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                prefixIcon: Icons.notes,
              ),
            ],
          ),
        ),
      )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save Expense'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClinicId == null) return;

    final amount = double.parse(_amountController.text.trim());
    final subcat = _subcategoryController.text.trim();
    final notes = _notesController.text.trim();

    await ref.read(expenseNotifierProvider.notifier).addExpense(
          clinicId: _selectedClinicId!,
          category: _category,
          subcategory: subcat.isEmpty ? null : subcat,
          amount: amount,
          paymentMethod: _paymentMethod,
          isRecurring: _isRecurring,
          notes: notes.isEmpty ? null : notes,
          date: _date,
        );

    if (mounted) Navigator.of(context).pop();
  }

  IconData _paymentIcon(String method) => switch (method) {
        'Cash' => Icons.payments_outlined,
        'UPI' => Icons.qr_code_2,
        'Card' => Icons.credit_card,
        _ => Icons.account_balance_outlined,
      };
}
