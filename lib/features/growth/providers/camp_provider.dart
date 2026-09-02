import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class CampWithAnalytics {
  final Camp camp;
  final Clinic? clinic;
  final int patientsAcquiredCount;
  final double followUpRevenue;
  final double roi;
  final double netProfit;

  const CampWithAnalytics({
    required this.camp,
    this.clinic,
    required this.patientsAcquiredCount,
    required this.followUpRevenue,
    required this.roi,
    required this.netProfit,
  });
}

class CampStats {
  final int totalCamps;
  final double totalCost;
  final double totalFollowUpRevenue;
  final int totalPatientsAcquired;
  final double aggregateRoi;
  final double totalNetProfit;

  const CampStats({
    required this.totalCamps,
    required this.totalCost,
    required this.totalFollowUpRevenue,
    required this.totalPatientsAcquired,
    required this.aggregateRoi,
    required this.totalNetProfit,
  });
}

final campsStreamProvider = StreamProvider<List<CampWithAnalytics>>((ref) {
  final db = ref.watch(databaseProvider);
  final activeClinic = ref.watch(activeClinicProvider);

  // Watch camps, clinics, patients, and memos
  final campsQuery =
      db.select(db.camps)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.date)]);

  return campsQuery.watch().asyncMap((campsList) async {
    final clinics =
        await (db.select(db.clinics)
          ..where((t) => t.isDeleted.equals(false))).get();
    final clinicMap = {for (final c in clinics) c.id: c};

    final allPatients =
        await (db.select(db.patients)
          ..where((t) => t.isDeleted.equals(false))).get();
    final allMemos =
        await (db.select(db.cashMemos)
          ..where((t) => t.isDeleted.equals(false))).get();

    final result = <CampWithAnalytics>[];

    for (final camp in campsList) {
      if (activeClinic != null &&
          camp.clinicId != null &&
          camp.clinicId != activeClinic.id) {
        continue;
      }

      // Find patients whose referralSource or primaryDisease/notes mentions this camp
      final campNameLower = camp.name.toLowerCase().trim();
      final matchingPatients =
          allPatients.where((p) {
            final refSource = (p.referralSource ?? '').toLowerCase();
            final notes = (p.notes ?? '').toLowerCase();
            return refSource.contains(campNameLower) ||
                refSource.contains('camp') && notes.contains(campNameLower) ||
                p.primaryClinicId == camp.clinicId &&
                    p.createdAt.difference(camp.date).inDays.abs() <= 2 &&
                    refSource.contains('camp');
          }).toList();

      final patientIds = matchingPatients.map((p) => p.id).toSet();

      // Calculate follow-up revenue (memos within 90 days of camp date)
      double revenue = 0;
      for (final memo in allMemos) {
        if (patientIds.contains(memo.patientId)) {
          final diff = memo.memoDate.difference(camp.date).inDays;
          if (diff >= 0 && diff <= 90) {
            revenue += memo.paidAmount;
          }
        }
      }

      final cost = camp.cost;
      final roi =
          cost > 0
              ? ((revenue - cost) / cost) * 100
              : (revenue > 0 ? 100.0 : 0.0);
      final netProfit = revenue - cost;

      result.add(
        CampWithAnalytics(
          camp: camp,
          clinic: camp.clinicId != null ? clinicMap[camp.clinicId] : null,
          patientsAcquiredCount: matchingPatients.length,
          followUpRevenue: revenue,
          roi: roi,
          netProfit: netProfit,
        ),
      );
    }

    return result;
  });
});

final campStatsProvider = Provider<AsyncValue<CampStats>>((ref) {
  final campsAsync = ref.watch(campsStreamProvider);

  return campsAsync.whenData((list) {
    final totalCamps = list.length;
    double totalCost = 0;
    double totalRevenue = 0;
    int totalPatients = 0;

    for (final item in list) {
      totalCost += item.camp.cost;
      totalRevenue += item.followUpRevenue;
      totalPatients += item.patientsAcquiredCount;
    }

    final netProfit = totalRevenue - totalCost;
    final aggRoi =
        totalCost > 0 ? ((totalRevenue - totalCost) / totalCost) * 100 : 0.0;

    return CampStats(
      totalCamps: totalCamps,
      totalCost: totalCost,
      totalFollowUpRevenue: totalRevenue,
      totalPatientsAcquired: totalPatients,
      aggregateRoi: aggRoi,
      totalNetProfit: netProfit,
    );
  });
});

class CampNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  CampNotifier(this._db) : super(const AsyncData(null));

  Future<String> addCamp({
    required String name,
    required DateTime date,
    String? location,
    double cost = 0.0,
    int attendance = 0,
    String? clinicId,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();

    final companion = CampsCompanion.insert(
      id: id,
      name: name.trim(),
      date: Value(date),
      location: Value(
        location?.trim().isEmpty == true ? null : location?.trim(),
      ),
      cost: Value(cost),
      attendance: Value(attendance),
      clinicId: Value(clinicId),
      notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
      createdAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.camps).insert(companion);
    });

    return id;
  }

  Future<void> updateCamp({
    required String id,
    required String name,
    required DateTime date,
    String? location,
    double cost = 0.0,
    int attendance = 0,
    String? clinicId,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.camps)..where((t) => t.id.equals(id))).write(
        CampsCompanion(
          name: Value(name.trim()),
          date: Value(date),
          location: Value(
            location?.trim().isEmpty == true ? null : location?.trim(),
          ),
          cost: Value(cost),
          attendance: Value(attendance),
          clinicId: Value(clinicId),
          notes: Value(notes?.trim().isEmpty == true ? null : notes?.trim()),
        ),
      );
    });
  }

  Future<void> deleteCamp(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.camps)..where(
        (t) => t.id.equals(id),
      )).write(const CampsCompanion(isDeleted: Value(true)));
    });
  }
}

final campNotifierProvider =
    StateNotifierProvider<CampNotifier, AsyncValue<void>>((ref) {
      final db = ref.watch(databaseProvider);
      return CampNotifier(db);
    });
