import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/master_disease_service.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/disease_autocomplete_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/footfall_provider.dart';

class AddFootfallDialog extends ConsumerStatefulWidget {
  const AddFootfallDialog({super.key});

  @override
  ConsumerState<AddFootfallDialog> createState() => _AddFootfallDialogState();
}

class _AddFootfallDialogState extends ConsumerState<AddFootfallDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _notesController = TextEditingController();

  String? _clinicId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _clinicId = ref.read(activeClinicProvider)?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _diseaseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a clinic.')),
      );
      return;
    }

    setState(() => _submitting = true);
    AppHaptics.medium();

    try {
      final disease = _diseaseController.text.trim();
      await ref.read(footfallNotifierProvider.notifier).addFootfall(
            clinicId: _clinicId!,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            disease: disease.isEmpty ? null : disease,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (disease.isNotEmpty) {
        ref.read(masterDiseaseServiceProvider).recordDisease(disease);
      }

      AppHaptics.success();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not log walk-in: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allClinics = ref.watch(clinicsStreamProvider).value ?? const [];
    final clinics = allClinics.where((c) {
      final name = c.name.toLowerCase();
      return !name.contains('online') && !name.contains('teleconsultation');
    }).toList();

    if ((_clinicId == null || clinics.every((c) => c.id != _clinicId)) && clinics.isNotEmpty) {
      final active = ref.read(activeClinicProvider);
      if (active != null && clinics.any((c) => c.id == active.id)) {
        _clinicId = active.id;
      } else {
        _clinicId = clinics.first.id;
      }
    }

    return AppFormDialog(
      title: 'Log Walk-in / Inquiry',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: const Text('Save Walk-in'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (clinics.length > 1) ...[
              PickerField<String>(
                label: 'Clinic',
                value: _clinicId ?? '',
                options: clinics
                    .map((c) => PickerOption(value: c.id, label: c.name))
                    .toList(),
                onChanged: (val) => setState(() => _clinicId = val),
              ),
              const SizedBox(height: Spacing.md),
            ],
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Visitor Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: Spacing.md),
            DiseaseAutocompleteField(
              controller: _diseaseController,
              label: 'Inquiry / Chief Complaint',
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
