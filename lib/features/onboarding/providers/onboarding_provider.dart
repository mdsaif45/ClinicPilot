import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const kDoctorNameKey = 'doctor_name';
const kOnboardingDoneKey = 'onboarding_complete';

/// Defaults offered on clinic setup.
const kDefaultRevenueGoal = 30000.0;
const kDefaultPatientGoal = 10;
const kDefaultRent = 5000.0;
const kDefaultConsultationFee = 300.0;
const kDefaultOpenDays = '1,2,3,4,5,6';

/// Doctor's name, shown in the dashboard greeting.
final doctorNameProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  final row =
      await (db.select(db.settings)
        ..where((t) => t.key.equals(kDoctorNameKey))).getSingleOrNull();
  return row?.value ?? '';
});

/// Whether the first-run flow still needs to be shown.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);

  final flag =
      await (db.select(db.settings)
        ..where((t) => t.key.equals(kOnboardingDoneKey))).getSingleOrNull();
  if (flag?.value == 'true') {
    try {
      if (Hive.isBoxOpen('settings')) {
        Hive.box('settings').put(kOnboardingDoneKey, true);
      }
    } catch (_) {}
    return true;
  }

  // An install that already holds clinics predates this flow.
  final clinics =
      await (db.select(db.clinics)
        ..where((t) => t.isDeleted.equals(false))).get();
  if (clinics.isNotEmpty) {
    await _write(db, kOnboardingDoneKey, 'true');
    try {
      if (Hive.isBoxOpen('settings')) {
        Hive.box('settings').put(kOnboardingDoneKey, true);
      }
    } catch (_) {}
    return true;
  }

  return false;
});

Future<void> _write(AppDatabase db, String key, String value) async {
  if (key == kOnboardingDoneKey) {
    try {
      if (Hive.isBoxOpen('settings')) {
        Hive.box('settings').put(kOnboardingDoneKey, value == 'true');
      }
    } catch (_) {}
  }
  await db
      .into(db.settings)
      .insertOnConflictUpdate(
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
  final String phone;
  final double rent;
  final double consultationFee;
  final String openDays;
  final double revenueGoal;
  final int patientGoal;

  const DraftClinic({
    required this.name,
    this.address = '',
    this.phone = '',
    this.rent = kDefaultRent,
    this.consultationFee = kDefaultConsultationFee,
    this.openDays = kDefaultOpenDays,
    this.revenueGoal = kDefaultRevenueGoal,
    this.patientGoal = kDefaultPatientGoal,
  });
}

class OnboardingController {
  final AppDatabase _db;
  final Ref _ref;

  const OnboardingController(this._db, this._ref);

  /// Writes everything the flow collected, then marks it done in one transaction.
  Future<void> complete({
    String? doctorFirstName,
    String? doctorLastName,
    String doctorName = '',
    String doctorEmail = '',
    String doctorPhone = '',
    String doctorQualification = '',
    String doctorRegNumber = '',
    required List<DraftClinic> clinics,
    double? revenueGoal,
    int? patientGoal,
  }) async {
    final fn = doctorFirstName?.trim() ?? '';
    final ln = doctorLastName?.trim() ?? '';
    var finalName = doctorName.trim();
    if (finalName.isEmpty) {
      if (fn.isNotEmpty && ln.isNotEmpty) {
        finalName = '$fn $ln';
      } else if (fn.isNotEmpty) {
        finalName = fn;
      } else if (ln.isNotEmpty) {
        finalName = 'Dr. $ln';
      }
    }

    await _db.transaction(() async {
      if (fn.isNotEmpty) await _write(_db, 'doctor_first_name', fn);
      if (ln.isNotEmpty) await _write(_db, 'doctor_last_name', ln);
      await _write(_db, kDoctorNameKey, finalName);
      if (doctorEmail.trim().isNotEmpty) {
        await _write(_db, 'doctor_email', doctorEmail.trim());
      }
      if (doctorPhone.trim().isNotEmpty) {
        await _write(_db, 'doctor_phone', doctorPhone.trim());
      }
      if (doctorQualification.trim().isNotEmpty) {
        await _write(_db, 'doctor_qualification', doctorQualification.trim());
      }
      if (doctorRegNumber.trim().isNotEmpty) {
        await _write(_db, 'doctor_reg_number', doctorRegNumber.trim());
      }

      String? firstId;
      for (final c in clinics) {
        if (c.name.trim().isEmpty) continue;
        final id = IdGenerator.generate();
        firstId ??= id;
        await _db
            .into(_db.clinics)
            .insert(
              ClinicsCompanion.insert(
                id: id,
                name: c.name.trim(),
                address: drift.Value(
                  c.address.trim().isEmpty ? null : c.address.trim(),
                ),
                phone: drift.Value(
                  c.phone.trim().isEmpty ? null : c.phone.trim(),
                ),
                monthlyRent: drift.Value(c.rent),
                defaultConsultationFee: drift.Value(c.consultationFee),
                openDays: drift.Value(c.openDays),
              ),
            );

        // Save clinic-level target goals
        await _write(
          _db,
          'monthly_revenue_goal_$id',
          c.revenueGoal.round().toString(),
        );
        await _write(
          _db,
          'monthly_new_patient_goal_$id',
          c.patientGoal.toString(),
        );
      }

      if (firstId != null) {
        await _write(_db, 'active_clinic_id', firstId);
        final first = clinics.firstWhere(
          (c) => c.name.trim().isNotEmpty,
          orElse: () => clinics.first,
        );
        await _write(
          _db,
          'monthly_revenue_goal',
          (revenueGoal ?? first.revenueGoal).round().toString(),
        );
        await _write(
          _db,
          'monthly_new_patient_goal',
          (patientGoal ?? first.patientGoal).toString(),
        );
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
