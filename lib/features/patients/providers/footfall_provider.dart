import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../clinics/providers/clinic_provider.dart';


class FootfallWithDetails {
  final Footfall footfall;
  final Clinic clinic;
  final Patient? convertedPatient;

  const FootfallWithDetails({
    required this.footfall,
    required this.clinic,
    this.convertedPatient,
  });

  bool get isConverted => footfall.convertedPatientId != null;
}

class FootfallStats {
  final int totalCount;
  final int convertedCount;
  final int pendingCount;
  final double conversionRate;

  const FootfallStats({
    required this.totalCount,
    required this.convertedCount,
    required this.pendingCount,
    required this.conversionRate,
  });
}

final footfallsStreamProvider = StreamProvider<List<FootfallWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  final activeClinic = ref.watch(activeClinicProvider);

  final query = db.select(db.footfalls).join([
    innerJoin(
      db.clinics,
      db.clinics.id.equalsExp(db.footfalls.clinicId),
    ),
    leftOuterJoin(
      db.patients,
      db.patients.id.equalsExp(db.footfalls.convertedPatientId),
    ),
  ])
    ..where(db.footfalls.isDeleted.equals(false))
    ..orderBy([OrderingTerm.desc(db.footfalls.date)]);

  return query.watch().map((rows) {
    var items = rows.map((row) {
      return FootfallWithDetails(
        footfall: row.readTable(db.footfalls),
        clinic: row.readTable(db.clinics),
        convertedPatient: row.readTableOrNull(db.patients),
      );
    }).toList();

    if (activeClinic != null) {
      items = items.where((f) => f.footfall.clinicId == activeClinic.id).toList();
    }

    return items;
  });
});

final footfallStatsProvider = Provider<AsyncValue<FootfallStats>>((ref) {
  final footfallsAsync = ref.watch(footfallsStreamProvider);

  return footfallsAsync.whenData((list) {
    final total = list.length;
    final converted = list.where((f) => f.isConverted).length;
    final pending = total - converted;
    final rate = total > 0 ? (converted / total) * 100 : 0.0;

    return FootfallStats(
      totalCount: total,
      convertedCount: converted,
      pendingCount: pending,
      conversionRate: rate,
    );
  });
});

class FootfallNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  FootfallNotifier(this._db) : super(const AsyncData(null));

  Future<String> addFootfall({
    required String clinicId,
    required String name,
    String? phone,
    String? disease,
    String? notes,
    DateTime? date,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();

    final companion = FootfallsCompanion.insert(
      id: id,
      clinicId: clinicId,
      name: name.trim(),
      phone: Value((phone == null || phone.trim().isEmpty) ? null : phone.trim()),
      disease: Value((disease == null || disease.trim().isEmpty)
          ? null
          : Formatters.toTitleCase(disease.trim())),
      notes: Value((notes == null || notes.trim().isEmpty) ? null : notes.trim()),
      date: Value(date ?? now),
      createdAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.footfalls).insert(companion);
    });

    return id;
  }

  Future<void> convertFootfall({
    required String footfallId,
    required String patientId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.footfalls)..where((t) => t.id.equals(footfallId)))
          .write(FootfallsCompanion(
        convertedPatientId: Value(patientId),
      ));
    });
  }

  Future<void> deleteFootfall(String footfallId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.footfalls)..where((t) => t.id.equals(footfallId)))
          .write(const FootfallsCompanion(isDeleted: Value(true)));
    });
  }
}

final footfallNotifierProvider =
    StateNotifierProvider<FootfallNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return FootfallNotifier(db);
});
