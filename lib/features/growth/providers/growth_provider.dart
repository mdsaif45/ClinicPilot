import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../../patients/providers/patient_provider.dart';

class GrowthAnalyticsData {
  final Map<String, int> referralSources;
  final Map<String, int> diseaseDistribution;
  final Map<int, double> dailyRevenue;
  final Map<int, double> dailyExpenses;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final int totalPatients;
  final String topReferralSource;
  final String topDisease;

  GrowthAnalyticsData({
    required this.referralSources,
    required this.diseaseDistribution,
    required this.dailyRevenue,
    required this.dailyExpenses,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalPatients,
    required this.topReferralSource,
    required this.topDisease,
  });
}

// Provider computing Growth Analytics & fl_chart data
final growthAnalyticsProvider = Provider.autoDispose<GrowthAnalyticsData>((ref) {
  final cashMemosAsync = ref.watch(cashMemosStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final patientsAsync = ref.watch(patientsStreamProvider);

  final memos = cashMemosAsync.asData?.value ?? [];
  final expenses = expensesAsync.asData?.value ?? [];
  final patients = patientsAsync.asData?.value ?? [];

  // Referral sources map
  final Map<String, int> referralMap = {};
  for (final p in patients) {
    referralMap[p.referralSource] = (referralMap[p.referralSource] ?? 0) + 1;
  }

  // Disease frequency map
  final Map<String, int> diseaseMap = {};
  for (final p in patients) {
    diseaseMap[p.disease] = (diseaseMap[p.disease] ?? 0) + 1;
  }

  // Daily revenue & expense maps for current month days (1..31)
  final Map<int, double> dailyRev = {};
  final Map<int, double> dailyExp = {};

  double totalRev = 0;
  for (final m in memos) {
    totalRev += m.memo.total;
    final day = m.memo.createdAt.day;
    dailyRev[day] = (dailyRev[day] ?? 0) + m.memo.total;
  }

  double totalExp = 0;
  for (final e in expenses) {
    totalExp += e.amount;
    final day = e.date.day;
    dailyExp[day] = (dailyExp[day] ?? 0) + e.amount;
  }

  String topRef = referralMap.isNotEmpty
      ? referralMap.entries.reduce((a, b) => a.value > b.value ? a : b).key
      : "N/A";

  String topDis = diseaseMap.isNotEmpty
      ? diseaseMap.entries.reduce((a, b) => a.value > b.value ? a : b).key
      : "N/A";

  return GrowthAnalyticsData(
    referralSources: referralMap,
    diseaseDistribution: diseaseMap,
    dailyRevenue: dailyRev,
    dailyExpenses: dailyExp,
    totalRevenue: totalRev,
    totalExpenses: totalExp,
    netProfit: totalRev - totalExp,
    totalPatients: patients.length,
    topReferralSource: topRef,
    topDisease: topDis,
  );
});
