import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../providers/expense_provider.dart';

class EditExpenseDialog extends ConsumerStatefulWidget {
  final Expense expense;

  const EditExpenseDialog({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends ConsumerState<EditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _categoryController;
  late TextEditingController _subcategoryController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late String _paymentMethod;
  late bool _isRecurring;
  late DateTime _date;

  final _categories = [
    'Rent',
    'Electricity',
    'Staff Salary',
    'Medicine Purchase',
    'Furniture',
    'Marketing',
    'Camp',
    'Internet',
    'Travel',
    'Miscellaneous'
  ];

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.expense.category);
    _subcategoryController = TextEditingController(text: widget.expense.subcategory ?? '');
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _notesController = TextEditingController(text: widget.expense.notes ?? '');
    _paymentMethod = widget.expense.paymentMethod;
    _isRecurring = widget.expense.isRecurring;
    _date = widget.expense.date;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subcategoryController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Expense Entry'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _categories.contains(_categoryController.text)
                    ? _categoryController.text
                    : _categories.first,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _categoryController.text = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subcategoryController,
                decoration: const InputDecoration(labelText: 'Subcategory / Details'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (Rs) *'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val.trim()) == null ? 'Required' : null,
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
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recurring Monthly Expense'),
                value: _isRecurring,
                onChanged: (val) {
                  if (val != null) setState(() => _isRecurring = val);
                },
              ),
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

    final amount = double.parse(_amountController.text.trim());

    await ref.read(expenseNotifierProvider.notifier).updateExpense(
          id: widget.expense.id,
          category: _categoryController.text.trim(),
          subcategory: _subcategoryController.text.trim().isEmpty
              ? null
              : _subcategoryController.text.trim(),
          amount: amount,
          paymentMethod: _paymentMethod,
          isRecurring: _isRecurring,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          date: _date,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated successfully')),
      );
    }
  }
}
