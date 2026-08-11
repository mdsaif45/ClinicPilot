import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../clinics/providers/clinic_provider.dart';
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
  final _whatsappController = TextEditingController();
  final _ageController = TextEditingController();
  final _areaController = TextEditingController();
  final _diseaseController = TextEditingController();

  String _gender = 'Male';
  String? _selectedClinicId;
  String _referralSource = 'Walk-in';

  final List<String> _referralSources = [
    'Walk-in',
    'Google Search',
    'Google Maps',
    'Instagram',
    'Friend/Family',
    'Camp',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _selectedClinicId = ref.read(activeClinicIdProvider);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _ageController.dispose();
    _areaController.dispose();
    _diseaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final clinics = clinicsAsync.value ?? [];

    return AlertDialog(
      title: const Text('Register New Patient'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Patient Full Name',
                prefixIcon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _whatsappController,
                label: 'WhatsApp Number (Optional)',
                prefixIcon: Icons.chat,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _ageController,
                      label: 'Age',
                      // Not a date picker — age is typed, so avoid a calendar icon.
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.age,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomDropdownField<String>(
                      label: 'Gender',
                      value: _gender,
                      prefixIcon: Icons.wc,
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _gender = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _areaController,
                label: 'Locality / Area (e.g. Babu Bazar)',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
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
                  if (val != null) setState(() => _selectedClinicId = val);
                },
                validator: (v) => v == null ? 'Select clinic' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _diseaseController,
                label: 'Disease / Chief Complaint',
                prefixIcon: Icons.medical_services,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _referralSource,
                decoration: const InputDecoration(
                  labelText: 'Referral Source (New Patient)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.campaign),
                ),
                items: _referralSources
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _referralSource = val);
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
          child: const Text('Register & Create Visit'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClinicId == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final area = _areaController.text.trim();
    final disease = _diseaseController.text.trim();

    await ref.read(patientNotifierProvider.notifier).registerPatient(
          name: name,
          phone: phone,
          whatsapp: whatsapp.isEmpty ? null : whatsapp,
          age: age,
          gender: _gender,
          area: area.isEmpty ? null : area,
          primaryClinicId: _selectedClinicId!,
          disease: disease,
          referralSource: _referralSource,
        );

    if (mounted) Navigator.of(context).pop();
  }
}
