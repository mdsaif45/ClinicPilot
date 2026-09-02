import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

class VisitWithDetails {
  final Visit visit;
  final Patient patient;
  final Clinic clinic;

  const VisitWithDetails({
    required this.visit,
    required this.patient,
    required this.clinic,
  });
}

// Stream of visits for a specific patient sorted descending by date
final patientVisitsStreamProvider = StreamProvider.family<
  List<VisitWithDetails>,
  String
>((ref, patientId) {
  final db = ref.watch(databaseProvider);
  final query =
      db.select(db.visits).join([
          innerJoin(db.patients, db.patients.id.equalsExp(db.visits.patientId)),
          innerJoin(db.clinics, db.clinics.id.equalsExp(db.visits.clinicId)),
        ])
        ..where(db.visits.patientId.equals(patientId))
        ..where(db.visits.isDeleted.equals(false))
        ..orderBy([OrderingTerm.desc(db.visits.visitDate)]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return VisitWithDetails(
        visit: row.readTable(db.visits),
        patient: row.readTable(db.patients),
        clinic: row.readTable(db.clinics),
      );
    }).toList();
  });
});

// All visits stream
final visitsStreamProvider = StreamProvider<List<VisitWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  final query =
      db.select(db.visits).join([
          innerJoin(db.patients, db.patients.id.equalsExp(db.visits.patientId)),
          innerJoin(db.clinics, db.clinics.id.equalsExp(db.visits.clinicId)),
        ])
        ..where(db.visits.isDeleted.equals(false))
        ..orderBy([OrderingTerm.desc(db.visits.visitDate)]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return VisitWithDetails(
        visit: row.readTable(db.visits),
        patient: row.readTable(db.patients),
        clinic: row.readTable(db.clinics),
      );
    }).toList();
  });
});

class VisitNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  VisitNotifier(this._db) : super(const AsyncData(null));

  // Add visit: automatically computes visitType ('new' if 0 prior visits, else 'repeat')
  Future<Visit> addVisit({
    required String patientId,
    required String clinicId,
    required String disease,
    String? chiefComplaint,
    String? referralSource,
    String consultationType = 'clinic',
    String? outcome,
    required DateTime visitDate,
    DateTime? nextFollowUpDate,
    String? notes,
  }) async {
    state = const AsyncLoading();

    // Compute visitType: 'new' if patient has zero prior visits, else 'repeat'
    final countQuery =
        _db.select(_db.visits)
          ..where((tbl) => tbl.patientId.equals(patientId))
          ..where((tbl) => tbl.isDeleted.equals(false));
    final priorVisits = await countQuery.get();
    final visitType = priorVisits.isEmpty ? 'new' : 'repeat';

    final id = IdGenerator.generate();
    final companion = VisitsCompanion.insert(
      id: id,
      patientId: patientId,
      clinicId: clinicId,
      visitType: visitType,
      consultationType: Value(consultationType),
      disease: disease,
      chiefComplaint: Value(chiefComplaint),
      referralSource: Value(referralSource),
      outcome: Value(outcome),
      visitDate: visitDate,
      nextFollowUpDate: Value(nextFollowUpDate),
      notes: Value(notes),
    );

    await _db.into(_db.visits).insert(companion);

    // If it's a new visit, update patient's primary disease and referral source if unassigned
    if (visitType == 'new') {
      await (_db.update(_db.patients)
        ..where((tbl) => tbl.id.equals(patientId))).write(
        PatientsCompanion(
          primaryDisease: Value(disease),
          referralSource: Value(referralSource),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    state = const AsyncData(null);
    return await (_db.select(_db.visits)
      ..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<void> updateVisit({
    required String id,
    required String disease,
    String? chiefComplaint,
    String? referralSource,
    String? outcome,
    required DateTime visitDate,
    DateTime? nextFollowUpDate,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.visits)..where((tbl) => tbl.id.equals(id))).write(
        VisitsCompanion(
          disease: Value(disease),
          chiefComplaint: Value(chiefComplaint),
          referralSource: Value(referralSource),
          outcome: Value(outcome),
          visitDate: Value(visitDate),
          nextFollowUpDate: Value(nextFollowUpDate),
          notes: Value(notes),
        ),
      );
    });
  }

  Future<void> archiveVisit(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.visits)..where(
        (tbl) => tbl.id.equals(id),
      )).write(const VisitsCompanion(isDeleted: Value(true)));
    });
  }

  Future<void> scheduleFollowUp({
    required String patientId,
    required DateTime nextFollowUpDate,
    String? reason,
    String? disease,
    String? clinicId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final latestVisits =
          await (_db.select(_db.visits)
                ..where((tbl) => tbl.patientId.equals(patientId))
                ..where((tbl) => tbl.isDeleted.equals(false))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.visitDate)]))
              .get();

      if (latestVisits.isNotEmpty) {
        final targetVisit = latestVisits.first;
        final updatedNotes =
            reason != null && reason.trim().isNotEmpty
                ? (targetVisit.notes != null && targetVisit.notes!.isNotEmpty
                    ? '${targetVisit.notes}\n[Follow-up Note: ${reason.trim()}]'
                    : 'Follow-up Note: ${reason.trim()}')
                : targetVisit.notes;

        await (_db.update(_db.visits)
          ..where((tbl) => tbl.id.equals(targetVisit.id))).write(
          VisitsCompanion(
            nextFollowUpDate: Value(nextFollowUpDate),
            notes: Value(updatedNotes),
          ),
        );
      } else {
        final defaultClinics = await _db.select(_db.clinics).get();
        final finalClinicId =
            clinicId ?? (defaultClinics.firstOrNull?.id ?? 'default');
        final finalDisease =
            (disease != null && disease.isNotEmpty)
                ? disease
                : 'General Consultation';
        final id = IdGenerator.generate();

        await _db
            .into(_db.visits)
            .insert(
              VisitsCompanion.insert(
                id: id,
                patientId: patientId,
                clinicId: finalClinicId,
                visitType: 'new',
                disease: finalDisease,
                visitDate: DateTime.now(),
                nextFollowUpDate: Value(nextFollowUpDate),
                notes: Value(reason),
              ),
            );
      }
    });
  }
}

final visitNotifierProvider =
    StateNotifierProvider<VisitNotifier, AsyncValue<void>>((ref) {
      final db = ref.watch(databaseProvider);
      return VisitNotifier(db);
    });
