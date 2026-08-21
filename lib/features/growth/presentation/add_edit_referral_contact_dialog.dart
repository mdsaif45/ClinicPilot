import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/picker_field.dart';
import '../providers/referral_crm_provider.dart';

class AddEditReferralContactDialog extends ConsumerStatefulWidget {
  final ReferralContact? existingContact;

  const AddEditReferralContactDialog({
    super.key,
    this.existingContact,
  });

  @override
  ConsumerState<AddEditReferralContactDialog> createState() =>
      _AddEditReferralContactDialogState();
}

class _AddEditReferralContactDialogState
    extends ConsumerState<AddEditReferralContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _personController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  late String _category;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existingContact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _personController = TextEditingController(text: c?.contactPerson ?? '');
    _category = c?.category ?? 'Pharmacy';
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    final notifier = ref.read(referralCrmNotifierProvider.notifier);
    final c = widget.existingContact;

    try {
      if (c == null) {
        await notifier.addContact(
          name: _nameController.text.trim(),
          contactPerson: _personController.text.trim(),
          category: _category,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
        );
      } else {
        await notifier.updateContact(
          id: c.id,
          name: _nameController.text.trim(),
          contactPerson: _personController.text.trim(),
          category: _category,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
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
          SnackBar(content: Text('Error saving referral partner: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingContact != null;

    return AppFormDialog(
      title: isEditing ? 'Edit Referral Partner' : 'Add Referral Partner',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(isEditing ? 'Save Changes' : 'Add Partner'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Partner / Organization Name *',
                  hintText: 'e.g. Apollo Pharmacy, Thyrocare Lab',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter organization name' : null,
              ),
              const SizedBox(height: Spacing.md),

              PickerField<String>(
                label: 'Partner Category',
                value: _category,
                options: const [
                  PickerOption(value: 'Pharmacy', label: 'Pharmacy / Medical Store'),
                  PickerOption(value: 'Diagnostic Lab', label: 'Diagnostic Lab / Pathology'),
                  PickerOption(value: 'Physiotherapy', label: 'Physiotherapy Center'),
                  PickerOption(value: 'Dentist', label: 'Dental Clinic'),
                  PickerOption(value: 'Gym / Fitness', label: 'Gym / Yoga / Fitness Center'),
                  PickerOption(value: 'Specialist Doctor', label: 'Specialist / GP Doctor'),
                  PickerOption(value: 'Other', label: 'Other Referral Source'),
                ],
                onChanged: (val) => setState(() => _category = val),
              ),
              const SizedBox(height: Spacing.md),

              TextFormField(
                controller: _personController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person / Manager',
                  hintText: 'e.g. Mr. Sharma / Chief Pharmacist',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: Spacing.md),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. 9876543210',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: Spacing.md),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address / Locality',
                  hintText: 'e.g. Main Market, Near City Hospital',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: Spacing.md),

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Partnership Notes',
                  hintText: 'e.g. Visited on Monday, agreed to keep clinic pamphlets at counter.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}