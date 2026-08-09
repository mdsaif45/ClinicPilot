import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const _uuid = Uuid();

final patientSearchQueryProvider = StateProvider<String>((ref) => '');

final patientsStreamProvider = StreamProvider<List<Patient>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = ref.watch(patientSearchQueryProvider).trim().toLowerCase();

  var select = db.select(db.patients)
    ..where((tbl) => tbl.isDeleted.equals(false));

  if (query.isNotEmpty) {
    select = select
      ..where((tbl) =>
          tbl.name.lower().contains(query) |
          tbl.phone.contains(query) |
          tbl.patientCode.lower().contains(query) |
          tbl.primaryDisease.lower().contains(query) |
          tbl.referralSource.lower().contains(query));
  }

  return (select..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
});

class PatientNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  PatientNotifier(this._db) : super(const AsyncData(null));

  Future<Patient> registerPatient({
    required String name,
    required String phone,
    String? whatsapp,
    required int age,
    required String gender,
    String? area,
    String? address,
    String? occupation,
    required String primaryClinicId,
    required String disease,
    String? referralSource,
    String? notes,
  }) async {
    state = const AsyncLoading();

    // Generate patient code P-2026-00001
    final year = DateTime.now().year;
    final allPatients = await (_db.select(_db.patients)).get();
    final nextNum = (allPatients.length + 1).toString().padLeft(5, '0');
    final patientCode = 'P-$year-$nextNum';

    final patientId = _uuid.v4();
    final now = DateTime.now();

    final companion = PatientsCompanion.insert(
      id: patientId,
      patientCode: Value(patientCode),
      name: name,
      phone: phone,
      whatsapp: Value(whatsapp),
      age: age,
      gender: gender,
      area: Value(area),
      address: Value(address),
      occupation: Value(occupation),
      primaryClinicId: Value(primaryClinicId),
      primaryDisease: Value(disease),
      referralSource: Value(referralSource),
      notes: Value(notes),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.into(_db.patients).insert(companion);

    // Register initial visit (visitType = 'new')
    final visitId = _uuid.v4();
    await _db.into(_db.visits).insert(
          VisitsCompanion.insert(
            id: visitId,
            patientId: patientId,
            clinicId: primaryClinicId,
            visitType: 'new',
            consultationType: const Value('clinic'),
            disease: disease,
            referralSource: Value(referralSource),
            visitDate: now,
            createdAt: Value(now),
          ),
        );

    state = const AsyncData(null);
    return await (_db.select(_db.patients)
          ..where((tbl) => tbl.id.equals(patientId)))
        .getSingle();
  }

  Future<void> updatePatient({
    required String id,
    required String name,
    required String phone,
    String? whatsapp,
    required int age,
    required String gender,
    String? area,
    String? address,
    String? occupation,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.patients)..where((tbl) => tbl.id.equals(id))).write(
        PatientsCompanion(
          name: Value(name),
          phone: Value(phone),
          whatsapp: Value(whatsapp),
          age: Value(age),
          gender: Value(gender),
          area: Value(area),
          address: Value(address),
          occupation: Value(occupation),
          notes: Value(notes),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> archivePatient(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.patients)..where((tbl) => tbl.id.equals(id))).write(
        const PatientsCompanion(isDeleted: Value(true)),
      );
    });
  }
}

final patientNotifierProvider =
    StateNotifierProvider<PatientNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return PatientNotifier(db);
});
