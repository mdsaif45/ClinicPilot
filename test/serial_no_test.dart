import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/features/patients/providers/patient_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_clinics.dart';

/// Serial No. is a manual, per-clinic register number - unique per clinic
/// (two clinics can each have their own "1"), enforced both by a live check
/// the form uses to warn before saving and by the database itself, which
/// migration_test.dart covers on the schema side.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTestClinics(db);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<void> addPatient(String id, String serial, String clinicId) {
    return db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: id,
            patientCode: Value('P-$id'),
            name: 'Patient $id',
            phone: '9800000000',
            age: 30,
            gender: 'Male',
            primaryClinicId: Value(clinicId),
            serialNo: Value(serial),
          ),
        );
  }

  group('serialNoInUseProvider', () {
    test('reports false when nothing at the clinic has that serial', () async {
      final inUse = await container.read(
        serialNoInUseProvider(
          const SerialLookupArgs(clinicId: 'clinic_old', serialNo: '1'),
        ).future,
      );
      expect(inUse, isFalse);
    });

    test(
      'reports true once a patient at the clinic holds that serial',
      () async {
        await addPatient('p1', '14', 'clinic_old');

        final inUse = await container.read(
          serialNoInUseProvider(
            const SerialLookupArgs(clinicId: 'clinic_old', serialNo: '14'),
          ).future,
        );
        expect(inUse, isTrue);
      },
    );

    test('the same serial is free at a different clinic', () async {
      await addPatient('p1', '14', 'clinic_old');

      final inUse = await container.read(
        serialNoInUseProvider(
          const SerialLookupArgs(clinicId: 'clinic_new', serialNo: '14'),
        ).future,
      );
      expect(inUse, isFalse);
    });

    test('excludingPatientId lets a patient keep their own serial', () async {
      await addPatient('p1', '14', 'clinic_old');

      final inUse = await container.read(
        serialNoInUseProvider(
          const SerialLookupArgs(
            clinicId: 'clinic_old',
            serialNo: '14',
            excludingPatientId: 'p1',
          ),
        ).future,
      );
      expect(
        inUse,
        isFalse,
        reason:
            'checking a patient against their own existing serial '
            'must not flag it as taken',
      );
    });

    test('an empty serial is never reported as in use', () async {
      final inUse = await container.read(
        serialNoInUseProvider(
          const SerialLookupArgs(clinicId: 'clinic_old', serialNo: ''),
        ).future,
      );
      expect(inUse, isFalse);
    });
  });

  group('registerPatient', () {
    test('writes the given serial number onto the new patient', () async {
      final notifier = PatientNotifier(db);
      final patient = await notifier.registerPatient(
        name: 'Asha Rao',
        phone: '9800000001',
        age: 34,
        gender: 'Female',
        primaryClinicId: 'clinic_old',
        serialNo: '7',
        disease: 'Migraine',
      );
      expect(patient.serialNo, '7');
    });

    test(
      'a duplicate serial at the same clinic is rejected by the database',
      () async {
        final notifier = PatientNotifier(db);
        await notifier.registerPatient(
          name: 'Asha Rao',
          phone: '9800000001',
          age: 34,
          gender: 'Female',
          primaryClinicId: 'clinic_old',
          serialNo: '7',
          disease: 'Migraine',
        );

        await expectLater(
          notifier.registerPatient(
            name: 'Second Patient',
            phone: '9800000002',
            age: 40,
            gender: 'Male',
            primaryClinicId: 'clinic_old',
            serialNo: '7',
            disease: 'Cold',
          ),
          throwsA(anything),
          reason:
              'the unique index must reject this, not only the live '
              'check the form runs before submit',
        );
      },
    );
  });

  group('updatePatient', () {
    test('changes the serial number on an existing patient', () async {
      final notifier = PatientNotifier(db);
      final patient = await notifier.registerPatient(
        name: 'Asha Rao',
        phone: '9800000001',
        age: 34,
        gender: 'Female',
        primaryClinicId: 'clinic_old',
        serialNo: '7',
        disease: 'Migraine',
      );

      await notifier.updatePatient(
        id: patient.id,
        name: patient.name,
        phone: patient.phone,
        age: patient.age,
        gender: patient.gender,
        serialNo: '99',
      );

      final updated =
          await (db.select(db.patients)
            ..where((t) => t.id.equals(patient.id))).getSingle();
      expect(updated.serialNo, '99');
    });

    test('a rejected duplicate serial actually throws, not just logs to '
        'provider state', () async {
      final notifier = PatientNotifier(db);
      await notifier.registerPatient(
        name: 'Asha Rao',
        phone: '9800000001',
        age: 34,
        gender: 'Female',
        primaryClinicId: 'clinic_old',
        serialNo: '7',
        disease: 'Migraine',
      );
      final second = await notifier.registerPatient(
        name: 'Second Patient',
        phone: '9800000002',
        age: 40,
        gender: 'Male',
        primaryClinicId: 'clinic_old',
        serialNo: '8',
        disease: 'Cold',
      );

      // updatePatient uses AsyncValue.guard internally; without explicitly
      // rethrowing, a caller's try/catch (Edit Patient's _saveChanges) would
      // never see this and would report success on a write that failed.
      await expectLater(
        notifier.updatePatient(
          id: second.id,
          name: second.name,
          phone: second.phone,
          age: second.age,
          gender: second.gender,
          serialNo: '7',
        ),
        throwsA(anything),
      );
    });
  });
}
