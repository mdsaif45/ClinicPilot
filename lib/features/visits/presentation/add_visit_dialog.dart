import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/master_disease_service.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/disease_autocomplete_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picker_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/visit_provider.dart';

class AddVisitDialog extends ConsumerStatefulWidget {
  final Patient patient;

  const AddVisitDialog({super.key, required this.patient});

  @override
  ConsumerState<AddVisitDialog> createState() => _AddVisitDialogState();
}

class _AddVisitDialogState extends ConsumerState<AddVisitDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _diseaseController;
  final _chiefComplaintController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedClinicId;
  String? _clinicError;
  String _consultationType = 'clinic';
  String? _outcome;
  DateTime _visitDate = DateTime.now();

  // Guards against a queued tap re-running _submit before the first write
  // finishes and the dialog closes.
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _diseaseController = TextEditingController(
      text: widget.patient.primaryDisease ?? '',
    );
    _selectedClinicId = ref.read(activeClinicIdProvider);
  }

  @override
  void dispose() {
    _diseaseController.dispose();
    _chiefComplaintController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final clinics = clinicsAsync.value ?? [];

    if (clinicsAsync.hasValue && clinics.isEmpty) {
      return AlertDialog(
        title: const Text('Add Visit'),
        content: EmptyState(
          icon: Icons.local_hospital_outlined,
          title: 'No clinic yet',
          message: 'Add a clinic before recording a visit.',
          actionLabel: 'Add clinic',
          onAction: () {
            Navigator.of(context).pop();
            context.push('/clinics');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AppFormDialog(
      title: 'Add Visit: ${widget.patient.name}',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child:
              _submitting
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Save Visit'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PickerField<String>(
              label: 'Clinic',
              prefixIcon: Icons.local_hospital,
              value: _selectedClinicId,
              errorText: _clinicError,
              options:
                  clinics
                      .map(
                        (c) => PickerOption(
                          value: c.id,
                          label: c.name,
                          subtitle: c.address,
                        ),
                      )
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    _selectedClinicId = val;
                    _clinicError = null;
                  }),
            ),
            const SizedBox(height: Spacing.md),
            DateField(
              label: 'Visit Date',
              value: _visitDate,
              onChanged: (d) => setState(() => _visitDate = d),
            ),
            const SizedBox(height: Spacing.md),
            DiseaseAutocompleteField(
              controller: _diseaseController,
              label: 'Disease / Condition',
              validator:
                  (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _chiefComplaintController,
              label: 'Chief Complaint (Optional)',
              prefixIcon: Icons.notes,
            ),
            const SizedBox(height: Spacing.md),
            PickerField<String>(
              label: 'Consultation Type',
              prefixIcon: Icons.event_note_outlined,
              value: _consultationType,
              options: const [
                PickerOption(
                  value: 'clinic',
                  label: 'Clinic',
                  subtitle: 'Seen in person',
                  icon: Icons.local_hospital_outlined,
                ),
                PickerOption(
                  value: 'online',
                  label: 'Online',
                  subtitle: 'Video or phone consultation',
                  icon: Icons.videocam_outlined,
                ),
                PickerOption(
                  value: 'camp',
                  label: 'Camp',
                  subtitle: 'Seen at a medical camp',
                  icon: Icons.festival_outlined,
                ),
              ],
              onChanged: (val) => setState(() => _consultationType = val),
            ),
            const SizedBox(height: Spacing.md),
            PickerField<String>(
              label: 'Outcome (Optional)',
              prefixIcon: Icons.insights_outlined,
              hint: 'Not recorded',
              value: _outcome,
              options: const [
                PickerOption(value: '', label: 'Not recorded'),
                PickerOption(value: 'improved', label: 'Improved'),
                PickerOption(value: 'no_change', label: 'No change'),
                PickerOption(value: 'worse', label: 'Worse'),
                PickerOption(value: 'recovered', label: 'Recovered'),
                PickerOption(value: 'lost_followup', label: 'Lost follow-up'),
              ],
              onChanged:
                  (val) => setState(() => _outcome = val.isEmpty ? null : val),
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
      _clinicError = _selectedClinicId == null ? 'Select a clinic' : null;
    });

    if (!formOk || _selectedClinicId == null) return;

    setState(() => _submitting = true);

    try {
      final dName = Formatters.toTitleCase(_diseaseController.text);
      if (dName.isNotEmpty) {
        ref.read(masterDiseaseServiceProvider).recordDisease(dName);
      }
      await ref
          .read(visitNotifierProvider.notifier)
          .addVisit(
            patientId: widget.patient.id,
            clinicId: _selectedClinicId!,
            disease: Formatters.toTitleCase(_diseaseController.text),

            chiefComplaint:
                _chiefComplaintController.text.trim().isEmpty
                    ? null
                    : _chiefComplaintController.text.trim(),
            consultationType: _consultationType,
            outcome: _outcome,
            visitDate: _visitDate,
            nextFollowUpDate: null,
          );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save visit: $e')));
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
