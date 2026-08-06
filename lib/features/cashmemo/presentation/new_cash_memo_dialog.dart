import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../patients/presentation/add_patient_dialog.dart';
import '../../patients/providers/patient_provider.dart';
import '../providers/cash_memo_provider.dart';
import 'receipt_preview_dialog.dart';

class NewCashMemoDialog extends ConsumerStatefulWidget {
  const NewCashMemoDialog({super.key});

  @override
  ConsumerState<NewCashMemoDialog> createState() => _NewCashMemoDialogState();
}

class _NewCashMemoDialogState extends ConsumerState<NewCashMemoDialog> {
  final _formKey = GlobalKey<FormState>();
  Patient? _selectedPatient;

  final _consultationController = TextEditingController(text: '500');
  final _medicineController = TextEditingController(text: '300');
  final _otherController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');

  String _paymentMethod = 'Cash';
  final List<String> _paymentOptions = ['Cash', 'UPI', 'Card', 'Bank'];

  double get _total {
    final consultation = double.tryParse(_consultationController.text) ?? 0;
    final medicine = double.tryParse(_medicineController.text) ?? 0;
    final other = double.tryParse(_otherController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final sum = (consultation + medicine + other) - discount;
    return sum < 0 ? 0 : sum;
  }

  @override
  void dispose() {
    _consultationController.dispose();
    _medicineController.dispose();
    _otherController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a patient")),
      );
      return;
    }

    final consultation = double.tryParse(_consultationController.text) ?? 0;
    final medicine = double.tryParse(_medicineController.text) ?? 0;
    final other = double.tryParse(_otherController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;

    final createdMemo = await ref.read(cashMemoNotifierProvider.notifier).createCashMemo(
          patientId: _selectedPatient!.id,
          consultationFee: consultation,
          medicineFee: medicine,
          otherFee: other,
          discount: discount,
          paymentMethod: _paymentMethod,
        );

    if (mounted && createdMemo != null) {
      final patient = _selectedPatient!;
      Navigator.of(context).pop();

      // Open PDF receipt preview directly
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewDialog(
            cashMemo: createdMemo,
            patient: patient,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsStreamProvider);
    final state = ref.watch(cashMemoNotifierProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "New Cash Memo",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                const Text("Select Patient", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                patientsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text("Error: $e"),
                  data: (patients) {
                    if (patients.isEmpty) {
                      return Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text("No patients found in system.", style: TextStyle(fontSize: 13)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showDialog(context: context, builder: (_) => const AddPatientDialog());
                                },
                                child: const Text("Add Patient"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return DropdownButtonFormField<Patient>(
                      value: _selectedPatient,
                      isExpanded: true,
                      hint: const Text("Choose patient..."),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      items: patients.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text("${p.name} (${p.phone} • ${p.disease})"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedPatient = val);
                      },
                      validator: (v) => v == null ? "Patient is required" : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Consultation Fee (₹)",
                        controller: _consultationController,
                        keyboardType: TextInputType.number,
                        onTap: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: "Medicine Fee (₹)",
                        controller: _medicineController,
                        keyboardType: TextInputType.number,
                        onTap: () => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Other Fee (₹)",
                        controller: _otherController,
                        keyboardType: TextInputType.number,
                        onTap: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: "Discount (₹)",
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        onTap: () => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Payment Method", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: _paymentOptions.map((pm) {
                    final selected = _paymentMethod == pm;
                    return ChoiceChip(
                      label: Text(pm),
                      selected: selected,
                      selectedColor: const Color(0xFF0F5132),
                      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                      onSelected: (val) {
                        if (val) setState(() => _paymentMethod = pm);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5132).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0F5132).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Payable:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        "₹ ${_total.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading ? null : _submit,
                    icon: const Icon(Icons.receipt_long),
                    label: state.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Generate Receipt & Print"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
