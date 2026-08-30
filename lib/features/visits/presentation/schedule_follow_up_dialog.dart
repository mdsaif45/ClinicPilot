import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../providers/visit_provider.dart';

class ScheduleFollowUpDialog extends ConsumerStatefulWidget {
  final Patient patient;
  final String? defaultDisease;
  final String? defaultClinicId;

  const ScheduleFollowUpDialog({
    super.key,
    required this.patient,
    this.defaultDisease,
    this.defaultClinicId,
  });

  @override
  ConsumerState<ScheduleFollowUpDialog> createState() => _ScheduleFollowUpDialogState();
}

class _ScheduleFollowUpDialogState extends ConsumerState<ScheduleFollowUpDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _followUpDate;
  final _noteController = TextEditingController();
  int _selectedPresetDays = 15;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _followUpDate = DateTime.now().add(const Duration(days: 15));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _applyPreset(int days) {
    AppHaptics.selection();
    setState(() {
      _selectedPresetDays = days;
      _followUpDate = DateTime.now().add(Duration(days: days));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    try {
      await ref.read(visitNotifierProvider.notifier).scheduleFollowUp(
            patientId: widget.patient.id,
            nextFollowUpDate: _followUpDate,
            reason: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
            disease: widget.defaultDisease ?? widget.patient.primaryDisease,
            clinicId: widget.defaultClinicId ?? widget.patient.primaryClinicId,
          );

      AppHaptics.success();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Follow-up scheduled for ${Formatters.formatDate(_followUpDate)}',
            ),
          ),
        );
      }
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scheduling follow-up: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppFormDialog(
      title: 'Schedule Follow-up: ${widget.patient.name}',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Schedule'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Duration Preset Chips
            Text(
              'Quick Follow-up Interval',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                _buildPresetChip(7, '+7 Days (1 Wk)'),
                _buildPresetChip(15, '+15 Days (2 Wks)'),
                _buildPresetChip(30, '+1 Month (4 Wks)'),
                _buildPresetChip(60, '+2 Months (8 Wks)'),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Date Picker Field
            DateField(
              label: 'Target Follow-up Date *',
              value: _followUpDate,
              onChanged: (date) {
                setState(() {
                  _followUpDate = date;
                  _selectedPresetDays = 0; // custom date
                });
              },
            ),
            const SizedBox(height: Spacing.md),

            // Clinical Checkpoint / Objective Notes
            CustomTextField(
              controller: _noteController,
              label: 'Review Objective / Notes',
              prefixIcon: Icons.edit_note_outlined,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(int days, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isSelected = _selectedPresetDays == days;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _applyPreset(days),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
      ),
    );
  }
}
