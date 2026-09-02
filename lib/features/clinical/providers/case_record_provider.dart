import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/case_record_models.dart';

final patientCaseRecordProvider = StreamProvider.family<
  MasterCaseRecordData?,
  String
>((ref, patientId) {
  final db = ref.watch(databaseProvider);

  final query =
      db.select(db.patientCaseRecords)
        ..where(
          (t) => t.patientId.equals(patientId) & t.isDeleted.equals(false),
        )
        ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
        ..limit(1);

  return query.watchSingleOrNull().map((row) {
    if (row == null) return null;
    return MasterCaseRecordData(
      id: row.id,
      patientId: row.patientId,
      recordDate: row.recordDate,
      identification: MasterCaseRecordData.parseIdentification(row.hpi),
      chiefComplaints: MasterCaseRecordData.parseChiefComplaints(
        row.chiefComplaintsJson,
      ),
      additionalComplaints: MasterCaseRecordData.parseAdditionalComplaints(
        row.hpi,
      ),
      hpi: MasterCaseRecordData.parseHpi(row.hpi),
      pastHistory: MasterCaseRecordData.parsePastHistory(row.pastHistoryJson),
      familyHistory: MasterCaseRecordData.parseFamilyHistory(
        row.familyHistoryJson,
      ),
      developmentalHistory: MasterCaseRecordData.parseDevHistory(
        row.developmentalHistoryJson,
      ),
      physicalGenerals: MasterCaseRecordData.parsePhysicalGenerals(
        row.physicalGeneralsJson,
      ),
      mentalGenerals: MasterCaseRecordData.parseMentalGenerals(
        row.mentalGeneralsJson,
      ),
      lifestyleHabits: MasterCaseRecordData.parseLifestyle(row.lifestyleJson),
      clinicalExam: MasterCaseRecordData.parseClinicalExam(
        row.clinicalExamJson,
      ),
      miasmaticAnalysis: MasterCaseRecordData.parseMiasmaticAnalysis(
        row.miasmaticAnalysisJson,
      ),
      caseTotality: MasterCaseRecordData.parseCaseTotality(
        row.caseTotalityJson,
      ),
      clinicalAssessment: MasterCaseRecordData.parseAssessment(
        row.caseTotalityJson,
      ),
      baselinePrescription: MasterCaseRecordData.parsePrescription(
        row.baselinePrescriptionJson,
      ),
      investigations: MasterCaseRecordData.parseInvestigations(
        row.investigationsJson,
      ),
      followUpDetails: MasterCaseRecordData.parseFollowUp(row.followUpNotes),
      followUpNotes: row.followUpNotes ?? '',
      outcomeDetails: MasterCaseRecordData.parseOutcome(row.outcome),
      outcome:
          MasterCaseRecordData.parseOutcome(
                    row.outcome,
                  ).finalStatus.isNotEmpty &&
                  !MasterCaseRecordData.parseOutcome(
                    row.outcome,
                  ).finalStatus.startsWith('{')
              ? MasterCaseRecordData.parseOutcome(row.outcome).finalStatus
              : (row.outcome != null && !row.outcome!.startsWith('{')
                  ? row.outcome!
                  : 'Under Active Treatment'),
      documentation: MasterCaseRecordData.parseDocumentation(row.hpi),
    );
  });
});

class CaseRecordNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  CaseRecordNotifier(this._db) : super(const AsyncData(null));

  int _parseSeverityToInt(String sev) {
    if (sev.contains('Mild') || sev == '1' || sev == '2' || sev == '3')
      return 3;
    if (sev.contains('Moderate') || sev == '4' || sev == '5' || sev == '6')
      return 5;
    if (sev.contains('Severe') || sev == '7' || sev == '8' || sev == '9')
      return 8;
    if (sev.contains('Intolerable') || sev == '10') return 10;
    final num = int.tryParse(sev.replaceAll(RegExp(r'[^0-9]'), ''));
    return num ?? 5;
  }

  Future<void> _syncComplaintsTable(
    String patientId,
    List<ChiefComplaintDetail> complaints,
  ) async {
    // Soft-delete existing complaints for this patient
    await (_db.update(_db.complaints)..where(
      (t) => t.patientId.equals(patientId),
    )).write(const ComplaintsCompanion(isDeleted: Value(true)));

    final now = DateTime.now();
    for (int i = 0; i < complaints.length; i++) {
      final c = complaints[i];
      if (c.complaint.trim().isEmpty) continue;

      await _db
          .into(_db.complaints)
          .insert(
            ComplaintsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: patientId,
              complaintIndex: Value(i + 1),
              complaintName: c.complaint.trim(),
              location: Value(
                c.location.trim().isNotEmpty ? c.location.trim() : null,
              ),
              onset: Value(c.onset.trim().isNotEmpty ? c.onset.trim() : null),
              duration: Value(
                c.duration.trim().isNotEmpty ? c.duration.trim() : null,
              ),
              sensation: Value(
                c.sensation.trim().isNotEmpty ? c.sensation.trim() : null,
              ),
              extension: Value(
                c.extensionRadiation.trim().isNotEmpty
                    ? c.extensionRadiation.trim()
                    : null,
              ),
              aggravatingFactors: Value(
                c.modalitiesAgg.trim().isNotEmpty
                    ? c.modalitiesAgg.trim()
                    : null,
              ),
              amelioratingFactors: Value(
                c.modalitiesAmel.trim().isNotEmpty
                    ? c.modalitiesAmel.trim()
                    : null,
              ),
              concomitants: Value(
                c.concomitants.trim().isNotEmpty ? c.concomitants.trim() : null,
              ),
              causation: Value(
                c.causation.trim().isNotEmpty ? c.causation.trim() : null,
              ),
              periodicity: Value(
                c.periodicity.trim().isNotEmpty ? c.periodicity.trim() : null,
              ),
              severity: Value(_parseSeverityToInt(c.severity)),
              status: const Value('Active'),
              notes: Value(
                c.associatedSymptoms.trim().isNotEmpty
                    ? c.associatedSymptoms.trim()
                    : null,
              ),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    }
  }

  Future<String> saveCaseRecord(MasterCaseRecordData data) async {
    state = const AsyncLoading();
    final id = data.id ?? IdGenerator.generate();
    final now = DateTime.now();

    final companion = PatientCaseRecordsCompanion(
      id: Value(id),
      patientId: Value(data.patientId),
      recordDate: Value(data.recordDate),
      chiefComplaintsJson: Value(data.chiefComplaintsJson),
      hpi: Value(data.hpiPackedJson),
      pastHistoryJson: Value(data.pastHistoryJson),
      familyHistoryJson: Value(data.familyHistoryJson),
      developmentalHistoryJson: Value(data.developmentalHistoryJson),
      physicalGeneralsJson: Value(data.physicalGeneralsJson),
      mentalGeneralsJson: Value(data.mentalGeneralsJson),
      lifestyleJson: Value(data.lifestyleJson),
      clinicalExamJson: Value(data.clinicalExamJson),
      miasmaticAnalysisJson: Value(data.miasmaticAnalysisJson),
      caseTotalityJson: Value(data.caseTotalityPackedJson),
      baselinePrescriptionJson: Value(data.baselinePrescriptionJson),
      investigationsJson: Value(data.investigationsJson),
      followUpNotes: Value(data.followUpPackedJson),
      outcome: Value(data.outcomePackedJson),
      updatedAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.patientCaseRecords).insertOnConflictUpdate(companion);
      await _syncComplaintsTable(data.patientId, data.chiefComplaints);
    });

    return id;
  }
}

final caseRecordNotifierProvider =
    StateNotifierProvider<CaseRecordNotifier, AsyncValue<void>>((ref) {
      final db = ref.watch(databaseProvider);
      return CaseRecordNotifier(db);
    });
