import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../clinics/providers/clinic_provider.dart';

class DashboardStats {
  final DateTime? selectedDate;
  final double? dailyRevenue;
  final double? dailyExpense;
  final double? dailyNetProfit;
  final int? dailyPatients;

  final double todayRevenue;
  final double todayExpense;
  final double todayNetProfit;
  final int todayPatients;

  final double monthlyRevenue;
  final double monthlyExpense;
  final double monthlyNetProfit;
  final double monthlyRevenueGoal;

  final int totalPatients;
  final int totalRepeatPatients;
  final int monthlyNewPatients;
  final int monthlyRepeatPatients;
  final int monthlyNewPatientGoal;

  /// Month-over-month change, as a percentage. Null when the previous month
  /// had nothing to compare against — reporting "+100%" against zero would
  /// overstate a first sale.
  final double? revenueGrowthPercent;
  final double? patientGrowthPercent;

  const DashboardStats({
    this.selectedDate,
    this.dailyRevenue,
    this.dailyExpense,
    this.dailyNetProfit,
    this.dailyPatients,
    required this.todayRevenue,
    required this.todayExpense,
    required this.todayNetProfit,
    required this.todayPatients,
    required this.monthlyRevenue,
    required this.monthlyExpense,
    required this.monthlyNetProfit,
    required this.monthlyRevenueGoal,
    required this.totalPatients,
    this.totalRepeatPatients = 0,
    required this.monthlyNewPatients,
    required this.monthlyRepeatPatients,
    required this.monthlyNewPatientGoal,
    this.revenueGrowthPercent,
    this.patientGrowthPercent,
  });

  DateTime get activeSelectedDate => selectedDate ?? DateTime.now();
  double get activeDailyRevenue => dailyRevenue ?? todayRevenue;
  double get activeDailyExpense => dailyExpense ?? todayExpense;
  double get activeDailyNetProfit => dailyNetProfit ?? todayNetProfit;
  int get activeDailyPatients => dailyPatients ?? todayPatients;

  bool get isToday {
    final now = DateTime.now();
    final d = activeSelectedDate;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool get isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    final d = activeSelectedDate;
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  double get revenueGoalProgress =>
      monthlyRevenueGoal <= 0
          ? 0
          : (monthlyRevenue / monthlyRevenueGoal).clamp(0.0, 1.0);

  double get newPatientGoalProgress =>
      monthlyNewPatientGoal <= 0
          ? 0
          : (monthlyNewPatients / monthlyNewPatientGoal).clamp(0.0, 1.0);
}

class DailyStats {
  final DateTime selectedDate;
  final double dailyRevenue;
  final double dailyExpense;
  final double dailyNetProfit;
  final int dailyPatients;

  const DailyStats({
    required this.selectedDate,
    required this.dailyRevenue,
    required this.dailyExpense,
    required this.dailyNetProfit,
    required this.dailyPatients,
  });

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  bool get isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return selectedDate.year == y.year &&
        selectedDate.month == y.month &&
        selectedDate.day == y.day;
  }
}

class MonthlyStats {
  final DateTime selectedMonth;
  final double monthlyRevenue;
  final double monthlyExpense;
  final double monthlyNetProfit;
  final double monthlyRevenueGoal;
  final int totalPatients;
  final int monthlyNewPatients;
  final int monthlyRepeatPatients;
  final int monthlyNewPatientGoal;
  final double? revenueGrowthPercent;
  final double? patientGrowthPercent;

  const MonthlyStats({
    required this.selectedMonth,
    required this.monthlyRevenue,
    required this.monthlyExpense,
    required this.monthlyNetProfit,
    required this.monthlyRevenueGoal,
    required this.totalPatients,
    required this.monthlyNewPatients,
    required this.monthlyRepeatPatients,
    required this.monthlyNewPatientGoal,
    this.revenueGrowthPercent,
    this.patientGrowthPercent,
  });

  bool get isCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.year == now.year && selectedMonth.month == now.month;
  }

  bool get isLastMonth {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month - 1, 1);
    return selectedMonth.year == last.year && selectedMonth.month == last.month;
  }

  double get revenueGoalProgress =>
      monthlyRevenueGoal <= 0
          ? 0
          : (monthlyRevenue / monthlyRevenueGoal).clamp(0.0, 1.0);

  double get newPatientGoalProgress =>
      monthlyNewPatientGoal <= 0
          ? 0
          : (monthlyNewPatients / monthlyNewPatientGoal).clamp(0.0, 1.0);
}

/// Active selected date for daily dashboard breakdown (date only, midnight normalized).
final selectedDashboardDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Active selected month for monthly dashboard breakdown (normalized to 1st of month).
final selectedDashboardMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

class _DashboardRawData {
  final List<CashMemo> memos;
  final List<Expense> expenses;
  final List<Visit> visits;
  final List<Patient> patients;
  final List<Setting> settings;

  const _DashboardRawData({
    required this.memos,
    required this.expenses,
    required this.visits,
    required this.patients,
    required this.settings,
  });
}

/// Continuous stream of raw database records for the dashboard.
final dashboardRawStreamsProvider = StreamProvider<_DashboardRawData>((ref) {
  final db = ref.watch(databaseProvider);

  final memos =
      (db.select(db.cashMemos)
        ..where((t) => t.isDeleted.equals(false))).watch();
  final expenses =
      (db.select(db.expenses)..where((t) => t.isDeleted.equals(false))).watch();
  final visits =
      (db.select(db.visits)..where((t) => t.isDeleted.equals(false))).watch();
  final patients =
      (db.select(db.patients)..where((t) => t.isDeleted.equals(false))).watch();
  final settings = db.select(db.settings).watch();

  return _combine5(memos, expenses, visits, patients, settings, (
    memoRows,
    expenseRows,
    visitRows,
    patientRows,
    settingRows,
  ) {
    return _DashboardRawData(
      memos: memoRows,
      expenses: expenseRows,
      visits: visitRows,
      patients: patientRows,
      settings: settingRows,
    );
  });
});

/// Legacy alias to preserve backwards compatibility.
final dailyRawStreamsProvider = dashboardRawStreamsProvider;

/// Scoped synchronous live daily statistics for the selected date.
///
/// Filters the in-memory database snapshot instantaneously with zero async
/// delay or loading states when traversing dates.
final dailyStatsProvider = Provider<DailyStats>((ref) {
  final rawData = ref.watch(dashboardRawStreamsProvider).valueOrNull;
  final activeClinic = ref.watch(activeClinicProvider);
  final clinicId = activeClinic?.id;
  final selectedDate = ref.watch(selectedDashboardDateProvider);

  if (rawData == null) {
    return DailyStats(
      selectedDate: selectedDate,
      dailyRevenue: 0.0,
      dailyExpense: 0.0,
      dailyNetProfit: 0.0,
      dailyPatients: 0,
    );
  }

  final selectedDayStart = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );
  final selectedDayEnd = selectedDayStart.add(const Duration(days: 1));

  bool inClinic(String? rowClinicId) =>
      clinicId == null || rowClinicId == clinicId;

  bool within(DateTime d, DateTime start, DateTime end) =>
      !d.isBefore(start) && d.isBefore(end);

  var dailyRevenue = 0.0;
  for (final m in rawData.memos) {
    if (!inClinic(m.clinicId)) continue;
    if (within(m.memoDate, selectedDayStart, selectedDayEnd)) {
      dailyRevenue += m.total;
    }
  }

  var dailyExpense = 0.0;
  for (final e in rawData.expenses) {
    if (!inClinic(e.clinicId)) continue;
    if (within(e.date, selectedDayStart, selectedDayEnd)) {
      dailyExpense += e.amount;
    }
  }

  var dailyVisits = 0;
  for (final v in rawData.visits) {
    if (!inClinic(v.clinicId)) continue;
    if (within(v.visitDate, selectedDayStart, selectedDayEnd)) {
      dailyVisits++;
    }
  }

  return DailyStats(
    selectedDate: selectedDate,
    dailyRevenue: dailyRevenue,
    dailyExpense: dailyExpense,
    dailyNetProfit: dailyRevenue - dailyExpense,
    dailyPatients: dailyVisits,
  );
});

/// Scoped synchronous live monthly statistics for the selected month.
///
/// Filters the in-memory database snapshot instantaneously with zero async
/// delay or loading states when traversing months.
final monthlyStatsProvider = Provider<MonthlyStats>((ref) {
  final rawData = ref.watch(dashboardRawStreamsProvider).valueOrNull;
  final activeClinic = ref.watch(activeClinicProvider);
  final clinicId = activeClinic?.id;
  final selectedMonth = ref.watch(selectedDashboardMonthProvider);

  if (rawData == null) {
    return MonthlyStats(
      selectedMonth: selectedMonth,
      monthlyRevenue: 0.0,
      monthlyExpense: 0.0,
      monthlyNetProfit: 0.0,
      monthlyRevenueGoal: 50000.0,
      totalPatients: 0,
      monthlyNewPatients: 0,
      monthlyRepeatPatients: 0,
      monthlyNewPatientGoal: 10,
    );
  }

  final monthStart = DateTime(selectedMonth.year, selectedMonth.month, 1);
  final nextMonthStart = DateTime(
    selectedMonth.year,
    selectedMonth.month + 1,
    1,
  );
  final prevMonthStart = DateTime(
    selectedMonth.year,
    selectedMonth.month - 1,
    1,
  );

  String? settingValue(String key) {
    for (final s in rawData.settings) {
      if (s.key == key) return s.value;
    }
    return null;
  }

  String? clinicRevenueGoal =
      clinicId != null ? settingValue('monthly_revenue_goal_$clinicId') : null;
  String? clinicPatientGoal =
      clinicId != null
          ? settingValue('monthly_new_patient_goal_$clinicId')
          : null;

  final goal =
      double.tryParse(
        clinicRevenueGoal ?? settingValue('monthly_revenue_goal') ?? '',
      ) ??
      50000.0;
  final patientGoal =
      int.tryParse(
        clinicPatientGoal ?? settingValue('monthly_new_patient_goal') ?? '',
      ) ??
      10;

  bool inClinic(String? rowClinicId) =>
      clinicId == null || rowClinicId == clinicId;

  bool within(DateTime d, DateTime start, DateTime end) =>
      !d.isBefore(start) && d.isBefore(end);

  var monthRevenue = 0.0, prevMonthRevenue = 0.0;
  for (final m in rawData.memos) {
    if (!inClinic(m.clinicId)) continue;
    if (within(m.memoDate, monthStart, nextMonthStart)) {
      monthRevenue += m.total;
    } else if (within(m.memoDate, prevMonthStart, monthStart)) {
      prevMonthRevenue += m.total;
    }
  }

  var monthExpense = 0.0;
  for (final e in rawData.expenses) {
    if (!inClinic(e.clinicId)) continue;
    if (within(e.date, monthStart, nextMonthStart)) monthExpense += e.amount;
  }

  var monthNew = 0, monthRepeat = 0, prevMonthNew = 0;
  for (final v in rawData.visits) {
    if (!inClinic(v.clinicId)) continue;
    if (within(v.visitDate, monthStart, nextMonthStart)) {
      if (v.visitType == 'new') {
        monthNew++;
      } else {
        monthRepeat++;
      }
    } else if (within(v.visitDate, prevMonthStart, monthStart) &&
        v.visitType == 'new') {
      prevMonthNew++;
    }
  }

  final totalPatients =
      clinicId == null
          ? rawData.patients.length
          : rawData.patients.where((p) => p.primaryClinicId == clinicId).length;

  double? growth(num current, num previous) =>
      previous <= 0 ? null : ((current - previous) / previous) * 100;

  return MonthlyStats(
    selectedMonth: selectedMonth,
    monthlyRevenue: monthRevenue,
    monthlyExpense: monthExpense,
    monthlyNetProfit: monthRevenue - monthExpense,
    monthlyRevenueGoal: goal,
    totalPatients: totalPatients,
    monthlyNewPatients: monthNew,
    monthlyRepeatPatients: monthRepeat,
    monthlyNewPatientGoal: patientGoal,
    revenueGrowthPercent: growth(monthRevenue, prevMonthRevenue),
    patientGrowthPercent: growth(monthNew, prevMonthNew),
  );
});

/// Live dashboard figures for overall practice performance.
///
/// Built on Drift's `watch()` so numbers re-emit as soon as records are written.
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final db = ref.watch(databaseProvider);
  final activeClinic = ref.watch(activeClinicProvider);
  final clinicId = activeClinic?.id;

  final memos =
      (db.select(db.cashMemos)
        ..where((t) => t.isDeleted.equals(false))).watch();
  final expenses =
      (db.select(db.expenses)..where((t) => t.isDeleted.equals(false))).watch();
  final visits =
      (db.select(db.visits)..where((t) => t.isDeleted.equals(false))).watch();
  final patients =
      (db.select(db.patients)..where((t) => t.isDeleted.equals(false))).watch();
  final settings = db.select(db.settings).watch();

  // A write to any of these tables re-runs the whole calculation.
  return _combine5(memos, expenses, visits, patients, settings, (
    memoRows,
    expenseRows,
    visitRows,
    patientRows,
    settingRows,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);

    String? settingValue(String key) {
      for (final s in settingRows) {
        if (s.key == key) return s.value;
      }
      return null;
    }

    String? clinicRevenueGoal =
        clinicId != null
            ? settingValue('monthly_revenue_goal_$clinicId')
            : null;
    String? clinicPatientGoal =
        clinicId != null
            ? settingValue('monthly_new_patient_goal_$clinicId')
            : null;

    final goal =
        double.tryParse(
          clinicRevenueGoal ?? settingValue('monthly_revenue_goal') ?? '',
        ) ??
        50000.0;
    final patientGoal =
        int.tryParse(
          clinicPatientGoal ?? settingValue('monthly_new_patient_goal') ?? '',
        ) ??
        10;

    bool inClinic(String? rowClinicId) =>
        clinicId == null || rowClinicId == clinicId;

    bool within(DateTime d, DateTime start, DateTime end) =>
        !d.isBefore(start) && d.isBefore(end);

    var todayRevenue = 0.0, monthRevenue = 0.0, prevMonthRevenue = 0.0;
    for (final m in memoRows) {
      if (!inClinic(m.clinicId)) continue;
      if (within(m.memoDate, todayStart, todayEnd)) todayRevenue += m.total;
      if (within(m.memoDate, monthStart, nextMonthStart)) {
        monthRevenue += m.total;
      } else if (within(m.memoDate, prevMonthStart, monthStart)) {
        prevMonthRevenue += m.total;
      }
    }

    var todayExpense = 0.0, monthExpense = 0.0;
    for (final e in expenseRows) {
      if (!inClinic(e.clinicId)) continue;
      if (within(e.date, todayStart, todayEnd)) todayExpense += e.amount;
      if (within(e.date, monthStart, nextMonthStart)) monthExpense += e.amount;
    }

    var todayVisits = 0, monthNew = 0, monthRepeat = 0, prevMonthNew = 0;
    for (final v in visitRows) {
      if (!inClinic(v.clinicId)) continue;
      if (within(v.visitDate, todayStart, todayEnd)) todayVisits++;
      if (within(v.visitDate, monthStart, nextMonthStart)) {
        if (v.visitType == 'new') {
          monthNew++;
        } else {
          monthRepeat++;
        }
      } else if (within(v.visitDate, prevMonthStart, monthStart) &&
          v.visitType == 'new') {
        prevMonthNew++;
      }
    }

    final totalPatients =
        clinicId == null
            ? patientRows.length
            : patientRows.where((p) => p.primaryClinicId == clinicId).length;

    final totalRepeatPatients =
        visitRows
            .where((v) => inClinic(v.clinicId) && v.visitType != 'new')
            .map((v) => v.patientId)
            .toSet()
            .length;

    double? growth(num current, num previous) =>
        previous <= 0 ? null : ((current - previous) / previous) * 100;

    return DashboardStats(
      selectedDate: todayStart,
      dailyRevenue: todayRevenue,
      dailyExpense: todayExpense,
      dailyNetProfit: todayRevenue - todayExpense,
      dailyPatients: todayVisits,
      todayRevenue: todayRevenue,
      todayExpense: todayExpense,
      todayNetProfit: todayRevenue - todayExpense,
      todayPatients: todayVisits,
      monthlyRevenue: monthRevenue,
      monthlyExpense: monthExpense,
      monthlyNetProfit: monthRevenue - monthExpense,
      monthlyRevenueGoal: goal,
      totalPatients: totalPatients,
      totalRepeatPatients: totalRepeatPatients,
      monthlyNewPatients: monthNew,
      monthlyRepeatPatients: monthRepeat,
      monthlyNewPatientGoal: patientGoal,
      revenueGrowthPercent: growth(monthRevenue, prevMonthRevenue),
      patientGrowthPercent: growth(monthNew, prevMonthNew),
    );
  });
});

/// Combines five streams, re-emitting whenever any of them produces a value.
Stream<R> _combine5<A, B, C, D, E, R>(
  Stream<A> sa,
  Stream<B> sb,
  Stream<C> sc,
  Stream<D> sd,
  Stream<E> se,
  R Function(A, B, C, D, E) combine,
) {
  late StreamController<R> controller;
  A? a;
  B? b;
  C? c;
  D? d;
  E? e;
  final subs = <StreamSubscription>[];

  void emit() {
    if (a != null && b != null && c != null && d != null && e != null) {
      controller.add(combine(a as A, b as B, c as C, d as D, e as E));
    }
  }

  controller = StreamController<R>(
    onListen: () {
      subs
        ..add(
          sa.listen((v) {
            a = v;
            emit();
          }, onError: controller.addError),
        )
        ..add(
          sb.listen((v) {
            b = v;
            emit();
          }, onError: controller.addError),
        )
        ..add(
          sc.listen((v) {
            c = v;
            emit();
          }, onError: controller.addError),
        )
        ..add(
          sd.listen((v) {
            d = v;
            emit();
          }, onError: controller.addError),
        )
        ..add(
          se.listen((v) {
            e = v;
            emit();
          }, onError: controller.addError),
        );
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
    },
  );

  return controller.stream;
}
