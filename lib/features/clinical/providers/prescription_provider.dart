import 'dart:convert';

import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/case_record_models.dart';

final patientPrescriptionsProvider =
    StreamProvider.family<List<Prescription>, String>((ref, patientId) {
      final db = ref.watch(databaseProvider);

      final query =
          db.select(db.prescriptions)
            ..where(
              (t) => t.patientId.equals(patientId) & t.isDeleted.equals(false),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.prescriptionDate),
              (t) => OrderingTerm.asc(t.remedyIndex),
            ]);

      return query.watch();
    });

final visitPrescriptionsProvider =
    StreamProvider.family<List<Prescription>, String>((ref, visitId) {
      final db = ref.watch(databaseProvider);

      final query =
          db.select(db.prescriptions)
            ..where(
              (t) => t.visitId.equals(visitId) & t.isDeleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.remedyIndex)]);

      return query.watch();
    });

class PrescriptionNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  PrescriptionNotifier(this._db) : super(const AsyncData(null));

  Future<void> _syncWithCaseRecord(String patientId) async {
    final activeBaselineRx =
        await (_db.select(_db.prescriptions)
              ..where(
                (t) =>
                    t.patientId.equals(patientId) &
                    t.isDeleted.equals(false) &
                    t.isBaseline.equals(true),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.remedyIndex),
                (t) => OrderingTerm.asc(t.createdAt),
              ]))
            .get();

    if (activeBaselineRx.isEmpty) return;

    final first = activeBaselineRx.first;
    final combinedRemedies = activeBaselineRx
        .map(
          (r) =>
              '${r.remedyName} ${r.potency} (${r.doseCount ?? ''} ${r.frequency ?? ''})'
                  .trim(),
        )
        .join('\n');

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
      final details = PrescriptionPlanDetails(
        remedyName: combinedRemedies,
        potency: first.potency,
        dose: first.doseCount ?? '',
        dietRegimenAdvice: first.dietaryAdvice ?? '',
        repetitionFrequency: first.frequency ?? '',
        pharmaceuticalForm: first.vehicle ?? '',
      );

      await (_db.update(_db.patientCaseRecords)
        ..where((t) => t.id.equals(existingCase.id))).write(
        PatientCaseRecordsCompanion(
          baselinePrescriptionJson: Value(jsonEncode(details.toJson())),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<String> addPrescription({
    required String patientId,
    String? visitId,
    DateTime? prescriptionDate,
    bool isBaseline = true,
    int remedyIndex = 1,
    required String remedyName,
    required String potency,
    String? doseCount,
    String? frequency,
    String? vehicle,
    String? durationDays,
    String? instructions,
    String? dietaryAdvice,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();

    final companion = PrescriptionsCompanion.insert(
      id: id,
      patientId: patientId,
      visitId: Value(visitId),
      prescriptionDate: Value(prescriptionDate ?? now),
      isBaseline: Value(isBaseline),
      remedyIndex: Value(remedyIndex),
      remedyName: remedyName.trim(),
      potency: potency.trim(),
      doseCount: Value(doseCount?.trim()),
      frequency: Value(frequency?.trim()),
      vehicle: Value(vehicle?.trim()),
      durationDays: Value(durationDays?.trim()),
      instructions: Value(instructions?.trim()),
      dietaryAdvice: Value(dietaryAdvice?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.prescriptions).insert(companion);
      if (isBaseline) {
        await _syncWithCaseRecord(patientId);
      }
    });

    return id;
  }

  Future<void> updatePrescription({
    required String id,
    int remedyIndex = 1,
    DateTime? prescriptionDate,
    bool? isBaseline,
    required String remedyName,
    required String potency,
    String? doseCount,
    String? frequency,
    String? vehicle,
    String? durationDays,
    String? instructions,
    String? dietaryAdvice,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing =
          await (_db.select(_db.prescriptions)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.prescriptions)
        ..where((t) => t.id.equals(id))).write(
        PrescriptionsCompanion(
          remedyIndex: Value(remedyIndex),
          prescriptionDate:
              prescriptionDate != null
                  ? Value(prescriptionDate)
                  : const Value.absent(),
          isBaseline:
              isBaseline != null ? Value(isBaseline) : const Value.absent(),
          remedyName: Value(remedyName.trim()),
          potency: Value(potency.trim()),
          doseCount: Value(doseCount?.trim()),
          frequency: Value(frequency?.trim()),
          vehicle: Value(vehicle?.trim()),
          durationDays: Value(durationDays?.trim()),
          instructions: Value(instructions?.trim()),
          dietaryAdvice: Value(dietaryAdvice?.trim()),
          updatedAt: Value(now),
        ),
      );
      if (existing != null &&
          ((existing.isBaseline ?? true) || (isBaseline ?? false))) {
        await _syncWithCaseRecord(existing.patientId);
      }
    });
  }

  Future<void> deletePrescription(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing =
          await (_db.select(_db.prescriptions)
            ..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.prescriptions)
        ..where((t) => t.id.equals(id))).write(
        PrescriptionsCompanion(
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

final prescriptionNotifierProvider =
    StateNotifierProvider<PrescriptionNotifier, AsyncValue<void>>((ref) {
      final db = ref.watch(databaseProvider);
      return PrescriptionNotifier(db);
    });
