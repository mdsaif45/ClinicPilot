import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/master_disease_service.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/disease_autocomplete_field.dart';
import '../../../core/widgets/picker_field.dart';
import '../providers/complaint_provider.dart';

class AddEditComplaintDialog extends ConsumerStatefulWidget {
  final String patientId;
  final Complaint? existingComplaint;
  final int defaultIndex;

  const AddEditComplaintDialog({
    super.key,
    required this.patientId,
    this.existingComplaint,
    this.defaultIndex = 1,
  });

  @override
  ConsumerState<AddEditComplaintDialog> createState() => _AddEditComplaintDialogState();
}

class _AddEditComplaintDialogState extends ConsumerState<AddEditComplaintDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _onsetController;
  late final TextEditingController _durationController;
  late final TextEditingController _sensationController;
  late final TextEditingController _extensionController;
  late final TextEditingController _aggController;
  late final TextEditingController _amelController;
  late final TextEditingController _concomitantsController;
  late final TextEditingController _causationController;
  late final TextEditingController _periodicityController;
  late final TextEditingController _notesController;

  late int _complaintIndex;
  late String _side;
  late double _severity;
  late String _status;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existingComplaint;
    _complaintIndex = c?.complaintIndex ?? widget.defaultIndex;
    _nameController = TextEditingController(text: c?.complaintName ?? '');
    _locationController = TextEditingController(text: c?.location ?? '');
    _side = c?.side ?? 'Not specified';
    _onsetController = TextEditingController(text: c?.onset ?? '');
    _durationController = TextEditingController(text: c?.duration ?? '');
    _sensationController = TextEditingController(text: c?.sensation ?? '');
    _extensionController = TextEditingController(text: c?.extension ?? '');
    _aggController = TextEditingController(text: c?.aggravatingFactors ?? '');
    _amelController = TextEditingController(text: c?.amelioratingFactors ?? '');
    _concomitantsController = TextEditingController(text: c?.concomitants ?? '');
    _causationController = TextEditingController(text: c?.causation ?? '');
    _periodicityController = TextEditingController(text: c?.periodicity ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _severity = (c?.severity ?? 5).toDouble();
    _status = c?.status ?? 'Active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _onsetController.dispose();
    _durationController.dispose();
    _sensationController.dispose();
    _extensionController.dispose();
    _aggController.dispose();
    _amelController.dispose();
    _concomitantsController.dispose();
    _causationController.dispose();
    _periodicityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    final notifier = ref.read(complaintNotifierProvider.notifier);
    final c = widget.existingComplaint;

    try {
      if (c == null) {
        await notifier.addComplaint(
          patientId: widget.patientId,
          complaintIndex: _complaintIndex,
          complaintName: _nameController.text.trim(),
          location: _locationController.text.trim(),
          side: _side,
          onset: _onsetController.text.trim(),
          duration: _durationController.text.trim(),
          sensation: _sensationController.text.trim(),
          extension: _extensionController.text.trim(),
          aggravatingFactors: _aggController.text.trim(),
          amelioratingFactors: _amelController.text.trim(),
          concomitants: _concomitantsController.text.trim(),
          causation: _causationController.text.trim(),
          periodicity: _periodicityController.text.trim(),
          severity: _severity.round(),
          status: _status,
          notes: _notesController.text.trim(),
        );
      } else {
        await notifier.updateComplaint(
          id: c.id,
          complaintIndex: _complaintIndex,
          complaintName: _nameController.text.trim(),
          location: _locationController.text.trim(),
          side: _side,
          onset: _onsetController.text.trim(),
          duration: _durationController.text.trim(),
          sensation: _sensationController.text.trim(),
          extension: _extensionController.text.trim(),
          aggravatingFactors: _aggController.text.trim(),
          amelioratingFactors: _amelController.text.trim(),
          concomitants: _concomitantsController.text.trim(),
          causation: _causationController.text.trim(),
          periodicity: _periodicityController.text.trim(),
          severity: _severity.round(),
          status: _status,
          notes: _notesController.text.trim(),
        );
      }

      AppHaptics.success();

      final cName = _nameController.text.trim();
      if (cName.isNotEmpty) {
        ref.read(masterDiseaseServiceProvider).recordDisease(cName);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving complaint: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingComplaint != null;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppFormDialog(
      title: isEditing ? 'Edit Complaint' : 'Add Clinical Complaint',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(isEditing ? 'Save Changes' : 'Add Complaint'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Complaint Name with Autocomplete & Order
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 105,
                    child: DropdownButtonFormField<int>(
                      value: _complaintIndex,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Order',
                        contentPadding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.sm),
                      ),
                      items: List.generate(
                        10,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('#${i + 1}'),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _complaintIndex = val);
                      },
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: DiseaseAutocompleteField(
                      controller: _nameController,
                      label: 'Complaint / Condition *',
                                            validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Please enter complaint' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Location & Side
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                                              ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: PickerField<String>(
                      label: 'Side',
                      value: _side,
                      options: const [
                        PickerOption(value: 'Not specified', label: 'Not specified'),
                        PickerOption(value: 'Right', label: 'Right (Rt.)'),
                        PickerOption(value: 'Left', label: 'Left (Lt.)'),
                        PickerOption(value: 'Bilateral', label: 'Bilateral (Both)'),
                        PickerOption(value: 'Central', label: 'Central'),
                      ],
                      onChanged: (val) => setState(() => _side = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Onset & Duration
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _onsetController,
                      decoration: const InputDecoration(
                        labelText: 'Onset',
                                              ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Sensation & Extension
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sensationController,
                      decoration: const InputDecoration(
                        labelText: 'Sensation / Character',
                                              ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _extensionController,
                      decoration: const InputDecoration(
                        labelText: 'Extension / Radiation',
                                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Modalities (< Aggravation & > Amelioration)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _aggController,
                      decoration: const InputDecoration(
                        labelText: 'Aggravation (<)',
                                                prefixIcon: Icon(Icons.arrow_upward, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _amelController,
                      decoration: const InputDecoration(
                        labelText: 'Amelioration (>)',
                                                prefixIcon: Icon(Icons.arrow_downward, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Concomitants & Causation
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _concomitantsController,
                      decoration: const InputDecoration(
                        labelText: 'Concomitants',
                                              ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _causationController,
                      decoration: const InputDecoration(
                        labelText: 'Causation',
                                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Periodicity & Status
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _periodicityController,
                      decoration: const InputDecoration(
                        labelText: 'Periodicity',
                                              ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: PickerField<String>(
                      label: 'Clinical Status',
                      value: _status,
                      options: const [
                        PickerOption(value: 'Active', label: 'Active (Ongoing)'),
                        PickerOption(value: 'Improving', label: 'Improving (Under Care)'),
                        PickerOption(value: 'Resolved', label: 'Resolved (Relieved)'),
                        PickerOption(value: 'Recurrent', label: 'Recurrent (Periodic)'),
                      ],
                      onChanged: (val) => setState(() => _status = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),

              // Severity (1-10 Slider)
              Text(
                'Severity: ${_severity.round()}/10',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _severity >= 8
                      ? scheme.error
                      : _severity >= 5
                          ? scheme.tertiary
                          : scheme.primary,
                ),
              ),
              Slider(
                value: _severity,
                min: 1,
                max: 10,
                divisions: 9,
                label: '${_severity.round()}/10',
                activeColor: _severity >= 8
                    ? scheme.error
                    : _severity >= 5
                        ? scheme.tertiary
                        : scheme.primary,
                onChanged: (val) => setState(() => _severity = val),
              ),
              const SizedBox(height: Spacing.xs),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Clinical Notes',
                  hintText: 'Additional details or observations...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}