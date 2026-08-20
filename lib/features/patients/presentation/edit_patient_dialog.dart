import 'package:flutter/material.dart';
import '../../../core/widgets/picker_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../providers/patient_provider.dart';

class EditPatientDialog extends ConsumerStatefulWidget {
  final Patient patient;

  const EditPatientDialog({super.key, required this.patient});

  @override
  ConsumerState<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends ConsumerState<EditPatientDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _ageController;
  late TextEditingController _areaController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;
  late TextEditingController _notesController;

  late String _gender;

  // Guards against a queued tap re-running _saveChanges before the first
  // write finishes and the dialog closes.
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _phoneController = TextEditingController(text: widget.patient.phone);
    _whatsappController = TextEditingController(text: widget.patient.whatsapp ?? '');
    _ageController = TextEditingController(text: widget.patient.age.toString());
    _areaController = TextEditingController(text: widget.patient.area ?? '');
    _addressController = TextEditingController(text: widget.patient.address ?? '');
    _occupationController = TextEditingController(text: widget.patient.occupation ?? '');
    _notesController = TextEditingController(text: widget.patient.notes ?? '');
    _gender = widget.patient.gender;
  }

  @override
  void dispose() {
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
    return AlertDialog(
      title: Text('Edit Patient (${widget.patient.patientCode})'),
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: 'WhatsApp Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A fixed label above the field, matching Gender's
                        // PickerField, rather than a floating labelText - the
                        // two were built from different label styles, which is
                        // why the row never lined up.
                        Text(
                          'Age *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || int.tryParse(val.trim()) == null ? 'Invalid' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PickerField<String>(
                      label: 'Gender',
                      value: const ['Male', 'Female', 'Other'].contains(_gender)
                          ? _gender
                          : 'Male',
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
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Area / Locality'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Full Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(labelText: 'Occupation'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Clinical Notes'),
                maxLines: 2,
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
