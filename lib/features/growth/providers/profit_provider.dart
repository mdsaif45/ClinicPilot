import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/providers/period_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class ProfitSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;

  /// Profit per day of the month, for the trend line.
  final Map<int, double> dailyProfit;

  final int daysWithActivity;

  /// The single most profitable day in the period, if there was one.
  final DateTime? bestDay;
  final double bestDayProfit;

  const ProfitSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.dailyProfit,
    required this.daysWithActivity,
    this.bestDay,
    this.bestDayProfit = 0,
  });

  /// Averaged over days that actually had activity, not calendar days — the
  /// clinics open on alternate evenings, so dividing by 31 would halve every
  /// figure and make the practice look worse than it is.
  double get avgDailyProfit =>
      daysWithActivity == 0 ? 0 : netProfit / daysWithActivity;

  double get margin =>
      totalIncome == 0 ? 0 : (netProfit / totalIncome) * 100;
}

/// Income, expenses and profit for the selected period.
final profitSummaryProvider = StreamProvider<ProfitSummary>((ref) async* {
  final db = ref.watch(databaseProvider);
  final periodState = ref.watch(periodProvider);
  final activeClinicId = ref.watch(activeClinicProvider)?.id;
  final range = periodState.dateRange;

  var memoQuery = db.select(db.cashMemos)
    ..where((t) => t.isDeleted.equals(false))
    ..where((t) =>
        t.createdAt.isBiggerOrEqual(Variable(range.start)) &
        t.createdAt.isSmallerOrEqual(Variable(range.end)));
  if (activeClinicId != null) {
    memoQuery = memoQuery..where((t) => t.clinicId.equals(activeClinicId));
  }
  final memos = await memoQuery.get();

  var expenseQuery = db.select(db.expenses)
    ..where((t) => t.isDeleted.equals(false))
    ..where((t) =>
        t.date.isBiggerOrEqual(Variable(range.start)) &
        t.date.isSmallerOrEqual(Variable(range.end)));
  if (activeClinicId != null) {
    expenseQuery = expenseQuery..where((t) => t.clinicId.equals(activeClinicId));
  }
  final expenses = await expenseQuery.get();

  final incomeByDay = <int, double>{};
  var totalIncome = 0.0;
  for (final m in memos) {
    incomeByDay[m.createdAt.day] =
        (incomeByDay[m.createdAt.day] ?? 0) + m.total;
    totalIncome += m.total;
  }

  final expenseByDay = <int, double>{};
  var totalExpenses = 0.0;
  for (final e in expenses) {
    expenseByDay[e.date.day] = (expenseByDay[e.date.day] ?? 0) + e.amount;
    totalExpenses += e.amount;
  }

  final days = {...incomeByDay.keys, ...expenseByDay.keys};
  final dailyProfit = <int, double>{};
  for (final d in days) {
    dailyProfit[d] = (incomeByDay[d] ?? 0) - (expenseByDay[d] ?? 0);
  }

  int? bestDayNumber;
  var bestProfit = 0.0;
  dailyProfit.forEach((day, profit) {
    if (bestDayNumber == null || profit > bestProfit) {
      bestDayNumber = day;
      bestProfit = profit;
    }
  });

  yield ProfitSummary(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netProfit: totalIncome - totalExpenses,
    dailyProfit: dailyProfit,
    daysWithActivity: days.length,
    bestDay: bestDayNumber == null
        ? null
        : DateTime(range.start.year, range.start.month, bestDayNumber!),
    bestDayProfit: bestProfit,
  );
});
