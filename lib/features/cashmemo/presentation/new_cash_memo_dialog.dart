import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../patients/providers/patient_provider.dart';
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
  String? _selectedClinicId;
  final _consultationController = TextEditingController(text: '300');
  final _medicineController = TextEditingController(text: '0');
  final _otherController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController();

  String _paymentMethod = 'Cash';
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
    final patientsAsync = ref.watch(patientsStreamProvider);
    final clinicsAsync = ref.watch(clinicsStreamProvider);

    final patients = patientsAsync.value ?? [];
    final clinics = clinicsAsync.value ?? [];

    final currentTotal = _total;
    if (_paidAmountController.text.isEmpty) {
      _paidAmountController.text = currentTotal.toStringAsFixed(0);
    }

    return AlertDialog(
      title: const Text('Create Cash Memo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedClinicId,
                decoration: const InputDecoration(
                  labelText: 'Clinic',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                items: clinics
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedClinicId = val;
                      final cl = clinics.firstWhere((c) => c.id == val);
                      _consultationController.text =
                          cl.defaultConsultationFee.toStringAsFixed(0);
                    });
                  }
                },
                validator: (v) => v == null ? 'Select clinic' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Patient>(
                value: _selectedPatient,
                decoration: const InputDecoration(
                  labelText: 'Select Patient',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: patients
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text('${p.patientCode} - ${p.name}'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPatient = val),
                validator: (v) => v == null ? 'Select a patient' : null,
              ),
              const SizedBox(height: 12),
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
                    const Text('Total Payable:',
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
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: _paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
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
          onPressed: _submit,
          child: const Text('Create Memo'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null || _selectedClinicId == null) return;

    final consult = double.tryParse(_consultationController.text) ?? 0.0;
    final med = double.tryParse(_medicineController.text) ?? 0.0;
    final other = double.tryParse(_otherController.text) ?? 0.0;
    final disc = double.tryParse(_discountController.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text) ?? _total;

    await ref.read(cashMemoNotifierProvider.notifier).createCashMemo(
          patientId: _selectedPatient!.id,
          clinicId: _selectedClinicId!,
          consultationFee: consult,
          medicineFee: med,
          otherFee: other,
          discount: disc,
          paidAmount: paid,
          paymentMethod: _paymentMethod,
        );

    if (mounted) Navigator.of(context).pop();
  }
}
