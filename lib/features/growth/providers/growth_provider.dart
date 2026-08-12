import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/providers/period_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class GrowthAnalytics {
  final Map<int, double> dailyRevenueMap;
  final Map<int, double> dailyExpenseMap;
  final Map<String, int> referralSourceCount;
  final Map<String, int> diseaseFrequency;
  final int totalNewPatients;
  final int totalRepeatPatients;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;

  /// Patients registered up to the end of the period, not just those seen
  /// within it - the running size of the practice.
  final int totalPatients;

  /// Visits per day across the period, for the patient trend line.
  final Map<int, int> dailyPatientMap;

  /// Change against the previous period of equal length. Null when that
  /// period had nothing to compare against.
  final double? newPatientGrowth;
  final double? repeatPatientGrowth;

  final int daysInPeriod;

  double get repeatRate {
    final total = totalNewPatients + totalRepeatPatients;
    return total == 0 ? 0 : (totalRepeatPatients / total) * 100;
  }

  double get avgDailyNewPatients =>
      daysInPeriod == 0 ? 0 : totalNewPatients / daysInPeriod;

  double get avgDailyRevenue =>
      daysInPeriod == 0 ? 0 : totalRevenue / daysInPeriod;

  double get avgRevenuePerVisit {
    final visits = totalNewPatients + totalRepeatPatients;
    return visits == 0 ? 0 : totalRevenue / visits;
  }

  const GrowthAnalytics({
    required this.dailyRevenueMap,
    required this.dailyExpenseMap,
    required this.referralSourceCount,
    required this.diseaseFrequency,
    required this.totalNewPatients,
    required this.totalRepeatPatients,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalPatients,
    required this.dailyPatientMap,
    required this.daysInPeriod,
    this.newPatientGrowth,
    this.repeatPatientGrowth,
  });
}

final growthAnalyticsProvider = StreamProvider<GrowthAnalytics>((ref) async* {
  final db = ref.watch(databaseProvider);
  final activeClinic = ref.watch(activeClinicProvider);
  final periodState = ref.watch(periodProvider);

  final range = periodState.dateRange;
  final activeClinicId = activeClinic?.id;

  // 1. Memos in period
  var memoQuery = db.select(db.cashMemos)
    ..where((tbl) => tbl.isDeleted.equals(false))
    ..where((tbl) =>
        tbl.createdAt.isBiggerOrEqual(Variable(range.start)) &
        tbl.createdAt.isSmallerOrEqual(Variable(range.end)));
  if (activeClinicId != null) {
    memoQuery = memoQuery..where((tbl) => tbl.clinicId.equals(activeClinicId));
  }
  final memos = await memoQuery.get();

  final dailyRevenueMap = <int, double>{};
  double totalRevenue = 0.0;
  for (final m in memos) {
    final day = m.createdAt.day;
    dailyRevenueMap[day] = (dailyRevenueMap[day] ?? 0.0) + m.total;
    totalRevenue += m.total;
  }

  // 2. Expenses in period
  var expQuery = db.select(db.expenses)
    ..where((tbl) => tbl.isDeleted.equals(false))
    ..where((tbl) =>
        tbl.date.isBiggerOrEqual(Variable(range.start)) &
        tbl.date.isSmallerOrEqual(Variable(range.end)));
  if (activeClinicId != null) {
    expQuery = expQuery..where((tbl) => tbl.clinicId.equals(activeClinicId));
  }
  final expenses = await expQuery.get();

  final dailyExpenseMap = <int, double>{};
  double totalExpenses = 0.0;
  for (final e in expenses) {
    final day = e.date.day;
    dailyExpenseMap[day] = (dailyExpenseMap[day] ?? 0.0) + e.amount;
    totalExpenses += e.amount;
  }

  // 3. Visits in period
  var visitQuery = db.select(db.visits)
    ..where((tbl) => tbl.isDeleted.equals(false))
    ..where((tbl) =>
        tbl.visitDate.isBiggerOrEqual(Variable(range.start)) &
        tbl.visitDate.isSmallerOrEqual(Variable(range.end)));
  if (activeClinicId != null) {
    visitQuery = visitQuery..where((tbl) => tbl.clinicId.equals(activeClinicId));
  }
  final visits = await visitQuery.get();

  int totalNewPatients = 0;
  int totalRepeatPatients = 0;
  final referralSourceCount = <String, int>{};
  final diseaseFrequency = <String, int>{};
  final dailyPatientMap = <int, int>{};

  for (final v in visits) {
    if (v.visitType == 'new') {
      totalNewPatients++;
    } else {
      totalRepeatPatients++;
    }

    if (v.referralSource != null && v.referralSource!.isNotEmpty) {
      referralSourceCount[v.referralSource!] =
          (referralSourceCount[v.referralSource!] ?? 0) + 1;
    }

    if (v.disease.isNotEmpty) {
      diseaseFrequency[v.disease] = (diseaseFrequency[v.disease] ?? 0) + 1;
    }

    final day = v.visitDate.day;
    dailyPatientMap[day] = (dailyPatientMap[day] ?? 0) + 1;
  }

  // Practice size: everyone registered by the end of the period.
  var patientCountQuery = db.select(db.patients)
    ..where((tbl) => tbl.isDeleted.equals(false))
    ..where((tbl) => tbl.createdAt.isSmallerOrEqual(Variable(range.end)));
  if (activeClinicId != null) {
    patientCountQuery = patientCountQuery
      ..where((tbl) => tbl.primaryClinicId.equals(activeClinicId));
  }
  final totalPatients = (await patientCountQuery.get()).length;

  // Same-length window immediately before this one, for the growth figures.
  final periodLength = range.end.difference(range.start);
  final prevEnd = range.start.subtract(const Duration(seconds: 1));
  final prevStart = prevEnd.subtract(periodLength);

  var prevVisitQuery = db.select(db.visits)
    ..where((tbl) => tbl.isDeleted.equals(false))
    ..where((tbl) =>
        tbl.visitDate.isBiggerOrEqual(Variable(prevStart)) &
        tbl.visitDate.isSmallerOrEqual(Variable(prevEnd)));
  if (activeClinicId != null) {
    prevVisitQuery = prevVisitQuery
      ..where((tbl) => tbl.clinicId.equals(activeClinicId));
  }
  final prevVisits = await prevVisitQuery.get();

  var prevNew = 0, prevRepeat = 0;
  for (final v in prevVisits) {
    if (v.visitType == 'new') {
      prevNew++;
    } else {
      prevRepeat++;
    }
  }

  double? growth(num current, num previous) =>
      previous <= 0 ? null : ((current - previous) / previous) * 100;

  yield GrowthAnalytics(
    dailyRevenueMap: dailyRevenueMap,
    dailyExpenseMap: dailyExpenseMap,
    referralSourceCount: referralSourceCount,
    diseaseFrequency: diseaseFrequency,
    totalNewPatients: totalNewPatients,
    totalRepeatPatients: totalRepeatPatients,
    totalRevenue: totalRevenue,
    totalExpenses: totalExpenses,
    netProfit: totalRevenue - totalExpenses,
    totalPatients: totalPatients,
    dailyPatientMap: dailyPatientMap,
    daysInPeriod: periodLength.inDays + 1,
    newPatientGrowth: growth(totalNewPatients, prevNew),
    repeatPatientGrowth: growth(totalRepeatPatients, prevRepeat),
  );
});
