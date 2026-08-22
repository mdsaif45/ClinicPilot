import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../cashmemo/presentation/new_cash_memo_dialog.dart';
import '../../expenses/presentation/add_expense_dialog.dart';
import '../../patients/presentation/add_patient_dialog.dart';
import '../../patients/providers/recall_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/goal_tracker_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showGoals = false;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      body: statsAsync.when(
        loading: () => const DashboardShimmer(),
        error: (e, _) => Center(child: Text('Could not load dashboard: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            AppHaptics.selection();
            ref.invalidate(dashboardStatsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: Spacing.xxl),
            children: [
              // 1. Top Greeting Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            () {
                              final name =
                                  ref.watch(doctorNameProvider).value ?? '';
                              return name.isEmpty
                                  ? '${Formatters.greeting(now)} 👋'
                                  : '${Formatters.greeting(now)}, $name 👋';
                            }(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            Formatters.formatFullDate(now),
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xs),

              // 2. Patient Follow-up Alert (Only surfaces when overdue patients exist)
              Consumer(builder: (context, ref, _) {
                final lists = ref.watch(recallListProvider).value;
                final count = lists == null
                    ? 0
                    : lists.overdue.length + lists.lapsed.length;
                if (count == 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    Spacing.sm,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                          vertical: Spacing.md,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_active_outlined,
                                color: theme.colorScheme.error, size: 22),
                            const SizedBox(width: Spacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    count == 1
                                        ? '1 patient needs following up'
                                        : '$count patients need following up',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Overdue for consultation or review',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 3. Today's Clinic Snapshot
              const SectionHeader(title: 'Today'),
              _TileRow(children: [
                _MiniTile(
                  label: "Today's Patients",
                  value: '${stats.todayPatients}',
                  numericValue: stats.todayPatients.toDouble(),
                  tone: _Tone.neutral,
                ),
                _MiniTile(
                  label: "Today's Revenue",
                  value: Formatters.formatCurrency(stats.todayRevenue),
                  numericValue: stats.todayRevenue,
                  tone: _Tone.positive,
                ),
                _MiniTile(
                  label: "Today's Profit",
                  value: Formatters.formatCurrency(stats.todayNetProfit),
                  numericValue: stats.todayNetProfit,
                  tone: stats.todayNetProfit < 0
                      ? _Tone.negative
                      : _Tone.positive,
                ),
              ]),

              // 4. This Month at a Glance (Year removed from title)
              SectionHeader(
                title: 'This Month (${DateFormat('MMMM').format(now)})',
                onAction: () {
                  AppHaptics.selection();
                  setState(() => _showGoals = !_showGoals);
                },
                actionIcon: _showGoals ? Icons.expand_less : Icons.expand_more,
              ),
              _TileRow(children: [
                _MiniTile(
                  label: 'Revenue',
                  value: Formatters.formatCurrency(stats.monthlyRevenue),
                  numericValue: stats.monthlyRevenue,
                  tone: _Tone.positive,
                ),
                _MiniTile(
                  label: 'Expenses',
                  value: Formatters.formatCurrency(stats.monthlyExpense),
                  numericValue: stats.monthlyExpense,
                  tone: _Tone.negative,
                ),
                _MiniTile(
                  label: 'Net Profit',
                  value: Formatters.formatCurrency(stats.monthlyNetProfit),
                  numericValue: stats.monthlyNetProfit,
                  tone: stats.monthlyNetProfit < 0
                      ? _Tone.negative
                      : _Tone.positive,
                ),
              ]),

              // 5. Goal Progress Card (Moved directly under This Month, hidden by default)
              if (_showGoals) ...[
                const SizedBox(height: Spacing.sm),
                GoalTrackerCard(stats: stats, now: now),
              ],

              // 6. Patients Summary
              const SectionHeader(title: 'Patients Summary'),
              _TileRow(children: [
                _MiniTile(
                  label: 'Total Patients',
                  value: '${stats.totalPatients}',
                  tone: _Tone.neutral,
                ),
                _MiniTile(
                  label: 'New This Month',
                  value: '${stats.monthlyNewPatients}',
                  tone: _Tone.neutral,
                ),
                _MiniTile(
                  label: 'Repeat This Month',
                  value: '${stats.monthlyRepeatPatients}',
                  tone: _Tone.neutral,
                ),
              ]),

              // 7. Quick Actions at bottom
              const SectionHeader(title: 'Quick Actions'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: Radii.mdAll,
                              ),
                            ),
                            onPressed: () {
                              AppHaptics.selection();
                              showDialog(
                                context: context,
                                builder: (_) => const AddPatientDialog(),
                              );
                            },
                            icon: const Icon(Icons.person_add_outlined, size: 18),
                            label: const Text('Add Patient'),
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: Radii.mdAll,
                              ),
                            ),
                            onPressed: () {
                              AppHaptics.selection();
                              showDialog(
                                context: context,
                                builder: (_) => const NewCashMemoDialog(),
                              );
                            },
                            icon: const Icon(Icons.receipt_long_outlined, size: 18),
                            label: const Text('Create Memo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: Radii.mdAll,
                          ),
                        ),
                        onPressed: () {
                          AppHaptics.selection();
                          showDialog(
                            context: context,
                            builder: (_) => const AddExpenseDialog(),
                          );
                        },
                        icon: const Icon(Icons.money_off_outlined, size: 18),
                        label: const Text('Log Expense'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Tone { positive, negative, neutral }

class _TileRow extends StatelessWidget {
  final List<Widget> children;

  const _TileRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: Spacing.md),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String label;
  final String value;
  final double? numericValue;
  final _Tone tone;

  const _MiniTile({
    required this.label,
    required this.value,
    this.numericValue,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (bg, border, text) = switch (tone) {
      _Tone.positive => (
          scheme.primaryContainer.withValues(alpha: 0.35),
          scheme.primary.withValues(alpha: 0.2),
          scheme.primary,
        ),
      _Tone.negative => (
          scheme.errorContainer.withValues(alpha: 0.35),
          scheme.error.withValues(alpha: 0.2),
          scheme.error,
        ),
      _Tone.neutral => (
          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          scheme.outlineVariant.withValues(alpha: 0.3),
          scheme.onSurface,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Radii.mdAll,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xs),
          if (numericValue != null)
            AnimatedCounter(
              value: numericValue!,
              formatter: (_) => value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: text,
              ),
            )
          else
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
