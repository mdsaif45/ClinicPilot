import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/period_provider.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';

class PaymentMethodStat {
  final String method;
  final double totalCollected;
  final double totalBilled;
  final int count;
  final double percentage;

  const PaymentMethodStat({
    required this.method,
    required this.totalCollected,
    required this.totalBilled,
    required this.count,
    required this.percentage,
  });
}

class PaymentBreakdownData {
  final double totalBilled;
  final double totalCollected;
  final double totalPending;
  final int totalMemos;
  final List<PaymentMethodStat> methods;

  const PaymentBreakdownData({
    required this.totalBilled,
    required this.totalCollected,
    required this.totalPending,
    required this.totalMemos,
    required this.methods,
  });
}

final paymentBreakdownProvider = Provider<AsyncValue<PaymentBreakdownData>>((ref) {
  final memosAsync = ref.watch(cashMemosStreamProvider);
  final period = ref.watch(periodProvider);

  return memosAsync.whenData((allMemos) {
    final range = period.dateRange;

    // Filter by date range
    final memoList = allMemos.where((m) {
      final d = m.memo.memoDate;
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }).toList();

    double totalBilled = 0;
    double totalCollected = 0;
    double totalPending = 0;

    final grouped = <String, ({double billed, double collected, int count})>{};

    for (final m in memoList) {
      final method = m.memo.paymentMethod.trim().isEmpty
          ? 'Cash'
          : m.memo.paymentMethod.trim();

      totalBilled += m.memo.total;
      totalCollected += m.memo.paidAmount;
      totalPending += m.pendingAmount;

      final current = grouped[method] ?? (billed: 0.0, collected: 0.0, count: 0);
      grouped[method] = (
        billed: current.billed + m.memo.total,
        collected: current.collected + m.memo.paidAmount,
        count: current.count + 1,
      );
    }

    final stats = grouped.entries.map((e) {
      final pct = totalCollected > 0 ? (e.value.collected / totalCollected) * 100 : 0.0;
      return PaymentMethodStat(
        method: e.key,
        totalCollected: e.value.collected,
        totalBilled: e.value.billed,
        count: e.value.count,
        percentage: pct,
      );
    }).toList()
      ..sort((a, b) => b.totalCollected.compareTo(a.totalCollected));

    return PaymentBreakdownData(
      totalBilled: totalBilled,
      totalCollected: totalCollected,
      totalPending: totalPending,
      totalMemos: memoList.length,
      methods: stats,
    );
  });
});
