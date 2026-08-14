import 'dart:async';

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

  final int totalPatients;
  final int monthlyNewPatients;
  final int monthlyRepeatPatients;
  final int monthlyNewPatientGoal;

  /// Month-over-month change, as a percentage. Null when the previous month
  /// had nothing to compare against — reporting "+100%" against zero would
  /// overstate a first sale.
  final double? revenueGrowthPercent;
  final double? patientGrowthPercent;

  const DashboardStats({
    required this.todayRevenue,
    required this.todayExpense,
    required this.todayNetProfit,
    required this.todayPatients,
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

  double get revenueGoalProgress => monthlyRevenueGoal <= 0
      ? 0
      : (monthlyRevenue / monthlyRevenueGoal).clamp(0.0, 1.0);
}

/// Live dashboard figures.
///
/// Built on Drift's `watch()` so every number re-emits as soon as a patient,
/// visit, memo or expense is written. The previous implementation was an
/// `async*` generator that yielded exactly once, so the dashboard silently
/// went stale until the screen was rebuilt.
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final db = ref.watch(databaseProvider);
  final activeClinic = ref.watch(activeClinicProvider);
  final clinicId = activeClinic?.id;

  final memos =
      (db.select(db.cashMemos)..where((t) => t.isDeleted.equals(false))).watch();
  final expenses =
      (db.select(db.expenses)..where((t) => t.isDeleted.equals(false))).watch();
  final visits =
      (db.select(db.visits)..where((t) => t.isDeleted.equals(false))).watch();
  final patients =
      (db.select(db.patients)..where((t) => t.isDeleted.equals(false))).watch();
  final settings = db.select(db.settings).watch();

  // A write to any of these tables re-runs the whole calculation.
  return _combine5(memos, expenses, visits, patients, settings,
      (memoRows, expenseRows, visitRows, patientRows, settingRows) {
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

    final goal =
        double.tryParse(settingValue('monthly_revenue_goal') ?? '') ?? 50000.0;
    final patientGoal =
        int.tryParse(settingValue('monthly_new_patient_goal') ?? '') ?? 10;

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

    final totalPatients = clinicId == null
        ? patientRows.length
        : patientRows.where((p) => p.primaryClinicId == clinicId).length;

    double? growth(num current, num previous) =>
        previous <= 0 ? null : ((current - previous) / previous) * 100;

    return DashboardStats(
      todayRevenue: todayRevenue,
      todayExpense: todayExpense,
      todayNetProfit: todayRevenue - todayExpense,
      todayPatients: todayVisits,
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
        ..add(sa.listen((v) {
          a = v;
          emit();
        }, onError: controller.addError))
        ..add(sb.listen((v) {
          b = v;
          emit();
        }, onError: controller.addError))
        ..add(sc.listen((v) {
          c = v;
          emit();
        }, onError: controller.addError))
        ..add(sd.listen((v) {
          d = v;
          emit();
        }, onError: controller.addError))
        ..add(se.listen((v) {
          e = v;
          emit();
        }, onError: controller.addError));
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
    },
  );

  return controller.stream;
}
