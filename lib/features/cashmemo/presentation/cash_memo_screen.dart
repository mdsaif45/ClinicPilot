import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../finances/presentation/monthly_statement_screen.dart';
import '../../finances/presentation/transaction_detail_screen.dart';
import '../../finances/providers/finances_clinic_filter_provider.dart';
import '../providers/cash_memo_provider.dart';
import 'edit_cash_memo_dialog.dart';
import 'new_cash_memo_dialog.dart';
import 'receipt_preview_dialog.dart';

class CashMemoScreen extends ConsumerWidget {
  const CashMemoScreen({super.key});

  void _openNewCashMemo(BuildContext context) {
    showDialog(context: context, builder: (_) => const NewCashMemoDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashMemosAsync = ref.watch(cashMemosStreamProvider);
    final selectedClinicId = ref.watch(financesClinicFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewCashMemo(context),
        icon: const Icon(Icons.receipt_long),
        label: const Text('New Cash Memo'),
      ),
      body: cashMemosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading memos: $err')),
        data: (allMemos) {
          final memos = selectedClinicId == null
              ? allMemos
              : allMemos.where((m) => m.memo.clinicId == selectedClinicId).toList();
          final totalRevenue =
              memos.fold<double>(0, (sum, m) => sum + m.memo.paidAmount);
          final totalPending =
              memos.fold<double>(0, (sum, m) => sum + m.pendingAmount);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.md,
                  Spacing.lg,
                  Spacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryTile(
                        label: 'Revenue Recorded',
                        value: Formatters.formatCurrency(totalRevenue),
                        caption: '${memos.length} '
                            '${memos.length == 1 ? 'memo' : 'memos'}',
                        fg: theme.colorScheme.primary,
                        bg: theme.colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _SummaryTile(
                        label: 'Pending',
                        value: Formatters.formatCurrency(totalPending),
                        caption: 'Uncollected',
                        fg: totalPending > 0
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        bg: totalPending > 0
                            ? theme.colorScheme.errorContainer
                            : theme.colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: memos.isEmpty
                    ? EmptyState.cashMemos(
                        onAction: () => showDialog(
                          context: context,
                          builder: (_) => const NewCashMemoDialog(),
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          for (final group in _groupMemosByMonth(memos))
                            SliverMainAxisGroup(
                              slivers: [
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: _StickyMemoMonthHeaderDelegate(
                                      group: group),
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final item = group.items[index];
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _MemoRow(item: item),
                                          if (index < group.items.length - 1)
                                            const Divider(
                                              height: 1,
                                              indent: Spacing.lg,
                                            ),
                                        ],
                                      );
                                    },
                                    childCount: group.items.length,
                                  ),
                                ),
                              ],
                            ),
                          const SliverPadding(
                            padding: EdgeInsets.only(bottom: 96),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemoMonthGroup {
  final DateTime month;
  final double totalRevenue;
  final List<CashMemoWithDetails> items;

  const _MemoMonthGroup({
    required this.month,
    required this.totalRevenue,
    required this.items,
  });
}

List<_MemoMonthGroup> _groupMemosByMonth(List<CashMemoWithDetails> list) {
  final map = <DateTime, List<CashMemoWithDetails>>{};
  for (final item in list) {
    final m = DateTime(item.memo.memoDate.year, item.memo.memoDate.month, 1);
    map.putIfAbsent(m, () => []).add(item);
  }
  final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return sortedKeys.map((m) {
    final items = map[m]!;
    final sum = items.fold<double>(0, (s, e) => s + e.memo.paidAmount);
    return _MemoMonthGroup(month: m, totalRevenue: sum, items: items);
  }).toList();
}

class _StickyMemoMonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final _MemoMonthGroup group;

  _StickyMemoMonthHeaderDelegate({required this.group});

  @override
  double get minExtent => 42.0;

  @override
  double get maxExtent => 42.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final monthTitle = Formatters.formatMonthYear(group.month);

    return Material(
      color: scheme.surface,
      elevation: overlapsContent ? 1.5 : 0,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MonthlyStatementScreen(
                initialMonth: group.month,
              ),
            ),
          );
        },
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest
                .withAlpha(overlapsContent ? 250 : 180),
            border: Border(
              top: BorderSide(color: theme.dividerColor.withAlpha(80)),
              bottom: BorderSide(color: theme.dividerColor.withAlpha(80)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    monthTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.formatCurrency(group.totalRevenue),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 35,
                    child: Center(
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyMemoMonthHeaderDelegate oldDelegate) {
    return oldDelegate.group.month != group.month ||
        oldDelegate.group.totalRevenue != group.totalRevenue ||
        oldDelegate.group.items.length != group.items.length;
  }
}

class _MemoRow extends ConsumerWidget {
  final CashMemoWithDetails item;

  const _MemoRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final memo = item.memo;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(memoItem: item),
          ),
        );
      },
      leading: Tooltip(
        message: memo.paymentMethod,
        child: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            PaymentIcons.forMethod(memo.paymentMethod),
            color: scheme.primary,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.patient.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Amounts stack on the right, so a column of memos can be read down
          // the edge without hunting for the figure inside a sentence.
          Text(
            Formatters.formatCurrency(memo.total),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: Spacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${memo.memoNumber} · ${Formatters.formatDayMonth(memo.memoDate)}',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              item.pendingAmount > 0
                  ? '${Formatters.formatCurrency(item.pendingAmount)} due'
                  : 'Paid',
              style: theme.textTheme.labelSmall?.copyWith(
                color: item.pendingAmount > 0
                    ? scheme.error
                    : scheme.onSurfaceVariant,
                fontWeight:
                    item.pendingAmount > 0 ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
        onSelected: (value) {
          switch (value) {
            case 'receipt':
              showDialog(
                context: context,
                builder: (_) => ReceiptPreviewDialog(
                  cashMemo: memo,
                  patient: item.patient,
                  clinicName: item.clinic.name,
                ),
              );
            case 'edit':
              showDialog(
                context: context,
                builder: (_) => EditCashMemoDialog(memo: memo),
              );
            case 'delete':
              _confirmDelete(context, ref, memo.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'receipt',
            child: ListTile(
              leading: Icon(Icons.print_outlined),
              title: Text('Receipt'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Delete'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete cash memo'),
        content: const Text(
          'This memo stops counting toward revenue and totals. The record is '
          'kept in the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () async {
              await ref
                  .read(cashMemoNotifierProvider.notifier)
                  .archiveCashMemo(id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Compact summary tile for the top of a list screen.
class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color fg;
  final Color bg;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: Spacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
          Text(caption, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
