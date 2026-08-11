import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../providers/clinic_provider.dart';
import 'add_edit_clinic_dialog.dart';

class ClinicsScreen extends ConsumerWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final activeId = ref.watch(activeClinicIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Clinics'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddEditClinicDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Clinic'),
      ),
      body: clinicsAsync.when(
        data: (clinics) {
          if (clinics.isEmpty) {
            return const Center(child: Text('No clinics configured.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              final isActive = clinic.id == activeId;

              return Card(
                elevation: isActive ? 4 : 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isActive
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(Icons.local_hospital, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  title: Row(
                    children: [
                      Text(
                        clinic.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${clinic.address ?? "N/A"}'),
                        Text('Monthly Rent: ${Formatters.formatCurrency(clinic.monthlyRent)}'),
                        Text('Default Fee: ${Formatters.formatCurrency(clinic.defaultConsultationFee)}'),
                        Text('Open Days: ${clinic.openDays} (1=Mon..7=Sun)'),
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AddEditClinicDialog(clinic: clinic),
                          );
                        },
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
