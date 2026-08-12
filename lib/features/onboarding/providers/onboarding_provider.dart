import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const kDoctorNameKey = 'doctor_name';
const kOnboardingDoneKey = 'onboarding_complete';

/// Defaults offered on the goals page.
///
/// Rs 30,000 is a deliberately reachable first milestone; the growth plan's
/// Rs 50,000 is the target after that. Ten new patients a month is the plan's
/// own stated goal, against the two to three the practice was managing.
const kDefaultRevenueGoal = 30000.0;
const kDefaultPatientGoal = 10;

const kRevenueGoalMin = 5000.0;
const kRevenueGoalMax = 200000.0;
const kPatientGoalMin = 1;
const kPatientGoalMax = 100;

/// Doctor's name, shown in the dashboard greeting.
final doctorNameProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  final row = await (db.select(db.settings)
        ..where((t) => t.key.equals(kDoctorNameKey)))
      .getSingleOrNull();
  return row?.value ?? '';
});

/// Whether the first-run flow still needs to be shown.
///
/// Keyed off an explicit flag rather than "are there any clinics", so a doctor
/// who deletes every clinic later is not dropped back into onboarding.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);

  final flag = await (db.select(db.settings)
        ..where((t) => t.key.equals(kOnboardingDoneKey)))
      .getSingleOrNull();
  if (flag?.value == 'true') return true;

  // An install that already holds clinics predates this flow. Treating it as
  // complete keeps existing data out of a setup wizard it does not need.
  final clinics = await (db.select(db.clinics)
        ..where((t) => t.isDeleted.equals(false)))
      .get();
  if (clinics.isNotEmpty) {
    await _write(db, kOnboardingDoneKey, 'true');
    return true;
  }

  return false;
});

Future<void> _write(AppDatabase db, String key, String value) {
  return db.into(db.settings).insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: key,
          value: value,
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
}

/// A clinic being described during onboarding, before it is written.
class DraftClinic {
  final String name;
  final String address;

  const DraftClinic({required this.name, this.address = ''});
}

class OnboardingController {
  final AppDatabase _db;
  final Ref _ref;

  const OnboardingController(this._db, this._ref);

  /// Writes everything the flow collected, then marks it done.
  ///
  /// One transaction: a half-finished setup would leave the app with a name
  /// but no clinic, and nothing to attribute a memo to.
  Future<void> complete({
    required String doctorName,
    required List<DraftClinic> clinics,
    required double revenueGoal,
    required int patientGoal,
  }) async {
    const uuid = Uuid();

    await _db.transaction(() async {
      await _write(_db, kDoctorNameKey, doctorName.trim());
      await _write(_db, 'monthly_revenue_goal',
          revenueGoal.round().toString());
      await _write(_db, 'monthly_new_patient_goal', patientGoal.toString());

      String? firstId;
      for (final c in clinics) {
        if (c.name.trim().isEmpty) continue;
        final id = uuid.v4();
        firstId ??= id;
        await _db.into(_db.clinics).insert(
              ClinicsCompanion.insert(
                id: id,
                name: c.name.trim(),
                address: drift.Value(
                    c.address.trim().isEmpty ? null : c.address.trim()),
              ),
            );
      }

      if (firstId != null) {
        await _write(_db, 'active_clinic_id', firstId);
      }

      await _write(_db, kOnboardingDoneKey, 'true');
    });

    _ref.invalidate(onboardingCompleteProvider);
    _ref.invalidate(doctorNameProvider);
  }
}

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref.watch(databaseProvider), ref);
});
