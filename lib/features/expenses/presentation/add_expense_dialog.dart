import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/choice_chip_field.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picker_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/expense_provider.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedClinicId;
  String? _clinicError;
  String _category = 'Medicine Purchase';
  String _paymentMethod = 'Cash';
  bool _isRecurring = false;
  DateTime _date = DateTime.now();

  // Guards against duplicate expenses if the user taps Save twice while an
  // insert is in flight.
  bool _submitting = false;

  final _amountController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _categories = [
    'Medicine Purchase',
    'Rent',
    'Electricity',
    'Assistant Salary',
    'Camp Expense',
    'Packaging',
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

    // An expense must belong to a clinic. Without one the write below will
    // never succeed, so say so before the form is filled in.
    if (clinicsAsync.hasValue && clinics.isEmpty) {
      return AlertDialog(
        title: const Text('Add Expense Entry'),
        content: EmptyState(
          icon: Icons.local_hospital_outlined,
          title: 'No clinic yet',
          message: 'Add a clinic before recording an expense.',
          actionLabel: 'Add clinic',
          onAction: () {
            Navigator.of(context).pop();
            context.push('/clinics');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AppFormDialog(
      title: 'Add Expense Entry',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Expense'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PickerField<String>(
              label: 'Clinic',
              prefixIcon: Icons.local_hospital,
              value: _selectedClinicId,
              errorText: _clinicError,
              options: clinics
                  .map((c) => PickerOption(
                        value: c.id,
                        label: c.name,
                        subtitle: c.address,
                      ))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedClinicId = val;
                _clinicError = null;
              }),
            ),
            const SizedBox(height: Spacing.md),
            DateField(
              label: 'Date',
              value: _date,
              onChanged: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: Spacing.md),
            PickerField<String>(
              label: 'Expense Category',
              prefixIcon: Icons.category,
              value: _category,
              options: _categories
                  .map((c) => PickerOption(value: c, label: c))
                  .toList(),
              onChanged: (val) => setState(() => _category = val),
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _subcategoryController,
              label: 'Subcategory / Details (e.g. Camp Name)',
              prefixIcon: Icons.subtitles,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _amountController,
              label: 'Amount (Rs)',
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || double.tryParse(v) == null ? 'Valid amount' : null,
            ),
            const SizedBox(height: Spacing.md),
            // The field was already being saved but had no control, so every
            // expense recorded as Cash whatever it actually was.
            ChoiceChipField<String>(
              label: 'Payment Method',
              options: const ['Cash', 'UPI', 'Card', 'Bank Transfer'],
              value: _paymentMethod,
              labelOf: (m) => m,
              iconOf: PaymentIcons.forMethod,
              onChanged: (m) => setState(() => _paymentMethod = m),
            ),
            const SizedBox(height: Spacing.md),
            CheckboxListTile(
              title: const Text('Recurring Fixed Cost (e.g. Rent)'),
              value: _isRecurring,
              onChanged: (val) => setState(() => _isRecurring = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              prefixIcon: Icons.notes,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final formOk = _formKey.currentState!.validate();

    setState(() {
      _clinicError = _selectedClinicId == null ? 'Select a clinic' : null;
    });

    if (!formOk || _selectedClinicId == null) return;

    setState(() => _submitting = true);

    final amount = double.parse(_amountController.text.trim());
    final subcat = _subcategoryController.text.trim();
    final notes = _notesController.text.trim();

    try {
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
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save expense: $e')),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
