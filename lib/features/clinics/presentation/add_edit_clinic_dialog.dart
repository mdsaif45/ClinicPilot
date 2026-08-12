import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/custom_text_field.dart';
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
  late TextEditingController _openDaysController;

  String _colorHex = '#0F5132';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clinic?.name ?? '');
    _addressController =
        TextEditingController(text: widget.clinic?.address ?? '');
    _phoneController = TextEditingController(text: widget.clinic?.phone ?? '');
    _rentController = TextEditingController(
        text: (widget.clinic?.monthlyRent ?? 3000.0).toStringAsFixed(0));
    _feeController = TextEditingController(
        text: (widget.clinic?.defaultConsultationFee ?? 300.0)
            .toStringAsFixed(0));
    _openDaysController =
        TextEditingController(text: widget.clinic?.openDays ?? '1,3,5');
    _colorHex = widget.clinic?.colorHex ?? '#0F5132';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _rentController.dispose();
    _feeController.dispose();
    _openDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.clinic != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Clinic' : 'Add New Clinic'),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Clinic Name',
                prefixIcon: Icons.local_hospital,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                label: 'Address / Location',
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _rentController,
                label: 'Monthly Fixed Rent (Rs)',
                prefixIcon: Icons.home_work,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Valid rent' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _feeController,
                label: 'Default Consultation Fee (Rs)',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Valid fee' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _openDaysController,
                label: 'Open Days (e.g. 1,3,5 for Mon,Wed,Fri)',
                prefixIcon: Icons.event,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
          child: Text(isEditing ? 'Save Changes' : 'Add Clinic'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final rent = double.parse(_rentController.text.trim());
    final fee = double.parse(_feeController.text.trim());
    final openDays = _openDaysController.text.trim();

    final notifier = ref.read(clinicNotifierProvider.notifier);

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

    if (mounted) Navigator.of(context).pop();
  }
}
