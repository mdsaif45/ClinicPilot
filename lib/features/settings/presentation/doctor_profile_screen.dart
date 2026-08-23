import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/custom_text_field.dart';
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
          // 1. Hero Avatar & Identity Card
          AppCard(
            margin: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xs,
            ),
            padding: const EdgeInsets.all(Spacing.xl),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      avatarLetter,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (profile.qualification.isNotEmpty) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      profile.qualification,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (profile.regNumber.isNotEmpty) ...[
                    const SizedBox(height: Spacing.sm),
                    CustomBadge(
                      label: 'Reg: ${profile.regNumber}',
                      color: scheme.secondary,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 2. Contact Information
          SettingsGroup(
            title: 'Contact Information',
            children: [
              AppListTile(
                icon: Icons.email_outlined,
                title: 'Email Address',
                subtitle: profile.email.isNotEmpty ? profile.email : 'Not set',
                onTap: () => _openEditDialog(context, profile),
              ),
              AppListTile(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                subtitle: profile.phone.isNotEmpty ? profile.phone : 'Not set',
                onTap: () => _openEditDialog(context, profile),
              ),
            ],
          ),

          // 3. Credentials & Practice Info
          SettingsGroup(
            title: 'Credentials & Practice',
            children: [
              AppListTile(
                icon: Icons.school_outlined,
                title: 'Qualifications / Degrees',
                subtitle: profile.qualification.isNotEmpty
                    ? profile.qualification
                    : 'Not set',
                onTap: () => _openEditDialog(context, profile),
              ),
              AppListTile(
                icon: Icons.badge_outlined,
                title: 'Medical Registration No.',
                subtitle: profile.regNumber.isNotEmpty
                    ? profile.regNumber
                    : 'Not set',
                onTap: () => _openEditDialog(context, profile),
              ),
              AppListTile(
                icon: Icons.local_hospital_outlined,
                title: 'Clinics Managed',
                subtitle: '${clinics.length} ${clinics.length == 1 ? 'Clinic' : 'Clinics'}',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/clinics'),
              ),
            ],
          ),

          // 4. Data & Cloud Sync Status
          SettingsGroup(
            title: 'Data & Sync Status',
            children: [
              const AppListTile(
                icon: Icons.cloud_off_outlined,
                title: 'Offline Safe Storage',
                subtitle: 'All records stored 100% locally and privately on this device',
              ),
              const AppListTile(
                icon: Icons.sync_outlined,
                title: 'Cloud Sync & Multi-Device',
                subtitle: 'Will be available in future releases',
              ),
            ],
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
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _qualificationController;
  late TextEditingController _regNumberController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initialFirst = widget.profile.firstName.isNotEmpty
        ? widget.profile.firstName
        : (widget.profile.name.isNotEmpty ? widget.profile.name : 'Dr. ');
    _firstNameController = TextEditingController(text: initialFirst);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _qualificationController = TextEditingController(text: widget.profile.qualification);
    _regNumberController = TextEditingController(text: widget.profile.regNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    label: 'First Name *',
                    prefixIcon: Icons.person_outline,
                    validator: (v) {
                      final fn = v?.trim() ?? '';
                      final ln = _lastNameController.text.trim();
                      if (fn.isEmpty && ln.isEmpty) return 'Required';
                      if ((fn == 'Dr.' || fn == 'Dr') && ln.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _qualificationController,
              label: 'Qualifications / Degrees',
              prefixIcon: Icons.school_outlined,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _regNumberController,
              label: 'Medical Registration No.',
              prefixIcon: Icons.badge_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
