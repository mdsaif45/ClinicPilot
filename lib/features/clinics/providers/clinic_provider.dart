import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

// Stream of all active clinics (not soft-deleted)
final clinicsStreamProvider = StreamProvider<List<Clinic>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.clinics)..where((tbl) => tbl.isDeleted.equals(false)))
      .watch();
});

// Active Clinic ID notifier persisting selection to database settings
class ActiveClinicIdNotifier extends StateNotifier<String> {
  final AppDatabase _db;

  ActiveClinicIdNotifier(this._db) : super('clinic_old') {
    _loadFromSettings();
  }

  Future<void> _loadFromSettings() async {
    final query = _db.select(_db.settings)
      ..where((tbl) => tbl.key.equals('active_clinic_id'));
    final setting = await query.getSingleOrNull();
    if (setting != null && setting.value.isNotEmpty) {
      state = setting.value;
    }
  }

  Future<void> setClinicId(String newId) async {
    state = newId;
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'active_clinic_id',
            value: newId,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}

final activeClinicIdProvider =
    StateNotifierProvider<ActiveClinicIdNotifier, String>((ref) {
  final db = ref.watch(databaseProvider);
  return ActiveClinicIdNotifier(db);
});

// Active Clinic entity provider
final activeClinicProvider = Provider<Clinic?>((ref) {
  final clinicsAsync = ref.watch(clinicsStreamProvider);
  final activeId = ref.watch(activeClinicIdProvider);

  return clinicsAsync.when(
    data: (clinics) {
      if (clinics.isEmpty) return null;
      return clinics.firstWhere(
        (c) => c.id == activeId,
        orElse: () => clinics.first,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Clinic mutation notifier
class ClinicNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ClinicNotifier(this._db) : super(const AsyncData(null));

  Future<void> addClinic({
    required String id,
    required String name,
    String? address,
    String? phone,
    required double monthlyRent,
    required double defaultConsultationFee,
    required String openDays,
    required String colorHex,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.into(_db.clinics).insert(
            ClinicsCompanion.insert(
              id: id,
              name: name,
              address: Value(address),
              phone: Value(phone),
              monthlyRent: Value(monthlyRent),
              defaultConsultationFee: Value(defaultConsultationFee),
              openDays: Value(openDays),
              colorHex: Value(colorHex),
            ),
          );
    });
  }

  Future<void> updateClinic({
    required String id,
    required String name,
    String? address,
    String? phone,
    required double monthlyRent,
    required double defaultConsultationFee,
    required String openDays,
    required String colorHex,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.clinics)..where((tbl) => tbl.id.equals(id))).write(
        ClinicsCompanion(
          name: Value(name),
          address: Value(address),
          phone: Value(phone),
          monthlyRent: Value(monthlyRent),
          defaultConsultationFee: Value(defaultConsultationFee),
          openDays: Value(openDays),
          colorHex: Value(colorHex),
        ),
      );
    });
  }

  Future<void> archiveClinic(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.clinics)..where((tbl) => tbl.id.equals(id))).write(
        const ClinicsCompanion(
          isDeleted: Value(true),
          isActive: Value(false),
        ),
      );
    });
  }
}

final clinicNotifierProvider =
    StateNotifierProvider<ClinicNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return ClinicNotifier(db);
});
