import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class DashboardStats {
  final double todayRevenue;
  final double todayExpense;
  final double todayNetProfit;
  final int todayPatients;
  final double monthlyRevenue;
  final double monthlyExpense;
  final double monthlyNetProfit;
  final double monthlyRevenueGoal;
  final int monthlyNewPatients;
  final int monthlyNewPatientGoal;

  const DashboardStats({
    required this.todayRevenue,
    required this.todayExpense,
    required this.todayNetProfit,
    required this.todayPatients,
    required this.monthlyRevenue,
    required this.monthlyExpense,
    required this.monthlyNetProfit,
    required this.monthlyRevenueGoal,
    required this.monthlyNewPatients,
    required this.monthlyNewPatientGoal,
  });

  double get revenueGoalProgress =>
      monthlyRevenueGoal > 0 ? (monthlyRevenue / monthlyRevenueGoal).clamp(0.0, 1.0) : 0.0;

  double get newPatientGoalProgress =>
      monthlyNewPatientGoal > 0 ? (monthlyNewPatients / monthlyNewPatientGoal).clamp(0.0, 1.0) : 0.0;
}

final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) async* {
  final db = ref.watch(databaseProvider);
  final activeClinic = ref.watch(activeClinicProvider);

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final monthStart = DateTime(now.year, now.month, 1, 0, 0, 0);
  final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final activeClinicId = activeClinic?.id;

  // Read goals from settings
  final goalSetting = await (db.select(db.settings)
        ..where((tbl) => tbl.key.equals('monthly_revenue_goal')))
      .getSingleOrNull();
  final monthlyGoal = double.tryParse(goalSetting?.value ?? '50000') ?? 50000.0;

  final newPatientGoalSetting = await (db.select(db.settings)
        ..where((tbl) => tbl.key.equals('monthly_new_patient_goal')))
      .getSingleOrNull();
  final monthlyNewPatientGoal = int.tryParse(newPatientGoalSetting?.value ?? '10') ?? 10;

  // Watch Cash Memos
  var memoQuery = db.select(db.cashMemos)
    ..where((tbl) => tbl.isDeleted.equals(false));
  if (activeClinicId != null) {
    memoQuery = memoQuery..where((tbl) => tbl.clinicId.equals(activeClinicId));
  }
  final allMemos = await memoQuery.get();

  final todayMemos = allMemos.where(
      (m) => m.createdAt.isAfter(todayStart) && m.createdAt.isBefore(todayEnd));
  final todayRevenue = todayMemos.fold<double>(0.0, (sum, m) => sum + m.total);

  final monthMemos = allMemos.where(
      (m) => m.createdAt.isAfter(monthStart) && m.createdAt.isBefore(monthEnd));
  final monthlyRevenue = monthMemos.fold<double>(0.0, (sum, m) => sum + m.total);

  // Watch Expenses
  var expQuery = db.select(db.expenses)
    ..where((tbl) => tbl.isDeleted.equals(false));
  if (activeClinicId != null) {
    expQuery = expQuery..where((tbl) => tbl.clinicId.equals(activeClinicId));
  }
  final allExpenses = await expQuery.get();

  final todayExpensesList = allExpenses
      .where((e) => e.date.isAfter(todayStart) && e.date.isBefore(todayEnd));
  final todayExpense = todayExpensesList.fold<double>(0.0, (sum, e) => sum + e.amount);

  final monthExpensesList = allExpenses
      .where((e) => e.date.isAfter(monthStart) && e.date.isBefore(monthEnd));
  final monthlyExpense = monthExpensesList.fold<double>(0.0, (sum, e) => sum + e.amount);

  // Watch Visits
  var visitQuery = db.select(db.visits)
    ..where((tbl) => tbl.isDeleted.equals(false));
  if (activeClinicId != null) {
    visitQuery = visitQuery..where((tbl) => tbl.clinicId.equals(activeClinicId));
  }
  final allVisits = await visitQuery.get();

  final todayPatients = allVisits
      .where((v) => v.visitDate.isAfter(todayStart) && v.visitDate.isBefore(todayEnd))
      .length;

  final monthlyNewPatients = allVisits
      .where((v) =>
          v.visitDate.isAfter(monthStart) &&
          v.visitDate.isBefore(monthEnd) &&
          v.visitType == 'new')
      .length;

  yield DashboardStats(
    todayRevenue: todayRevenue,
    todayExpense: todayExpense,
    todayNetProfit: todayRevenue - todayExpense,
    todayPatients: todayPatients,
    monthlyRevenue: monthlyRevenue,
    monthlyExpense: monthlyExpense,
    monthlyNetProfit: monthlyRevenue - monthlyExpense,
    monthlyRevenueGoal: monthlyGoal,
    monthlyNewPatients: monthlyNewPatients,
    monthlyNewPatientGoal: monthlyNewPatientGoal,
  );
});
