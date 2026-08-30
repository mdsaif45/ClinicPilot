import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/document_attachment_gallery.dart';
import '../../../core/widgets/picker_field.dart';
import '../models/investigation_templates.dart';
import '../providers/investigation_provider.dart';

class AddEditInvestigationDialog extends ConsumerStatefulWidget {
  final String patientId;
  final String? visitId;
  final Investigation? existingInvestigation;
  final bool defaultIsBaseline;

  const AddEditInvestigationDialog({
    super.key,
    required this.patientId,
    this.visitId,
    this.existingInvestigation,
    this.defaultIsBaseline = false,
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
  late bool _isBaseline;
  late String _category;
  late List<String> _reportAttachments;
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
    _isBaseline = inv?.isBaseline ?? widget.defaultIsBaseline;
    _category = inv?.testCategory ?? 'Blood / Biochemistry';
    _computedFlag = inv?.flag ?? 'Normal';
    _reportAttachments = InvestigationNotifier.parseAttachments(inv?.reportAttachments);

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
          isBaseline: _isBaseline,
          testCategory: _category,
          testName: _nameController.text.trim(),
          numericValue: numVal,
          stringValue: strVal,
          unit: _unitController.text.trim(),
          refRangeMin: minVal,
          refRangeMax: maxVal,
          flag: _computedFlag,
          labName: _labController.text.trim(),
          reportAttachments: _reportAttachments,
          notes: _notesController.text.trim(),
        );
      } else {
        await notifier.updateInvestigation(
          id: inv.id,
          testDate: _testDate,
          isBaseline: _isBaseline,
          testCategory: _category,
          testName: _nameController.text.trim(),
          numericValue: numVal,
          stringValue: strVal,
          unit: _unitController.text.trim(),
          refRangeMin: minVal,
          refRangeMax: maxVal,
          flag: _computedFlag,
          labName: _labController.text.trim(),
          reportAttachments: _reportAttachments,
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
          SnackBar(content: Text('Error saving investigation: $e')),
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

              // Test Name
              CustomTextField(
                controller: _nameController,
                label: 'Test Parameter Name *',
                prefixIcon: Icons.biotech_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter test parameter name' : null,
              ),
              const SizedBox(height: Spacing.md),

              // Date & Category (2 clean fields)
              Row(
                children: [
                  Expanded(
                    child: DateField(
                      label: 'Test Date',
                      value: _testDate,
                      onChanged: (date) => setState(() => _testDate = date),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
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
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Diagnostic Lab Name
              CustomTextField(
                controller: _labController,
                label: 'Diagnostic Lab Name',
                prefixIcon: Icons.local_hospital_outlined,
              ),
              const SizedBox(height: Spacing.md),

              // Measured Value & Unit (2 clean fields with integrated live Flag badge)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _valueController,
                      label: 'Measured Value *',
                      prefixIcon: Icons.analytics_outlined,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: Spacing.sm),
                        child: UnconstrainedBox(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
                            decoration: BoxDecoration(
                              color: flagColor.withValues(alpha: 0.12),
                              borderRadius: Radii.smAll,
                              border: Border.all(color: flagColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              _computedFlag.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: flagColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter value' : null,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _unitController,
                      label: 'Unit',
                      prefixIcon: Icons.straighten_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Reference Range (Min - Max)
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _minController,
                      label: 'Ref Range Min',
                      prefixIcon: Icons.arrow_downward_outlined,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _maxController,
                      label: 'Ref Range Max',
                      prefixIcon: Icons.arrow_upward_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Document / Report Attachment Gallery (PDF, Images)
              DocumentAttachmentGallery(
                patientId: widget.patientId,
                attachments: _reportAttachments,
                onAttachmentsChanged: (list) => setState(() => _reportAttachments = list),
              ),
              const SizedBox(height: Spacing.md),

              CustomTextField(
                controller: _notesController,
                label: 'Clinical Interpretation / Remarks',
                prefixIcon: Icons.notes_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
    );
  }
}