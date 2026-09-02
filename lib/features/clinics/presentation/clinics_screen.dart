import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../providers/clinic_provider.dart';
import 'add_edit_clinic_dialog.dart';

class ClinicsScreen extends ConsumerWidget {
  const ClinicsScreen({super.key});

  void _openAddClinic(BuildContext context) {
    AppHaptics.selection();
    showDialog(context: context, builder: (_) => const AddEditClinicDialog());
  }

  void _openEditClinic(BuildContext context, Clinic clinic) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditClinicDialog(clinic: clinic),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final activeId = ref.watch(activeClinicIdProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Clinics')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddClinic(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Clinic'),
      ),
      body: clinicsAsync.when(
        data: (clinics) {
          if (clinics.isEmpty) {
            return const Center(child: Text('No clinics configured.'));
          }

          final effectiveActiveId =
              activeId ?? (clinics.isNotEmpty ? clinics.first.id : null);

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            itemCount: clinics.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              final isActive = clinic.id == effectiveActiveId;

              return Container(
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? scheme.primaryContainer.withValues(alpha: 0.3)
                          : scheme.surfaceContainerLow,
                  borderRadius: Radii.mdAll,
                  border: Border.all(
                    color:
                        isActive
                            ? scheme.primary
                            : scheme.outlineVariant.withValues(alpha: 0.5),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
                  leading: Radio<String>(
                    value: clinic.id,
                    groupValue: effectiveActiveId,
                    activeColor: scheme.primary,
                    onChanged: (val) {
                      if (val != null) {
                        AppHaptics.selection();
                        ref
                            .read(activeClinicIdProvider.notifier)
                            .setClinicId(val);
                      }
                    },
                  ),
                  title: Text(
                    clinic.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit Clinic Details & Targets',
                    onPressed: () => _openEditClinic(context, clinic),
                  ),
                  onTap: () {
                    AppHaptics.selection();
                    ref
                        .read(activeClinicIdProvider.notifier)
                        .setClinicId(clinic.id);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
