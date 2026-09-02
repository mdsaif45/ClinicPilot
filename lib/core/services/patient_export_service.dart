import 'package:drift/drift.dart';
import 'package:excel/excel.dart' as xlsx;

import '../../features/clinical/models/case_record_models.dart';
import '../database/app_database.dart';
import '../utils/formatters.dart';
import 'list_export_service.dart';

/// Aggregated patient record containing demographics, clinical summary, and financial billing.
class PatientExportRow {
  final Patient patient;
  final String clinicName;
  final int totalVisits;
  final DateTime? firstVisitDate;
  final DateTime? lastVisitDate;
  final String? lastVisitOutcome;
  final String activeComplaints;
  final String lastPrescription;
  final int totalInvestigations;
  final DateTime? nextFollowUpDate;
  final String followUpStatus;
  final double totalConsultationFees;
  final double totalMedicineFees;
  final double totalDiscounts;
  final double totalBilled;
  final double totalPaid;
  final double outstandingBalance;
  final String preferredPaymentMode;

  const PatientExportRow({
    required this.patient,
    required this.clinicName,
    required this.totalVisits,
    this.firstVisitDate,
    this.lastVisitDate,
    this.lastVisitOutcome,
    required this.activeComplaints,
    required this.lastPrescription,
    required this.totalInvestigations,
    this.nextFollowUpDate,
    required this.followUpStatus,
    required this.totalConsultationFees,
    required this.totalMedicineFees,
    required this.totalDiscounts,
    required this.totalBilled,
    required this.totalPaid,
    required this.outstandingBalance,
    required this.preferredPaymentMode,
  });
}

/// Service dedicated to complete, comprehensive patient data exports across CSV, Multi-Sheet XLSX, and PDF.
class PatientExportService {
  const PatientExportService._();

  static xlsx.CellValue? _cellValue(Object? value) {
    return switch (value) {
      null => null,
      int v => xlsx.IntCellValue(v),
      double v => xlsx.DoubleCellValue(v),
      DateTime v => xlsx.DateTimeCellValue.fromDateTime(v),
      bool v => xlsx.BoolCellValue(v),
      _ => xlsx.TextCellValue(value.toString()),
    };
  }

  static void _styleHeaderRow(xlsx.Sheet sheet, int colCount) {
    for (var col = 0; col < colCount; col++) {
      final cell = sheet.cell(xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = ListExportService.headerStyle;
    }
  }

  // --- Clinical Formatters for Master Case Records ---

  static String _formatChiefComplaints(List<ChiefComplaintDetail> complaints) {
    if (complaints.isEmpty) return '';
    final items = <String>[];
    for (var i = 0; i < complaints.length; i++) {
      final c = complaints[i];
      final details = <String>[];
      if (c.onset.isNotEmpty) details.add('Onset: ${c.onset}');
      if (c.duration.isNotEmpty) details.add('Duration: ${c.duration}');
      if (c.location.isNotEmpty) details.add('Location: ${c.location}');
      if (c.sensation.isNotEmpty) details.add('Sensation: ${c.sensation}');
      if (c.modalitiesAgg.isNotEmpty) details.add('< ${c.modalitiesAgg}');
      if (c.modalitiesAmel.isNotEmpty) details.add('> ${c.modalitiesAmel}');
      if (c.severity.isNotEmpty) details.add('Severity: ${c.severity}');

      final detailStr = details.isNotEmpty ? ' (${details.join(', ')})' : '';
      items.add('${i + 1}. ${c.complaint}$detailStr');
    }
    return items.join('; ');
  }

  static String _formatPastHistory(PastHistoryDetails p) {
    final parts = <String>[];
    if (p.majorIllnesses.isNotEmpty) parts.add('Illnesses: ${p.majorIllnesses}');
    if (p.surgeries.isNotEmpty) parts.add('Surgeries: ${p.surgeries}');
    if (p.hospitalisations.isNotEmpty) parts.add('Hospitalizations: ${p.hospitalisations}');
    if (p.allergies.isNotEmpty) parts.add('Allergies: ${p.allergies}');
    if (p.childhoodIllnesses.isNotEmpty) parts.add('Childhood: ${p.childhoodIllnesses}');
    return parts.join('; ');
  }

  static String _formatFamilyHistory(FamilyHistoryDetails f) {
    final parts = <String>[];
    if (f.father.isNotEmpty) parts.add('Father: ${f.father}');
    if (f.mother.isNotEmpty) parts.add('Mother: ${f.mother}');
    if (f.siblings.isNotEmpty) parts.add('Siblings: ${f.siblings}');
    if (f.majorFamilialDiseases.isNotEmpty) parts.add('Familial: ${f.majorFamilialDiseases}');
    if (f.hereditaryDiseases.isNotEmpty) parts.add('Hereditary: ${f.hereditaryDiseases}');
    return parts.join('; ');
  }

  static String _formatPhysicalGeneralsSummary(PhysicalGenerals pg) {
    final parts = <String>[];
    if (pg.thermal.isNotEmpty) parts.add('Thermal: ${pg.thermal}');
    if (pg.thirst.isNotEmpty) parts.add('Thirst: ${pg.thirst}');
    if (pg.appetite.isNotEmpty) parts.add('Appetite: ${pg.appetite}');
    if (pg.cravings.isNotEmpty) parts.add('Cravings: ${pg.cravings}');
    if (pg.aversions.isNotEmpty) parts.add('Aversions: ${pg.aversions}');
    if (pg.stool.isNotEmpty) parts.add('Stool: ${pg.stool}');
    if (pg.urine.isNotEmpty) parts.add('Urine: ${pg.urine}');
    if (pg.perspiration.isNotEmpty) parts.add('Sweat: ${pg.perspiration}');
    if (pg.sleep.isNotEmpty) parts.add('Sleep: ${pg.sleep}');
    if (pg.dreams.isNotEmpty) parts.add('Dreams: ${pg.dreams}');
    return parts.join('; ');
  }

  static String _formatMentalGeneralsSummary(MentalGenerals mg) {
    final parts = <String>[];
    if (mg.generalMentalState.isNotEmpty) parts.add('State: ${mg.generalMentalState}');
    if (mg.disposition.isNotEmpty) parts.add('Disposition: ${mg.disposition}');
    if (mg.fears.isNotEmpty) parts.add('Fears: ${mg.fears}');
    if (mg.anxiety.isNotEmpty) parts.add('Anxiety: ${mg.anxiety}');
    if (mg.anger.isNotEmpty) parts.add('Anger: ${mg.anger}');
    if (mg.memory.isNotEmpty) parts.add('Memory: ${mg.memory}');
    if (mg.responseToStress.isNotEmpty) parts.add('Stress: ${mg.responseToStress}');
    return parts.join('; ');
  }

  static String _formatClinicalExam(ClinicalExamVitals v) {
    final parts = <String>[];
    if (v.bloodPressure.isNotEmpty) parts.add('BP: ${v.bloodPressure}');
    if (v.pulse.isNotEmpty) parts.add('Pulse: ${v.pulse}');
    if (v.weightKg.isNotEmpty) parts.add('Weight: ${v.weightKg} kg');
    if (v.heightCm.isNotEmpty) parts.add('Height: ${v.heightCm} cm');
    if (v.bmi.isNotEmpty) parts.add('BMI: ${v.bmi}');
    if (v.temperature.isNotEmpty) parts.add('Temp: ${v.temperature}');
    if (v.otherExaminationFindings.isNotEmpty) parts.add('Exam: ${v.otherExaminationFindings}');
    return parts.join('; ');
  }

  static String _formatMiasm(MiasmaticAnalysis m) {
    final parts = <String>[];
    if (m.dominantMiasm.isNotEmpty) parts.add('Dominant: ${m.dominantMiasm}');
    if (m.secondaryMixedMiasm.isNotEmpty) parts.add('Secondary: ${m.secondaryMixedMiasm}');
    if (m.psoricFeatures.isNotEmpty) parts.add('Psora: ${m.psoricFeatures}');
    if (m.sycoticFeatures.isNotEmpty) parts.add('Sycosis: ${m.sycoticFeatures}');
    if (m.syphiliticFeatures.isNotEmpty) parts.add('Syphilis: ${m.syphiliticFeatures}');
    if (m.tubercularFeatures.isNotEmpty) parts.add('Tubercular: ${m.tubercularFeatures}');
    return parts.join('; ');
  }

  static String _formatTotality(CaseTotality t) {
    final parts = <String>[];
    if (t.characteristicSymptoms.isNotEmpty) parts.add('Keynotes: ${t.characteristicSymptoms}');
    if (t.totalityOfSymptoms.isNotEmpty) parts.add('Totality: ${t.totalityOfSymptoms}');
    if (t.rubricsSelected.isNotEmpty) parts.add('Rubrics: ${t.rubricsSelected}');
    if (t.finalRemedySelection.isNotEmpty) parts.add('Selected: ${t.finalRemedySelection} ${t.potency}'.trim());
    return parts.join('; ');
  }

  static String _formatPrescriptionPlan(PrescriptionPlanDetails rx) {
    final parts = <String>[];
    if (rx.remedyName.isNotEmpty) {
      parts.add('${rx.remedyName} ${rx.potency}'.trim());
    }
    if (rx.dose.isNotEmpty) parts.add('Dose: ${rx.dose}');
    if (rx.repetitionFrequency.isNotEmpty) parts.add('Freq: ${rx.repetitionFrequency}');
    if (rx.pharmaceuticalForm.isNotEmpty) parts.add('Form: ${rx.pharmaceuticalForm}');
    if (rx.dietRegimenAdvice.isNotEmpty) parts.add('Diet: ${rx.dietRegimenAdvice}');
    return parts.join(', ');
  }

  /// Queries database and computes rich [PatientExportRow] objects for all active patients.
  static Future<List<PatientExportRow>> fetchPatientExportRows(AppDatabase db) async {
    final patients = await (db.select(db.patients)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.serialNo)]))
        .get();

    final clinics = await (db.select(db.clinics)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final clinicMap = {for (final c in clinics) c.id: c.name};

    final allVisits = await (db.select(db.visits)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.visitDate)]))
        .get();

    final allMemos = await (db.select(db.cashMemos)
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final allComplaints = await (db.select(db.complaints)
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final allRx = await (db.select(db.prescriptions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    final allInvestigations = await (db.select(db.investigations)
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    // Group by patientId
    final visitsByPatient = <String, List<Visit>>{};
    for (final v in allVisits) {
      visitsByPatient.putIfAbsent(v.patientId, () => []).add(v);
    }

    final memosByPatient = <String, List<CashMemo>>{};
    for (final m in allMemos) {
      memosByPatient.putIfAbsent(m.patientId, () => []).add(m);
    }

    final complaintsByPatient = <String, List<Complaint>>{};
    for (final c in allComplaints) {
      complaintsByPatient.putIfAbsent(c.patientId, () => []).add(c);
    }

    final rxByPatient = <String, List<Prescription>>{};
    for (final rx in allRx) {
      rxByPatient.putIfAbsent(rx.patientId, () => []).add(rx);
    }

    final invByPatient = <String, List<Investigation>>{};
    for (final inv in allInvestigations) {
      invByPatient.putIfAbsent(inv.patientId, () => []).add(inv);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = <PatientExportRow>[];

    for (final p in patients) {
      final pVisits = visitsByPatient[p.id] ?? const [];
      final pMemos = memosByPatient[p.id] ?? const [];
      final pComplaints = complaintsByPatient[p.id] ?? const [];
      final pRx = rxByPatient[p.id] ?? const [];
      final pInv = invByPatient[p.id] ?? const [];

      // 1. Visit Metrics
      final totalVisits = pVisits.length;
      final firstVisitDate = pVisits.isNotEmpty ? pVisits.first.visitDate : null;
      final lastVisit = pVisits.isNotEmpty ? pVisits.last : null;
      final lastVisitDate = lastVisit?.visitDate;
      final lastVisitOutcome = lastVisit?.outcome;

      // Next Follow-up
      DateTime? nextFollowUpDate;
      for (final v in pVisits.reversed) {
        if (v.nextFollowUpDate != null) {
          nextFollowUpDate = v.nextFollowUpDate;
          break;
        }
      }

      String followUpStatus = 'None';
      if (nextFollowUpDate != null) {
        final fDate = DateTime(nextFollowUpDate.year, nextFollowUpDate.month, nextFollowUpDate.day);
        final diff = today.difference(fDate).inDays;
        if (diff > 0) {
          followUpStatus = 'Overdue by $diff day${diff == 1 ? '' : 's'}';
        } else if (diff == 0) {
          followUpStatus = 'Due Today';
        } else {
          followUpStatus = 'Upcoming in ${-diff} day${-diff == 1 ? '' : 's'}';
        }
      }

      // 2. Clinical Metrics
      final activeComplaintsList = pComplaints
          .where((c) => c.status.toLowerCase() != 'resolved')
          .map((c) => c.severity > 0 ? '${c.complaintName} (Severity ${c.severity}/10)' : c.complaintName)
          .toList();
      final activeComplaints = activeComplaintsList.join('; ');

      String lastRxText = '';
      if (pRx.isNotEmpty) {
        final latestRx = pRx.first;
        lastRxText = '${latestRx.remedyName} ${latestRx.potency}'.trim();
        final freq = latestRx.frequency;
        if (freq != null && freq.isNotEmpty) {
          lastRxText += ' ($freq)';
        }
      }

      // 3. Financial Metrics
      double totalConsultationFees = 0;
      double totalMedicineFees = 0;
      double totalDiscounts = 0;
      double totalBilled = 0;
      double totalPaid = 0;
      final paymentMethodCounts = <String, int>{};

      for (final m in pMemos) {
        totalConsultationFees += m.consultationFee.toDouble();
        totalMedicineFees += m.medicineFee.toDouble();
        totalDiscounts += m.discount.toDouble();
        totalBilled += m.total.toDouble();
        totalPaid += m.paidAmount.toDouble();
        if (m.paymentMethod.isNotEmpty) {
          paymentMethodCounts[m.paymentMethod] = (paymentMethodCounts[m.paymentMethod] ?? 0) + 1;
        }
      }

      final outstandingBalance = totalBilled - totalPaid;
      String preferredPayment = 'Cash';
      if (paymentMethodCounts.isNotEmpty) {
        preferredPayment = paymentMethodCounts.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
      }

      result.add(
        PatientExportRow(
          patient: p,
          clinicName: clinicMap[p.primaryClinicId] ?? p.primaryClinicId,
          totalVisits: totalVisits,
          firstVisitDate: firstVisitDate,
          lastVisitDate: lastVisitDate,
          lastVisitOutcome: lastVisitOutcome,
          activeComplaints: activeComplaints,
          lastPrescription: lastRxText,
          totalInvestigations: pInv.length,
          nextFollowUpDate: nextFollowUpDate,
          followUpStatus: followUpStatus,
          totalConsultationFees: totalConsultationFees,
          totalMedicineFees: totalMedicineFees,
          totalDiscounts: totalDiscounts,
          totalBilled: totalBilled,
          totalPaid: totalPaid,
          outstandingBalance: outstandingBalance,
          preferredPaymentMode: preferredPayment,
        ),
      );
    }

    return result;
  }

  /// Master column definition for comprehensive patient export.
  static List<ExportColumn<PatientExportRow>> getMasterExportColumns() {
    return [
      ExportColumn('Serial No.', (r) => r.patient.serialNo),
      ExportColumn('Patient Code', (r) => r.patient.patientCode),
      ExportColumn('Full Name', (r) => r.patient.name),
      ExportColumn('Phone Number', (r) => r.patient.phone),
      ExportColumn('WhatsApp Number', (r) => r.patient.whatsapp ?? ''),
      ExportColumn('Email Address', (r) => r.patient.email ?? ''),
      ExportColumn('Age', (r) => r.patient.age),
      ExportColumn('Gender', (r) => r.patient.gender),
      ExportColumn('Occupation', (r) => r.patient.occupation ?? ''),
      ExportColumn('Area / Locality', (r) => r.patient.area ?? ''),
      ExportColumn('Full Address', (r) => r.patient.address ?? ''),
      ExportColumn('Primary Clinic', (r) => r.clinicName),
      ExportColumn('Primary Disease / Chief Condition', (r) => r.patient.primaryDisease ?? ''),
      ExportColumn('Active Complaints', (r) => r.activeComplaints),
      ExportColumn('Total Visits', (r) => r.totalVisits),
      ExportColumn('First Visit Date', (r) => r.firstVisitDate != null ? Formatters.formatDate(r.firstVisitDate!) : ''),
      ExportColumn('Last Visit Date', (r) => r.lastVisitDate != null ? Formatters.formatDate(r.lastVisitDate!) : ''),
      ExportColumn('Last Visit Outcome', (r) => r.lastVisitOutcome ?? ''),
      ExportColumn('Last Prescribed Remedy', (r) => r.lastPrescription),
      ExportColumn('Total Lab Tests', (r) => r.totalInvestigations),
      ExportColumn('Next Follow-Up Date', (r) => r.nextFollowUpDate != null ? Formatters.formatDate(r.nextFollowUpDate!) : ''),
      ExportColumn('Follow-Up Status', (r) => r.followUpStatus),
      ExportColumn('Total Consultation Fees (Rs.)', (r) => r.totalConsultationFees),
      ExportColumn('Total Medicine Fees (Rs.)', (r) => r.totalMedicineFees),
      ExportColumn('Total Discounts (Rs.)', (r) => r.totalDiscounts),
      ExportColumn('Total Amount Billed (Rs.)', (r) => r.totalBilled),
      ExportColumn('Total Amount Paid (Rs.)', (r) => r.totalPaid),
      ExportColumn('Outstanding Balance (Rs.)', (r) => r.outstandingBalance),
      ExportColumn('Preferred Payment Mode', (r) => r.preferredPaymentMode),
      ExportColumn('Referral Source', (r) => r.patient.referralSource ?? ''),
      ExportColumn('Google Review Given', (r) => r.patient.reviewGiven ? 'Yes' : 'No'),
      ExportColumn('Google Review Asked Date', (r) => r.patient.reviewAskedAt != null ? Formatters.formatDate(r.patient.reviewAskedAt!) : ''),
      ExportColumn('Registration Date', (r) => Formatters.formatDate(r.patient.createdAt)),
      ExportColumn('Last Updated', (r) => Formatters.formatDate(r.patient.updatedAt)),
      ExportColumn('General Clinical Notes', (r) => r.patient.notes ?? ''),
    ];
  }

  /// Compact, high-signal columns tailored for printable PDF table reports.
  static List<ExportColumn<PatientExportRow>> getPdfExportColumns() {
    return [
      ExportColumn('Serial', (r) => r.patient.serialNo),
      ExportColumn('Code', (r) => r.patient.patientCode),
      ExportColumn('Name', (r) => r.patient.name),
      ExportColumn('Phone', (r) => r.patient.phone),
      ExportColumn('Age/Gender', (r) => '${r.patient.age} ${r.patient.gender.isNotEmpty ? r.patient.gender[0].toUpperCase() : ''}'),
      ExportColumn('Area', (r) => r.patient.area ?? ''),
      ExportColumn('Primary Disease', (r) => r.patient.primaryDisease ?? ''),
      ExportColumn('Visits', (r) => r.totalVisits),
      ExportColumn('Last Visit', (r) => r.lastVisitDate != null ? Formatters.formatDate(r.lastVisitDate!) : '-'),
      ExportColumn('Next Follow-up', (r) => r.nextFollowUpDate != null ? Formatters.formatDate(r.nextFollowUpDate!) : '-'),
      ExportColumn('Total Paid', (r) => 'Rs. ${r.totalPaid.toStringAsFixed(0)}'),
      ExportColumn('Balance', (r) => 'Rs. ${r.outstandingBalance.toStringAsFixed(0)}'),
    ];
  }

  /// Builds a complete 10-sheet multi-workbook Excel (.xlsx) file.
  static Future<List<int>> buildMultiSheetPatientXlsx(AppDatabase db) async {
    final excel = xlsx.Excel.createExcel();
    excel.rename('Sheet1', 'Patients Master');

    final rows = await fetchPatientExportRows(db);
    final patientMap = {for (final r in rows) r.patient.id: r.patient};

    // 1. Sheet: Patients Master
    final masterSheet = excel['Patients Master'];
    final masterColumns = getMasterExportColumns();
    masterSheet.appendRow(masterColumns.map((c) => xlsx.TextCellValue(c.header)).toList());
    _styleHeaderRow(masterSheet, masterColumns.length);

    for (final row in rows) {
      masterSheet.appendRow(masterColumns.map((c) => _cellValue(c.value(row))).toList());
    }

    // 2. Sheet: Visits History
    final allVisits = await (db.select(db.visits)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.visitDate)]))
        .get();

    final allClinics = await (db.select(db.clinics)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final clinicNameById = {for (final c in allClinics) c.id: c.name};

    final visitsSheet = excel['Visits History'];
    final visitHeaders = [
      'Visit Date',
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Clinic',
      'Visit Type',
      'Consultation Mode',
      'Disease / Condition Treated',
      'Chief Complaint',
      'Outcome',
      'Next Follow-Up Date',
      'Notes',
    ];
    visitsSheet.appendRow(visitHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(visitsSheet, visitHeaders.length);

    for (final v in allVisits) {
      final p = patientMap[v.patientId];
      visitsSheet.appendRow([
        _cellValue(v.visitDate),
        _cellValue(p?.serialNo ?? ''),
        _cellValue(p?.patientCode ?? ''),
        _cellValue(p?.name ?? ''),
        _cellValue(clinicNameById[v.clinicId] ?? v.clinicId),
        _cellValue(v.visitType),
        _cellValue(v.consultationType),
        _cellValue(v.disease),
        _cellValue(v.chiefComplaint ?? ''),
        _cellValue(v.outcome ?? ''),
        _cellValue(v.nextFollowUpDate),
        _cellValue(v.notes ?? ''),
      ]);
    }

    // 3. Sheet: Clinical Complaints
    final allComplaints = await (db.select(db.complaints)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.complaintIndex)]))
        .get();

    final complaintsSheet = excel['Clinical Complaints'];
    final compHeaders = [
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Complaint #',
      'Complaint Name',
      'Onset',
      'Duration',
      'Location / Site',
      'Side',
      'Sensation / Character',
      'Extension / Radiation',
      'Aggravating Factors (<)',
      'Ameliorating Factors (>)',
      'Concomitants',
      'Severity (1-10)',
      'Status',
      'Notes',
    ];
    complaintsSheet.appendRow(compHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(complaintsSheet, compHeaders.length);

    for (final c in allComplaints) {
      final p = patientMap[c.patientId];
      complaintsSheet.appendRow([
        _cellValue(p?.serialNo ?? ''),
        _cellValue(p?.patientCode ?? ''),
        _cellValue(p?.name ?? ''),
        _cellValue(c.complaintIndex),
        _cellValue(c.complaintName),
        _cellValue(c.onset ?? ''),
        _cellValue(c.duration ?? ''),
        _cellValue(c.location ?? ''),
        _cellValue(c.side ?? ''),
        _cellValue(c.sensation ?? ''),
        _cellValue(c.extension ?? ''),
        _cellValue(c.aggravatingFactors ?? ''),
        _cellValue(c.amelioratingFactors ?? ''),
        _cellValue(c.concomitants ?? ''),
        _cellValue(c.severity),
        _cellValue(c.status),
        _cellValue(c.notes ?? ''),
      ]);
    }

    // 4. Sheet: Prescriptions History
    final allPrescriptions = await (db.select(db.prescriptions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    final rxSheet = excel['Prescriptions History'];
    final rxHeaders = [
      'Date',
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Remedy Name',
      'Potency',
      'Vehicle',
      'Dose Count',
      'Frequency',
      'Duration (Days)',
      'Instructions',
      'Dietary Advice',
    ];
    rxSheet.appendRow(rxHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(rxSheet, rxHeaders.length);

    for (final rx in allPrescriptions) {
      final p = patientMap[rx.patientId];
      rxSheet.appendRow([
        _cellValue(rx.createdAt),
        _cellValue(p?.serialNo ?? ''),
        _cellValue(p?.patientCode ?? ''),
        _cellValue(p?.name ?? ''),
        _cellValue(rx.remedyName),
        _cellValue(rx.potency),
        _cellValue(rx.vehicle ?? ''),
        _cellValue(rx.doseCount ?? ''),
        _cellValue(rx.frequency ?? ''),
        _cellValue(rx.durationDays ?? ''),
        _cellValue(rx.instructions ?? ''),
        _cellValue(rx.dietaryAdvice ?? ''),
      ]);
    }

    // 5. Sheet: Lab Investigations
    final allInvestigations = await (db.select(db.investigations)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.testDate)]))
        .get();

    final invSheet = excel['Lab Investigations'];
    final invHeaders = [
      'Test Date',
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Test Name',
      'Category',
      'Result Value',
      'Unit',
      'Flag',
      'Min Ref',
      'Max Ref',
      'Lab Name',
      'Doctor Notes',
    ];
    invSheet.appendRow(invHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(invSheet, invHeaders.length);

    for (final inv in allInvestigations) {
      final p = patientMap[inv.patientId];
      final val = inv.numericValue != null ? inv.numericValue.toString() : (inv.stringValue ?? '');
      invSheet.appendRow([
        _cellValue(inv.testDate),
        _cellValue(p?.serialNo ?? ''),
        _cellValue(p?.patientCode ?? ''),
        _cellValue(p?.name ?? ''),
        _cellValue(inv.testName),
        _cellValue(inv.testCategory),
        _cellValue(val),
        _cellValue(inv.unit ?? ''),
        _cellValue(inv.flag),
        _cellValue(inv.refRangeMin),
        _cellValue(inv.refRangeMax),
        _cellValue(inv.labName ?? ''),
        _cellValue(inv.notes ?? ''),
      ]);
    }

    // 6. Sheet: Billing & Cash Memos
    final allMemos = await (db.select(db.cashMemos)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.memoDate)]))
        .get();

    final memoSheet = excel['Billing & Cash Memos'];
    final memoHeaders = [
      'Memo Number',
      'Memo Date',
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Clinic',
      'Consultation Fee (Rs.)',
      'Medicine Fee (Rs.)',
      'Other Fees (Rs.)',
      'Discount (Rs.)',
      'Total Amount (Rs.)',
      'Paid Amount (Rs.)',
      'Balance (Rs.)',
      'Payment Method',
    ];
    memoSheet.appendRow(memoHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(memoSheet, memoHeaders.length);

    for (final m in allMemos) {
      final p = patientMap[m.patientId];
      final balance = m.total - m.paidAmount;
      memoSheet.appendRow([
        _cellValue(m.memoNumber),
        _cellValue(m.memoDate),
        _cellValue(p?.serialNo ?? ''),
        _cellValue(p?.patientCode ?? ''),
        _cellValue(p?.name ?? ''),
        _cellValue(clinicNameById[m.clinicId] ?? m.clinicId),
        _cellValue(m.consultationFee),
        _cellValue(m.medicineFee),
        _cellValue(m.otherFee),
        _cellValue(m.discount),
        _cellValue(m.total),
        _cellValue(m.paidAmount),
        _cellValue(balance),
        _cellValue(m.paymentMethod),
      ]);
    }

    // 7. Sheet: Follow-Up & Recall Schedule
    final followUpSheet = excel['Follow-Up Schedule'];
    final followUpHeaders = [
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Phone Number',
      'Primary Clinic',
      'Primary Disease',
      'Last Visit Date',
      'Next Follow-Up Date',
      'Follow-Up Status',
      'Last Prescribed Remedy',
    ];
    followUpSheet.appendRow(followUpHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(followUpSheet, followUpHeaders.length);

    for (final r in rows) {
      if (r.nextFollowUpDate != null || r.totalVisits > 0) {
        followUpSheet.appendRow([
          _cellValue(r.patient.serialNo),
          _cellValue(r.patient.patientCode),
          _cellValue(r.patient.name),
          _cellValue(r.patient.phone),
          _cellValue(r.clinicName),
          _cellValue(r.patient.primaryDisease ?? ''),
          _cellValue(r.lastVisitDate != null ? Formatters.formatDate(r.lastVisitDate!) : ''),
          _cellValue(r.nextFollowUpDate != null ? Formatters.formatDate(r.nextFollowUpDate!) : ''),
          _cellValue(r.followUpStatus),
          _cellValue(r.lastPrescription),
        ]);
      }
    }

    // 8. Sheet: Master Case Records (Human-Readable Clinical Summaries)
    final allCaseRecords = await (db.select(db.patientCaseRecords)
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final caseSheet = excel['Master Case Records'];
    final caseHeaders = [
      'Record Date',
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Chief Complaints',
      'History of Present Illness (HPI)',
      'Past Medical History',
      'Family History',
      'Physical Generals Summary',
      'Mental Generals Summary',
      'Clinical Exam & Vitals',
      'Miasmatic Analysis',
      'Case Totality & Keynotes',
      'Baseline Prescription Plan',
      'Follow-up Notes & Progression',
      'Outcome',
    ];
    caseSheet.appendRow(caseHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(caseSheet, caseHeaders.length);

    // 9. Sheet: Physical & Mental Generals (Repertorization & Homeopathic Analysis)
    final generalsSheet = excel['Physical & Mental Generals'];
    final generalsHeaders = [
      'Serial No.',
      'Patient Code',
      'Patient Name',
      'Thermal State',
      'Thirst & Drinking Habits',
      'Appetite & Hunger',
      'Food Desires / Cravings',
      'Food Aversions',
      'Food Intolerances',
      'Stool & Bowels',
      'Urine Characteristics',
      'Perspiration & Odour',
      'Sleep & Sleeping Habits',
      'Dreams & Recurring Themes',
      'Energy & Vitality',
      'Mental Disposition',
      'Fears & Phobias',
      'Anxiety & Sadness',
      'Anger & Irritability',
      'Memory & Concentration',
      'Response to Stress',
      'Dominant Miasm',
    ];
    generalsSheet.appendRow(generalsHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(generalsSheet, generalsHeaders.length);

    for (final rec in allCaseRecords) {
      final p = patientMap[rec.patientId];
      final complaints = MasterCaseRecordData.parseChiefComplaints(rec.chiefComplaintsJson);
      final hpi = MasterCaseRecordData.parseHpi(rec.hpi);
      final pastHistory = MasterCaseRecordData.parsePastHistory(rec.pastHistoryJson);
      final familyHistory = MasterCaseRecordData.parseFamilyHistory(rec.familyHistoryJson);
      final physicalGenerals = MasterCaseRecordData.parsePhysicalGenerals(rec.physicalGeneralsJson);
      final mentalGenerals = MasterCaseRecordData.parseMentalGenerals(rec.mentalGeneralsJson);
      final clinicalExam = MasterCaseRecordData.parseClinicalExam(rec.clinicalExamJson);
      final miasm = MasterCaseRecordData.parseMiasmaticAnalysis(rec.miasmaticAnalysisJson);
      final totality = MasterCaseRecordData.parseCaseTotality(rec.caseTotalityJson);
      final prescription = MasterCaseRecordData.parsePrescription(rec.baselinePrescriptionJson);
      final outcome = MasterCaseRecordData.parseOutcome(rec.outcome);

      // Add to Master Case Records Sheet
      caseSheet.appendRow([
        _cellValue(rec.recordDate),
        _cellValue(p?.serialNo ?? ''),
        _cellValue(p?.patientCode ?? ''),
        _cellValue(p?.name ?? ''),
        _cellValue(_formatChiefComplaints(complaints)),
        _cellValue(hpi.chronologicalDevelopment),
        _cellValue(_formatPastHistory(pastHistory)),
        _cellValue(_formatFamilyHistory(familyHistory)),
        _cellValue(_formatPhysicalGeneralsSummary(physicalGenerals)),
        _cellValue(_formatMentalGeneralsSummary(mentalGenerals)),
        _cellValue(_formatClinicalExam(clinicalExam)),
        _cellValue(_formatMiasm(miasm)),
        _cellValue(_formatTotality(totality)),
        _cellValue(_formatPrescriptionPlan(prescription)),
        _cellValue(rec.followUpNotes ?? ''),
        _cellValue(outcome.finalStatus.isNotEmpty ? outcome.finalStatus : (rec.outcome ?? '')),
      ]);

      // Add to Physical & Mental Generals Repertory Sheet
      generalsSheet.appendRow([
        _cellValue(p?.serialNo ?? ''),
        _cellValue(p?.patientCode ?? ''),
        _cellValue(p?.name ?? ''),
        _cellValue(physicalGenerals.thermal),
        _cellValue(physicalGenerals.thirst),
        _cellValue(physicalGenerals.appetite),
        _cellValue(physicalGenerals.cravings),
        _cellValue(physicalGenerals.aversions),
        _cellValue(physicalGenerals.intolerances),
        _cellValue(physicalGenerals.stool),
        _cellValue(physicalGenerals.urine),
        _cellValue(physicalGenerals.perspiration),
        _cellValue(physicalGenerals.sleep),
        _cellValue(physicalGenerals.dreams),
        _cellValue(physicalGenerals.energyVitality),
        _cellValue(mentalGenerals.disposition),
        _cellValue(mentalGenerals.fears),
        _cellValue(mentalGenerals.anxiety),
        _cellValue(mentalGenerals.anger),
        _cellValue(mentalGenerals.memory),
        _cellValue(mentalGenerals.responseToStress),
        _cellValue(miasm.dominantMiasm),
      ]);
    }

    // 10. Sheet: Walk-in Leads & Footfalls
    final allFootfalls = await (db.select(db.footfalls)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();

    final footfallsSheet = excel['Walk-in Leads & Footfalls'];
    final footfallHeaders = [
      'Inquiry Date',
      'Visitor / Lead Name',
      'Phone Number',
      'Clinic',
      'Disease / Health Issue Inquired',
      'Conversion Status',
      'Converted Patient Code',
      'Converted Patient Name',
      'Reception Notes',
    ];
    footfallsSheet.appendRow(footfallHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(footfallsSheet, footfallHeaders.length);

    for (final f in allFootfalls) {
      final convertedP = f.convertedPatientId != null ? patientMap[f.convertedPatientId] : null;
      final isConverted = f.convertedPatientId != null;
      footfallsSheet.appendRow([
        _cellValue(f.date),
        _cellValue(f.name),
        _cellValue(f.phone ?? ''),
        _cellValue(clinicNameById[f.clinicId] ?? f.clinicId),
        _cellValue(f.disease ?? ''),
        _cellValue(isConverted ? 'Converted to Patient' : 'Pending Inquiry'),
        _cellValue(convertedP?.patientCode ?? ''),
        _cellValue(convertedP?.name ?? ''),
        _cellValue(f.notes ?? ''),
      ]);
    }

    final rawBytes = excel.encode()!;
    return ListExportService.enableAutoFilter(rawBytes);
  }
}
