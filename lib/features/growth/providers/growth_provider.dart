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
  }

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
  );
});
