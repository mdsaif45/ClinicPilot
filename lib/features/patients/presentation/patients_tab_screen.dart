import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/list_export_service.dart';
import '../../../core/services/patient_export_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/export_action.dart';
import '../../../core/widgets/swipeable_sections.dart';
import '../providers/footfall_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/recall_provider.dart';
import 'footfalls_screen.dart';
import 'patients_screen.dart';
import 'recall_screen.dart';

/// The patient directory, follow-up recall list, and walk-in footfalls under one tab.
class PatientsTabScreen extends StatelessWidget {
  final int initialIndex;

  const PatientsTabScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SwipeableSections(
      initialIndex: initialIndex,
      labels: const ['Directory', 'Follow-ups', 'Footfalls'],
      children: const [
        PatientsScreen(),
        RecallScreen(showAppBar: false),
        FootfallsScreen(),
      ],
      trailingBuilder: (index) {
        if (index == 0) return const _PatientsExportAction();
        if (index == 1) return const _FollowUpsExportAction();
        if (index == 2) return const _FootfallsExportAction();
        return null;
      },
    );
  }
}

/// Column spec for the Patients export (backward-compatibility pinned in tests).
List<ExportColumn<Patient>> patientsExportColumns(Map<String, String> clinicNames) {
  return [
    ExportColumn('Serial No.', (p) => p.serialNo),
    ExportColumn('Patient Code', (p) => p.patientCode),
    ExportColumn('Name', (p) => p.name),
    ExportColumn('Phone', (p) => p.phone),
    ExportColumn('WhatsApp', (p) => p.whatsapp ?? ''),
    ExportColumn('Email', (p) => p.email ?? ''),
    ExportColumn('Age', (p) => p.age),
    ExportColumn('Gender', (p) => p.gender),
    ExportColumn('Occupation', (p) => p.occupation ?? ''),
    ExportColumn('Area', (p) => p.area ?? ''),
    ExportColumn('Address', (p) => p.address ?? ''),
    ExportColumn(
      'Clinic',
      (p) => clinicNames[p.primaryClinicId] ?? p.primaryClinicId,
    ),
    ExportColumn('Primary Disease', (p) => p.primaryDisease ?? ''),
    ExportColumn('Referral Source', (p) => p.referralSource ?? ''),
    ExportColumn('Google Review Given', (p) => p.reviewGiven ? 'Yes' : 'No'),
    ExportColumn('Google Review Asked Date', (p) => p.reviewAskedAt != null ? Formatters.formatDate(p.reviewAskedAt!) : ''),
    ExportColumn('Registered On', (p) => Formatters.formatDate(p.createdAt)),
    ExportColumn('Last Updated', (p) => Formatters.formatDate(p.updatedAt)),
    ExportColumn('Notes', (p) => p.notes ?? ''),
  ];
}

class _PatientsExportAction extends ConsumerWidget {
  const _PatientsExportAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportRows = ref.watch(patientExportRowsProvider).value ?? const [];
    final db = ref.read(databaseProvider);

    return ExportAction<PatientExportRow>(
      screenSlug: 'patients',
      title: 'Patient Directory',
      rows: exportRows,
      columns: PatientExportService.getMasterExportColumns(),
      pdfColumns: PatientExportService.getPdfExportColumns(),
      customXlsxBuilder: () => PatientExportService.buildMultiSheetPatientXlsx(db),
    );
  }
}

/// Column spec for Follow-ups export.
List<ExportColumn<RecallEntry>> followUpsExportColumns() {
  return [
    ExportColumn('Patient Code', (e) => e.patient.patientCode),
    ExportColumn('Serial No.', (e) => e.patient.serialNo),
    ExportColumn('Patient Name', (e) => e.patient.name),
    ExportColumn('Phone', (e) => e.patient.phone),
    ExportColumn('Clinic', (e) => e.clinic.name),
    ExportColumn('Primary Disease', (e) => e.visit.disease),
    ExportColumn('Last Visit Date', (e) => Formatters.formatDate(e.visit.visitDate)),
    ExportColumn('Follow-up Due Date', (e) => e.visit.nextFollowUpDate != null ? Formatters.formatDate(e.visit.nextFollowUpDate!) : 'Not scheduled'),
    ExportColumn('Status', (e) {
      if (e.isOverdue) return 'Overdue by ${e.daysOverdue} day${e.daysOverdue == 1 ? '' : 's'}';
      if (e.isDueToday) return 'Due Today';
      if (e.daysOverdue < 0) return 'Upcoming in ${-e.daysOverdue} day${-e.daysOverdue == 1 ? '' : 's'}';
      return 'Lapsed';
    }),
    ExportColumn('Last Visit Outcome', (e) => e.visit.outcome ?? ''),
    ExportColumn('Notes', (e) => e.visit.notes ?? ''),
  ];
}

class _FollowUpsExportAction extends ConsumerWidget {
  const _FollowUpsExportAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recallLists = ref.watch(recallListProvider).value;
    final allEntries = recallLists != null
        ? [
            ...recallLists.overdue,
            ...recallLists.dueSoon,
            ...recallLists.upcoming,
            ...recallLists.lapsed,
          ]
        : <RecallEntry>[];

    return ExportAction<RecallEntry>(
      screenSlug: 'follow-ups',
      title: 'Follow-Up Recall Schedule',
      rows: allEntries,
      columns: followUpsExportColumns(),
    );
  }
}

/// Column spec for Walk-in Footfalls export.
List<ExportColumn<FootfallWithDetails>> footfallsExportColumns() {
  return [
    ExportColumn('Inquiry Date', (f) => Formatters.formatDate(f.footfall.date)),
    ExportColumn('Visitor Name', (f) => f.footfall.name),
    ExportColumn('Phone', (f) => f.footfall.phone ?? ''),
    ExportColumn('Clinic', (f) => f.clinic.name),
    ExportColumn('Disease Inquired', (f) => f.footfall.disease ?? ''),
    ExportColumn('Conversion Status', (f) => f.isConverted ? 'Converted to Patient' : 'Pending Inquiry'),
    ExportColumn('Converted Patient Code', (f) => f.convertedPatient?.patientCode ?? ''),
    ExportColumn('Converted Patient Name', (f) => f.convertedPatient?.name ?? ''),
    ExportColumn('Reception Notes', (f) => f.footfall.notes ?? ''),
    ExportColumn('Logged On', (f) => Formatters.formatDate(f.footfall.createdAt)),
  ];
}

class _FootfallsExportAction extends ConsumerWidget {
  const _FootfallsExportAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footfalls = ref.watch(footfallsStreamProvider).value ?? const [];

    return ExportAction<FootfallWithDetails>(
      screenSlug: 'footfalls',
      title: 'Walk-in Leads & Footfalls',
      rows: footfalls,
      columns: footfallsExportColumns(),
    );
  }
}
