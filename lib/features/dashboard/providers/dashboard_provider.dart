import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../../patients/providers/patient_provider.dart';

class DashboardStats {
  final double todayRevenue;
  final double todayExpense;
  final double todayNetProfit;
  final int todayPatients;
  final double monthlyRevenue;
  final double monthlyExpense;
  final double monthlyNetProfit;
  final int monthlyPatients;
  final double monthlyGoal;

  DashboardStats({
    required this.todayRevenue,
    required this.todayExpense,
    required this.todayNetProfit,
    required this.todayPatients,
    required this.monthlyRevenue,
    required this.monthlyExpense,
    required this.monthlyNetProfit,
    required this.monthlyPatients,
    required this.monthlyGoal,
  });
}

// Provider computing real-time dashboard analytics
final dashboardStatsProvider = Provider.autoDispose<DashboardStats>((ref) {
  final cashMemosAsync = ref.watch(cashMemosStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final patientsAsync = ref.watch(patientsStreamProvider);

  final now = DateTime.now();

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  final memos = cashMemosAsync.asData?.value ?? [];
  final expenses = expensesAsync.asData?.value ?? [];
  final patients = patientsAsync.asData?.value ?? [];

  double todayRevenue = 0;
  double monthlyRevenue = 0;
  for (final m in memos) {
    if (isSameDay(m.memo.createdAt, now)) {
      todayRevenue += m.memo.total;
    }
    if (isSameMonth(m.memo.createdAt, now)) {
      monthlyRevenue += m.memo.total;
    }
  }

  double todayExpense = 0;
  double monthlyExpense = 0;
  for (final e in expenses) {
    if (isSameDay(e.date, now)) {
      todayExpense += e.amount;
    }
    if (isSameMonth(e.date, now)) {
      monthlyExpense += e.amount;
    }
  }

  int todayPatients = patients.where((p) => isSameDay(p.createdAt, now)).length;
  int monthlyPatients = patients.where((p) => isSameMonth(p.createdAt, now)).length;

  return DashboardStats(
    todayRevenue: todayRevenue,
    todayExpense: todayExpense,
    todayNetProfit: todayRevenue - todayExpense,
    todayPatients: todayPatients,
    monthlyRevenue: monthlyRevenue,
    monthlyExpense: monthlyExpense,
    monthlyNetProfit: monthlyRevenue - monthlyExpense,
    monthlyPatients: monthlyPatients,
    monthlyGoal: 50000.0,
  );
});
