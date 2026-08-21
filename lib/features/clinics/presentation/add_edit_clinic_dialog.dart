import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
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
  late String _openDays;

  String _colorHex = '#0F5132';

  // Guards against a queued tap re-running _submit before the first write
  // finishes and the dialog closes.
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
    _openDays = widget.clinic?.openDays ?? '1,3,5';
    _colorHex = widget.clinic?.colorHex ?? '#0F5132';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _rentController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.clinic != null;

    return AppFormDialog(
      title: isEditing ? 'Edit Clinic' : 'Add New Clinic',
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
            CustomTextField(
              controller: _rentController,
              label: 'Monthly Fixed Rent (Rs)',
              prefixIcon: Icons.home_work,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || double.tryParse(v) == null ? 'Valid rent' : null,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _feeController,
              label: 'Default Consultation Fee (Rs)',
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || double.tryParse(v) == null ? 'Valid fee' : null,
            ),
            const SizedBox(height: Spacing.md),
            DaySelectorField(
              label: 'Open Days',
              value: _openDays,
              onChanged: (v) => setState(() => _openDays = v),
            ),
          ],
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
    final openDays = _openDays;

    final notifier = ref.read(clinicNotifierProvider.notifier);

    try {
      if (widget.clinic != null) {
        await notifier.updateClinic(
          id: widget.clinic!.id,
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
          id: _uuid.v4(),
          name: name,
          address: address.isEmpty ? null : address,
          phone: phone.isEmpty ? null : phone,
          monthlyRent: rent,
          defaultConsultationFee: fee,
          openDays: openDays,
          colorHex: _colorHex,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save clinic: \$e')),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
