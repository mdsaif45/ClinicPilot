import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

const kDoctorFirstNameKey = 'doctor_first_name';
const kDoctorLastNameKey = 'doctor_last_name';
const kDoctorEmailKey = 'doctor_email';
const kDoctorPhoneKey = 'doctor_phone';
const kDoctorQualificationKey = 'doctor_qualification';
const kDoctorRegNumberKey = 'doctor_reg_number';
const kDoctorSpecialtyKey = 'doctor_specialty';

enum ClinicalSpecialty {
  homeopathy(
    'homeopathy',
    'Homeopathy',
    'BHMS / MD (Hom.)',
    Icons.healing_outlined,
  ),
  generalPractice(
    'general_practice',
    'General Medicine',
    'MBBS / MD / Family Medicine',
    Icons.medical_services_outlined,
  ),
  dental(
    'dental',
    'Dentistry',
    'BDS / MDS / Dental Surgery',
    Icons.grid_view_rounded,
  ),
  ayurveda('ayurveda', 'Ayurveda', 'BAMS / MD (Ayu.)', Icons.eco_outlined),
  multiSpecialty(
    'multi_specialty',
    'Multi-Specialty / General OPD',
    'All clinical modules enabled',
    Icons.local_hospital_outlined,
  );

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;

  const ClinicalSpecialty(this.id, this.label, this.subtitle, this.icon);

  static ClinicalSpecialty fromId(
    String? rawId, {
    String? qualificationFallback,
  }) {
    if (rawId != null && rawId.isNotEmpty) {
      for (final s in ClinicalSpecialty.values) {
        if (s.id.toLowerCase() == rawId.toLowerCase() ||
            s.name.toLowerCase() == rawId.toLowerCase()) {
          return s;
        }
      }
    }

    // Smart fallback inference from qualification string
    if (qualificationFallback != null && qualificationFallback.isNotEmpty) {
      final q = qualificationFallback.toUpperCase();
      if (q.contains('BHMS') ||
          q.contains('HOMOE') ||
          q.contains('HOMEO') ||
          q.contains('H.M.B.S') ||
          q.contains('D.H.M.S') ||
          q.contains('DHMS')) {
        return ClinicalSpecialty.homeopathy;
      }
      if (q.contains('BDS') ||
          q.contains('MDS') ||
          q.contains('DENTAL') ||
          q.contains('DENTIST')) {
        return ClinicalSpecialty.dental;
      }
      if (q.contains('BAMS') ||
          q.contains('AYUR') ||
          q.contains('MD(AYU)') ||
          q.contains('MD (AYU)')) {
        return ClinicalSpecialty.ayurveda;
      }
      if (q.contains('MBBS') ||
          q.contains('M.B.B.S') ||
          q.contains('DNB') ||
          q.contains('PHYSICIAN') ||
          q.contains('GP')) {
        return ClinicalSpecialty.generalPractice;
      }
    }

    return ClinicalSpecialty.multiSpecialty;
  }
}

class DoctorProfile {
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String phone;
  final String qualification;
  final String regNumber;
  final ClinicalSpecialty specialty;

  const DoctorProfile({
    this.firstName = '',
    this.lastName = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.qualification = '',
    this.regNumber = '',
    this.specialty = ClinicalSpecialty.multiSpecialty,
  });

  bool get isHomeopathy => specialty == ClinicalSpecialty.homeopathy;
  bool get isDental => specialty == ClinicalSpecialty.dental;
  bool get isGeneralPractice => specialty == ClinicalSpecialty.generalPractice;
  bool get isAyurveda => specialty == ClinicalSpecialty.ayurveda;
  bool get isMultiSpecialty => specialty == ClinicalSpecialty.multiSpecialty;

  String get displayName {
    if (name.isNotEmpty) return name;
    if (lastName.isNotEmpty) {
      if (firstName.isNotEmpty) {
        return '$firstName $lastName';
      }
      return 'Dr. $lastName';
    }
    if (firstName.isNotEmpty) return firstName;
    return 'Doctor Profile';
  }

  String get greetingName {
    final ln =
        lastName
            .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
            .trim();
    if (ln.isNotEmpty) {
      return 'Dr. $ln';
    }
    final n =
        name
            .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
            .trim();
    if (n.isNotEmpty) {
      final parts = n.split(RegExp(r'\s+'));
      return 'Dr. ${parts.last}';
    }
    final fn =
        firstName
            .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
            .trim();
    if (fn.isNotEmpty) {
      return 'Dr. $fn';
    }
    return 'Doctor';
  }

  DoctorProfile copyWith({
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? phone,
    String? qualification,
    String? regNumber,
    ClinicalSpecialty? specialty,
  }) {
    return DoctorProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      qualification: qualification ?? this.qualification,
      regNumber: regNumber ?? this.regNumber,
      specialty: specialty ?? this.specialty,
    );
  }
}

final doctorProfileStreamProvider = StreamProvider<DoctorProfile>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.settings)..where(
    (t) => t.key.isIn([
      kDoctorFirstNameKey,
      kDoctorLastNameKey,
      kDoctorNameKey,
      kDoctorEmailKey,
      kDoctorPhoneKey,
      kDoctorQualificationKey,
      kDoctorRegNumberKey,
      kDoctorSpecialtyKey,
    ]),
  )).watch().map((rows) {
    String firstName = '';
    String lastName = '';
    String name = '';
    String email = '';
    String phone = '';
    String qualification = '';
    String regNumber = '';
    String rawSpecialty = '';

    for (final row in rows) {
      if (row.key == kDoctorFirstNameKey) firstName = row.value;
      if (row.key == kDoctorLastNameKey) lastName = row.value;
      if (row.key == kDoctorNameKey) name = row.value;
      if (row.key == kDoctorEmailKey) email = row.value;
      if (row.key == kDoctorPhoneKey) phone = row.value;
      if (row.key == kDoctorQualificationKey) qualification = row.value;
      if (row.key == kDoctorRegNumberKey) regNumber = row.value;
      if (row.key == kDoctorSpecialtyKey) rawSpecialty = row.value;
    }

    // Smart fallback if firstName / lastName were not set individually
    if (firstName.isEmpty && lastName.isEmpty && name.isNotEmpty) {
      final clean =
          name
              .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
              .trim();
      final parts = clean.split(RegExp(r'\s+'));
      if (parts.length > 1) {
        firstName = 'Dr. ${parts.sublist(0, parts.length - 1).join(' ')}';
        lastName = parts.last;
      } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
        firstName = 'Dr. ${parts.first}';
        lastName = '';
      }
    }

    if (name.isEmpty) {
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        name = '$firstName $lastName';
      } else if (firstName.isNotEmpty) {
        name = firstName;
      } else if (lastName.isNotEmpty) {
        name = 'Dr. $lastName';
      }
    }

    final specialty = ClinicalSpecialty.fromId(
      rawSpecialty,
      qualificationFallback: qualification,
    );

    return DoctorProfile(
      firstName: firstName,
      lastName: lastName,
      name: name,
      email: email,
      phone: phone,
      qualification: qualification,
      regNumber: regNumber,
      specialty: specialty,
    );
  });
});

class DoctorProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;
  final Ref _ref;

  DoctorProfileNotifier(this._db, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? name,
    String email = '',
    String phone = '',
    String qualification = '',
    String regNumber = '',
    ClinicalSpecialty? specialty,
  }) async {
    state = const AsyncValue.loading();
    try {
      final fn = firstName?.trim() ?? '';
      final ln = lastName?.trim() ?? '';
      var computedName = name?.trim() ?? '';
      if (computedName.isEmpty && (fn.isNotEmpty || ln.isNotEmpty)) {
        if (fn.isNotEmpty && ln.isNotEmpty) {
          computedName = '$fn $ln';
        } else if (fn.isNotEmpty) {
          computedName = fn;
        } else {
          computedName = 'Dr. $ln';
        }
      }

      await _db.transaction(() async {
        if (fn.isNotEmpty) await _saveSetting(kDoctorFirstNameKey, fn);
        if (ln.isNotEmpty) await _saveSetting(kDoctorLastNameKey, ln);
        await _saveSetting(kDoctorNameKey, computedName);
        await _saveSetting(kDoctorEmailKey, email.trim());
        await _saveSetting(kDoctorPhoneKey, phone.trim());
        await _saveSetting(kDoctorQualificationKey, qualification.trim());
        await _saveSetting(kDoctorRegNumberKey, regNumber.trim());
        if (specialty != null) {
          await _saveSetting(kDoctorSpecialtyKey, specialty.id);
        }
      });

      _ref.invalidate(doctorNameProvider);
      _ref.invalidate(doctorProfileStreamProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> _saveSetting(String key, String value) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
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
