import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/widgets/remedy_autocomplete_field.dart';
import '../providers/prescription_provider.dart';

class AddEditPrescriptionDialog extends ConsumerStatefulWidget {
  final String patientId;
  final String? visitId;
  final Prescription? existingPrescription;
  final int defaultIndex;
  final bool defaultIsBaseline;

  const AddEditPrescriptionDialog({
    super.key,
    required this.patientId,
    this.visitId,
    this.existingPrescription,
    this.defaultIndex = 1,
    this.defaultIsBaseline = false,
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
  late DateTime _prescriptionDate;
  late bool _isBaseline;
  late String _potency;
  late String _frequency;
  late String _vehicle;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPrescription;
    _remedyIndex = p?.remedyIndex ?? widget.defaultIndex;
    _prescriptionDate = p?.prescriptionDate ?? DateTime.now();
    _isBaseline = p?.isBaseline ?? widget.defaultIsBaseline;
    _nameController = TextEditingController(text: p?.remedyName ?? '');
    _potency = p?.potency ?? '200CH';
    _doseController = TextEditingController(text: p?.doseCount ?? '');
    _frequency = p?.frequency ?? 'OD (Once daily)';
    _vehicle = p?.vehicle ?? 'Globules / Pellets';
    _durationController = TextEditingController(text: p?.durationDays ?? '');
    _instructionsController = TextEditingController(
      text: p?.instructions ?? '',
    );
    _dietaryController = TextEditingController(
      text: p?.dietaryAdvice ?? '',
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
          prescriptionDate: _prescriptionDate,
          isBaseline: _isBaseline,
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
          prescriptionDate: _prescriptionDate,
          isBaseline: _isBaseline,
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
      title: isEditing ? 'Edit Remedy (Rx #$_remedyIndex)' : 'Prescribe Remedy (Rx #$_remedyIndex)',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Remedy Name with Autocomplete (Prominent top field)
              RemedyAutocompleteField(
                controller: _nameController,
                label: 'Remedy (Latin Binomial) *',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter remedy name' : null,
              ),
              const SizedBox(height: Spacing.md),

              // Date & Potency (2 clean fields)
              Row(
                children: [
                  Expanded(
                    child: DateField(
                      label: 'Prescription Date',
                      value: _prescriptionDate,
                      onChanged: (date) => setState(() => _prescriptionDate = date),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        const standardOptions = [
                          PickerOption(value: 'Q / MT', label: 'Q (Mother Tincture)'),
                          PickerOption(value: '3X', label: '3X'),
                          PickerOption(value: '6X', label: '6X'),
                          PickerOption(value: '12X', label: '12X'),
                          PickerOption(value: '30C', label: '30C'),
                          PickerOption(value: '200CH', label: '200CH'),
                          PickerOption(value: '1M', label: '1M (1000C)'),
                          PickerOption(value: '10M', label: '10M'),
                          PickerOption(value: '50M', label: '50M'),
                          PickerOption(value: 'CM', label: 'CM (100,000C)'),
                          PickerOption(value: '0/1 (LM1)', label: 'LM 0/1'),
                          PickerOption(value: '0/3 (LM3)', label: 'LM 0/3'),
                          PickerOption(value: '0/6 (LM6)', label: 'LM 0/6'),
                          PickerOption(value: '0/12 (LM12)', label: 'LM 0/12'),
                          PickerOption(value: '0/30 (LM30)', label: 'LM 0/30'),
                        ];

                        final isCustom = !standardOptions.any((o) => o.value == _potency);
                        final options = [
                          ...standardOptions,
                          if (isCustom) PickerOption(value: _potency, label: _potency),
                        ];

                        return PickerField<String>(
                          label: 'Potency *',
                          value: _potency,
                          options: options,
                          onChanged: (val) => setState(() => _potency = val),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Dose & Vehicle
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _doseController,
                      label: 'Dose',
                      prefixIcon: Icons.medication_outlined,
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

              // Frequency & Duration
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
                    child: CustomTextField(
                      controller: _durationController,
                      label: 'Duration',
                      prefixIcon: Icons.timelapse_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Timing / Instructions
              CustomTextField(
                controller: _instructionsController,
                label: 'Timing / Instructions',
                prefixIcon: Icons.schedule_outlined,
              ),
              const SizedBox(height: Spacing.md),

              // Dietary Advice & Restrictions
              CustomTextField(
                controller: _dietaryController,
                label: 'Dietary Restrictions / Restrictions Advice',
                prefixIcon: Icons.restaurant_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
    );
  }
}