import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/monthly_statement_provider.dart';
import 'money_received_screen.dart';
import 'money_spent_screen.dart';
import 'transaction_detail_screen.dart';

// Screen displaying the executive monthly practice statement with Inflow/Outflow drilldowns.
class MonthlyStatementScreen extends ConsumerStatefulWidget {
  final DateTime initialMonth;

  const MonthlyStatementScreen({super.key, required this.initialMonth});

  @override
  ConsumerState<MonthlyStatementScreen> createState() => _MonthlyStatementScreenState();
}

class _MonthlyStatementScreenState extends ConsumerState<MonthlyStatementScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Practice Month',
    );
    if (picked != null && mounted) {
      setState(() {
        _currentMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statementAsync = ref.watch(monthlyStatementProvider(_currentMonth));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 22),
              tooltip: 'Previous Month',
              onPressed: _prevMonth,
            ),
            InkWell(
              onTap: () => _pickMonth(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withAlpha(120),
                  borderRadius: Radii.smAll,
                  border: Border.all(color: theme.dividerColor.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: scheme.primary),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      Formatters.formatMonthYear(_currentMonth),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: Spacing.xxs),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 22),
              tooltip: 'Next Month',
              onPressed: _nextMonth,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: statementAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading statement: $err')),
        data: (data) {
          final netMargin = data.totalReceived - data.totalSpent;
          final isSurplus = netMargin >= 0;
          final recentExpenses = data.expenses.take(4).toList();
          final recentReceived = data.cashMemos.take(4).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
            children: [
              // 1. Executive Practice Performance Card
              AppCard(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics_outlined, size: 18, color: scheme.primary),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              'Executive Summary',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSurplus
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: Radii.pillAll,
                            border: Border.all(
                              color: isSurplus
                                  ? const Color(0xFF81C784)
                                  : const Color(0xFFE57373),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSurplus ? Icons.trending_up : Icons.trending_down,
                                size: 14,
                                color: isSurplus
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFD32F2F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSurplus ? 'Net Surplus' : 'Operating Deficit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSurplus
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),

                    // Net Margin Hero Figure
                    Text(
                      Formatters.formatCurrency(netMargin.abs()),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSurplus
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFD32F2F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSurplus
                          ? 'Net practice operating surplus for this month'
                          : 'Operating expenses exceeded collections for this month',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: Spacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: Spacing.md),

                    // Inflow vs Outflow 2-Column Ledger
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MoneyReceivedScreen(month: _currentMonth),
                                ),
                              );
                            },
                            borderRadius: Radii.smAll,
                            child: Container(
                              padding: const EdgeInsets.all(Spacing.sm),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9).withAlpha(120),
                                borderRadius: Radii.smAll,
                                border: Border.all(color: const Color(0xFFC8E6C9)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cash Memo',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: const Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Spacing.xs),
                                  Text(
                                    '+ ${Formatters.formatCurrency(data.totalReceived)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                  Text(
                                    '${data.cashMemos.length} collections',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MoneySpentScreen(month: _currentMonth),
                                ),
                              );
                            },
                            borderRadius: Radii.smAll,
                            child: Container(
                              padding: const EdgeInsets.all(Spacing.sm),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE).withAlpha(120),
                                borderRadius: Radii.smAll,
                                border: Border.all(color: const Color(0xFFFFCDD2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Expenses',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: const Color(0xFFD32F2F),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: Color(0xFFD32F2F),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Spacing.xs),
                                  Text(
                                    '- ${Formatters.formatCurrency(data.totalSpent)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD32F2F),
                                    ),
                                  ),
                                  Text(
                                    '${data.expenses.length} records',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // 2. Expenses Section
              AppCard(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFEBEE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.north_east, size: 16, color: Color(0xFFD32F2F)),
                            ),
                            const SizedBox(width: Spacing.sm),
                            Text(
                              'Expenses',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MoneySpentScreen(month: _currentMonth),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    if (recentExpenses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                        child: Center(
                          child: Text(
                            'No expenses recorded for this month.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentExpenses.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 48),
                        itemBuilder: (context, i) => _PreviewExpenseRow(item: recentExpenses[i]),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // 3. Cash Memos Section
              AppCard(
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.south_west, size: 16, color: Color(0xFF2E7D32)),
                            ),
                            const SizedBox(width: Spacing.sm),
                            Text(
                              'Cash Memo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MoneyReceivedScreen(month: _currentMonth),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    if (recentReceived.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                        child: Center(
                          child: Text(
                            'No collections recorded for this month.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentReceived.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 48),
                        itemBuilder: (context, i) => _PreviewReceivedRow(item: recentReceived[i]),
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

class _PreviewExpenseRow extends StatelessWidget {
  final ExpenseWithClinic item;

  const _PreviewExpenseRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final exp = item.expense;

    final title = exp.notes != null && exp.notes!.trim().isNotEmpty
        ? exp.notes!
        : (exp.subcategory != null && exp.subcategory!.trim().isNotEmpty
            ? '${exp.category} (${exp.subcategory})'
            : exp.category);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(expenseItem: item),
          ),
        );
      },
      leading: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEBEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.north_east,
          size: 16,
          color: Color(0xFFD32F2F),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      subtitle: Text(
        Formatters.formatDayMonth(exp.date),
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '- ${Formatters.formatCurrency(exp.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PaymentIcons.forMethod(exp.paymentMethod),
                size: 12,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                exp.paymentMethod,
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

class _PreviewReceivedRow extends StatelessWidget {
  final CashMemoWithDetails item;

  const _PreviewReceivedRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final memo = item.memo;
    final patient = item.patient;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(memoItem: item),
          ),
        );
      },
      leading: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.south_west,
          size: 16,
          color: Color(0xFF2E7D32),
        ),
      ),
      title: Text(
        patient.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      subtitle: Text(
        Formatters.formatDayMonth(memo.memoDate),
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '+ ${Formatters.formatCurrency(memo.paidAmount)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PaymentIcons.forMethod(memo.paymentMethod),
                size: 12,
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
