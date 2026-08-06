import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/custom_text_field.dart';
import '../providers/patient_provider.dart';

class AddPatientDialog extends ConsumerStatefulWidget {
  const AddPatientDialog({super.key});

  @override
  ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _diseaseController = TextEditingController();

  String _gender = 'Male';
  String _referralSource = 'Walk-in';

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _referralOptions = [
    'Walk-in',
    'Google Search',
    'Google Maps',
    'Instagram',
    'Friend/Family',
    'Camp',
    'Others'
  ];

  final List<String> _commonDiseases = [
    'Migraine',
    'Diabetes',
    'Thyroid',
    'PCOS',
    'Skin Disease',
    'Arthritis',
    'General Health'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _diseaseController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final disease = _diseaseController.text.trim().isEmpty ? 'General' : _diseaseController.text.trim();

    final success = await ref.read(patientNotifierProvider.notifier).registerPatient(
          name: name,
          phone: phone,
          age: age,
          gender: _gender,
          clinicId: 'default_clinic',
          disease: disease,
          referralSource: _referralSource,
        );

    if (mounted && success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Patient '$name' registered successfully!"),
          backgroundColor: const Color(0xFF0F5132),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientNotifierProvider);

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
                      "Register Patient",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                CustomTextField(
                  label: "Patient Name",
                  hint: "e.g. Mr. Rahul Sharma",
                  controller: _nameController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: "Phone Number",
                        hint: "9876543210",
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Phone is required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: CustomTextField(
                        label: "Age",
                        hint: "29",
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  "Gender",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: _genderOptions.map((g) {
                    final selected = _gender == g;
                    return ChoiceChip(
                      label: Text(g),
                      selected: selected,
                      selectedColor: const Color(0xFF0F5132),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _gender = g);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: "Disease / Case",
                  hint: "e.g. Migraine, PCOS",
                  controller: _diseaseController,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _commonDiseases.map((d) {
                    return ActionChip(
                      label: Text(d, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        setState(() => _diseaseController.text = d);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Referral Source",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _referralSource,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  items: _referralOptions.map((src) {
                    return DropdownMenuItem(value: src, child: Text(src));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _referralSource = val);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Register Patient"),
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
