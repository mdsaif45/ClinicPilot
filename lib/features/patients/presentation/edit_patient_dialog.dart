import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../providers/patient_provider.dart';

class EditPatientDialog extends ConsumerStatefulWidget {
  final Patient patient;

  const EditPatientDialog({super.key, required this.patient});

  @override
  ConsumerState<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends ConsumerState<EditPatientDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _serialController;
  late DateTime _entryDate;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _ageController;
  late TextEditingController _areaController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;
  late TextEditingController _notesController;
  late String _gender;

  // Guards against duplicate writes if the doctor double-taps Save while
  // the first update is in flight.
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController(text: widget.patient.serialNo);
    _entryDate = widget.patient.createdAt;
    _nameController = TextEditingController(text: widget.patient.name);
    _phoneController = TextEditingController(text: widget.patient.phone);
    _whatsappController =
        TextEditingController(text: widget.patient.whatsapp ?? '');
    _ageController =
        TextEditingController(text: widget.patient.age.toString());
    _areaController =
        TextEditingController(text: widget.patient.area ?? '');
    _addressController =
        TextEditingController(text: widget.patient.address ?? '');
    _occupationController =
        TextEditingController(text: widget.patient.occupation ?? '');
    _notesController =
        TextEditingController(text: widget.patient.notes ?? '');
    _gender = widget.patient.gender;
  }

  @override
  void dispose() {
    _serialController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _ageController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serialText = _serialController.text.trim();
    final liveSerialInUse = serialText.isEmpty
        ? false
        : ref
                .watch(serialNoInUseProvider(SerialLookupArgs(
                  clinicId: widget.patient.primaryClinicId,
                  serialNo: serialText,
                  excludingPatientId: widget.patient.id,
                )))
                .value ==
            true;

    return AppFormDialog(
      title: 'Edit Patient (${widget.patient.patientCode})',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _saveChanges,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
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
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                if (liveSerialInUse) {
                  return 'Serial ${val.trim()} is already used at this clinic';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            DateField(
              label: 'Patient Entry Date',
              value: _entryDate,
              onChanged: (d) => setState(() => _entryDate = d),
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _nameController,
              label: 'Patient Full Name',
              prefixIcon: Icons.person,
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
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
            CustomTextField(
              controller: _addressController,
              label: 'Full Address',
              prefixIcon: Icons.home,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _occupationController,
              label: 'Occupation',
              prefixIcon: Icons.work,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _notesController,
              label: 'Clinical Notes',
              prefixIcon: Icons.notes,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      await ref.read(patientNotifierProvider.notifier).updatePatient(
            id: widget.patient.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            whatsapp: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _gender,
            area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            occupation: _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            serialNo: _serialController.text.trim(),
            createdAt: _entryDate,
          );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update patient: \$e')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient updated successfully')),
      );
    }
  }
}
