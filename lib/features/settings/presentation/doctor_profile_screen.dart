import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/info_row.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/doctor_profile_provider.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  void _openEditDialog(BuildContext context, DoctorProfile profile) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => EditDoctorProfileDialog(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(doctorProfileStreamProvider).value ?? const DoctorProfile();
    final clinics = ref.watch(clinicsStreamProvider).value ?? [];

    final displayName = profile.name.isNotEmpty ? profile.name : 'Doctor Profile';
    final initial = profile.name.isNotEmpty
        ? profile.name.replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '').trim()
        : 'D';
    final avatarLetter = initial.isNotEmpty ? initial[0].toUpperCase() : 'D';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => _openEditDialog(context, profile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          // 1. Doctor Avatar & Name Header Card
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    avatarLetter,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (profile.qualification.isNotEmpty) ...[
                        const SizedBox(height: Spacing.xs),
                        Text(
                          profile.qualification,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (profile.regNumber.isNotEmpty) ...[
                        const SizedBox(height: Spacing.xs),
                        CustomBadge(
                          label: 'Reg: ${profile.regNumber}',
                          color: scheme.secondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // 2. Contact Information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text(
              'CONTACT INFORMATION',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: profile.email.isNotEmpty ? profile.email : 'Not set',
                ),
                const Divider(height: 1),
                InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: profile.phone.isNotEmpty ? profile.phone : 'Not set',
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // 3. Credentials & Practice Information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text(
              'CREDENTIALS & PRACTICE',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Qualifications',
                  value: profile.qualification.isNotEmpty ? profile.qualification : 'Not set',
                ),
                const Divider(height: 1),
                InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Registration No.',
                  value: profile.regNumber.isNotEmpty ? profile.regNumber : 'Not set',
                ),
                const Divider(height: 1),
                InfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Clinics Managed',
                  value: '${clinics.length} ${clinics.length == 1 ? 'Clinic' : 'Clinics'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // 4. Cloud Sync & Storage Foundation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text(
              'DATA & SYNC STATUS',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          AppCard(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: Radii.mdAll,
                  ),
                  child: Icon(Icons.cloud_off_outlined, color: scheme.onSurfaceVariant, size: 22),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Safe Storage',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All clinical cases, patients & financials remain 100% private and stored locally on this device. Cloud sync and backup will be available in future releases.',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // 5. Edit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: AppButton.primary(
              label: 'Edit Doctor Profile',
              icon: Icons.edit_outlined,
              fullWidth: true,
              onPressed: () => _openEditDialog(context, profile),
            ),
          ),
        ],
      ),
    );
  }
}

class EditDoctorProfileDialog extends ConsumerStatefulWidget {
  final DoctorProfile profile;

  const EditDoctorProfileDialog({super.key, required this.profile});

  @override
  ConsumerState<EditDoctorProfileDialog> createState() => _EditDoctorProfileDialogState();
}

class _EditDoctorProfileDialogState extends ConsumerState<EditDoctorProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _qualificationController;
  late TextEditingController _regNumberController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _qualificationController = TextEditingController(text: widget.profile.qualification);
    _regNumberController = TextEditingController(text: widget.profile.regNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await ref.read(doctorProfileNotifierProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            qualification: _qualificationController.text.trim(),
            regNumber: _regNumberController.text.trim(),
          );

      if (mounted) {
        AppHaptics.success();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppHaptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Edit Doctor Profile',
      actions: [
        AppButton.text(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: 'Save Profile',
          loading: _saving,
          onPressed: _saving ? null : _submit,
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
              label: 'Doctor Full Name *',
              hint: 'e.g. Dr. Md. Saifuddin',
              prefixIcon: Icons.person_outline,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'e.g. doctor@gmail.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'e.g. 9830012345',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _qualificationController,
              label: 'Qualifications / Degrees',
              hint: 'e.g. BHMS, MD (Hom.)',
              prefixIcon: Icons.school_outlined,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _regNumberController,
              label: 'Medical Registration No.',
              hint: 'e.g. WBMC-12345',
              prefixIcon: Icons.badge_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
