import 'dart:convert';

import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/case_record_models.dart';
import '../models/investigation_templates.dart';

final patientInvestigationsProvider =
    StreamProvider.family<List<Investigation>, String>((ref, patientId) {
      final db = ref.watch(databaseProvider);

      final query =
          db.select(db.investigations)
            ..where(
              (t) => t.patientId.equals(patientId) & t.isDeleted.equals(false),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.testDate),
              (t) => OrderingTerm.desc(t.createdAt),
            ]);

      return query.watch();
    });

final parameterTrendProvider = StreamProvider.family<
  List<Investigation>,
  ({String patientId, String testName})
>((ref, arg) {
  final db = ref.watch(databaseProvider);

  final query =
      db.select(db.investigations)
        ..where(
          (t) =>
              t.patientId.equals(arg.patientId) &
              t.testName.equals(arg.testName) &
              t.isDeleted.equals(false),
        )
        ..orderBy([(t) => OrderingTerm.asc(t.testDate)]);

  return query.watch();
});

class InvestigationNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  InvestigationNotifier(this._db) : super(const AsyncData(null));

  static List<String> parseAttachments(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  static String? serializeAttachments(List<String> files) {
    final clean = files.where((f) => f.trim().isNotEmpty).toList();
    return clean.isEmpty ? null : jsonEncode(clean);
  }

  Future<void> _syncWithCaseRecord(String patientId) async {
    final activeBaselineTests =
        await (_db.select(_db.investigations)
              ..where(
                (t) =>
                    t.patientId.equals(patientId) &
                    t.isDeleted.equals(false) &
                    t.isBaseline.equals(true),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.testDate),
                (t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();

    if (activeBaselineTests.isEmpty) return;

    final first = activeBaselineTests.first;
    final combinedNames = activeBaselineTests.map((t) => t.testName).join(', ');
    final summary = activeBaselineTests
        .map(
          (t) =>
              '${t.testName}: ${t.stringValue ?? t.numericValue?.toString() ?? ''} ${t.unit ?? ''} (${t.flag})',
        )
        .join('; ');

    final existingCase =
        await (_db.select(_db.patientCaseRecords)
              ..where(
                (t) =>
                    t.patientId.equals(patientId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
              ..limit(1))
            .getSingleOrNull();

    if (existingCase != null) {
      final details = InvestigationsPlanDetails(
        investigationName: combinedNames,
        reportSummary: summary,
        resultValue:
            first.numericValue != null
                ? '${first.numericValue} ${first.unit ?? ''}'
                : (first.stringValue ?? ''),
        unit: first.unit ?? '',
        normalAbnormal: first.flag,
      );

      await (_db.update(_db.patientCaseRecords)
        ..where((t) => t.id.equals(existingCase.id))).write(
        PatientCaseRecordsCompanion(
          investigationsJson: Value(jsonEncode(details.toJson())),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<String> addInvestigation({
    required String patientId,
    String? visitId,
    DateTime? testDate,
    bool isBaseline = true,
    String testCategory = 'Blood / Biochemistry',
    required String testName,
    double? numericValue,
    String? stringValue,
    String? unit,
    double? refRangeMin,
    double? refRangeMax,
    String? flag,
    String? labName,
    List<String> reportAttachments = const [],
    String? notes,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();
    final computedFlag =
        flag ?? computeLabFlag(numericValue, refRangeMin, refRangeMax);

    final companion = InvestigationsCompanion.insert(
      id: id,
      patientId: patientId,
      visitId: Value(visitId),
      testDate: Value(testDate ?? now),
      isBaseline: Value(isBaseline),
      testCategory: Value(testCategory),
      testName: testName.trim(),
      numericValue: Value(numericValue),
      stringValue: Value(stringValue?.trim()),
      unit: Value(unit?.trim()),
      refRangeMin: Value(refRangeMin),
      refRangeMax: Value(refRangeMax),
      flag: Value(computedFlag),
      labName: Value(labName?.trim()),
      reportAttachments: Value(serializeAttachments(reportAttachments)),
      notes: Value(notes?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.investigations).insert(companion);
      if (isBaseline) {
        await _syncWithCaseRecord(patientId);
      }
    });

    return id;
  }

  Future<void> updateInvestigation({
    required String id,
    DateTime? testDate,
    bool? isBaseline,
    String testCategory = 'Blood / Biochemistry',
    required String testName,
    double? numericValue,
    String? stringValue,
    String? unit,
    double? refRangeMin,
    double? refRangeMax,
    String? flag,
    String? labName,
    List<String>? reportAttachments,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    final computedFlag =
        flag ?? computeLabFlag(numericValue, refRangeMin, refRangeMax);

    state = await AsyncValue.guard(() async {
      final existing =
          await (_db.select(_db.investigations)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.investigations)
        ..where((t) => t.id.equals(id))).write(
        InvestigationsCompanion(
          testDate: testDate != null ? Value(testDate) : const Value.absent(),
          isBaseline:
              isBaseline != null ? Value(isBaseline) : const Value.absent(),
          testCategory: Value(testCategory),
          testName: Value(testName.trim()),
          numericValue: Value(numericValue),
          stringValue: Value(stringValue?.trim()),
          unit: Value(unit?.trim()),
          refRangeMin: Value(refRangeMin),
          refRangeMax: Value(refRangeMax),
          flag: Value(computedFlag),
          labName: Value(labName?.trim()),
          reportAttachments:
              reportAttachments != null
                  ? Value(serializeAttachments(reportAttachments))
                  : const Value.absent(),
          notes: Value(notes?.trim()),
          updatedAt: Value(now),
        ),
      );
      if (existing != null &&
          ((existing.isBaseline ?? true) || (isBaseline ?? false))) {
        await _syncWithCaseRecord(existing.patientId);
      }
    });
  }

  Future<void> deleteInvestigation(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing =
          await (_db.select(_db.investigations)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.investigations)
        ..where((t) => t.id.equals(id))).write(
        InvestigationsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      if (existing != null && (existing.isBaseline ?? true)) {
        await _syncWithCaseRecord(existing.patientId);
      }
    });
  }
}

final investigationNotifierProvider =
    StateNotifierProvider<InvestigationNotifier, AsyncValue<void>>((ref) {
      final db = ref.watch(databaseProvider);
      return InvestigationNotifier(db);
    });
