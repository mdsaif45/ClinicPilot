import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';


final patientPrescriptionsProvider =
    StreamProvider.family<List<Prescription>, String>((ref, patientId) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.prescriptions)
    ..where((t) => t.patientId.equals(patientId) & t.isDeleted.equals(false))
    ..orderBy([
      (t) => OrderingTerm.desc(t.prescriptionDate),
      (t) => OrderingTerm.asc(t.remedyIndex),
    ]);

  return query.watch();
});

final visitPrescriptionsProvider =
    StreamProvider.family<List<Prescription>, String>((ref, visitId) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.prescriptions)
    ..where((t) => t.visitId.equals(visitId) & t.isDeleted.equals(false))
    ..orderBy([
      (t) => OrderingTerm.asc(t.remedyIndex),
    ]);

  return query.watch();
});

class PrescriptionNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  PrescriptionNotifier(this._db) : super(const AsyncData(null));

  Future<String> addPrescription({
    required String patientId,
    String? visitId,
    DateTime? prescriptionDate,
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
    });

    return id;
  }

  Future<void> updatePrescription({
    required String id,
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
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.prescriptions)..where((t) => t.id.equals(id))).write(
        PrescriptionsCompanion(
          remedyIndex: Value(remedyIndex),
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
    });
  }

  Future<void> deletePrescription(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.prescriptions)..where((t) => t.id.equals(id))).write(
        PrescriptionsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }
}

final prescriptionNotifierProvider =
    StateNotifierProvider<PrescriptionNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return PrescriptionNotifier(db);
});
