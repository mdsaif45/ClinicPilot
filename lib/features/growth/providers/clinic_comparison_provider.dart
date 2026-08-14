import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/providers/period_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class ClinicMetrics {
  final Clinic clinic;
  final double revenue;
  final double variableExpenses;
  final double rent;
  final double netProfit;
  final int newPatients;
  final int repeatPatients;
  final int totalVisits;
  final double avgRevenuePerVisit;
  final double avgPatientsPerClinicDay;
  final double growthPercentageVsPrev;

  const ClinicMetrics({
    required this.clinic,
    required this.revenue,
    required this.variableExpenses,
    required this.rent,
    required this.netProfit,
    required this.newPatients,
    required this.repeatPatients,
    required this.totalVisits,
    required this.avgRevenuePerVisit,
    required this.avgPatientsPerClinicDay,
    required this.growthPercentageVsPrev,
  });
}

final clinicComparisonProvider = StreamProvider<List<ClinicMetrics>>((ref) async* {
  final db = ref.watch(databaseProvider);
  final periodState = ref.watch(periodProvider);
  final clinicsAsync = ref.watch(clinicsStreamProvider);

  final clinics = clinicsAsync.value ?? [];
  if (clinics.isEmpty) {
    yield [];
    return;
  }

  final range = periodState.dateRange;
  final priorRange = periodState.priorDateRange;

  final metricsList = <ClinicMetrics>[];

  for (final clinic in clinics) {
    // 1. Current Revenue
    final memoQuery = db.select(db.cashMemos)
      ..where((tbl) => tbl.clinicId.equals(clinic.id))
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) =>
          tbl.memoDate.isBiggerOrEqual(Variable(range.start)) &
          tbl.memoDate.isSmallerOrEqual(Variable(range.end)));
    final memos = await memoQuery.get();
    final revenue = memos.fold<double>(0.0, (sum, m) => sum + m.total);

    // Prior Revenue
    final priorMemoQuery = db.select(db.cashMemos)
      ..where((tbl) => tbl.clinicId.equals(clinic.id))
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) =>
          tbl.memoDate.isBiggerOrEqual(Variable(priorRange.start)) &
          tbl.memoDate.isSmallerOrEqual(Variable(priorRange.end)));
    final priorMemos = await priorMemoQuery.get();
    final priorRevenue = priorMemos.fold<double>(0.0, (sum, m) => sum + m.total);

    final growthPct = priorRevenue > 0
        ? ((revenue - priorRevenue) / priorRevenue) * 100
        : (revenue > 0 ? 100.0 : 0.0);

    // 2. Variable Expenses
    final expQuery = db.select(db.expenses)
      ..where((tbl) => tbl.clinicId.equals(clinic.id))
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) =>
          tbl.date.isBiggerOrEqual(Variable(range.start)) &
          tbl.date.isSmallerOrEqual(Variable(range.end)));
    final expenses = await expQuery.get();
    final variableExpenses = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

    // Prorate monthly fixed rent by calendar days in period vs days in month
    final daysInRange = range.end.difference(range.start).inDays + 1;
    final daysInMonth = DateTime(range.start.year, range.start.month + 1, 0).day;
    final rent = clinic.monthlyRent * (daysInRange / daysInMonth);
    final netProfit = revenue - (variableExpenses + rent);

    // 3. Visits
    final visitQuery = db.select(db.visits)
      ..where((tbl) => tbl.clinicId.equals(clinic.id))
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..where((tbl) =>
          tbl.visitDate.isBiggerOrEqual(Variable(range.start)) &
          tbl.visitDate.isSmallerOrEqual(Variable(range.end)));
    final visits = await visitQuery.get();

    final newPatients = visits.where((v) => v.visitType == 'new').length;
    final repeatPatients = visits.where((v) => v.visitType == 'repeat').length;
    final totalVisits = visits.length;

    final avgRevenuePerVisit = totalVisits > 0 ? revenue / totalVisits : 0.0;

    // Calculate open clinic days in period
    final openDaysList = clinic.openDays
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();

    int openClinicDaysCount = 0;
    var dayIter = range.start;
    while (!dayIter.isAfter(range.end)) {
      if (openDaysList.contains(dayIter.weekday)) {
        openClinicDaysCount++;
      }
      dayIter = dayIter.add(const Duration(days: 1));
    }
    if (openClinicDaysCount == 0) openClinicDaysCount = 1;

    final avgPatientsPerClinicDay = totalVisits / openClinicDaysCount;

    metricsList.add(
      ClinicMetrics(
        clinic: clinic,
        revenue: revenue,
        variableExpenses: variableExpenses,
        rent: rent,
        netProfit: netProfit,
        newPatients: newPatients,
        repeatPatients: repeatPatients,
        totalVisits: totalVisits,
        avgRevenuePerVisit: avgRevenuePerVisit,
        avgPatientsPerClinicDay: avgPatientsPerClinicDay,
        growthPercentageVsPrev: growthPct,
      ),
    );
  }

  yield metricsList;
});
