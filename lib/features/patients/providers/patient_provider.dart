import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const _uuid = Uuid();

// Stream of all patients from SQLite DB
final patientsStreamProvider = StreamProvider.autoDispose<List<Patient>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.patients)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();
});

// Real-time search query state
final patientSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// Filtered patients provider based on search query
final filteredPatientsProvider = Provider.autoDispose<AsyncValue<List<Patient>>>((ref) {
  final patientsAsync = ref.watch(patientsStreamProvider);
  final query = ref.watch(patientSearchQueryProvider).trim().toLowerCase();

  return patientsAsync.whenData((patients) {
    if (query.isEmpty) return patients;
    return patients.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.phone.contains(query) ||
          p.disease.toLowerCase().contains(query) ||
          p.referralSource.toLowerCase().contains(query);
    }).toList();
  });
});

// Patient repository notifier for actions
class PatientNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  PatientNotifier(this._db) : super(const AsyncValue.data(null));

  Future<bool> registerPatient({
    required String name,
    required String phone,
    required int age,
    required String gender,
    required String clinicId,
    required String disease,
    required String referralSource,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = _uuid.v4();
      await _db.into(_db.patients).insert(
            PatientsCompanion.insert(
              id: id,
              name: name,
              phone: phone,
              age: age,
              gender: gender,
              clinicId: clinicId,
              disease: disease,
              referralSource: referralSource,
            ),
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final patientNotifierProvider = StateNotifierProvider.autoDispose<PatientNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return PatientNotifier(db);
});
