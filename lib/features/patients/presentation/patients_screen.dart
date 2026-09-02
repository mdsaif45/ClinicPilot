import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/patient_provider.dart';
import 'add_patient_dialog.dart';
import 'edit_patient_dialog.dart';
import 'patient_profile_screen.dart';

/// Patient directory.
///
/// Deliberately one compact row per patient rather than a card. The doctor
/// scans this list to find somebody, so the job is fitting as many legible
/// names on screen as possible; anything beyond identifying the right person
/// belongs on the profile, one tap away.
class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsStreamProvider);
    final query = ref.watch(patientSearchQueryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => showDialog(
              context: context,
              builder: (_) => const AddPatientDialog(),
            ),
        icon: const Icon(Icons.person_add),
        label: const Text('New Patient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.lg,
              Spacing.lg,
              Spacing.sm,
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search name, code, serial or phone',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged:
                  (val) =>
                      ref.read(patientSearchQueryProvider.notifier).state = val,
            ),
          ),
          Expanded(
            child: patientsAsync.when(
              loading:
                  () => ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: 6,
                    separatorBuilder:
                        (_, __) => const Divider(height: 1, indent: Spacing.lg),
                    itemBuilder: (_, __) => const ListTileShimmer(),
                  ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (patients) {
                if (patients.isEmpty) {
                  return query.isEmpty
                      ? EmptyState.patients(
                        onAction:
                            () => showDialog(
                              context: context,
                              builder: (_) => const AddPatientDialog(),
                            ),
                      )
                      : EmptyState.search(
                        title: 'No match for "$query"',
                        message: 'Try a name, patient code or phone number.',
                      );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: patients.length,
                  separatorBuilder:
                      (_, __) => const Divider(height: 1, indent: Spacing.lg),
                  itemBuilder:
                      (context, index) => _PatientRow(patient: patients[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientRow extends ConsumerWidget {
  final Patient patient;

  const _PatientRow({required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // "34 F" reads faster than two labelled fields and costs a fraction of
    // the width.
    final gender =
        patient.gender.isNotEmpty ? patient.gender[0].toUpperCase() : '';

    return ListTile(
      onTap: () {
        AppHaptics.light();
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => PatientProfileScreen(patient: patient),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      leading: Hero(
        tag: 'patient-avatar-${patient.id}',
        child: CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primary.withValues(alpha: 0.15),
          child: Text(
            patient.name.trim().isNotEmpty
                ? patient.name.trim()[0].toUpperCase()
                : '?',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              patient.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text('${patient.age} $gender', style: theme.textTheme.labelMedium),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: Spacing.xs),
        child: Row(
          children: [
            if (patient.phone.trim().isNotEmpty) ...[
              Icon(Icons.call, size: 13, color: scheme.onSurfaceVariant),
              const SizedBox(width: Spacing.xs),
              Text(patient.phone, style: theme.textTheme.labelMedium),
            ] else if (patient.email?.trim().isNotEmpty == true) ...[
              Icon(
                Icons.email_outlined,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  patient.email!,
                  style: theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else ...[
              Icon(
                Icons.badge_outlined,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                patient.patientCode.isNotEmpty
                    ? patient.patientCode
                    : 'No contact on file',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ],
        ),
      ),
      // Edit and archive move into an overflow menu. As always-visible icon
      // buttons they competed with the row itself for attention, and archive
      // sat one mis-tap away from opening the patient.
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              showDialog(
                context: context,
                builder: (_) => EditPatientDialog(patient: patient),
              );
            case 'archive':
              _confirmArchive(context, ref);
          }
        },
        itemBuilder:
            (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Remove'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
      ),
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Remove patient'),
            content: Text(
              'Remove ${patient.name}? They will stop appearing in lists and '
              'totals.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                ),
                onPressed: () async {
                  AppHaptics.error();
                  await ref
                      .read(patientNotifierProvider.notifier)
                      .archivePatient(patient.id);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${patient.name} removed'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            AppHaptics.medium();
                            ref
                                .read(patientNotifierProvider.notifier)
                                .restorePatient(patient.id);
                          },
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }
}
