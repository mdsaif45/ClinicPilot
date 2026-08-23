import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';


final patientComplaintsProvider =
    StreamProvider.family<List<Complaint>, String>((ref, patientId) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.complaints)
    ..where((t) => t.patientId.equals(patientId) & t.isDeleted.equals(false))
    ..orderBy([
      (t) => OrderingTerm.asc(t.complaintIndex),
      (t) => OrderingTerm.asc(t.createdAt),
    ]);

  return query.watch();
});

class ComplaintNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ComplaintNotifier(this._db) : super(const AsyncData(null));

  Future<String> addComplaint({
    required String patientId,
    String? visitId,
    int complaintIndex = 1,
    required String complaintName,
    String? location,
    String? side,
    String? onset,
    String? duration,
    String? sensation,
    String? extension,
    String? aggravatingFactors,
    String? amelioratingFactors,
    String? concomitants,
    String? causation,
    String? periodicity,
    int severity = 5,
    String status = 'Active',
    String? notes,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();

    final companion = ComplaintsCompanion.insert(
      id: id,
      patientId: patientId,
      visitId: Value(visitId),
      complaintIndex: Value(complaintIndex),
      complaintName: complaintName.trim(),
      location: Value(location?.trim()),
      side: Value(side),
      onset: Value(onset?.trim()),
      duration: Value(duration?.trim()),
      sensation: Value(sensation?.trim()),
      extension: Value(extension?.trim()),
      aggravatingFactors: Value(aggravatingFactors?.trim()),
      amelioratingFactors: Value(amelioratingFactors?.trim()),
      concomitants: Value(concomitants?.trim()),
      causation: Value(causation?.trim()),
      periodicity: Value(periodicity?.trim()),
      severity: Value(severity),
      status: Value(status),
      notes: Value(notes?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.complaints).insert(companion);
    });

    return id;
  }

  Future<void> updateComplaint({
    required String id,
    required String complaintName,
    int complaintIndex = 1,
    String? location,
    String? side,
    String? onset,
    String? duration,
    String? sensation,
    String? extension,
    String? aggravatingFactors,
    String? amelioratingFactors,
    String? concomitants,
    String? causation,
    String? periodicity,
    int severity = 5,
    String status = 'Active',
    String? notes,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.complaints)..where((t) => t.id.equals(id))).write(
        ComplaintsCompanion(
          complaintName: Value(complaintName.trim()),
          complaintIndex: Value(complaintIndex),
          location: Value(location?.trim()),
          side: Value(side),
          onset: Value(onset?.trim()),
          duration: Value(duration?.trim()),
          sensation: Value(sensation?.trim()),
          extension: Value(extension?.trim()),
          aggravatingFactors: Value(aggravatingFactors?.trim()),
          amelioratingFactors: Value(amelioratingFactors?.trim()),
          concomitants: Value(concomitants?.trim()),
          causation: Value(causation?.trim()),
          periodicity: Value(periodicity?.trim()),
          severity: Value(severity),
          status: Value(status),
          notes: Value(notes?.trim()),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> updateStatus(String id, String status) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.complaints)..where((t) => t.id.equals(id))).write(
        ComplaintsCompanion(
          status: Value(status),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> deleteComplaint(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      await (_db.update(_db.complaints)..where((t) => t.id.equals(id))).write(
        ComplaintsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }
}

final complaintNotifierProvider =
    StateNotifierProvider<ComplaintNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return ComplaintNotifier(db);
});
