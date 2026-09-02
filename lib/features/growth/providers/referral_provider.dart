import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/providers/period_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class ReferralStat {
  final String source;
  final int patients;
  final double revenue;

  const ReferralStat({
    required this.source,
    required this.patients,
    required this.revenue,
  });
}

class ReferralAnalytics {
  final List<ReferralStat> stats;
  final int totalPatients;
  final double totalRevenue;

  const ReferralAnalytics({
    required this.stats,
    required this.totalPatients,
    required this.totalRevenue,
  });

  ReferralStat? get topBySource => stats.isEmpty ? null : stats.first;

  double shareOf(ReferralStat s) =>
      totalPatients == 0 ? 0 : (s.patients / totalPatients) * 100;
}

/// Where patients come from, and what each channel is worth.
///
/// Revenue uses **first-touch** attribution: every rupee a patient ever pays is
/// credited to the source that first brought them in. Referral source is only
/// asked on a new visit, so crediting per-visit would score every repeat visit
/// as unattributed and make each channel look far weaker than it is.
///
/// The question this answers is "which channel brings patients worth having",
/// which needs lifetime value, not first-consultation value.
final referralAnalyticsProvider = StreamProvider<ReferralAnalytics>((
  ref,
) async* {
  final db = ref.watch(databaseProvider);
  final periodState = ref.watch(periodProvider);
  final activeClinicId = ref.watch(activeClinicProvider)?.id;
  final range = periodState.dateRange;

  // Each patient's originating source, taken from their earliest visit.
  var firstVisitQuery =
      db.select(db.visits)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.visitDate)]);
  if (activeClinicId != null) {
    firstVisitQuery =
        firstVisitQuery..where((t) => t.clinicId.equals(activeClinicId));
  }
  final allVisits = await firstVisitQuery.get();

  final sourceOfPatient = <String, String>{};
  for (final v in allVisits) {
    if (sourceOfPatient.containsKey(v.patientId)) continue;
    final src = (v.referralSource ?? '').trim();
    sourceOfPatient[v.patientId] = src.isEmpty ? 'Not recorded' : src;
  }

  // Patients counted are those whose FIRST visit falls inside the period, so
  // the figure reads as "acquired this month" rather than "seen this month".
  final acquiredInPeriod = <String, String>{};
  final seenFirstAt = <String, DateTime>{};
  for (final v in allVisits) {
    if (seenFirstAt.containsKey(v.patientId)) continue;
    seenFirstAt[v.patientId] = v.visitDate;
    if (!v.visitDate.isBefore(range.start) && !v.visitDate.isAfter(range.end)) {
      acquiredInPeriod[v.patientId] = sourceOfPatient[v.patientId]!;
    }
  }

  // Revenue earned in the period, credited to each patient's original source.
  var memoQuery =
      db.select(db.cashMemos)
        ..where((t) => t.isDeleted.equals(false))
        ..where(
          (t) =>
              t.memoDate.isBiggerOrEqual(Variable(range.start)) &
              t.memoDate.isSmallerOrEqual(Variable(range.end)),
        );
  if (activeClinicId != null) {
    memoQuery = memoQuery..where((t) => t.clinicId.equals(activeClinicId));
  }
  final memos = await memoQuery.get();

  final revenueBySource = <String, double>{};
  var totalRevenue = 0.0;
  for (final m in memos) {
    final src = sourceOfPatient[m.patientId] ?? 'Not recorded';
    revenueBySource[src] = (revenueBySource[src] ?? 0) + m.total;
    totalRevenue += m.total;
  }

  final patientsBySource = <String, int>{};
  for (final src in acquiredInPeriod.values) {
    patientsBySource[src] = (patientsBySource[src] ?? 0) + 1;
  }

  final sources = {...patientsBySource.keys, ...revenueBySource.keys};
  final stats =
      sources
          .map(
            (s) => ReferralStat(
              source: s,
              patients: patientsBySource[s] ?? 0,
              revenue: revenueBySource[s] ?? 0,
            ),
          )
          .toList()
        ..sort((a, b) {
          final byPatients = b.patients.compareTo(a.patients);
          return byPatients != 0 ? byPatients : b.revenue.compareTo(a.revenue);
        });

  yield ReferralAnalytics(
    stats: stats,
    totalPatients: acquiredInPeriod.length,
    totalRevenue: totalRevenue,
  );
});
