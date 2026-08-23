import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/investigation_templates.dart';


final patientInvestigationsProvider =
    StreamProvider.family<List<Investigation>, String>((ref, patientId) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.investigations)
    ..where((t) => t.patientId.equals(patientId) & t.isDeleted.equals(false))
    ..orderBy([
      (t) => OrderingTerm.desc(t.testDate),
      (t) => OrderingTerm.desc(t.createdAt),
    ]);

  return query.watch();
});

final parameterTrendProvider = StreamProvider.family<
    List<Investigation>, ({String patientId, String testName})>((ref, arg) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.investigations)
    ..where((t) =>
        t.patientId.equals(arg.patientId) &
        t.testName.equals(arg.testName) &
        t.isDeleted.equals(false))
    ..orderBy([
      (t) => OrderingTerm.asc(t.testDate),
    ]);

  return query.watch();
});

class InvestigationNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  InvestigationNotifier(this._db) : super(const AsyncData(null));

  Future<String> addInvestigation({
    required String patientId,
    String? visitId,
    DateTime? testDate,
    String testCategory = 'Blood / Biochemistry',
    required String testName,
    double? numericValue,
    String? stringValue,
    String? unit,
    double? refRangeMin,
    double? refRangeMax,
    String? flag,
    String? labName,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();
    final computedFlag = flag ?? computeLabFlag(numericValue, refRangeMin, refRangeMax);

    final companion = InvestigationsCompanion.insert(
      id: id,
      patientId: patientId,
      visitId: Value(visitId),
      testDate: Value(testDate ?? now),
      testCategory: Value(testCategory),
      testName: testName.trim(),
      numericValue: Value(numericValue),
      stringValue: Value(stringValue?.trim()),
      unit: Value(unit?.trim()),
      refRangeMin: Value(refRangeMin),
      refRangeMax: Value(refRangeMax),
      flag: Value(computedFlag),
      labName: Value(labName?.trim()),
      notes: Value(notes?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.investigations).insert(companion);
    });

    return id;
  }

  Future<void> updateInvestigation({
    required String id,
    DateTime? testDate,
    String testCategory = 'Blood / Biochemistry',
    required String testName,
    double? numericValue,
    String? stringValue,
    String? unit,
    double? refRangeMin,
    double? refRangeMax,
    String? flag,
    String? labName,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    final computedFlag = flag ?? computeLabFlag(numericValue, refRangeMin, refRangeMax);

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.investigations)..where((t) => t.id.equals(id))).write(
        InvestigationsCompanion(
          testDate: testDate != null ? Value(testDate) : const Value.absent(),
          testCategory: Value(testCategory),
          testName: Value(testName.trim()),
          numericValue: Value(numericValue),
          stringValue: Value(stringValue?.trim()),
          unit: Value(unit?.trim()),
          refRangeMin: Value(refRangeMin),
          refRangeMax: Value(refRangeMax),
          flag: Value(computedFlag),
          labName: Value(labName?.trim()),
          notes: Value(notes?.trim()),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> deleteInvestigation(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.investigations)..where((t) => t.id.equals(id))).write(
        InvestigationsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }
}

final investigationNotifierProvider =
    StateNotifierProvider<InvestigationNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return InvestigationNotifier(db);
});
