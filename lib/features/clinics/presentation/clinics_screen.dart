import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/day_selector_field.dart';
import '../providers/clinic_provider.dart';
import 'add_edit_clinic_dialog.dart';

class ClinicsScreen extends ConsumerWidget {
  const ClinicsScreen({super.key});

  void _openAddClinic(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddEditClinicDialog(),
    );
  }

  void _openEditClinic(BuildContext context, Clinic clinic) {
    showDialog(
      context: context,
      builder: (_) => AddEditClinicDialog(clinic: clinic),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final activeId = ref.watch(activeClinicIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Clinics'),
      ),
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

          return ListView.builder(
            padding: const EdgeInsets.all(Spacing.lg),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              final isActive = clinic.id == activeId;
              final scheme = Theme.of(context).colorScheme;

              return Card(
                elevation: isActive ? 4 : 1,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: Radii.mdAll,
                  side: isActive
                      ? BorderSide(
                          color: scheme.primary,
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(Spacing.lg),
                  leading: CircleAvatar(
                    backgroundColor: scheme.primary,
                    child: Icon(Icons.local_hospital, color: scheme.onPrimary),
                  ),
                  title: Row(
                    children: [
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: Spacing.sm),
                        const CustomBadge(label: 'Active'),
                      ],
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: Spacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${clinic.address ?? "N/A"}'),
                        Text('Monthly Rent: ${Formatters.formatCurrency(clinic.monthlyRent)}'),
                        Text('Default Fee: ${Formatters.formatCurrency(clinic.defaultConsultationFee)}'),
                        Text('Open: ${DaySelectorField.describe(clinic.openDays)}'),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isActive)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          tooltip: 'Set Active',
                          onPressed: () {
                            ref
                                .read(activeClinicIdProvider.notifier)
                                .setClinicId(clinic.id);
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openEditClinic(context, clinic),
                      ),
                    ],
                  ),
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
