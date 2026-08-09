import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../cashmemo/presentation/receipt_preview_dialog.dart';
import '../../visits/providers/visit_provider.dart';
import '../../visits/presentation/add_visit_dialog.dart';
import 'edit_patient_dialog.dart';

class PatientProfileScreen extends ConsumerWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(patientVisitsStreamProvider(patient.id));
    final memosAsync = ref.watch(cashMemosStreamProvider);

    final patientMemos = (memosAsync.value ?? [])
        .where((m) => m.memo.patientId == patient.id)
        .toList();

    final lifetimeRevenue =
        patientMemos.fold<double>(0.0, (sum, m) => sum + m.memo.total);
    final totalPending =
        patientMemos.fold<double>(0.0, (sum, m) => sum + m.pendingAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.patientCode} - ${patient.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Patient',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EditPatientDialog(patient: patient),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddVisitDialog(patient: patient),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Visit'),
      ),
      body: visitsAsync.when(
        data: (visitDetailsList) {
          final totalVisits = visitDetailsList.length;
          final avgBill = totalVisits > 0 ? lifetimeRevenue / totalVisits : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Overview Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              patient.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CustomBadge(
                              label: '${patient.age} yrs (${patient.gender})',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Phone: ${patient.phone}'),
                        if (patient.area != null) Text('Area: ${patient.area}'),
                        if (patient.primaryDisease != null)
                          Text('Primary Disease: ${patient.primaryDisease}'),
                        if (patient.referralSource != null)
                          Text('Referral Source: ${patient.referralSource}'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Total Visits', '$totalVisits'),
                            _buildStatItem('Lifetime Revenue',
                                Formatters.formatCurrency(lifetimeRevenue)),
                            _buildStatItem('Avg Bill',
                                Formatters.formatCurrency(avgBill)),
                            _buildStatItem(
                              'Pending Amount',
                              Formatters.formatCurrency(totalPending),
                              color: totalPending > 0
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Visit History & Encounters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (visitDetailsList.isEmpty)
                  const Center(child: Text('No visits recorded yet.'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visitDetailsList.length,
                    itemBuilder: (context, index) {
                      final item = visitDetailsList[index];
                      final v = item.visit;
                      final memoItem = patientMemos.firstWhere(
                        (m) => m.memo.visitId == v.id,
                        orElse: () => patientMemos.isNotEmpty
                            ? patientMemos.first
                            : CashMemoWithDetails(
                                memo: CashMemo(
                                  id: '',
                                  memoNumber: '',
                                  patientId: patient.id,
                                  clinicId: item.clinic.id,
                                  consultationFee: 0,
                                  medicineFee: 0,
                                  otherFee: 0,
                                  discount: 0,
                                  total: 0,
                                  paidAmount: 0,
                                  paymentMethod: 'Cash',
                                  isDeleted: false,
                                  createdAt: v.visitDate,
                                ),
                                patient: patient,
                                clinic: item.clinic,
                              ),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: v.visitType == 'new'
                                ? Colors.green[100]
                                : Colors.blue[100],
                            child: Icon(
                              v.visitType == 'new'
                                  ? Icons.person_add
                                  : Icons.repeat,
                              color: v.visitType == 'new'
                                  ? Colors.green[800]
                                  : Colors.blue[800],
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                Formatters.formatDate(v.visitDate),
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              CustomBadge(
                                label: v.visitType.toUpperCase(),
                                color: v.visitType == 'new'
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Clinic: ${item.clinic.name}'),
                                Text('Disease: ${v.disease}'),
                                if (v.outcome != null)
                                  Text(
                                      'Outcome: ${v.outcome!.replaceAll('_', ' ').toUpperCase()}'),
                                Text(
                                  'Bill Total: ${Formatters.formatCurrency(memoItem.memo.total)} (${memoItem.memo.paymentMethod})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          trailing: memoItem.memo.id.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.receipt_long),
                                  tooltip: 'Re-print Receipt PDF',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ReceiptPreviewDialog(
                                        cashMemo: memoItem.memo,
                                        patient: patient,
                                        clinicName: item.clinic.name,
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
