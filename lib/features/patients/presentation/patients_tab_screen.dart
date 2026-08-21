import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/list_export_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/export_action.dart';
import '../../../core/widgets/swipeable_sections.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/patient_provider.dart';
import 'footfalls_screen.dart';
import 'patients_screen.dart';
import 'recall_screen.dart';

/// The patient directory and the follow-up list under one tab.
///
/// Follow-ups were only reachable from a dashboard card that appears when
/// somebody is overdue — so the one moment the doctor might want to check
/// whether anyone needs chasing, and nobody does, there was no way in. Sitting
/// beside the directory it is always reachable, and it is the same subject:
/// both are lists of patients, one by name and one by who is due.
class PatientsTabScreen extends StatelessWidget {
  const PatientsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Directory leads: looking someone up is the far more frequent task.
    return SwipeableSections(
      labels: const ['Directory', 'Follow-ups', 'Footfalls'],
      children: const [
        PatientsScreen(),
        RecallScreen(showAppBar: false),
        FootfallsScreen(),
      ],
      // Export only covers the directory - a follow-up list is a view over
      // the same patients, not a distinct export the plan asked for.
      trailingBuilder: (index) =>
          index == 0 ? const _PatientsExportAction() : null,
    );
  }
}

/// Column spec for the Patients export, pulled out as a plain function so
/// its output can be pinned in a test without touching the widget tree or
/// the platform file-picker channel.
List<ExportColumn<Patient>> patientsExportColumns(Map<String, String> clinicNames) {
  return [
    ExportColumn('Serial No.', (p) => p.serialNo),
    ExportColumn('Patient Code', (p) => p.patientCode),
    ExportColumn('Name', (p) => p.name),
    ExportColumn('Phone', (p) => p.phone),
    ExportColumn('WhatsApp', (p) => p.whatsapp),
    ExportColumn('Age', (p) => p.age),
    ExportColumn('Gender', (p) => p.gender),
    ExportColumn('Area', (p) => p.area),
    ExportColumn(
      'Clinic',
      (p) => clinicNames[p.primaryClinicId] ?? p.primaryClinicId,
    ),
    ExportColumn('Primary Disease', (p) => p.primaryDisease),
    ExportColumn('Referral Source', (p) => p.referralSource),
    ExportColumn('Registered On', (p) => Formatters.formatDate(p.createdAt)),
  ];
}

class _PatientsExportAction extends ConsumerWidget {
  const _PatientsExportAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientsStreamProvider).value ?? const [];
    final clinics = ref.watch(clinicsStreamProvider).value ?? const [];
    final clinicNames = {for (final c in clinics) c.id: c.name};

    return ExportAction<Patient>(
      screenSlug: 'patients',
      title: 'Patient Directory',
      rows: patients,
      columns: patientsExportColumns(clinicNames),
    );
  }
}
