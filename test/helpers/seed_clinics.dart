import 'package:drift/drift.dart';

import 'package:clinic_pilot/core/database/app_database.dart';

/// Creates the clinics that tests reference by a fixed id.
///
/// The app used to seed these when the database was created. Onboarding now
/// creates clinics from what the doctor types, so a test inserting a visit or
/// memo against `clinic_old` has to make that row itself or trip the foreign
/// key.
Future<void> seedTestClinics(AppDatabase db) async {
  // Rents match what the app used to seed, since tests assert profit maths
  // against these figures.
  await db
      .into(db.clinics)
      .insertOnConflictUpdate(
        ClinicsCompanion.insert(
          id: 'clinic_old',
          name: 'Old Clinic',
          monthlyRent: const Value(3000.0),
          openDays: const Value('1,3,5'),
        ),
      );
  await db
      .into(db.clinics)
      .insertOnConflictUpdate(
        ClinicsCompanion.insert(
          id: 'clinic_new',
          name: 'New Clinic',
          monthlyRent: const Value(8000.0),
          openDays: const Value('2,4,6'),
        ),
      );
}
