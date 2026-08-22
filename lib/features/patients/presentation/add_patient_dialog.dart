import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/disease_autocomplete_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picker_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/patient_provider.dart';

class AddPatientDialog extends ConsumerStatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialDisease;
  final String? initialClinicId;

  const AddPatientDialog({
    super.key,
    this.initialName,
    this.initialPhone,
    this.initialDisease,
    this.initialClinicId,
  });

  @override
  ConsumerState<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends ConsumerState<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _serialController = TextEditingController();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _whatsappController = TextEditingController();
  final _ageController = TextEditingController();
  final _areaController = TextEditingController();
  late final TextEditingController _diseaseController;

  String _gender = 'Male';
  String? _selectedClinicId;
  String? _clinicError;
  String _referralSource = 'Direct Walk-in';

  bool _submitting = false;

  final List<String> _referralSources = [
    'Direct Walk-in',
    'Patient Referral',
    'Doctor Referral',
    'Camp / Event',
    'Google Search',
    'Social Media',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _diseaseController = TextEditingController(text: widget.initialDisease ?? '');
    _selectedClinicId = widget.initialClinicId ?? ref.read(activeClinicIdProvider);
  }

  @override
  void dispose() {
    _serialController.dispose();
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

    if (_selectedClinicId == null && clinics.length == 1) {
      _selectedClinicId = clinics.first.id;
    }

    final serialText = _serialController.text.trim();
    final liveSerialInUse = serialText.isEmpty || _selectedClinicId == null
        ? false
        : ref
                .watch(serialNoInUseProvider(SerialLookupArgs(
                  clinicId: _selectedClinicId!,
                  serialNo: serialText,
                )))
                .value ==
            true;

    if (clinicsAsync.hasValue && clinics.isEmpty) {
      return AppFormDialog(
        title: 'Register New Patient',
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
        child: EmptyState(
          icon: Icons.local_hospital_outlined,
          title: 'No clinic yet',
          message: 'Add a clinic before registering a patient.',
          actionLabel: 'Add clinic',
          onAction: () {
            Navigator.of(context).pop();
            context.push('/clinics');
          },
        ),
      );
    }

    return AppFormDialog(
      title: 'Register New Patient',
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
              : const Text('Register & Create Visit'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _serialController,
              label: 'Serial No.',
              hint: 'As in the register',
              prefixIcon: Icons.tag,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (liveSerialInUse) {
                  return 'Serial ${v.trim()} is already used at this clinic';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _nameController,
              label: 'Patient Full Name',
              prefixIcon: Icons.person,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _whatsappController,
              label: 'WhatsApp Number (Optional)',
              prefixIcon: Icons.chat,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _ageController,
                    label: 'Age',
                    prefixIcon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.age,
                  ),
                ),
                const SizedBox(width: Spacing.md),
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
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _areaController,
              label: 'Locality / Area',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: Spacing.md),
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
            DiseaseAutocompleteField(
              controller: _diseaseController,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
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
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final formOk = _formKey.currentState!.validate();

    setState(() {
      _clinicError = _selectedClinicId == null ? 'Please select a clinic' : null;
    });

    if (!formOk || _selectedClinicId == null) {
      AppHaptics.error();
      return;
    }

    setState(() => _submitting = true);

    final serialNo = _serialController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final whatsapp = _whatsappController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final area = _areaController.text.trim();
    final disease = Formatters.toTitleCase(_diseaseController.text);

    try {
      final patient =
          await ref.read(patientNotifierProvider.notifier).registerPatient(
                name: name,
                phone: phone,
                whatsapp: whatsapp.isEmpty ? null : whatsapp,
                age: age,
                gender: _gender,
                area: area.isEmpty ? null : area,
                primaryClinicId: _selectedClinicId!,
                serialNo: serialNo,
                disease: disease,
                referralSource: _referralSource,
              );
      AppHaptics.success();
      if (mounted) Navigator.of(context).pop(patient.id);
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not register patient: $e')),
        );
      }
      return;
    }
  }
}
