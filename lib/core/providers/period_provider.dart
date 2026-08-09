import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
