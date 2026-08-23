import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

const kDoctorEmailKey = 'doctor_email';
const kDoctorPhoneKey = 'doctor_phone';
const kDoctorQualificationKey = 'doctor_qualification';
const kDoctorRegNumberKey = 'doctor_reg_number';

class DoctorProfile {
  final String name;
  final String email;
  final String phone;
  final String qualification;
  final String regNumber;

  const DoctorProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.qualification = '',
    this.regNumber = '',
  });

  DoctorProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? qualification,
    String? regNumber,
  }) {
    return DoctorProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      qualification: qualification ?? this.qualification,
      regNumber: regNumber ?? this.regNumber,
    );
  }
}

final doctorProfileStreamProvider = StreamProvider<DoctorProfile>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.settings)
        ..where((t) => t.key.isIn([
              kDoctorNameKey,
              kDoctorEmailKey,
              kDoctorPhoneKey,
              kDoctorQualificationKey,
              kDoctorRegNumberKey,
            ])))
      .watch()
      .map((rows) {
    String name = '';
    String email = '';
    String phone = '';
    String qualification = '';
    String regNumber = '';

    for (final row in rows) {
      if (row.key == kDoctorNameKey) name = row.value;
      if (row.key == kDoctorEmailKey) email = row.value;
      if (row.key == kDoctorPhoneKey) phone = row.value;
      if (row.key == kDoctorQualificationKey) qualification = row.value;
      if (row.key == kDoctorRegNumberKey) regNumber = row.value;
    }

    return DoctorProfile(
      name: name,
      email: email,
      phone: phone,
      qualification: qualification,
      regNumber: regNumber,
    );
  });
});

class DoctorProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  final Ref _ref;

  DoctorProfileNotifier(this._db, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required String name,
    String email = '',
    String phone = '',
    String qualification = '',
    String regNumber = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      await _db.transaction(() async {
        await _saveSetting(kDoctorNameKey, name.trim());
        await _saveSetting(kDoctorEmailKey, email.trim());
        await _saveSetting(kDoctorPhoneKey, phone.trim());
        await _saveSetting(kDoctorQualificationKey, qualification.trim());
        await _saveSetting(kDoctorRegNumberKey, regNumber.trim());
      });
      _ref.invalidate(doctorProfileStreamProvider);
      _ref.invalidate(doctorNameProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _saveSetting(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
  }
}

final doctorProfileNotifierProvider =
    StateNotifierProvider<DoctorProfileNotifier, AsyncValue<void>>((ref) {
  return DoctorProfileNotifier(ref.watch(databaseProvider), ref);
});
