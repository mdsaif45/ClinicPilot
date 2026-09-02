import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/transaction_history_provider.dart';
import 'monthly_statement_screen.dart';
import 'transaction_detail_screen.dart';

/// Screen displaying the unified transaction history grouped chronologically by month (Image 1).
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(transactionHistoryGroupsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Search Bar (Matching Image 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.md,
              Spacing.lg,
              Spacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients, expenses, memos, vendors...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(transactionSearchQueryProvider.notifier)
                                .state = '';
                            setState(() {});
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withAlpha(120),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withAlpha(100),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withAlpha(100),
                  ),
                ),
              ),
              onChanged: (val) {
                ref.read(transactionSearchQueryProvider.notifier).state = val;
                setState(() {});
              },
            ),
          ),

          // Transaction Groups List with Sticky Month Headers
          Expanded(
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, _) =>
                      Center(child: Text('Error loading history: $err')),
              data: (groups) {
                if (groups.isEmpty) {
                  return const EmptyState.cashMemos();
                }

                return CustomScrollView(
                  slivers: [
                    for (final group in groups)
                      SliverMainAxisGroup(
                        slivers: [
                          // Sticky Month Bar -> Pinned while scrolling transactions in this month
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyMonthHeaderDelegate(group: group),
                          ),
                          // Transactions under this month
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final itemIndex = index ~/ 2;
                                if (index.isOdd) {
                                  return const Divider(height: 1, indent: 68);
                                }
                                return _TransactionItemTile(
                                  item: group.items[itemIndex],
                                );
                              },
                              childCount:
                                  group.items.isEmpty
                                      ? 0
                                      : group.items.length * 2 - 1,
                            ),
                          ),
                        ],
                      ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyMonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final MonthTransactionGroup group;

  const _StickyMonthHeaderDelegate({required this.group});

  @override
  double get minExtent => 42.0;

  @override
  double get maxExtent => 42.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final monthTitle = Formatters.formatMonthYear(group.month);

    final netAmountStr =
        group.netCashFlow > 0
            ? '+ ${Formatters.formatCurrency(group.netCashFlow)}'
            : (group.netCashFlow < 0
                ? '- ${Formatters.formatCurrency(group.netCashFlow.abs())}'
                : Formatters.formatCurrency(0));
    final amountColor =
        group.netCashFlow > 0
            ? FinanceColors.green
            : (group.netCashFlow < 0
                ? FinanceColors.red
                : scheme.onSurfaceVariant);

    return Material(
      color: scheme.surface,
      elevation: overlapsContent ? 1.5 : 0,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MonthlyStatementScreen(initialMonth: group.month),
            ),
          );
        },
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withAlpha(
              overlapsContent ? 250 : 180,
            ),
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
                  Icon(Icons.calendar_month, size: 16, color: scheme.primary),
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
                    netAmountStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: Spacing.xxs),
                  Icon(Icons.chevron_right, size: 18, color: amountColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyMonthHeaderDelegate oldDelegate) {
    return oldDelegate.group.month != group.month ||
        oldDelegate.group.totalCollections != group.totalCollections ||
        oldDelegate.group.items.length != group.items.length;
  }
}

class _TransactionItemTile extends StatelessWidget {
  final FinanceTransactionItem item;

  const _TransactionItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dateStr = Formatters.formatDayMonth(
      item.date,
    ); // e.g. "30 Aug" (no year)

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xxs,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => TransactionDetailScreen(
                  memoItem: item.memoItem,
                  expenseItem: item.expenseItem,
                ),
          ),
        );
      },
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              item.isExpense
                  ? FinanceColors
                      .redBg // Soft red circle for money out / expense
                  : FinanceColors
                      .greenBg, // Soft green circle for money in / cash memo
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.isExpense ? Icons.north_east : Icons.south_west,
          size: 18,
          color:
              item.isExpense
                  ? FinanceColors
                      .red // Negative money red
                  : FinanceColors.green, // Positive money green
        ),
      ),
      title: Text(
        item.title, // Clean direct name without repetitive prefix
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          dateStr, // Clean date without year, without repetitive prefix or clinic clutter
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
            item.isExpense
                ? '- ${Formatters.formatCurrency(item.amount)}'
                : '+ ${Formatters.formatCurrency(item.amount)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  item.isExpense
                      ? FinanceColors
                          .red // Red with minus (-)
                      : FinanceColors.green, // Green with plus (+)
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PaymentIcons.forMethod(item.paymentMethod),
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                item.paymentMethod,
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
