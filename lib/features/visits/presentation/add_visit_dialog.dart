import 'package:flutter/material.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/utils/formatters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/custom_text_field.dart';
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
  String _consultationType = 'clinic';
  String? _outcome;
  DateTime _visitDate = DateTime.now();
  DateTime? _nextFollowUpDate;

  @override
  void initState() {
    super.initState();
    _diseaseController =
        TextEditingController(text: widget.patient.primaryDisease ?? '');
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

    return AlertDialog(
      title: Text('Add Visit: ${widget.patient.name}'),
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
              PickerField<String>(
                label: 'Clinic',
                prefixIcon: Icons.local_hospital,
                value: _selectedClinicId,
                options: clinics
                    .map((c) => PickerOption(
                          value: c.id,
                          label: c.name,
                          subtitle: c.address,
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedClinicId = val),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _diseaseController,
                label: 'Disease / Condition',
                prefixIcon: Icons.medical_services,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _chiefComplaintController,
                label: 'Chief Complaint (Optional)',
                prefixIcon: Icons.notes,
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              PickerField<String>(
                label: 'Outcome (Optional)',
                prefixIcon: Icons.insights_outlined,
                hint: 'Not recorded',
                value: _outcome,
                options: const [
                  // Empty string clears the field: the column is nullable, and
                  // without this a mis-tap could never be undone.
                  PickerOption(value: '', label: 'Not recorded'),
                  PickerOption(value: 'improved', label: 'Improved'),
                  PickerOption(value: 'no_change', label: 'No change'),
                  PickerOption(value: 'worse', label: 'Worse'),
                  PickerOption(value: 'recovered', label: 'Recovered'),
                  PickerOption(value: 'lost_followup', label: 'Lost follow-up'),
                ],
                onChanged: (val) =>
                    setState(() => _outcome = val.isEmpty ? null : val),
              ),
              const SizedBox(height: 12),
              // The column existed in the schema and was already being saved,
              // but nothing ever set it - so no follow-up could be recorded.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_repeat_outlined),
                title: const Text('Next follow-up'),
                subtitle: Text(
                  _nextFollowUpDate == null
                      ? 'Not scheduled'
                      : Formatters.formatDate(_nextFollowUpDate!),
                ),
                trailing: _nextFollowUpDate == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear',
                        onPressed: () =>
                            setState(() => _nextFollowUpDate = null),
                      ),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _nextFollowUpDate ?? now.add(const Duration(days: 30)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 730)),
                  );
                  if (picked != null) {
                    setState(() => _nextFollowUpDate = picked);
                  }
                },
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
          onPressed: _submit,
          child: const Text('Save Visit'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClinicId == null) return;

    await ref.read(visitNotifierProvider.notifier).addVisit(
          patientId: widget.patient.id,
          clinicId: _selectedClinicId!,
          disease: _diseaseController.text.trim(),
          chiefComplaint: _chiefComplaintController.text.trim().isEmpty
              ? null
              : _chiefComplaintController.text.trim(),
          consultationType: _consultationType,
          outcome: _outcome,
          visitDate: _visitDate,
          nextFollowUpDate: _nextFollowUpDate,
        );

    if (mounted) Navigator.of(context).pop();
  }
}
