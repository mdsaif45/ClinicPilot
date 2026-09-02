import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/formatters.dart';

enum PeriodFilter { today, thisWeek, thisMonth, lastMonth, custom }

extension PeriodFilterX on PeriodFilter {
  String get label {
    switch (this) {
      case PeriodFilter.today:
        return 'Today';
      case PeriodFilter.thisWeek:
        return 'This Week';
      case PeriodFilter.thisMonth:
        return 'This Month';
      case PeriodFilter.lastMonth:
        return 'Last Month';
      case PeriodFilter.custom:
        return 'Custom Range';
    }
  }
}

class PeriodState {
  final PeriodFilter filter;
  final DateTimeRange dateRange;

  const PeriodState({
    required this.filter,
    required this.dateRange,
  });

  PeriodState copyWith({
    PeriodFilter? filter,
    DateTimeRange? dateRange,
  }) {
    return PeriodState(
      filter: filter ?? this.filter,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  /// Whether current period is a single calendar day (e.g. today or day-by-day).
  bool get isSingleDay {
    final start = dateRange.start;
    final end = dateRange.end;
    return start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
  }

  /// Whether current period spans an entire month (1st to last day of month).
  bool get isFullMonth {
    final start = dateRange.start;
    final end = dateRange.end;
    return start.day == 1 &&
        end.year == start.year &&
        end.month == start.month &&
        end.day >= 28;
  }

  /// Whether the user can navigate forward without entering future dates.
  bool get canGoForward {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final thisMonthStart = DateTime(now.year, now.month, 1);

    final start = dateRange.start;
    final end = dateRange.end;

    if (isFullMonth || filter == PeriodFilter.thisMonth) {
      return DateTime(start.year, start.month, 1).isBefore(thisMonthStart);
    }

    if (isSingleDay || filter == PeriodFilter.today) {
      return DateTime(start.year, start.month, start.day).isBefore(todayMidnight);
    }

    if (filter == PeriodFilter.thisWeek) {
      return false; // Already in current week
    }

    return end.isBefore(DateTime(now.year, now.month, now.day, 23, 59, 59));
  }

  /// Human-friendly display label (e.g. "September 2026", "Today", "Yesterday", "01 Sep 2026").
  String get displayLabel {
    final start = dateRange.start;
    final end = dateRange.end;
    final now = DateTime.now();

    // 1. Single day formatting (never show "01 Sep 2026 — 01 Sep 2026")
    if (isSingleDay) {
      final isToday = start.year == now.year &&
          start.month == now.month &&
          start.day == now.day;
      if (isToday) return 'Today';

      final yesterday = now.subtract(const Duration(days: 1));
      final isYesterday = start.year == yesterday.year &&
          start.month == yesterday.month &&
          start.day == yesterday.day;
      if (isYesterday) return 'Yesterday';

      return Formatters.formatDate(start);
    }

    // 2. Full month formatting (e.g. "September 2026", "August 2026")
    if (isFullMonth) {
      return Formatters.formatMonthYear(start);
    }

    // 3. Multi-day range formatting
    switch (filter) {
      case PeriodFilter.today:
        return 'Today';
      case PeriodFilter.thisWeek:
        return 'This Week';
      case PeriodFilter.thisMonth:
        return Formatters.formatMonthYear(start);
      case PeriodFilter.lastMonth:
        return Formatters.formatMonthYear(start);
      case PeriodFilter.custom:
        return '${Formatters.formatDate(start)} — ${Formatters.formatDate(end)}';
    }
  }

  // Calculate prior equivalent period date range for percentage comparison
  DateTimeRange get priorDateRange {
    final duration = dateRange.end.difference(dateRange.start);
    final priorEnd = dateRange.start.subtract(const Duration(seconds: 1));
    final priorStart = priorEnd.subtract(duration);
    return DateTimeRange(start: priorStart, end: priorEnd);
  }
}

class PeriodNotifier extends StateNotifier<PeriodState> {
  PeriodNotifier() : super(_calculateInitialState());

  static PeriodState _calculateInitialState() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return PeriodState(
      filter: PeriodFilter.thisMonth,
      dateRange: DateTimeRange(start: start, end: end),
    );
  }

  void setMonth(DateTime month) {
    final now = DateTime.now();
    // Future restriction: cannot select future months
    final clampedMonth = (month.year > now.year ||
            (month.year == now.year && month.month > now.month))
        ? DateTime(now.year, now.month, 1)
        : month;

    final start = DateTime(clampedMonth.year, clampedMonth.month, 1, 0, 0, 0);
    final end = DateTime(clampedMonth.year, clampedMonth.month + 1, 0, 23, 59, 59);

    final isThisMonth =
        clampedMonth.year == now.year && clampedMonth.month == now.month;
    final isLastMonth =
        (clampedMonth.year == now.year && clampedMonth.month == now.month - 1) ||
            (clampedMonth.year == now.year - 1 &&
                now.month == 1 &&
                clampedMonth.month == 12);

    state = PeriodState(
      filter: isThisMonth
          ? PeriodFilter.thisMonth
          : (isLastMonth ? PeriodFilter.lastMonth : PeriodFilter.custom),
      dateRange: DateTimeRange(start: start, end: end),
    );
  }

  void previousPeriod() {
    final start = state.dateRange.start;
    final end = state.dateRange.end;

    // 1. If currently on a single day (e.g. Today or single day custom)
    if (state.isSingleDay || state.filter == PeriodFilter.today) {
      final prev = start.subtract(const Duration(days: 1));
      final s = DateTime(prev.year, prev.month, prev.day, 0, 0, 0);
      final e = DateTime(prev.year, prev.month, prev.day, 23, 59, 59);
      state = PeriodState(
        filter: PeriodFilter.custom,
        dateRange: DateTimeRange(start: s, end: e),
      );
      return;
    }

    // 2. If currently on a full month
    if (state.isFullMonth ||
        state.filter == PeriodFilter.thisMonth ||
        state.filter == PeriodFilter.lastMonth) {
      setMonth(DateTime(start.year, start.month - 1, 1));
      return;
    }

    // 3. Other ranges
    switch (state.filter) {
      case PeriodFilter.thisWeek:
        final prevStart = start.subtract(const Duration(days: 7));
        final prevEnd = end.subtract(const Duration(days: 7));
        state = PeriodState(
          filter: PeriodFilter.custom,
          dateRange: DateTimeRange(start: prevStart, end: prevEnd),
        );
        break;

      case PeriodFilter.today:
      case PeriodFilter.thisMonth:
      case PeriodFilter.lastMonth:
      case PeriodFilter.custom:
        final durationDays = end.difference(start).inDays + 1;
        final prevStart = start.subtract(Duration(days: durationDays));
        final prevEnd = end.subtract(Duration(days: durationDays));
        state = PeriodState(
          filter: PeriodFilter.custom,
          dateRange: DateTimeRange(start: prevStart, end: prevEnd),
        );
        break;
    }
  }

  void nextPeriod() {
    // Future restriction check
    if (!state.canGoForward) return;

    final start = state.dateRange.start;
    final end = state.dateRange.end;
    final now = DateTime.now();

    // 1. If currently on a single day
    if (state.isSingleDay || state.filter == PeriodFilter.today) {
      final nxt = start.add(const Duration(days: 1));
      final s = DateTime(nxt.year, nxt.month, nxt.day, 0, 0, 0);
      final e = DateTime(nxt.year, nxt.month, nxt.day, 23, 59, 59);
      final isToday = (nxt.year == now.year &&
          nxt.month == now.month &&
          nxt.day == now.day);
      state = PeriodState(
        filter: isToday ? PeriodFilter.today : PeriodFilter.custom,
        dateRange: DateTimeRange(start: s, end: e),
      );
      return;
    }

    // 2. If currently on a full month
    if (state.isFullMonth ||
        state.filter == PeriodFilter.thisMonth ||
        state.filter == PeriodFilter.lastMonth) {
      setMonth(DateTime(start.year, start.month + 1, 1));
      return;
    }

    // 3. Other ranges
    switch (state.filter) {
      case PeriodFilter.thisWeek:
        final nxtStart = start.add(const Duration(days: 7));
        final nxtEnd = end.add(const Duration(days: 7));
        state = PeriodState(
          filter: PeriodFilter.custom,
          dateRange: DateTimeRange(start: nxtStart, end: nxtEnd),
        );
        break;

      case PeriodFilter.today:
      case PeriodFilter.thisMonth:
      case PeriodFilter.lastMonth:
      case PeriodFilter.custom:
        final durationDays = end.difference(start).inDays + 1;
        final nxtStart = start.add(Duration(days: durationDays));
        final nxtEnd = end.add(Duration(days: durationDays));
        state = PeriodState(
          filter: PeriodFilter.custom,
          dateRange: DateTimeRange(start: nxtStart, end: nxtEnd),
        );
        break;
    }
  }

  void setFilter(PeriodFilter filter, {DateTimeRange? customRange}) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (filter) {
      case PeriodFilter.today:
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodFilter.thisWeek:
        final weekday = now.weekday; // Mon = 1, Sun = 7
        start = DateTime(now.year, now.month, now.day - (weekday - 1), 0, 0, 0);
        end = DateTime(now.year, now.month, now.day + (7 - weekday), 23, 59, 59);
        break;
      case PeriodFilter.thisMonth:
        start = DateTime(now.year, now.month, 1, 0, 0, 0);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case PeriodFilter.lastMonth:
        start = DateTime(now.year, now.month - 1, 1, 0, 0, 0);
        end = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case PeriodFilter.custom:
        if (customRange != null) {
          start = DateTime(customRange.start.year, customRange.start.month,
              customRange.start.day, 0, 0, 0);
          end = DateTime(customRange.end.year, customRange.end.month,
              customRange.end.day, 23, 59, 59);
        } else {
          start = state.dateRange.start;
          end = state.dateRange.end;
        }
        break;
    }

    state = PeriodState(
      filter: filter,
      dateRange: DateTimeRange(start: start, end: end),
    );
  }
}

final periodProvider =
    StateNotifierProvider<PeriodNotifier, PeriodState>((ref) {
  return PeriodNotifier();
});
