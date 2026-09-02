import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';
import '../providers/monthly_statement_provider.dart';
import 'sort_by_bottom_sheet.dart';
import 'transaction_detail_screen.dart';

/// Screen displaying all collections (money received) for a selected month with sorting (Image 5).
class MoneyReceivedScreen extends ConsumerStatefulWidget {
  final DateTime month;

  const MoneyReceivedScreen({super.key, required this.month});

  @override
  ConsumerState<MoneyReceivedScreen> createState() => _MoneyReceivedScreenState();
}

class _MoneyReceivedScreenState extends ConsumerState<MoneyReceivedScreen> {
  FinanceSortOption _sortOption = FinanceSortOption.recents;

  @override
  Widget build(BuildContext context) {
    final statementAsync = ref.watch(monthlyStatementProvider(widget.month));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cash Memos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              Formatters.formatMonthYear(widget.month),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: statementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading collections: $err')),
        data: (data) {
          final sortedMemos = sortCashMemos(data.cashMemos, _sortOption);

          if (sortedMemos.isEmpty) {
            return const EmptyState.cashMemos();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sort by pill button (Matching Image 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.sm),
                child: _SortPill(
                  sortOption: _sortOption,
                  onTap: () async {
                    final selected = await showSortByBottomSheet(context, _sortOption);
                    if (selected != null && mounted) {
                      setState(() => _sortOption = selected);
                    }
                  },
                ),
              ),

              // Total received bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cash Memos (${sortedMemos.length})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(data.totalReceived),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xs),
              const Divider(height: 1),

              // Collections List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: sortedMemos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
                  itemBuilder: (context, index) {
                    final item = sortedMemos[index];
                    return _ReceivedTile(item: item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  final FinanceSortOption sortOption;
  final VoidCallback onTap;

  const _SortPill({required this.sortOption, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withAlpha(90)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort by : ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            Text(
              sortOption.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ReceivedTile extends StatelessWidget {
  final CashMemoWithDetails item;

  const _ReceivedTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final memo = item.memo;
    final patient = item.patient;
    final dateStr = Formatters.formatDayMonth(memo.memoDate);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xxs),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(memoItem: item),
          ),
        );
      },
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9), // Soft green circle for money in
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.south_west,
          size: 20,
          color: Color(0xFF2E7D32),
        ),
      ),
      title: Text(
        patient.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          dateStr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '+ ${Formatters.formatCurrency(memo.paidAmount)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PaymentIcons.forMethod(memo.paymentMethod),
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                memo.paymentMethod,
                style: TextStyle(
                  fontSize: 10,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
