import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      body: statsAsync.when(
        loading: () => const DashboardShimmer(),
        error: (e, _) => Center(child: Text('Could not load dashboard: $e')),
        data:
            (stats) => RefreshIndicator(
              onRefresh: () async {
                AppHaptics.selection();
                ref.invalidate(dashboardStatsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  Spacing.sm,
                  0,
                  Spacing.xxl,
                ),
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
                                      ref
                                          .watch(doctorProfileStreamProvider)
                                          .value;
                                  final greetingName =
                                      profile?.greetingName ?? '';
                                  final name =
                                      greetingName.isNotEmpty
                                          ? greetingName
                                          : (ref
                                                  .watch(doctorNameProvider)
                                                  .value ??
                                              '');
                                  final cleanName = () {
                                    if (name.isEmpty) return '';
                                    final stripped =
                                        name
                                            .replaceFirst(
                                              RegExp(
                                                r'^Dr\.?\s*',
                                                caseSensitive: false,
                                              ),
                                              '',
                                            )
                                            .trim();
                                    if (stripped.isEmpty) return name;
                                    final parts = stripped.split(
                                      RegExp(r'\s+'),
                                    );
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
                  // 2. Date-Navigable Daily Clinic Snapshot (Isolated & Smoothly Animated)
                  const _DailySnapshotSection(),

                  // 4. Date-Navigable Monthly Clinic Snapshot & Goals
                  const _MonthlySnapshotSection(),

                  // 6. Patients Summary
                  const SectionHeader(title: 'Patients Summary'),
                  _TileRow(
                    children: [
                      MetricCard(
                        label: 'Total Patients',
                        value: '${stats.totalPatients}',
                        subtitle: '${stats.totalRepeatPatients} repeat',
                        icon: Icons.people_alt_outlined,
                        tone: MetricTone.neutral,
                      ),
                      MetricCard(
                        label: 'New Patients',
                        value: '${stats.monthlyNewPatients}',
                        subtitle: 'this month',
                        icon: Icons.person_add_outlined,
                        tone: MetricTone.neutral,
                      ),
                      MetricCard(
                        label: 'Repeat Patients',
                        value: '${stats.monthlyRepeatPatients}',
                        subtitle: 'this month',
                        icon: Icons.replay,
                        tone: MetricTone.neutral,
                      ),
                    ],
                  ),

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

class _DailySnapshotSection extends ConsumerWidget {
  const _DailySnapshotSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDashboardDateProvider);
    final daily = ref.watch(dailyStatsProvider);

    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DailySnapshotHeader(selectedDate: selectedDate),
        _TileRow(
          children: [
            MetricCard(
              label: isToday ? "Today's Patients" : 'Patients',
              value: '${daily.dailyPatients}',
              numericValue: daily.dailyPatients.toDouble(),
              icon: Icons.person_outline,
              tone: MetricTone.neutral,
            ),
            MetricCard(
              label: isToday ? "Today's Revenue" : 'Revenue',
              value: Formatters.formatCurrency(daily.dailyRevenue),
              numericValue: daily.dailyRevenue,
              icon: Icons.currency_rupee,
              tone: MetricTone.positive,
            ),
            MetricCard(
              label: isToday ? "Today's Profit" : 'Profit',
              value: Formatters.formatCurrency(daily.dailyNetProfit),
              numericValue: daily.dailyNetProfit,
              icon: Icons.currency_rupee,
              tone:
                  daily.dailyNetProfit < 0
                      ? MetricTone.negative
                      : MetricTone.positive,
            ),
          ],
        ),
      ],
    );
  }
}

class _DailySnapshotHeader extends ConsumerWidget {
  final DateTime selectedDate;

  const _DailySnapshotHeader({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
    final isYesterday =
        selectedDate.year == yesterday.year &&
        selectedDate.month == yesterday.month &&
        selectedDate.day == yesterday.day;

    String dateTitle;
    if (isToday) {
      dateTitle = 'Today';
    } else if (isYesterday) {
      dateTitle = 'Yesterday';
    } else {
      dateTitle = DateFormat('d MMM, EEE').format(selectedDate);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.sm,
        Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Quick Jump to Today (Enterprise standard Option 1)
          if (!isToday) ...[
            InkWell(
              onTap: () {
                AppHaptics.selection();
                ref.read(selectedDashboardDateProvider.notifier).state = today;
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 13, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Today',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          // Date Traversal Controls (< DatePicker >)
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Day',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              AppHaptics.selection();
              ref.read(selectedDashboardDateProvider.notifier).state = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day - 1,
              );
            },
          ),
          InkWell(
            onTap: () async {
              AppHaptics.selection();
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate.isAfter(today) ? today : selectedDate,
                firstDate: DateTime(2020),
                lastDate: today,
              );
              if (picked != null) {
                ref
                    .read(selectedDashboardDateProvider.notifier)
                    .state = DateTime(picked.year, picked.month, picked.day);
              }
            },
            borderRadius: Radii.smAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: isToday ? scheme.onSurfaceVariant : scheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('d MMM').format(selectedDate),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isToday ? FontWeight.w500 : FontWeight.w700,
                      color: isToday ? scheme.onSurfaceVariant : scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Day',
            visualDensity: VisualDensity.compact,
            onPressed:
                isToday
                    ? null
                    : () {
                      AppHaptics.selection();
                      final next = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day + 1,
                      );
                      if (!next.isAfter(today)) {
                        ref.read(selectedDashboardDateProvider.notifier).state =
                            next;
                      }
                    },
          ),
        ],
      ),
    );
  }
}

class _MonthlySnapshotSection extends ConsumerStatefulWidget {
  const _MonthlySnapshotSection();

  @override
  ConsumerState<_MonthlySnapshotSection> createState() =>
      _MonthlySnapshotSectionState();
}

class _MonthlySnapshotSectionState
    extends ConsumerState<_MonthlySnapshotSection> {
  bool _showGoals = false;

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedDashboardMonthProvider);
    final monthly = ref.watch(monthlyStatsProvider);
    final stats = ref.watch(dashboardStatsProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthlySnapshotHeader(
          selectedMonth: selectedMonth,
          showGoals: _showGoals,
          onToggleGoals: () {
            AppHaptics.selection();
            setState(() => _showGoals = !_showGoals);
          },
        ),
        _TileRow(
          children: [
            MetricCard(
              label: 'Revenue',
              value: Formatters.formatCurrency(monthly.monthlyRevenue),
              numericValue: monthly.monthlyRevenue,
              icon: Icons.currency_rupee,
              tone: MetricTone.positive,
            ),
            MetricCard(
              label: 'Expenses',
              value: Formatters.formatCurrency(monthly.monthlyExpense),
              numericValue: monthly.monthlyExpense,
              icon: Icons.cancel_outlined,
              tone: MetricTone.negative,
            ),
            MetricCard(
              label: 'Net Profit',
              value: Formatters.formatCurrency(monthly.monthlyNetProfit),
              numericValue: monthly.monthlyNetProfit,
              icon: Icons.currency_rupee,
              tone:
                  monthly.monthlyNetProfit < 0
                      ? MetricTone.negative
                      : MetricTone.positive,
            ),
          ],
        ),
        if (_showGoals && stats != null) ...[
          const SizedBox(height: Spacing.sm),
          GoalTrackerCard(
            stats: DashboardStats(
              todayRevenue: stats.todayRevenue,
              todayExpense: stats.todayExpense,
              todayNetProfit: stats.todayNetProfit,
              todayPatients: stats.todayPatients,
              monthlyRevenue: monthly.monthlyRevenue,
              monthlyExpense: monthly.monthlyExpense,
              monthlyNetProfit: monthly.monthlyNetProfit,
              monthlyRevenueGoal: monthly.monthlyRevenueGoal,
              totalPatients: monthly.totalPatients,
              monthlyNewPatients: monthly.monthlyNewPatients,
              monthlyRepeatPatients: monthly.monthlyRepeatPatients,
              monthlyNewPatientGoal: monthly.monthlyNewPatientGoal,
            ),
            now: selectedMonth,
          ),
        ],
      ],
    );
  }
}

class _MonthlySnapshotHeader extends ConsumerWidget {
  final DateTime selectedMonth;
  final bool showGoals;
  final VoidCallback onToggleGoals;

  const _MonthlySnapshotHeader({
    required this.selectedMonth,
    required this.showGoals,
    required this.onToggleGoals,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final isCurrentMonth =
        selectedMonth.year == currentMonth.year &&
        selectedMonth.month == currentMonth.month;
    final isLastMonth =
        selectedMonth.year == lastMonth.year &&
        selectedMonth.month == lastMonth.month;

    String monthTitle;
    if (isCurrentMonth) {
      monthTitle = 'This Month (${DateFormat('MMMM').format(now)})';
    } else if (isLastMonth) {
      monthTitle = 'Last Month (${DateFormat('MMMM').format(selectedMonth)})';
    } else {
      monthTitle = DateFormat('MMMM yyyy').format(selectedMonth);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.sm,
        Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onToggleGoals,
              borderRadius: Radii.smAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        monthTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      showGoals ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Quick Jump to This Month (Enterprise standard Option 1)
          if (!isCurrentMonth) ...[
            InkWell(
              onTap: () {
                AppHaptics.selection();
                ref.read(selectedDashboardMonthProvider.notifier).state =
                    currentMonth;
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 13, color: scheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'This Month',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          // Month Traversal Controls (< MonthPicker >)
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Month',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              AppHaptics.selection();
              ref.read(selectedDashboardMonthProvider.notifier).state =
                  DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color:
                      isCurrentMonth ? scheme.onSurfaceVariant : scheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM yyyy').format(selectedMonth),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight:
                        isCurrentMonth ? FontWeight.w500 : FontWeight.w700,
                    color:
                        isCurrentMonth
                            ? scheme.onSurfaceVariant
                            : scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Month',
            visualDensity: VisualDensity.compact,
            onPressed:
                isCurrentMonth
                    ? null
                    : () {
                      AppHaptics.selection();
                      final next = DateTime(
                        selectedMonth.year,
                        selectedMonth.month + 1,
                        1,
                      );
                      if (!next.isAfter(currentMonth)) {
                        ref
                            .read(selectedDashboardMonthProvider.notifier)
                            .state = next;
                      }
                    },
          ),
        ],
      ),
    );
  }
}
