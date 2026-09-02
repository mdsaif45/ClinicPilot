import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/patient_export_service.dart';

final patientSearchQueryProvider = StateProvider<String>((ref) => '');

/// Whether a serial number is already used by another patient at the same
/// clinic - the same question the (clinic, serial_no) unique index enforces
/// at the database level, surfaced here so the form can say so before the
/// doctor taps Save rather than after a thrown constraint error.
///
/// [excludingPatientId] lets Edit Patient check a serial against every OTHER
/// patient at the clinic without the row being edited flagging itself.
class SerialLookupArgs {
  final String clinicId;
  final String serialNo;
  final String? excludingPatientId;

  const SerialLookupArgs({
    required this.clinicId,
    required this.serialNo,
    this.excludingPatientId,
  });

  @override
  bool operator ==(Object other) =>
      other is SerialLookupArgs &&
      other.clinicId == clinicId &&
      other.serialNo == serialNo &&
      other.excludingPatientId == excludingPatientId;

  @override
  int get hashCode => Object.hash(clinicId, serialNo, excludingPatientId);
}

final serialNoInUseProvider = FutureProvider.autoDispose.family<
  bool,
  SerialLookupArgs
>((ref, args) async {
  final db = ref.watch(databaseProvider);
  final trimmed = args.serialNo.trim();
  if (trimmed.isEmpty) return false;

  var query = db.select(db.patients)..where(
    (t) => t.primaryClinicId.equals(args.clinicId) & t.serialNo.equals(trimmed),
  );
  if (args.excludingPatientId != null) {
    query = query..where((t) => t.id.equals(args.excludingPatientId!).not());
  }

  final match = await query.getSingleOrNull();
  return match != null;
});

final patientByIdProvider = StreamProvider.family<Patient?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.patients)
    ..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
});

final patientsStreamProvider = StreamProvider<List<Patient>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = ref.watch(patientSearchQueryProvider).trim().toLowerCase();

  var select = db.select(db.patients)
    ..where((tbl) => tbl.isDeleted.equals(false));

  if (query.isNotEmpty) {
    select =
        select..where(
          (tbl) =>
              tbl.name.lower().contains(query) |
              tbl.phone.contains(query) |
              tbl.email.lower().contains(query) |
              tbl.patientCode.lower().contains(query) |
              tbl.serialNo.lower().contains(query) |
              tbl.primaryDisease.lower().contains(query) |
              tbl.referralSource.lower().contains(query),
        );
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
    String? email,
    required int age,
    required String gender,
    String? area,
    String? address,
    String? occupation,
    required String primaryClinicId,
    required String serialNo,
    required String disease,
    String? referralSource,
    String? notes,
    DateTime? entryDate,
    String consultationType = 'clinic',
  }) async {
    state = const AsyncLoading();

    final entry = entryDate ?? DateTime.now();

    // Generate patient code P-2026-00001
    final year = entry.year;
    final allPatients = await (_db.select(_db.patients)).get();
    final nextNum = (allPatients.length + 1).toString().padLeft(5, '0');
    final patientCode = 'P-$year-$nextNum';

    final effectiveSerial =
        serialNo.trim().isNotEmpty
            ? serialNo.trim()
            : (consultationType == 'online' ||
                    primaryClinicId == 'clinic_online'
                ? 'ONL-$nextNum'
                : nextNum);

    final patientId = IdGenerator.generate();

    final companion = PatientsCompanion.insert(
      id: patientId,
      patientCode: Value(patientCode),
      serialNo: Value(effectiveSerial),
      name: name,
      phone: phone,
      whatsapp: Value(whatsapp),
      email: Value(email),
      age: age,
      gender: gender,
      area: Value(area),
      address: Value(address),
      occupation: Value(occupation),
      primaryClinicId: Value(primaryClinicId),
      primaryDisease: Value(disease),
      referralSource: Value(referralSource),
      notes: Value(notes),
      createdAt: Value(entry),
      updatedAt: Value(DateTime.now()),
    );

    // One transaction: the patient row has no FK on clinic, only the visit
    // row does, so without a transaction a bad clinic id let the patient
    // save while the visit - and the whole registration - failed after it.
    await _db.transaction(() async {
      // Ensure virtual online clinic exists if registering an online patient
      if (primaryClinicId == 'clinic_online') {
        final existingOnline =
            await (_db.select(_db.clinics)
              ..where((c) => c.id.equals('clinic_online'))).getSingleOrNull();
        if (existingOnline == null) {
          await _db
              .into(_db.clinics)
              .insertOnConflictUpdate(
                ClinicsCompanion.insert(
                  id: 'clinic_online',
                  name: 'Online / Teleconsultation',
                  address: const Value('Digital / Remote Practice'),
                  phone: const Value(''),
                  defaultConsultationFee: const Value(300.0),
                  monthlyRent: const Value(0.0),
                  openDays: const Value('1,2,3,4,5,6,7'),
                  colorHex: const Value('#7C3AED'),
                ),
              );
        }
      }

      await _db.into(_db.patients).insert(companion);

      // Register initial visit (visitType = 'new')
      final visitId = IdGenerator.generate();
      await _db
          .into(_db.visits)
          .insert(
            VisitsCompanion.insert(
              id: visitId,
              patientId: patientId,
              clinicId: primaryClinicId,
              visitType: 'new',
              consultationType: Value(consultationType),
              disease: disease,
              referralSource: Value(referralSource),
              visitDate: entry,
              createdAt: Value(entry),
            ),
          );
    });

    state = const AsyncData(null);
    return await (_db.select(_db.patients)
      ..where((tbl) => tbl.id.equals(patientId))).getSingle();
  }

  Future<void> updatePatient({
    required String id,
    required String name,
    required String phone,
    String? whatsapp,
    String? email,
    required int age,
    required String gender,
    String? area,
    String? address,
    String? occupation,
    String? notes,
    required String serialNo,
    DateTime? createdAt,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await (_db.update(_db.patients)..where((tbl) => tbl.id.equals(id))).write(
        PatientsCompanion(
          name: Value(name),
          phone: Value(phone),
          whatsapp: Value(whatsapp),
          email: Value(email),
          age: Value(age),
          gender: Value(gender),
          area: Value(area),
          address: Value(address),
          occupation: Value(occupation),
          notes: Value(notes),
          serialNo: Value(serialNo),
          createdAt:
              createdAt != null ? Value(createdAt) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
    state = result;

    // AsyncValue.guard captures a thrown error into state rather than
    // letting it propagate - correct for a screen just watching this
    // notifier's state, but Edit Patient's own try/catch around this call
    // needs the exception itself (e.g. a duplicate serial number rejected by
    // the unique index) to show the right message and re-enable its button.
    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Records that a Google review was requested, and whether the patient said
  /// they left one. The app cannot verify publication - only that the ask
  /// happened, which is the part the doctor controls.
  Future<void> setReviewStatus({
    required String patientId,
    required bool asked,
    required bool given,
  }) async {
    await (_db.update(_db.patients)
      ..where((t) => t.id.equals(patientId))).write(
      PatientsCompanion(
        reviewAskedAt: Value(asked ? DateTime.now() : null),
        reviewGiven: Value(given),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> archivePatient(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.patients)..where(
        (tbl) => tbl.id.equals(id),
      )).write(const PatientsCompanion(isDeleted: Value(true)));
    });
  }

  Future<void> restorePatient(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.patients)..where(
        (tbl) => tbl.id.equals(id),
      )).write(const PatientsCompanion(isDeleted: Value(false)));
    });
  }
}

final patientNotifierProvider =
    StateNotifierProvider<PatientNotifier, AsyncValue<void>>((ref) {
      final db = ref.watch(databaseProvider);
      return PatientNotifier(db);
    });

/// A patient plus the fields needed to tell two same-named people apart.
class PatientSearchResult {
  final Patient patient;
  final DateTime? lastVisitDate;
  final int visitCount;

  const PatientSearchResult({
    required this.patient,
    this.lastVisitDate,
    this.visitCount = 0,
  });
}

/// Searches patients for the picker.
///
/// An empty query returns the most recently seen patients, because the next
/// memo is nearly always for someone just consulted. Filtering happens in SQL
/// with a LIMIT so this stays constant-cost as the patient list grows — never
/// load every patient into memory and filter in Dart.
final patientSearchProvider = FutureProvider.autoDispose
    .family<List<PatientSearchResult>, String>((ref, query) async {
      final db = ref.watch(databaseProvider);
      final q = query.trim().toLowerCase();
      const limit = 50;

      final rows =
          await db
              .customSelect(
                '''
    SELECT p.*,
           MAX(v.visit_date) AS last_visit,
           COUNT(v.id)       AS visit_count
    FROM patients p
    LEFT JOIN visits v ON v.patient_id = p.id AND v.is_deleted = 0
    WHERE p.is_deleted = 0
      AND (
        ?1 = ''
        OR LOWER(p.name)         LIKE '%' || ?1 || '%'
        OR LOWER(p.phone)        LIKE '%' || ?1 || '%'
        OR LOWER(p.patient_code) LIKE '%' || ?1 || '%'
        OR LOWER(p.serial_no)    LIKE '%' || ?1 || '%'
      )
    GROUP BY p.id
    ORDER BY last_visit DESC NULLS LAST, p.created_at DESC
    LIMIT $limit
    ''',
                variables: [Variable<String>(q)],
                readsFrom: {db.patients, db.visits},
              )
              .get();

      return rows.map((row) {
        final lastVisitRaw = row.data['last_visit'] as int?;
        return PatientSearchResult(
          patient: db.patients.map(row.data),
          lastVisitDate:
              lastVisitRaw == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(lastVisitRaw * 1000),
          visitCount: (row.data['visit_count'] as int?) ?? 0,
        );
      }).toList();
    });

/// Rich aggregated patient data provider for complete exports across CSV, XLSX, and PDF.
final patientExportRowsProvider =
    FutureProvider.autoDispose<List<PatientExportRow>>((ref) async {
      final db = ref.watch(databaseProvider);
      return PatientExportService.fetchPatientExportRows(db);
    });
