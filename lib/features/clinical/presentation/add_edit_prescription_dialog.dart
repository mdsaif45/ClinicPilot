import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/remedy_autocomplete_field.dart';
import '../providers/prescription_provider.dart';

class AddEditPrescriptionDialog extends ConsumerStatefulWidget {
  final String patientId;
  final String? visitId;
  final Prescription? existingPrescription;
  final int defaultIndex;

  const AddEditPrescriptionDialog({
    super.key,
    required this.patientId,
    this.visitId,
    this.existingPrescription,
    this.defaultIndex = 1,
  });

  @override
  ConsumerState<AddEditPrescriptionDialog> createState() => _AddEditPrescriptionDialogState();
}

class _AddEditPrescriptionDialogState extends ConsumerState<AddEditPrescriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _doseController;
  late final TextEditingController _durationController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _dietaryController;

  late int _remedyIndex;
  late String _potency;
  late String _frequency;
  late String _vehicle;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPrescription;
    _remedyIndex = p?.remedyIndex ?? widget.defaultIndex;
    _nameController = TextEditingController(text: p?.remedyName ?? '');
    _potency = p?.potency ?? '200CH';
    _doseController = TextEditingController(text: p?.doseCount ?? '4 pills');
    _frequency = p?.frequency ?? 'OD (Once daily)';
    _vehicle = p?.vehicle ?? 'Globules / Pellets';
    _durationController = TextEditingController(text: p?.durationDays ?? '7 days');
    _instructionsController = TextEditingController(
      text: p?.instructions ?? 'Morning empty stomach',
    );
    _dietaryController = TextEditingController(
      text: p?.dietaryAdvice ?? 'Avoid raw onion, garlic, camphor, strong coffee, menthol',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    final notifier = ref.read(prescriptionNotifierProvider.notifier);
    final p = widget.existingPrescription;

    try {
      if (p == null) {
        await notifier.addPrescription(
          patientId: widget.patientId,
          visitId: widget.visitId,
          remedyIndex: _remedyIndex,
          remedyName: _nameController.text.trim(),
          potency: _potency,
          doseCount: _doseController.text.trim(),
          frequency: _frequency,
          vehicle: _vehicle,
          durationDays: _durationController.text.trim(),
          instructions: _instructionsController.text.trim(),
          dietaryAdvice: _dietaryController.text.trim(),
        );
      } else {
        await notifier.updatePrescription(
          id: p.id,
          remedyIndex: _remedyIndex,
          remedyName: _nameController.text.trim(),
          potency: _potency,
          doseCount: _doseController.text.trim(),
          frequency: _frequency,
          vehicle: _vehicle,
          durationDays: _durationController.text.trim(),
          instructions: _instructionsController.text.trim(),
          dietaryAdvice: _dietaryController.text.trim(),
        );
      }

      AppHaptics.success();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving prescription: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPrescription != null;

    return AppFormDialog(
      title: isEditing ? 'Edit Remedy Prescription' : 'Prescribe Homeopathic Remedy',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(isEditing ? 'Save Changes' : 'Add Remedy'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remedy Name with Autocomplete & Order
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 125,
                    child: DropdownButtonFormField<int>(
                      value: _remedyIndex,
                      isDense: true,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Rx #',
                        contentPadding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.sm),
                      ),
                      items: List.generate(
                        8,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Rx #${i + 1}'),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _remedyIndex = val);
                      },
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: RemedyAutocompleteField(
                      controller: _nameController,
                      label: 'Remedy (Latin Binomial) *',
                      hint: 'e.g. Thuja Occidentalis',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter remedy name' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Potency & Dose Count
              Row(
                children: [
                  Expanded(
                    child: PickerField<String>(
                      label: 'Potency',
                      value: _potency,
                      options: const [
                        PickerOption(value: 'Q / MT', label: 'Q (Mother Tincture)'),
                        PickerOption(value: '6CH', label: '6CH'),
                        PickerOption(value: '30CH', label: '30CH'),
                        PickerOption(value: '200CH', label: '200CH'),
                        PickerOption(value: '1M', label: '1M (1000CH)'),
                        PickerOption(value: '10M', label: '10M'),
                        PickerOption(value: '50M', label: '50M'),
                        PickerOption(value: 'CM', label: 'CM (100M)'),
                        PickerOption(value: '0/1 (LM-01)', label: '0/1 (LM-01)'),
                        PickerOption(value: '0/2 (LM-02)', label: '0/2 (LM-02)'),
                        PickerOption(value: '0/3 (LM-03)', label: '0/3 (LM-03)'),
                      ],
                      onChanged: (val) => setState(() => _potency = val),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _doseController,
                      decoration: const InputDecoration(
                        labelText: 'Dose',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Frequency & Vehicle
              Row(
                children: [
                  Expanded(
                    child: PickerField<String>(
                      label: 'Frequency',
                      value: _frequency,
                      options: const [
                        PickerOption(value: 'OD (Once daily)', label: 'OD (Once daily)'),
                        PickerOption(value: 'BD (Twice daily)', label: 'BD (Twice daily)'),
                        PickerOption(value: 'TDS (Thrice daily)', label: 'TDS (Thrice daily)'),
                        PickerOption(value: 'QID (4 times daily)', label: 'QID (4 times daily)'),
                        PickerOption(value: 'Stat (Immediately)', label: 'Stat (Single dose)'),
                        PickerOption(value: 'Weekly', label: 'Weekly (Once a week)'),
                        PickerOption(value: 'SOS (As Needed)', label: 'SOS (As Needed)'),
                        PickerOption(value: 'Hourly / Fractional', label: 'Hourly / Fractional'),
                      ],
                      onChanged: (val) => setState(() => _frequency = val),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: PickerField<String>(
                      label: 'Vehicle',
                      value: _vehicle,
                      options: const [
                        PickerOption(value: 'Globules / Pellets', label: 'Globules / Pellets'),
                        PickerOption(value: 'Mother Tincture in Water', label: 'Drops in Water'),
                        PickerOption(value: 'Distilled Water / RS', label: 'Liquid in Water'),
                        PickerOption(value: 'Sugar of Milk / Lactose', label: 'Powder (Lactose)'),
                      ],
                      onChanged: (val) => setState(() => _vehicle = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Duration & Instructions
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Timing / Instructions',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Dietary Advice & Restrictions
              TextFormField(
                controller: _dietaryController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Dietary Restrictions / Restrictions Advice',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}