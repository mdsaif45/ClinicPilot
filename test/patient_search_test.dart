import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_clinics.dart';
import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/features/patients/providers/patient_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> addPatient(String id, String code, String name, String phone,
      {bool deleted = false}) async {
    await db.into(db.patients).insert(PatientsCompanion.insert(
          id: id,
          patientCode: Value(code),
          name: name,
          phone: phone,
          age: 30,
          gender: 'Female',
          primaryClinicId: const Value('clinic_old'),
          isDeleted: Value(deleted),
        ));
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTestClinics(db);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await addPatient('p1', 'P-2026-00001', 'Fatima Begum', '9800000001');
    await addPatient('p2', 'P-2026-00002', 'Fatima Khatun', '9800000002');
    await addPatient('p3', 'P-2026-00003', 'Rahman Ali', '9800000003');
    await addPatient('p4', 'P-2026-00004', 'Deleted Person', '9800000004',
        deleted: true);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('empty query returns all active patients', () async {
    final r = await container.read(patientSearchProvider('').future);
    expect(r.length, 3);
  });

  test('soft-deleted patients never appear', () async {
    final r = await container.read(patientSearchProvider('').future);
    expect(r.any((e) => e.patient.id == 'p4'), isFalse);

    final byName = await container.read(patientSearchProvider('Deleted').future);
    expect(byName, isEmpty);
  });

  test('matches by name, case-insensitively', () async {
    final r = await container.read(patientSearchProvider('fatima').future);
    expect(r.length, 2);
  });

  test('same-named patients are distinguishable by code', () async {
    final r = await container.read(patientSearchProvider('Fatima').future);
    final codes = r.map((e) => e.patient.patientCode).toSet();
    expect(codes.length, 2, reason: 'each result must carry a unique code');
  });

  test('matches by phone', () async {
    final r = await container.read(patientSearchProvider('9800000003').future);
    expect(r.single.patient.name, 'Rahman Ali');
  });

  test('matches by patient code', () async {
    final r = await container.read(patientSearchProvider('P-2026-00002').future);
    expect(r.single.patient.id, 'p2');
  });

  test('unknown query returns empty, does not throw', () async {
    final r = await container.read(patientSearchProvider('zzzz').future);
    expect(r, isEmpty);
  });
}
