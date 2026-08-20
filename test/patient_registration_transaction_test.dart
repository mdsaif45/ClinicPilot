import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/features/patients/providers/patient_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// registerPatient writes a patient row and its first visit row in two
/// separate inserts. Only the visit has a foreign key on clinic_id, so a bad
/// or missing clinic id let the patient save while the visit - and the whole
/// registration - failed after it: a patient with no visit, indistinguishable
/// in the list from one that registered correctly, backed by a dialog that
/// reported an error and never closed. This pins both inserts to one
/// transaction so a rejected clinic id leaves no row behind at all.
void main() {
  late AppDatabase db;
  late PatientNotifier notifier;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    notifier = PatientNotifier(db);
  });

  tearDown(() async => db.close());

  test('a clinic id that does not exist leaves no patient row behind',
      () async {
    await expectLater(
      notifier.registerPatient(
        name: 'Test Patient',
        phone: '9800000099',
        age: 30,
        gender: 'Male',
        primaryClinicId: 'no-such-clinic',
        disease: 'Test',
      ),
      throwsA(anything),
    );

    final patients = await db.select(db.patients).get();
    expect(patients, isEmpty,
        reason: 'the visit insert failed on the bad clinic id, so the '
            'patient half of the same registration must not survive it');

    final visits = await db.select(db.visits).get();
    expect(visits, isEmpty);
  });
}
