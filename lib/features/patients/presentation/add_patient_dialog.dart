import 'package:flutter/material.dart';
import '../../../core/widgets/picker_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    child: PickerField<String>(
                      label: 'Gender',
                      prefixIcon: Icons.wc,
                      value: _gender,
                      options: const [
                        PickerOption(value: 'Male', label: 'Male'),
                        PickerOption(value: 'Female', label: 'Female'),
                        PickerOption(value: 'Other', label: 'Other'),
                      ],
                      onChanged: (val) => setState(() => _gender = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _areaController,
                label: 'Locality / Area',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
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
              CustomTextField(
                controller: _diseaseController,
                label: 'Disease / Chief Complaint',
                prefixIcon: Icons.medical_services,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              PickerField<String>(
                label: 'Referral Source (New Patient)',
                prefixIcon: Icons.campaign,
                value: _referralSource,
                options: _referralSources
                    .map((r) => PickerOption(value: r, label: r))
                    .toList(),
                onChanged: (val) => setState(() => _referralSource = val),
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
