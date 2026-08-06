import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../providers/patient_provider.dart';
import 'add_patient_dialog.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  void _openAddPatient(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddPatientDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPatientsAsync = ref.watch(filteredPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patients Directory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: "Add Patient",
            onPressed: () => _openAddPatient(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPatient(context),
        backgroundColor: const Color(0xFF0F5132),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Patient", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              onChanged: (query) {
                ref.read(patientSearchQueryProvider.notifier).state = query;
              },
              decoration: InputDecoration(
                hintText: "Search patient by name, phone, disease...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ref.watch(patientSearchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(patientSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredPatientsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error loading patients: $err")),
                data: (patients) {
                  if (patients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No patients found",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openAddPatient(context),
                            icon: const Icon(Icons.add),
                            label: const Text("Register First Patient"),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF0F5132).withOpacity(0.12),
                            child: Text(
                              patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                              style: const TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                patient.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "(${patient.age} yrs • ${patient.gender})",
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(patient.phone, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                CustomBadge(label: patient.disease, color: const Color(0xFF0D6EFD)),
                                CustomBadge(label: patient.referralSource, color: const Color(0xFF198754)),
                              ],
                            ),
                          ),
                          trailing: Text(
                            Formatters.formatDate(patient.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
