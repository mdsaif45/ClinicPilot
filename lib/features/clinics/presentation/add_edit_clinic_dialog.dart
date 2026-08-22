import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/day_selector_field.dart';
import '../providers/clinic_provider.dart';

const _uuid = Uuid();

class AddEditClinicDialog extends ConsumerStatefulWidget {
  final Clinic? clinic;

  const AddEditClinicDialog({super.key, this.clinic});

  @override
  ConsumerState<AddEditClinicDialog> createState() =>
      _AddEditClinicDialogState();
}

class _AddEditClinicDialogState extends ConsumerState<AddEditClinicDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _rentController;
  late TextEditingController _feeController;
  late TextEditingController _revGoalController;
  late TextEditingController _patGoalController;
  late String _openDays;

  String _colorHex = '#0F5132';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clinic?.name ?? '');
    _addressController =
        TextEditingController(text: widget.clinic?.address ?? '');
    _phoneController = TextEditingController(text: widget.clinic?.phone ?? '');
    _rentController = TextEditingController(
      text: widget.clinic != null
          ? widget.clinic!.monthlyRent.toStringAsFixed(0)
          : '0',
    );
    _feeController = TextEditingController(
      text: widget.clinic != null
          ? widget.clinic!.defaultConsultationFee.toStringAsFixed(0)
          : '300',
    );
    _revGoalController = TextEditingController(text: '50000');
    _patGoalController = TextEditingController(text: '15');
    _openDays = widget.clinic?.openDays ?? '1,3,5';
    _colorHex = widget.clinic?.colorHex ?? '#0F5132';

    if (widget.clinic != null) {
      _loadClinicGoals(widget.clinic!.id);
    }
  }

  Future<void> _loadClinicGoals(String clinicId) async {
    final db = ref.read(databaseProvider);
    final rev = await (db.select(db.settings)
          ..where((tbl) => tbl.key.equals('monthly_revenue_goal_$clinicId')))
        .getSingleOrNull();
    if (rev != null && mounted) _revGoalController.text = rev.value;

    final pat = await (db.select(db.settings)
          ..where((tbl) => tbl.key.equals('monthly_new_patient_goal_$clinicId')))
        .getSingleOrNull();
    if (pat != null && mounted) _patGoalController.text = pat.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _rentController.dispose();
    _feeController.dispose();
    _revGoalController.dispose();
    _patGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.clinic != null;
    final theme = Theme.of(context);

    return AppFormDialog(
      title: isEditing ? 'Edit Clinic & Targets' : 'Add New Clinic',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Save Changes' : 'Add Clinic'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Clinic Name',
                prefixIcon: Icons.local_hospital,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: Spacing.md),
              CustomTextField(
                controller: _addressController,
                label: 'Address / Location',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: Spacing.md),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: Spacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _rentController,
                      label: 'Monthly Rent (₹)',
                      prefixIcon: Icons.home_work_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || double.tryParse(v) == null ? 'Valid rent' : null,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _feeController,
                      label: 'Default Fee (₹)',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || double.tryParse(v) == null ? 'Valid fee' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              DaySelectorField(
                label: 'Open Days',
                value: _openDays,
                onChanged: (v) => setState(() => _openDays = v),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'CLINIC MONTHLY TARGETS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _revGoalController,
                      label: 'Revenue Goal (₹)',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || double.tryParse(v) == null ? 'Valid target' : null,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: CustomTextField(
                      controller: _patGoalController,
                      label: 'New Patients Goal',
                      prefixIcon: Icons.person_add_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || int.tryParse(v) == null ? 'Valid target' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final rent = double.parse(_rentController.text.trim());
    final fee = double.parse(_feeController.text.trim());
    final revGoal = _revGoalController.text.trim();
    final patGoal = _patGoalController.text.trim();
    final openDays = _openDays;

    final notifier = ref.read(clinicNotifierProvider.notifier);
    final db = ref.read(databaseProvider);
    final String clinicId = widget.clinic?.id ?? _uuid.v4();

    try {
      if (widget.clinic != null) {
        await notifier.updateClinic(
          id: clinicId,
          name: name,
          address: address.isEmpty ? null : address,
          phone: phone.isEmpty ? null : phone,
          monthlyRent: rent,
          defaultConsultationFee: fee,
          openDays: openDays,
          colorHex: _colorHex,
        );
      } else {
        await notifier.addClinic(
          id: clinicId,
          name: name,
          address: address.isEmpty ? null : address,
          phone: phone.isEmpty ? null : phone,
          monthlyRent: rent,
          defaultConsultationFee: fee,
          openDays: openDays,
          colorHex: _colorHex,
        );
      }

      // Save clinic-level target goals
      await db.into(db.settings).insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: 'monthly_revenue_goal_$clinicId',
              value: revGoal,
              updatedAt: drift.Value(DateTime.now()),
            ),
          );

      await db.into(db.settings).insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: 'monthly_new_patient_goal_$clinicId',
              value: patGoal,
              updatedAt: drift.Value(DateTime.now()),
            ),
          );

      final activeId = ref.read(activeClinicIdProvider);
      if (activeId == null || activeId == clinicId) {
        await db.into(db.settings).insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: 'monthly_revenue_goal',
                value: revGoal,
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
        await db.into(db.settings).insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: 'monthly_new_patient_goal',
                value: patGoal,
                updatedAt: drift.Value(DateTime.now()),
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save clinic: $e')),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
