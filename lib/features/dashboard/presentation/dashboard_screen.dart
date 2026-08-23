import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../cashmemo/presentation/new_cash_memo_dialog.dart';
import '../../expenses/presentation/add_expense_dialog.dart';
import '../../patients/presentation/add_patient_dialog.dart';
import '../../patients/providers/recall_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../settings/providers/doctor_profile_provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/daily_insight_card.dart';
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
            padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
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
                              final profile =
                                  ref.watch(doctorProfileStreamProvider).value;
                              final greetingName = profile?.greetingName ?? '';
                              final name = greetingName.isNotEmpty
                                  ? greetingName
                                  : (ref.watch(doctorNameProvider).value ?? '');
                              final cleanName = () {
                                if (name.isEmpty) return '';
                                final stripped = name
                                    .replaceFirst(
                                        RegExp(r'^Dr\.?\s*',
                                            caseSensitive: false),
                                        '')
                                    .trim();
                                if (stripped.isEmpty) return name;
                                final parts =
                                    stripped.split(RegExp(r'\s+'));
                                return 'Dr. ${parts.last}';
                              }();
                              return cleanName.isEmpty
                                  ? '${Formatters.greeting(now)} 👋'
                                  : '${Formatters.greeting(now)}, $cleanName 👋';
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
                MetricCard(
                  label: "Today's Patients",
                  value: '${stats.todayPatients}',
                  numericValue: stats.todayPatients.toDouble(),
                  icon: Icons.person_outline,
                  tone: MetricTone.neutral,
                ),
                MetricCard(
                  label: "Today's Revenue",
                  value: Formatters.formatCurrency(stats.todayRevenue),
                  numericValue: stats.todayRevenue,
                  icon: Icons.currency_rupee,
                  tone: MetricTone.positive,
                ),
                MetricCard(
                  label: "Today's Profit",
                  value: Formatters.formatCurrency(stats.todayNetProfit),
                  numericValue: stats.todayNetProfit,
                  icon: Icons.currency_rupee,
                  tone: stats.todayNetProfit < 0
                      ? MetricTone.negative
                      : MetricTone.positive,
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
                MetricCard(
                  label: 'Revenue',
                  value: Formatters.formatCurrency(stats.monthlyRevenue),
                  numericValue: stats.monthlyRevenue,
                  icon: Icons.currency_rupee,
                  tone: MetricTone.positive,
                ),
                MetricCard(
                  label: 'Expenses',
                  value: Formatters.formatCurrency(stats.monthlyExpense),
                  numericValue: stats.monthlyExpense,
                  icon: Icons.cancel_outlined,
                  tone: MetricTone.negative,
                ),
                MetricCard(
                  label: 'Net Profit',
                  value: Formatters.formatCurrency(stats.monthlyNetProfit),
                  numericValue: stats.monthlyNetProfit,
                  icon: Icons.currency_rupee,
                  tone: stats.monthlyNetProfit < 0
                      ? MetricTone.negative
                      : MetricTone.positive,
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
                MetricCard(
                  label: 'Total Patients',
                  value: '${stats.totalPatients}',
                  icon: Icons.person_add_outlined,
                  tone: MetricTone.neutral,
                ),
                MetricCard(
                  label: 'New This Month',
                  value: '${stats.monthlyNewPatients}',
                  icon: Icons.person_add_outlined,
                  tone: MetricTone.neutral,
                ),
                MetricCard(
                  label: 'Repeat This Month',
                  value: '${stats.monthlyRepeatPatients}',
                  icon: Icons.person_add_outlined,
                  tone: MetricTone.neutral,
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
                          child: AppButton.tonal(
                            label: 'Add Patient',
                            icon: Icons.person_add_outlined,
                            fullWidth: true,
                            onPressed: () {
                              AppHaptics.selection();
                              showDialog(
                                context: context,
                                builder: (_) => const AddPatientDialog(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: AppButton.tonal(
                            label: 'Create Memo',
                            icon: Icons.receipt_long_outlined,
                            fullWidth: true,
                            onPressed: () {
                              AppHaptics.selection();
                              showDialog(
                                context: context,
                                builder: (_) => const NewCashMemoDialog(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    AppButton.outlined(
                      label: 'Log Expense',
                      icon: Icons.money_off_outlined,
                      fullWidth: true,
                      onPressed: () {
                        AppHaptics.selection();
                        showDialog(
                          context: context,
                          builder: (_) => const AddExpenseDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              const DailyInsightCard(),
            ],
          ),
        ),
      ),
    );
  }
}

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
