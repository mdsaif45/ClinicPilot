import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/picker_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/camp_provider.dart';

class AddEditCampDialog extends ConsumerStatefulWidget {
  final Camp? existingCamp;

  const AddEditCampDialog({super.key, this.existingCamp});

  @override
  ConsumerState<AddEditCampDialog> createState() => _AddEditCampDialogState();
}

class _AddEditCampDialogState extends ConsumerState<AddEditCampDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _costController;
  late final TextEditingController _attendanceController;
  late final TextEditingController _notesController;

  late DateTime _date;
  String? _clinicId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCamp;
    _nameController = TextEditingController(text: c?.name ?? '');
    _locationController = TextEditingController(text: c?.location ?? '');
    _costController = TextEditingController(
      text: c != null && c.cost > 0 ? c.cost.toStringAsFixed(0) : '',
    );
    _attendanceController = TextEditingController(
      text: c != null && c.attendance > 0 ? c.attendance.toString() : '',
    );
    _notesController = TextEditingController(text: c?.notes ?? '');
    _date = c?.date ?? DateTime.now();
    _clinicId = c?.clinicId ?? ref.read(activeClinicProvider)?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _attendanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    AppHaptics.medium();

    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
    final attendance = int.tryParse(_attendanceController.text.trim()) ?? 0;
    final notes = _notesController.text.trim();

    try {
      if (widget.existingCamp != null) {
        await ref.read(campNotifierProvider.notifier).updateCamp(
              id: widget.existingCamp!.id,
              name: name,
              date: _date,
              location: location.isEmpty ? null : location,
              cost: cost,
              attendance: attendance,
              clinicId: _clinicId,
              notes: notes.isEmpty ? null : notes,
            );
      } else {
        await ref.read(campNotifierProvider.notifier).addCamp(
              name: name,
              date: _date,
              location: location.isEmpty ? null : location,
              cost: cost,
              attendance: attendance,
              clinicId: _clinicId,
              notes: notes.isEmpty ? null : notes,
            );
      }

      AppHaptics.success();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save camp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingCamp != null;
    final clinics = ref.watch(clinicsStreamProvider).value ?? const [];

    return AppFormDialog(
      title: isEdit ? 'Edit Health Camp' : 'Log Health Camp',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(isEdit ? 'Save Changes' : 'Create Camp'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Camp Name *',
                hintText: 'e.g. Annual Free Eye & Health Camp',
                prefixIcon: Icon(Icons.campaign_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Camp name is required' : null,
            ),
            const SizedBox(height: Spacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text('Camp Date: ${Formatters.formatDate(_date)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location / Venue',
                hintText: 'e.g. Community Hall, Ward 78',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Cost (₹)',
                      hintText: 'e.g. 2500',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _attendanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Attendance',
                      hintText: 'e.g. 80',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            if (clinics.isNotEmpty) ...[
              PickerField<String?>(
                label: 'Associated Clinic',
                value: _clinicId,
                options: [
                  const PickerOption(value: null, label: 'All / General Practice'),
                  ...clinics.map((c) => PickerOption(value: c.id, label: c.name)),
                ],
                onChanged: (val) => setState(() => _clinicId = val),
              ),
              const SizedBox(height: Spacing.md),
            ],
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'e.g. Medicines distributed, volunteer partners',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
