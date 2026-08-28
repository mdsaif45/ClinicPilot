import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

enum ActivityTimeRange { day, week, month }

enum ActivityMetric { revenue, patients }

/// Active time range tab (Day, Week, Month).
final activityRangeProvider =
    StateProvider<ActivityTimeRange>((ref) => ActivityTimeRange.day);

/// Active metric toggle (Revenue vs Patients).
final activityMetricProvider =
    StateProvider<ActivityMetric>((ref) => ActivityMetric.revenue);

/// Active selected date for activity screen (midnight normalized).
final selectedActivityDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

class HourlyActivityBin {
  final int hour; // 0..23
  final String label; // e.g. "10 AM"
  final double revenue;
  final int patients;

  const HourlyActivityBin({
    required this.hour,
    required this.label,
    required this.revenue,
    required this.patients,
  });
}

class DailyActivityBin {
  final DateTime date;
  final String dayLabel; // e.g. "Mon"
  final double revenue;
  final int patients;
  final bool isTargetMet;

  const DailyActivityBin({
    required this.date,
    required this.dayLabel,
    required this.revenue,
    required this.patients,
    required this.isTargetMet,
  });
}

class BubbleCalendarDay {
  final DateTime date;
  final int dayNumber;
  final double revenue;
  final int patients;
  final double intensity; // 0.0 to 1.0 relative size
  final bool isInSelectedMonth;
  final bool isToday;

  const BubbleCalendarDay({
    required this.date,
    required this.dayNumber,
    required this.revenue,
    required this.patients,
    required this.intensity,
    required this.isInSelectedMonth,
    required this.isToday,
  });
}

class WeeklySubtotal {
  final String label; // e.g. "Aug 1 – 7"
  final double revenue;
  final int patients;

  const WeeklySubtotal({
    required this.label,
    required this.revenue,
    required this.patients,
  });
}

enum ActivityEventType { consultation, dispense, expense }

class TimelineActivityItem {
  final String id;
  final DateTime timestamp;
  final ActivityEventType type;
  final String title;
  final String? subtitle;
  final double? amount;
  final String? paymentMethod;
  final String? diseaseTag;
  final String? patientId;
  final String? patientCode;
  final String? patientName;
  final String? memoNumber;
  final String? visitType;
  final String? notes;
  final String? category;

  const TimelineActivityItem({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    this.subtitle,
    this.amount,
    this.paymentMethod,
    this.diseaseTag,
    this.patientId,
    this.patientCode,
    this.patientName,
    this.memoNumber,
    this.visitType,
    this.notes,
    this.category,
  });
}

class PracticeActivityState {
  final DateTime selectedDate;
  final ActivityTimeRange range;
  final ActivityMetric metric;
  final double totalRevenue;
  final int totalPatients;
  final double totalExpense;
  final double netProfit;
  final List<HourlyActivityBin> hourlyBins;
  final String? peakRushDescription;
  final List<DailyActivityBin> weeklyBins;
  final double weeklyTargetValue;
  final double weeklyAchievementPercent;
  final List<BubbleCalendarDay> monthlyBubbleDays;
  final List<WeeklySubtotal> monthlyWeeklySubtotals;
  final List<TimelineActivityItem> timelineItems;

  const PracticeActivityState({
    required this.selectedDate,
    required this.range,
    required this.metric,
    required this.totalRevenue,
    required this.totalPatients,
    required this.totalExpense,
    required this.netProfit,
    required this.hourlyBins,
    this.peakRushDescription,
    required this.weeklyBins,
    required this.weeklyTargetValue,
    required this.weeklyAchievementPercent,
    required this.monthlyBubbleDays,
    required this.monthlyWeeklySubtotals,
    required this.timelineItems,
  });
}

/// Computes synchronous, live activity and chart metrics across Day, Week, and Month.
final practiceActivityProvider = Provider<PracticeActivityState>((ref) {
  final rawData = ref.watch(dashboardRawStreamsProvider).valueOrNull;
  final activeClinic = ref.watch(activeClinicProvider);
  final clinicId = activeClinic?.id;

  final range = ref.watch(activityRangeProvider);
  final metric = ref.watch(activityMetricProvider);
  final selectedDate = ref.watch(selectedActivityDateProvider);

  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);

  if (rawData == null) {
    return PracticeActivityState(
      selectedDate: selectedDate,
      range: range,
      metric: metric,
      totalRevenue: 0,
      totalPatients: 0,
      totalExpense: 0,
      netProfit: 0,
      hourlyBins: const [],
      weeklyBins: const [],
      weeklyTargetValue: 0,
      weeklyAchievementPercent: 0,
      monthlyBubbleDays: const [],
      monthlyWeeklySubtotals: const [],
      timelineItems: const [],
    );
  }

  bool inClinic(String? rowClinicId) =>
      clinicId == null || rowClinicId == clinicId;

  final patientMap = {for (final p in rawData.patients) p.id: p};

  // 1. DAY VIEW CALCULATIONS (Hourly 9 AM - 9 PM)
  final dayStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  final dayEnd = dayStart.add(const Duration(days: 1));

  final dayMemos = rawData.memos
      .where((m) => inClinic(m.clinicId) && !m.memoDate.isBefore(dayStart) && m.memoDate.isBefore(dayEnd))
      .toList();
  final dayVisits = rawData.visits
      .where((v) => inClinic(v.clinicId) && !v.visitDate.isBefore(dayStart) && v.visitDate.isBefore(dayEnd))
      .toList();
  final dayExpenses = rawData.expenses
      .where((e) => inClinic(e.clinicId) && !e.date.isBefore(dayStart) && e.date.isBefore(dayEnd))
      .toList();

  final hourlyBins = <HourlyActivityBin>[];
  int peakHour = 10;
  var maxPeakVal = 0.0;

  for (int h = 0; h < 24; h++) {
    final hourStart = DateTime(dayStart.year, dayStart.month, dayStart.day, h);
    final hourEnd = hourStart.add(const Duration(hours: 1));

    var hRev = 0.0;
    for (final m in dayMemos) {
      if (!m.memoDate.isBefore(hourStart) && m.memoDate.isBefore(hourEnd)) {
        hRev += m.total;
      }
    }

    var hPts = 0;
    for (final v in dayVisits) {
      if (!v.visitDate.isBefore(hourStart) && v.visitDate.isBefore(hourEnd)) {
        hPts++;
      }
    }

    final val = metric == ActivityMetric.revenue ? hRev : hPts.toDouble();
    if (val > maxPeakVal) {
      maxPeakVal = val;
      peakHour = h;
    }

    final formattedHour = DateFormat('h a').format(hourStart);
    hourlyBins.add(
      HourlyActivityBin(
        hour: h,
        label: formattedHour,
        revenue: hRev,
        patients: hPts,
      ),
    );
  }

  String? peakRushDesc;
  if (maxPeakVal > 0) {
    final startH = DateFormat('h:mm a').format(DateTime(dayStart.year, dayStart.month, dayStart.day, peakHour));
    final endH = DateFormat('h:mm a').format(DateTime(dayStart.year, dayStart.month, dayStart.day, peakHour + 2));
    peakRushDesc = 'Peak clinic activity observed between $startH – $endH';
  }

  // 2. WEEK VIEW CALCULATIONS (Mon - Sun of selectedDate week)
  // DateTime.weekday: 1 is Mon, 7 is Sun
  final weekStart = dayStart.subtract(Duration(days: dayStart.weekday - 1));
  final weeklyBins = <DailyActivityBin>[];
  var weekTotalRev = 0.0;
  var weekTotalPts = 0;
  final dailyTarget = metric == ActivityMetric.revenue ? 3000.0 : 10.0;

  for (int i = 0; i < 7; i++) {
    final curDate = weekStart.add(Duration(days: i));
    final curEnd = curDate.add(const Duration(days: 1));

    var dRev = 0.0;
    for (final m in rawData.memos) {
      if (inClinic(m.clinicId) && !m.memoDate.isBefore(curDate) && m.memoDate.isBefore(curEnd)) {
        dRev += m.total;
      }
    }

    var dPts = 0;
    for (final v in rawData.visits) {
      if (inClinic(v.clinicId) && !v.visitDate.isBefore(curDate) && v.visitDate.isBefore(curEnd)) {
        dPts++;
      }
    }

    weekTotalRev += dRev;
    weekTotalPts += dPts;

    final actualVal = metric == ActivityMetric.revenue ? dRev : dPts.toDouble();
    weeklyBins.add(
      DailyActivityBin(
        date: curDate,
        dayLabel: DateFormat('EEE').format(curDate),
        revenue: dRev,
        patients: dPts,
        isTargetMet: actualVal >= dailyTarget,
      ),
    );
  }

  final weeklyTargetVal = dailyTarget * 6; // 6 working days
  final actualWeeklyVal = metric == ActivityMetric.revenue ? weekTotalRev : weekTotalPts.toDouble();
  final weeklyAchievementPct = weeklyTargetVal > 0 ? (actualWeeklyVal / weeklyTargetVal).clamp(0.0, 2.0) : 0.0;

  // 3. MONTH VIEW CALCULATIONS (Bubble Matrix)
  final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
  final nextMonthStart = DateTime(selectedDate.year, selectedDate.month + 1, 1);
  final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

  // Find max day value for bubble scaling
  var maxMonthlyDayVal = 1.0;
  final monthDayValues = <int, (double, int)>{};

  for (int d = 1; d <= daysInMonth; d++) {
    final curDayStart = DateTime(selectedDate.year, selectedDate.month, d);
    final curDayEnd = curDayStart.add(const Duration(days: 1));

    var dRev = 0.0;
    for (final m in rawData.memos) {
      if (inClinic(m.clinicId) && !m.memoDate.isBefore(curDayStart) && m.memoDate.isBefore(curDayEnd)) {
        dRev += m.total;
      }
    }

    var dPts = 0;
    for (final v in rawData.visits) {
      if (inClinic(v.clinicId) && !v.visitDate.isBefore(curDayStart) && v.visitDate.isBefore(curDayEnd)) {
        dPts++;
      }
    }

    monthDayValues[d] = (dRev, dPts);
    final val = metric == ActivityMetric.revenue ? dRev : dPts.toDouble();
    if (val > maxMonthlyDayVal) {
      maxMonthlyDayVal = val;
    }
  }

  final bubbleDays = <BubbleCalendarDay>[];
  // Calculate grid padding for first day of month (Sun = 0, Mon = 1 ... Sat = 6)
  final firstWeekday = monthStart.weekday % 7; // Sunday = 0

  // Leading days from previous month
  for (int i = 0; i < firstWeekday; i++) {
    final prevDate = monthStart.subtract(Duration(days: firstWeekday - i));
    bubbleDays.add(
      BubbleCalendarDay(
        date: prevDate,
        dayNumber: prevDate.day,
        revenue: 0,
        patients: 0,
        intensity: 0,
        isInSelectedMonth: false,
        isToday: false,
      ),
    );
  }

  // Days in current month
  for (int d = 1; d <= daysInMonth; d++) {
    final date = DateTime(selectedDate.year, selectedDate.month, d);
    final (dRev, dPts) = monthDayValues[d]!;
    final val = metric == ActivityMetric.revenue ? dRev : dPts.toDouble();
    final intensity = (val / maxMonthlyDayVal).clamp(0.0, 1.0);

    bubbleDays.add(
      BubbleCalendarDay(
        date: date,
        dayNumber: d,
        revenue: dRev,
        patients: dPts,
        intensity: intensity,
        isInSelectedMonth: true,
        isToday: date.year == todayMidnight.year && date.month == todayMidnight.month && date.day == todayMidnight.day,
      ),
    );
  }

  // Trailing days to fill 7-col grid
  final remainingCells = (7 - (bubbleDays.length % 7)) % 7;
  for (int i = 1; i <= remainingCells; i++) {
    final nextDate = nextMonthStart.add(Duration(days: i - 1));
    bubbleDays.add(
      BubbleCalendarDay(
        date: nextDate,
        dayNumber: nextDate.day,
        revenue: 0,
        patients: 0,
        intensity: 0,
        isInSelectedMonth: false,
        isToday: false,
      ),
    );
  }

  // Monthly Weekly Subtotals
  final weeklySubtotals = <WeeklySubtotal>[];
  for (int w = 0; w < 4; w++) {
    final startDay = w * 7 + 1;
    final endDay = (w + 1) * 7 > daysInMonth ? daysInMonth : (w + 1) * 7;
    var wRev = 0.0;
    var wPts = 0;
    for (int d = startDay; d <= endDay; d++) {
      final (r, p) = monthDayValues[d] ?? (0.0, 0);
      wRev += r;
      wPts += p;
    }
    final monthShort = DateFormat('MMM').format(selectedDate);
    weeklySubtotals.add(
      WeeklySubtotal(
        label: '$monthShort $startDay – $endDay',
        revenue: wRev,
        patients: wPts,
      ),
    );
  }

  // 4. TIMELINE / CLINICAL JOURNAL ITEMS FOR SELECTED RANGE
  DateTime rangeStart;
  DateTime rangeEnd;
  if (range == ActivityTimeRange.day) {
    rangeStart = dayStart;
    rangeEnd = dayEnd;
  } else if (range == ActivityTimeRange.week) {
    rangeStart = weekStart;
    rangeEnd = weekStart.add(const Duration(days: 7));
  } else {
    rangeStart = monthStart;
    rangeEnd = nextMonthStart;
  }

  final timelineItems = <TimelineActivityItem>[];

  for (final v in rawData.visits) {
    if (!inClinic(v.clinicId)) continue;
    if (!v.visitDate.isBefore(rangeStart) && v.visitDate.isBefore(rangeEnd)) {
      final patient = patientMap[v.patientId];
      final pName = patient?.name ?? 'Patient';
      final isNew = v.visitType.toLowerCase() == 'new';
      final vType = isNew ? 'New Consultation' : 'Follow-up Consultation';

      timelineItems.add(
        TimelineActivityItem(
          id: 'v_${v.id}',
          timestamp: v.visitDate,
          type: ActivityEventType.consultation,
          title: '$pName • $vType',
          subtitle: v.disease.isNotEmpty ? 'Condition: ${v.disease}' : 'General Consultation',
          diseaseTag: v.disease,
          patientId: v.patientId,
          patientCode: patient?.patientCode,
          patientName: pName,
          visitType: vType,
          notes: v.notes,
          category: 'Consultation',
        ),
      );
    }
  }

  for (final m in rawData.memos) {
    if (!inClinic(m.clinicId)) continue;
    if (!m.memoDate.isBefore(rangeStart) && m.memoDate.isBefore(rangeEnd)) {
      final patient = patientMap[m.patientId];
      final pName = patient?.name ?? 'Patient';
      final pMethod = m.paymentMethod.toUpperCase();

      timelineItems.add(
        TimelineActivityItem(
          id: 'cm_${m.id}',
          timestamp: m.memoDate,
          type: ActivityEventType.dispense,
          title: 'Invoice #${m.memoNumber} • $pName',
          subtitle: 'Payment: $pMethod',
          amount: m.total,
          paymentMethod: pMethod,
          patientId: m.patientId,
          patientCode: patient?.patientCode,
          patientName: pName,
          memoNumber: m.memoNumber,
          notes: m.notes,
          category: 'Dispense',
        ),
      );
    }
  }

  for (final e in rawData.expenses) {
    if (!inClinic(e.clinicId)) continue;
    if (!e.date.isBefore(rangeStart) && e.date.isBefore(rangeEnd)) {
      timelineItems.add(
        TimelineActivityItem(
          id: 'e_${e.id}',
          timestamp: e.date,
          type: ActivityEventType.expense,
          title: 'Clinic Expense • ${e.category}',
          subtitle: e.notes?.isNotEmpty == true ? e.notes : 'Operational Cost',
          amount: e.amount,
          paymentMethod: e.paymentMethod.toUpperCase(),
          notes: e.notes,
          category: e.category,
        ),
      );
    }
  }

  // Sort descending chronologically
  timelineItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // Compute active totals for range
  var totalRev = 0.0;
  for (final m in rawData.memos) {
    if (inClinic(m.clinicId) && !m.memoDate.isBefore(rangeStart) && m.memoDate.isBefore(rangeEnd)) {
      totalRev += m.total;
    }
  }

  var totalPts = 0;
  for (final v in rawData.visits) {
    if (inClinic(v.clinicId) && !v.visitDate.isBefore(rangeStart) && v.visitDate.isBefore(rangeEnd)) {
      totalPts++;
    }
  }

  var totalExp = 0.0;
  for (final e in rawData.expenses) {
    if (inClinic(e.clinicId) && !e.date.isBefore(rangeStart) && e.date.isBefore(rangeEnd)) {
      totalExp += e.amount;
    }
  }

  return PracticeActivityState(
    selectedDate: selectedDate,
    range: range,
    metric: metric,
    totalRevenue: totalRev,
    totalPatients: totalPts,
    totalExpense: totalExp,
    netProfit: totalRev - totalExp,
    hourlyBins: hourlyBins,
    peakRushDescription: peakRushDesc,
    weeklyBins: weeklyBins,
    weeklyTargetValue: weeklyTargetVal,
    weeklyAchievementPercent: weeklyAchievementPct,
    monthlyBubbleDays: bubbleDays,
    monthlyWeeklySubtotals: weeklySubtotals,
    timelineItems: timelineItems,
  );
});
