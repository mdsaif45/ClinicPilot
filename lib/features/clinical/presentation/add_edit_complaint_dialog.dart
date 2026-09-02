import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/master_disease_service.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/disease_autocomplete_field.dart';
import '../../../core/widgets/image_comparison_gallery.dart';
import '../../../core/widgets/picker_field.dart';
import '../providers/complaint_provider.dart';

class AddEditComplaintDialog extends ConsumerStatefulWidget {
  final String patientId;
  final String? visitId;
  final Complaint? existingComplaint;
  final int defaultIndex;
  final bool defaultIsBaseline;

  const AddEditComplaintDialog({
    super.key,
    required this.patientId,
    this.visitId,
    this.existingComplaint,
    this.defaultIndex = 1,
    this.defaultIsBaseline = false,
  });

  @override
  ConsumerState<AddEditComplaintDialog> createState() =>
      _AddEditComplaintDialogState();
}

class _AddEditComplaintDialogState
    extends ConsumerState<AddEditComplaintDialog> {
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
  late DateTime _complaintDate;
  late bool _isBaseline;
  late String _side;
  late double _severity;
  late String _status;
  late List<String> _beforeImages;
  late List<String> _afterImages;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existingComplaint;
    _complaintIndex = c?.complaintIndex ?? widget.defaultIndex;
    _complaintDate = c?.complaintDate ?? DateTime.now();
    _isBaseline = c?.isBaseline ?? widget.defaultIsBaseline;
    _nameController = TextEditingController(text: c?.complaintName ?? '');
    _locationController = TextEditingController(text: c?.location ?? '');
    _side = c?.side ?? 'Not specified';
    _onsetController = TextEditingController(text: c?.onset ?? '');
    _durationController = TextEditingController(text: c?.duration ?? '');
    _sensationController = TextEditingController(text: c?.sensation ?? '');
    _extensionController = TextEditingController(text: c?.extension ?? '');
    _aggController = TextEditingController(text: c?.aggravatingFactors ?? '');
    _amelController = TextEditingController(text: c?.amelioratingFactors ?? '');
    _concomitantsController = TextEditingController(
      text: c?.concomitants ?? '',
    );
    _causationController = TextEditingController(text: c?.causation ?? '');
    _periodicityController = TextEditingController(text: c?.periodicity ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _severity = (c?.severity ?? 5).toDouble();
    _status = c?.status ?? 'Active';
    _beforeImages = ComplaintNotifier.parseImages(c?.beforeImages);
    _afterImages = ComplaintNotifier.parseImages(c?.afterImages);
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
          visitId: widget.visitId,
          complaintDate: _complaintDate,
          isBaseline: _isBaseline,
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
          beforeImages: _beforeImages,
          afterImages: _afterImages,
          notes: _notesController.text.trim(),
        );
      } else {
        await notifier.updateComplaint(
          id: c.id,
          complaintDate: _complaintDate,
          isBaseline: _isBaseline,
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
          beforeImages: _beforeImages,
          afterImages: _afterImages,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving complaint: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingComplaint != null;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppFormDialog(
      title:
          isEditing
              ? 'Edit Complaint (#$_complaintIndex)'
              : 'Add Clinical Complaint (#$_complaintIndex)',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint / Condition Name (Primary)
            DiseaseAutocompleteField(
              controller: _nameController,
              label: 'Complaint / Condition *',
              validator:
                  (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Please enter complaint'
                          : null,
            ),
            const SizedBox(height: Spacing.md),

            // Date & Clinical Status (2 clean fields)
            Row(
              children: [
                Expanded(
                  child: DateField(
                    label: 'Complaint Date',
                    value: _complaintDate,
                    onChanged: (date) => setState(() => _complaintDate = date),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Clinical Status',
                    value: _status,
                    options: const [
                      PickerOption(value: 'Active', label: 'Active (Ongoing)'),
                      PickerOption(
                        value: 'Improving',
                        label: 'Improving (Under Care)',
                      ),
                      PickerOption(
                        value: 'Resolved',
                        label: 'Resolved (Relieved)',
                      ),
                      PickerOption(
                        value: 'Recurrent',
                        label: 'Recurrent (Periodic)',
                      ),
                    ],
                    onChanged: (val) => setState(() => _status = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Location & Side
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Side',
                    value: _side,
                    options: const [
                      PickerOption(
                        value: 'Not specified',
                        label: 'Not specified',
                      ),
                      PickerOption(value: 'Right', label: 'Right (Rt.)'),
                      PickerOption(value: 'Left', label: 'Left (Lt.)'),
                      PickerOption(
                        value: 'Bilateral',
                        label: 'Bilateral (Both)',
                      ),
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
                  child: CustomTextField(
                    controller: _onsetController,
                    label: 'Onset',
                    prefixIcon: Icons.access_time_outlined,
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

            // Sensation & Extension
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _sensationController,
                    label: 'Sensation / Character',
                    prefixIcon: Icons.touch_app_outlined,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: CustomTextField(
                    controller: _extensionController,
                    label: 'Extension / Radiation',
                    prefixIcon: Icons.alt_route_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Modalities (< Aggravation & > Amelioration)
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _aggController,
                    label: 'Aggravation (<)',
                    prefixIcon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: CustomTextField(
                    controller: _amelController,
                    label: 'Amelioration (>)',
                    prefixIcon: Icons.arrow_downward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Concomitants & Causation
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _concomitantsController,
                    label: 'Concomitants',
                    prefixIcon: Icons.link_outlined,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: CustomTextField(
                    controller: _causationController,
                    label: 'Causation',
                    prefixIcon: Icons.psychology_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Periodicity
            CustomTextField(
              controller: _periodicityController,
              label: 'Periodicity / Timing Modality',
              prefixIcon: Icons.event_repeat_outlined,
            ),
            const SizedBox(height: Spacing.md),

            // Severity (1-10 with badge indicator)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Severity Rating',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _severity >= 8
                                ? scheme.errorContainer
                                : _severity >= 5
                                ? scheme.tertiaryContainer
                                : scheme.primaryContainer,
                        borderRadius: Radii.pillAll,
                      ),
                      child: Text(
                        '${_severity.round()}/10 • ${_severity <= 3 ? 'Mild' : (_severity <= 6 ? 'Moderate' : (_severity <= 9 ? 'Severe' : 'Intolerable'))}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              _severity >= 8
                                  ? scheme.onErrorContainer
                                  : _severity >= 5
                                  ? scheme.onTertiaryContainer
                                  : scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: _severity,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor:
                        _severity >= 8
                            ? scheme.error
                            : _severity >= 5
                            ? scheme.tertiary
                            : scheme.primary,
                    onChanged: (val) => setState(() => _severity = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Before & After Clinical Image Comparison Gallery
            ImageComparisonGallery(
              patientId: widget.patientId,
              beforeImages: _beforeImages,
              afterImages: _afterImages,
              onBeforeImagesChanged:
                  (list) => setState(() => _beforeImages = list),
              onAfterImagesChanged:
                  (list) => setState(() => _afterImages = list),
            ),
            const SizedBox(height: Spacing.md),

            // Notes
            CustomTextField(
              controller: _notesController,
              label: 'Clinical Notes & Observations',
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
