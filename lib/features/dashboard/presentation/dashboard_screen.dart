import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../cashmemo/presentation/new_cash_memo_dialog.dart';
import '../../expenses/presentation/add_expense_dialog.dart';
import '../../patients/presentation/add_patient_dialog.dart';
import '../../patients/providers/recall_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load dashboard: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.only(bottom: Spacing.xxl),
          children: [
            // Greeting reflects the actual time of day; a fixed "Good Day"
            // reads as an unfinished placeholder.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Formatters.greeting(now)}, Dr. Zaid 👋',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          // Clinic name lives in the app bar switcher directly
                          // above; repeating it here said the same thing twice.
                          Formatters.formatFullDate(now),
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SectionHeader(title: 'Today'),
            _TileRow(children: [
              _MiniTile(
                label: "Today's Revenue",
                value: Formatters.formatCurrency(stats.todayRevenue),
                tone: _Tone.positive,
              ),
              _MiniTile(
                label: "Today's Expenses",
                value: Formatters.formatCurrency(stats.todayExpense),
                tone: _Tone.negative,
              ),
              _MiniTile(
                label: "Today's Profit",
                value: Formatters.formatCurrency(stats.todayNetProfit),
                tone: stats.todayNetProfit < 0 ? _Tone.negative : _Tone.positive,
              ),
            ]),

            SectionHeader(title: 'Monthly Overview (${Formatters.formatMonthYear(now)})'),
            _TileRow(children: [
              _MiniTile(
                label: 'Revenue',
                value: Formatters.formatCurrency(stats.monthlyRevenue),
                tone: _Tone.positive,
              ),
              _MiniTile(
                label: 'Expenses',
                value: Formatters.formatCurrency(stats.monthlyExpense),
                tone: _Tone.negative,
              ),
              _MiniTile(
                label: 'Net Profit',
                value: Formatters.formatCurrency(stats.monthlyNetProfit),
                tone:
                    stats.monthlyNetProfit < 0 ? _Tone.negative : _Tone.positive,
              ),
            ]),

            const SectionHeader(title: 'Patients Overview'),
            _TileRow(children: [
              _MiniTile(
                label: 'Total Patients',
                value: '${stats.totalPatients}',
                tone: _Tone.neutral,
              ),
              _MiniTile(
                label: 'New Patients',
                value: '${stats.monthlyNewPatients}',
                tone: _Tone.neutral,
              ),
              _MiniTile(
                label: 'Repeat Patients',
                value: '${stats.monthlyRepeatPatients}',
                tone: _Tone.neutral,
              ),
            ]),

            const SectionHeader(title: 'Monthly Growth'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: _GrowthTile(
                      label: 'Revenue Growth',
                      percent: stats.revenueGrowthPercent,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: _GrowthTile(
                      label: 'Patient Growth',
                      percent: stats.patientGrowthPercent,
                    ),
                  ),
                ],
              ),
            ),

            SectionHeader(
                title: 'Goal Progress (${Formatters.formatMonthYear(now)})'),
            AppCard(
              child: Builder(builder: (context) {
                final remaining =
                    stats.monthlyRevenueGoal - stats.monthlyRevenue;
                final pct = (stats.revenueGoalProgress * 100);

                // Days left in the month, and what each remaining clinic day
                // has to earn. "Rs 4,850 a day" is actionable in a way that
                // "2% of goal" is not.
                final lastDay =
                    DateTime(now.year, now.month + 1, 0).day;
                final daysLeft = (lastDay - now.day) + 1;
                final perDay = daysLeft > 0 ? remaining / daysLeft : remaining;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Earned leads. The target is context, not the headline.
                        Text(
                          Formatters.formatCurrency(stats.monthlyRevenue),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            'of ${Formatters.formatCurrency(stats.monthlyRevenueGoal)}',
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    ClipRRect(
                      borderRadius: Radii.pillAll,
                      child: LinearProgressIndicator(
                        value: stats.revenueGoalProgress,
                        minHeight: 12,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    if (remaining <= 0)
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            'Target reached',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _GoalFact(
                              label: 'Still needed',
                              value: Formatters.formatCurrency(remaining),
                            ),
                          ),
                          Expanded(
                            child: _GoalFact(
                              label: '$daysLeft '
                                  '${daysLeft == 1 ? 'day' : 'days'} left',
                              value:
                                  '${Formatters.formatCurrency(perDay)}/day',
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              }),
            ),

            // Surfaced on the landing screen rather than buried: a recall
            // list only works if it is seen without being sought.
            Consumer(builder: (context, ref, _) {
              final lists = ref.watch(recallListProvider).value;
              final count = lists == null
                  ? 0
                  : lists.overdue.length + lists.lapsed.length;
              if (count == 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.lg,
                  0,
                ),
                child: Material(
                  color: theme.colorScheme.errorContainer
                      .withValues(alpha: 0.35),
                  borderRadius: Radii.mdAll,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/recall'),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active_outlined,
                              color: theme.colorScheme.error),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  count == 1
                                      ? '1 patient needs following up'
                                      : '$count patients need following up',
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  'Overdue or not seen in a while',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SectionHeader(title: 'Quick Actions'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const AddPatientDialog(),
                          ),
                          icon: const Icon(Icons.person_add_outlined),
                          label: const Text('Add Patient'),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const NewCashMemoDialog(),
                          ),
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('Create Memo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const AddExpenseDialog(),
                          ),
                          icon: const Icon(Icons.money_off),
                          label: const Text('Log Expense'),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/comparison'),
                          icon: const Icon(Icons.compare_arrows),
                          label: const Text('Compare'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { positive, negative, neutral }

/// Three tiles side by side, matching the compact overview rows.
class _TileRow extends StatelessWidget {
  final List<Widget> children;

  const _TileRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: Spacing.md),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String label;
  final String value;
  final _Tone tone;

  const _MiniTile({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final (fg, bg) = switch (tone) {
      _Tone.positive => (scheme.primary, scheme.primaryContainer),
      _Tone.negative => (scheme.error, scheme.errorContainer),
      _Tone.neutral => (scheme.onSurface, scheme.surfaceContainerHighest),
    };

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Month-over-month change. Renders a dash when there is no prior month to
/// compare against, rather than an inflated percentage.
class _GrowthTile extends StatelessWidget {
  final String label;
  final double? percent;

  const _GrowthTile({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = percent;
    final rising = (p ?? 0) >= 0;
    final colour = p == null
        ? scheme.onSurfaceVariant
        : (rising ? scheme.primary : scheme.error);

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Icon(
                p == null
                    ? Icons.remove
                    : (rising ? Icons.trending_up : Icons.trending_down),
                size: 18,
                color: colour,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                p == null
                    ? 'No prior month'
                    : '${rising ? '+' : ''}${p.toStringAsFixed(1)}%',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: colour, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One label/value pair inside the goal card.
class _GoalFact extends StatelessWidget {
  final String label;
  final String value;

  const _GoalFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
