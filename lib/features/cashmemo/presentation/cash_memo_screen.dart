import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/cash_memo_provider.dart';
import 'edit_cash_memo_dialog.dart';
import 'new_cash_memo_dialog.dart';
import 'receipt_preview_dialog.dart';

/// Payment methods carry an icon rather than a text chip: on a list scanned at
/// a glance a symbol reads faster than a word, and it frees the width the chip
/// was taking from the patient name.
IconData paymentIcon(String method) => switch (method.toLowerCase()) {
      'cash' => Icons.payments_outlined,
      'upi' => Icons.qr_code_2,
      'card' => Icons.credit_card,
      _ => Icons.account_balance_outlined,
    };

class CashMemoScreen extends ConsumerWidget {
  const CashMemoScreen({super.key});

  void _openNewCashMemo(BuildContext context) {
    showDialog(context: context, builder: (_) => const NewCashMemoDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashMemosAsync = ref.watch(cashMemosStreamProvider);
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
        data: (memos) {
          final totalRevenue =
              memos.fold<double>(0, (sum, m) => sum + m.memo.total);
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
                    ? const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No cash memos yet',
                        message: 'Bill a patient and it will appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: memos.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: Spacing.lg),
                        itemBuilder: (context, i) =>
                            _MemoRow(item: memos[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
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
      onTap: () => showDialog(
        context: context,
        builder: (_) => ReceiptPreviewDialog(
          cashMemo: memo,
          patient: item.patient,
          clinicName: item.clinic.name,
        ),
      ),
      leading: Tooltip(
        message: memo.paymentMethod,
        child: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(paymentIcon(memo.paymentMethod), color: scheme.primary),
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
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${memo.memoNumber} · ${Formatters.formatDate(memo.createdAt)}',
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
