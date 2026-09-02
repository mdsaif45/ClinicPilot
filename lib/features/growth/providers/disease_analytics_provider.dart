import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/providers/period_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class DiseaseStat {
  final String disease;
  final int patientCount;
  final int visitCount;
  final double totalRevenue;
  final int repeatPatients;
  final double repeatRate;
  final double avgRevenuePerPatient;

  const DiseaseStat({
    required this.disease,
    required this.patientCount,
    required this.visitCount,
    required this.totalRevenue,
    required this.repeatPatients,
    required this.repeatRate,
    required this.avgRevenuePerPatient,
  });
}

class DiseaseAnalyticsSummary {
  final int totalConditions;
  final String topRevenueDisease;
  final double topRevenueAmount;
  final String topVolumeDisease;
  final int topVolumeCount;
  final double totalRevenue;
  final List<DiseaseStat> stats;

  const DiseaseAnalyticsSummary({
    required this.totalConditions,
    required this.topRevenueDisease,
    required this.topRevenueAmount,
    required this.topVolumeDisease,
    required this.topVolumeCount,
    required this.totalRevenue,
    required this.stats,
  });
}

final diseaseAnalyticsProvider = Provider<AsyncValue<DiseaseAnalyticsSummary>>((
  ref,
) {
  final period = ref.watch(periodProvider);
  final activeClinic = ref.watch(activeClinicProvider);

  final range = period.dateRange;

  return ref.watch(_rawDiseaseDataProvider).whenData((data) {
    final visits =
        data.visits.where((v) {
          final inRange =
              !v.visitDate.isBefore(range.start) &&
              !v.visitDate.isAfter(range.end);
          final inClinic =
              activeClinic == null || v.clinicId == activeClinic.id;
          return inRange && inClinic;
        }).toList();

    final memos =
        data.memos.where((m) {
          final inRange =
              !m.memoDate.isBefore(range.start) &&
              !m.memoDate.isAfter(range.end);
          final inClinic =
              activeClinic == null || m.clinicId == activeClinic.id;
          return inRange && inClinic;
        }).toList();

    final patientMap = {for (final p in data.patients) p.id: p};

    // Patient visits per disease
    final diseaseToPatients = <String, Set<String>>{};
    final diseaseToVisits = <String, int>{};
    final diseaseToRepeatPatients = <String, Set<String>>{};
    final patientVisitCounts =
        <String, Map<String, int>>{}; // disease -> patientId -> count

    for (final v in visits) {
      final disease =
          (v.disease.trim().isEmpty
              ? 'General Consultation'
              : v.disease.trim());
      diseaseToPatients.putIfAbsent(disease, () => <String>{}).add(v.patientId);
      diseaseToVisits[disease] = (diseaseToVisits[disease] ?? 0) + 1;

      final pCounts = patientVisitCounts.putIfAbsent(
        disease,
        () => <String, int>{},
      );
      pCounts[v.patientId] = (pCounts[v.patientId] ?? 0) + 1;
      if (pCounts[v.patientId]! > 1 || v.visitType.toLowerCase() == 'repeat') {
        diseaseToRepeatPatients
            .putIfAbsent(disease, () => <String>{})
            .add(v.patientId);
      }
    }

    // Revenue per disease from memos
    final diseaseToRevenue = <String, double>{};
    for (final m in memos) {
      final p = patientMap[m.patientId];
      final primary = p?.primaryDisease;
      final disease =
          (primary != null && primary.trim().isNotEmpty)
              ? primary.trim()
              : 'General Consultation';
      diseaseToRevenue[disease] =
          (diseaseToRevenue[disease] ?? 0.0) + m.paidAmount;
    }

    // Combine all unique diseases
    final allDiseases = <String>{
      ...diseaseToPatients.keys,
      ...diseaseToRevenue.keys,
    };

    final statsList = <DiseaseStat>[];
    for (final d in allDiseases) {
      final pCount =
          diseaseToPatients[d]?.length ??
          (patientMap.values.where((p) => p.primaryDisease == d).length);
      final vCount = diseaseToVisits[d] ?? pCount;
      final rev = diseaseToRevenue[d] ?? 0.0;
      final repCount = diseaseToRepeatPatients[d]?.length ?? 0;
      final repRate = pCount > 0 ? (repCount / pCount) * 100 : 0.0;
      final avgRev = pCount > 0 ? rev / pCount : 0.0;

      statsList.add(
        DiseaseStat(
          disease: d,
          patientCount: pCount,
          visitCount: vCount,
          totalRevenue: rev,
          repeatPatients: repCount,
          repeatRate: repRate,
          avgRevenuePerPatient: avgRev,
        ),
      );
    }

    statsList.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final totalRev = statsList.fold<double>(
      0.0,
      (sum, s) => sum + s.totalRevenue,
    );
    final topRev = statsList.isNotEmpty ? statsList.first : null;

    final byVolume = [...statsList]
      ..sort((a, b) => b.patientCount.compareTo(a.patientCount));
    final topVol = byVolume.isNotEmpty ? byVolume.first : null;

    return DiseaseAnalyticsSummary(
      totalConditions: statsList.length,
      topRevenueDisease: topRev?.disease ?? '—',
      topRevenueAmount: topRev?.totalRevenue ?? 0.0,
      topVolumeDisease: topVol?.disease ?? '—',
      topVolumeCount: topVol?.patientCount ?? 0,
      totalRevenue: totalRev,
      stats: statsList,
    );
  });
});

final _rawDiseaseDataProvider = StreamProvider<
  ({List<Visit> visits, List<CashMemo> memos, List<Patient> patients})
>((ref) {
  final db = ref.watch(databaseProvider);

  final visitsStream =
      (db.select(db.visits)..where((t) => t.isDeleted.equals(false))).watch();

  return visitsStream.asyncMap((visits) async {
    final memos =
        await (db.select(db.cashMemos)
          ..where((t) => t.isDeleted.equals(false))).get();
    final patients =
        await (db.select(db.patients)
          ..where((t) => t.isDeleted.equals(false))).get();
    return (visits: visits, memos: memos, patients: patients);
  });
});
