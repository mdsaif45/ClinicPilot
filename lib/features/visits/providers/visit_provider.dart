import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const _uuid = Uuid();

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
final patientVisitsStreamProvider =
    StreamProvider.family<List<VisitWithDetails>, String>((ref, patientId) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.visits).join([
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
  final query = db.select(db.visits).join([
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
    final countQuery = _db.select(_db.visits)
      ..where((tbl) => tbl.patientId.equals(patientId))
      ..where((tbl) => tbl.isDeleted.equals(false));
    final priorVisits = await countQuery.get();
    final visitType = priorVisits.isEmpty ? 'new' : 'repeat';

    final id = _uuid.v4();
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
      await (_db.update(_db.patients)..where((tbl) => tbl.id.equals(patientId)))
          .write(
        PatientsCompanion(
          primaryDisease: Value(disease),
          referralSource: Value(referralSource),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    state = const AsyncData(null);
    return await (_db.select(_db.visits)..where((tbl) => tbl.id.equals(id)))
        .getSingle();
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
      await (_db.update(_db.visits)..where((tbl) => tbl.id.equals(id))).write(
        const VisitsCompanion(isDeleted: Value(true)),
      );
    });
  }
}

final visitNotifierProvider =
    StateNotifierProvider<VisitNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return VisitNotifier(db);
});
