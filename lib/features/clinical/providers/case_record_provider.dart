import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/case_record_models.dart';


final patientCaseRecordProvider =
    StreamProvider.family<MasterCaseRecordData?, String>((ref, patientId) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.patientCaseRecords)
    ..where((t) => t.patientId.equals(patientId) & t.isDeleted.equals(false))
    ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
    ..limit(1);

  return query.watchSingleOrNull().map((row) {
    if (row == null) return null;
    return MasterCaseRecordData(
      id: row.id,
      patientId: row.patientId,
      recordDate: row.recordDate,
      identification: MasterCaseRecordData.parseIdentification(row.hpi),
      chiefComplaints: MasterCaseRecordData.parseChiefComplaints(row.chiefComplaintsJson),
      additionalComplaints: MasterCaseRecordData.parseAdditionalComplaints(row.hpi),
      hpi: MasterCaseRecordData.parseHpi(row.hpi),
      pastHistory: MasterCaseRecordData.parsePastHistory(row.pastHistoryJson),
      familyHistory: MasterCaseRecordData.parseFamilyHistory(row.familyHistoryJson),
      developmentalHistory: MasterCaseRecordData.parseDevHistory(row.developmentalHistoryJson),
      physicalGenerals: MasterCaseRecordData.parsePhysicalGenerals(row.physicalGeneralsJson),
      mentalGenerals: MasterCaseRecordData.parseMentalGenerals(row.mentalGeneralsJson),
      lifestyleHabits: MasterCaseRecordData.parseLifestyle(row.lifestyleJson),
      clinicalExam: MasterCaseRecordData.parseClinicalExam(row.clinicalExamJson),
      miasmaticAnalysis: MasterCaseRecordData.parseMiasmaticAnalysis(row.miasmaticAnalysisJson),
      caseTotality: MasterCaseRecordData.parseCaseTotality(row.caseTotalityJson),
      clinicalAssessment: MasterCaseRecordData.parseAssessment(row.caseTotalityJson),
      baselinePrescription: MasterCaseRecordData.parsePrescription(row.baselinePrescriptionJson),
      investigations: MasterCaseRecordData.parseInvestigations(row.investigationsJson),
      followUpDetails: MasterCaseRecordData.parseFollowUp(row.followUpNotes),
      followUpNotes: row.followUpNotes ?? '',
      outcomeDetails: MasterCaseRecordData.parseOutcome(row.outcome),
      outcome: row.outcome ?? 'Under Active Treatment',
      documentation: MasterCaseRecordData.parseDocumentation(row.hpi),
    );
  });
});

class CaseRecordNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  CaseRecordNotifier(this._db) : super(const AsyncData(null));

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
    });

    return id;
  }
}

final caseRecordNotifierProvider =
    StateNotifierProvider<CaseRecordNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return CaseRecordNotifier(db);
});