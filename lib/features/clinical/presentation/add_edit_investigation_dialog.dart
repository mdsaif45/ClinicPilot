import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/picker_field.dart';
import '../models/investigation_templates.dart';
import '../providers/investigation_provider.dart';

class AddEditInvestigationDialog extends ConsumerStatefulWidget {
  final String patientId;
  final String? visitId;
  final Investigation? existingInvestigation;

  const AddEditInvestigationDialog({
    super.key,
    required this.patientId,
    this.visitId,
    this.existingInvestigation,
  });

  @override
  ConsumerState<AddEditInvestigationDialog> createState() => _AddEditInvestigationDialogState();
}

class _AddEditInvestigationDialogState extends ConsumerState<AddEditInvestigationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  late final TextEditingController _unitController;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final TextEditingController _labController;
  late final TextEditingController _notesController;

  late DateTime _testDate;
  late String _category;
  String _computedFlag = 'Normal';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final inv = widget.existingInvestigation;
    _nameController = TextEditingController(text: inv?.testName ?? '');
    _valueController = TextEditingController(
      text: inv?.numericValue != null ? inv!.numericValue.toString() : (inv?.stringValue ?? ''),
    );
    _unitController = TextEditingController(text: inv?.unit ?? 'mg/dL');
    _minController = TextEditingController(
      text: inv?.refRangeMin != null ? inv!.refRangeMin.toString() : '',
    );
    _maxController = TextEditingController(
      text: inv?.refRangeMax != null ? inv!.refRangeMax.toString() : '',
    );
    _labController = TextEditingController(text: inv?.labName ?? '');
    _notesController = TextEditingController(text: inv?.notes ?? '');
    _testDate = inv?.testDate ?? DateTime.now();
    _category = inv?.testCategory ?? 'Blood / Biochemistry';
    _computedFlag = inv?.flag ?? 'Normal';

    _valueController.addListener(_recomputeFlag);
    _minController.addListener(_recomputeFlag);
    _maxController.addListener(_recomputeFlag);
  }

  void _recomputeFlag() {
    final val = double.tryParse(_valueController.text.trim());
    final min = double.tryParse(_minController.text.trim());
    final max = double.tryParse(_maxController.text.trim());
    final flag = computeLabFlag(val, min, max);
    if (flag != _computedFlag) {
      setState(() => _computedFlag = flag);
    }
  }

  void _onTemplateSelected(LabTestTemplate t) {
    AppHaptics.selection();
    setState(() {
      _nameController.text = t.name;
      _category = t.category;
      _unitController.text = t.unit;
      _minController.text = t.refMin.toString();
      _maxController.text = t.refMax.toString();
      _recomputeFlag();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _labController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    final notifier = ref.read(investigationNotifierProvider.notifier);
    final inv = widget.existingInvestigation;

    final numVal = double.tryParse(_valueController.text.trim());
    final strVal = numVal == null ? _valueController.text.trim() : null;
    final minVal = double.tryParse(_minController.text.trim());
    final maxVal = double.tryParse(_maxController.text.trim());

    try {
      if (inv == null) {
        await notifier.addInvestigation(
          patientId: widget.patientId,
          visitId: widget.visitId,
          testDate: _testDate,
          testCategory: _category,
          testName: _nameController.text.trim(),
          numericValue: numVal,
          stringValue: strVal,
          unit: _unitController.text.trim(),
          refRangeMin: minVal,
          refRangeMax: maxVal,
          flag: _computedFlag,
          labName: _labController.text.trim(),
          notes: _notesController.text.trim(),
        );
      } else {
        await notifier.updateInvestigation(
          id: inv.id,
          testDate: _testDate,
          testCategory: _category,
          testName: _nameController.text.trim(),
          numericValue: numVal,
          stringValue: strVal,
          unit: _unitController.text.trim(),
          refRangeMin: minVal,
          refRangeMax: maxVal,
          flag: _computedFlag,
          labName: _labController.text.trim(),
          notes: _notesController.text.trim(),
        );
      }

      AppHaptics.success();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving lab test: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingInvestigation != null;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final flagColor = _computedFlag == 'High'
        ? scheme.error
        : _computedFlag == 'Low'
            ? scheme.tertiary
            : scheme.primary;

    return AppFormDialog(
      title: isEditing ? 'Edit Lab Report' : 'Add Investigation / Lab Test',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(isEditing ? 'Save Changes' : 'Record Test'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template Selector Quick Menu
              if (!isEditing) ...[
                Text(
                  'Quick Presets (Common Diagnostic Panels):',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kCuratedLabTests.length,
                    separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
                    itemBuilder: (_, index) {
                      final t = kCuratedLabTests[index];
                      return ActionChip(
                        label: Text(t.name, style: const TextStyle(fontSize: 12)),
                        onPressed: () => _onTemplateSelected(t),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],

              // Test Name & Category
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Test Parameter Name *',
                  prefixIcon: Icon(Icons.biotech_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter test parameter name' : null,
              ),
              const SizedBox(height: Spacing.md),

              // Category & Date
              Row(
                children: [
                  Expanded(
                    child: PickerField<String>(
                      label: 'Category',
                      value: _category,
                      options: const [
                        PickerOption(value: 'Blood / Biochemistry', label: 'Blood / Biochemistry'),
                        PickerOption(value: 'Diabetes / Glycemia', label: 'Diabetes / Glycemia'),
                        PickerOption(value: 'Renal / Kidney Function', label: 'Renal / Kidney'),
                        PickerOption(value: 'Liver Function Test (LFT)', label: 'Liver (LFT)'),
                        PickerOption(value: 'Lipid Profile', label: 'Lipid Profile'),
                        PickerOption(value: 'Thyroid Panel', label: 'Thyroid Panel'),
                        PickerOption(value: 'Complete Blood Count (CBC)', label: 'CBC / Hemogram'),
                        PickerOption(value: 'Urine / Stool Routine', label: 'Urine / Stool'),
                        PickerOption(value: 'Radiology / Imaging', label: 'Radiology (X-Ray/USG)'),
                        PickerOption(value: 'Vitamins & Minerals', label: 'Vitamins / Minerals'),
                      ],
                      onChanged: (val) => setState(() => _category = val),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        AppHaptics.selection();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _testDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _testDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Test Date',
                          prefixIcon: Icon(Icons.calendar_today, size: 16),
                        ),
                        child: Text(
                          Formatters.formatDate(_testDate),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Measured Value & Unit & Live Flag
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Measured Value *',
                        hintText: 'e.g. 142.5',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter value' : null,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'mg/dL',
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: flagColor.withValues(alpha: 0.12),
                      borderRadius: Radii.smAll,
                      border: Border.all(color: flagColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _computedFlag.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: flagColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Reference Range (Min - Max)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minController,
                      decoration: const InputDecoration(
                        labelText: 'Ref Range Min',
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _maxController,
                      decoration: const InputDecoration(
                        labelText: 'Ref Range Max',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Diagnostic Lab Name & Doctor Notes
              TextFormField(
                controller: _labController,
                decoration: const InputDecoration(
                  labelText: 'Diagnostic Lab / Center Name',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
              ),
              const SizedBox(height: Spacing.md),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Clinical Interpretation / Remarks',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}