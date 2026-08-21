import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/case_record_models.dart';

const _uuid = Uuid();

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
      chiefComplaints: MasterCaseRecordData.parseChiefComplaints(row.chiefComplaintsJson),
      hpi: row.hpi ?? '',
      pastHistory: row.pastHistoryJson ?? '',
      familyHistory: row.familyHistoryJson ?? '',
      developmentalHistory: row.developmentalHistoryJson ?? '',
      physicalGenerals: MasterCaseRecordData.parsePhysicalGenerals(row.physicalGeneralsJson),
      mentalGenerals: MasterCaseRecordData.parseMentalGenerals(row.mentalGeneralsJson),
      lifestyleHabits: row.lifestyleJson ?? '',
      clinicalExam: MasterCaseRecordData.parseClinicalExam(row.clinicalExamJson),
      miasmaticAnalysis: MasterCaseRecordData.parseMiasmaticAnalysis(row.miasmaticAnalysisJson),
      caseTotality: MasterCaseRecordData.parseCaseTotality(row.caseTotalityJson),
      baselinePrescription: row.baselinePrescriptionJson ?? '',
      investigations: row.investigationsJson ?? '',
      followUpNotes: row.followUpNotes ?? '',
      outcome: row.outcome ?? 'Under Active Treatment',
    );
  });
});

class CaseRecordNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  CaseRecordNotifier(this._db) : super(const AsyncData(null));

  Future<String> saveCaseRecord(MasterCaseRecordData data) async {
    state = const AsyncLoading();
    final id = data.id ?? _uuid.v4();
    final now = DateTime.now();

    final companion = PatientCaseRecordsCompanion(
      id: Value(id),
      patientId: Value(data.patientId),
      recordDate: Value(data.recordDate),
      chiefComplaintsJson: Value(data.chiefComplaintsJson),
      hpi: Value(data.hpi),
      pastHistoryJson: Value(data.pastHistory),
      familyHistoryJson: Value(data.familyHistory),
      developmentalHistoryJson: Value(data.developmentalHistory),
      physicalGeneralsJson: Value(data.physicalGeneralsJson),
      mentalGeneralsJson: Value(data.mentalGeneralsJson),
      lifestyleJson: Value(data.lifestyleHabits),
      clinicalExamJson: Value(data.clinicalExamJson),
      miasmaticAnalysisJson: Value(data.miasmaticAnalysisJson),
      caseTotalityJson: Value(data.caseTotalityJson),
      baselinePrescriptionJson: Value(data.baselinePrescription),
      investigationsJson: Value(data.investigations),
      followUpNotes: Value(data.followUpNotes),
      outcome: Value(data.outcome),
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
