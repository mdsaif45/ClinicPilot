import 'package:flutter/material.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/choice_chip_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../patients/presentation/patient_picker.dart';
import '../providers/cash_memo_provider.dart';

class NewCashMemoDialog extends ConsumerStatefulWidget {
  final Patient? initialPatient;

  const NewCashMemoDialog({super.key, this.initialPatient});

  @override
  ConsumerState<NewCashMemoDialog> createState() => _NewCashMemoDialogState();
}

class _NewCashMemoDialogState extends ConsumerState<NewCashMemoDialog> {
  final _formKey = GlobalKey<FormState>();

  Patient? _selectedPatient;
  // PatientPickerField is not a FormField, so its error is tracked here.
  String? _patientError;
  String? _selectedClinicId;
  final _consultationController = TextEditingController(text: '300');
  final _medicineController = TextEditingController(text: '0');
  final _otherController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController();

  String _paymentMethod = 'Cash';
  DateTime _memoDate = DateTime.now();

  // Guards against a memo being created twice from taps queued while the
  // first write is still in flight.
  bool _submitting = false;
  final List<String> _paymentMethods = ['Cash', 'UPI', 'Card', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.initialPatient;
    _selectedClinicId = ref.read(activeClinicIdProvider);

    final activeClinic = ref.read(activeClinicProvider);
    if (activeClinic != null) {
      _consultationController.text =
          activeClinic.defaultConsultationFee.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _consultationController.dispose();
    _medicineController.dispose();
    _otherController.dispose();
    _discountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  double get _total {
    final c = double.tryParse(_consultationController.text) ?? 0.0;
    final m = double.tryParse(_medicineController.text) ?? 0.0;
    final o = double.tryParse(_otherController.text) ?? 0.0;
    final d = double.tryParse(_discountController.text) ?? 0.0;
    return (c + m + o) - d;
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);

    final clinics = clinicsAsync.value ?? [];

    final currentTotal = _total;
    if (_paidAmountController.text.isEmpty) {
      _paidAmountController.text = currentTotal.toStringAsFixed(0);
    }

    return AlertDialog(
      title: const Text('Create Cash Memo'),
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
                onChanged: (val) {
                  setState(() {
                    _selectedClinicId = val;
                    final cl = clinics.firstWhere((c) => c.id == val);
                    _consultationController.text =
                        cl.defaultConsultationFee.toStringAsFixed(0);
                  });
                },
              ),
              const SizedBox(height: 12),
              DateField(
                label: 'Date',
                value: _memoDate,
                onChanged: (d) => setState(() => _memoDate = d),
              ),
              const SizedBox(height: 12),
              // Searchable picker rather than a dropdown: a flat list cannot
              // scale, and cannot distinguish two patients with the same name.
              PatientPickerField(
                selected: _selectedPatient,
                onSelected: (p) => setState(() {
                  _selectedPatient = p;
                  _patientError = null;
                }),
                errorText: _patientError,
              ),
              SizedBox(height: 12),
              CustomTextField(
                controller: _consultationController,
                label: 'Consultation Fee (Rs)',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _medicineController,
                label: 'Medicine Fee (Rs)',
                prefixIcon: Icons.medication,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _otherController,
                label: 'Other Charges (Rs)',
                prefixIcon: Icons.add_circle_outline,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _discountController,
                label: 'Discount (Rs)',
                prefixIcon: Icons.discount,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _paidAmountController,
                label: 'Paid Amount (Rs)',
                prefixIcon: Icons.payments,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Payable:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      Formatters.formatCurrency(currentTotal),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ChoiceChipField<String>(
                label: 'Payment Method',
                options: _paymentMethods,
                value: _paymentMethod,
                labelOf: (m) => m,
                iconOf: _paymentIcon,
                onChanged: (m) => setState(() => _paymentMethod = m),
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
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Memo'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final formOk = _formKey.currentState!.validate();

    // Surface the missing patient instead of failing silently.
    setState(() {
      _patientError = _selectedPatient == null ? 'Select a patient' : null;
    });

    if (!formOk || _selectedPatient == null || _selectedClinicId == null) return;

    setState(() => _submitting = true);

    final consult = double.tryParse(_consultationController.text) ?? 0.0;
    final med = double.tryParse(_medicineController.text) ?? 0.0;
    final other = double.tryParse(_otherController.text) ?? 0.0;
    final disc = double.tryParse(_discountController.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text) ?? _total;

    try {
      await ref.read(cashMemoNotifierProvider.notifier).createCashMemo(
            patientId: _selectedPatient!.id,
            clinicId: _selectedClinicId!,
            consultationFee: consult,
            medicineFee: med,
            otherFee: other,
            discount: disc,
            paidAmount: paid,
            paymentMethod: _paymentMethod,
            memoDate: _memoDate,
          );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create memo: \$e')),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  IconData _paymentIcon(String method) => switch (method) {
        'Cash' => Icons.payments_outlined,
        'UPI' => Icons.qr_code_2,
        'Card' => Icons.credit_card,
        _ => Icons.account_balance_outlined,
      };
}
