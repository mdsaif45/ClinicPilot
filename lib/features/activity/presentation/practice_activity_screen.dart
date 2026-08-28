import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';
import '../providers/practice_activity_provider.dart';
import 'widgets/activity_journal_feed.dart';
import 'widgets/hourly_rush_chart.dart';
import 'widgets/monthly_bubble_matrix.dart';
import 'widgets/weekly_benchmark_chart.dart';

class PracticeActivityScreen extends ConsumerWidget {
  const PracticeActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceActivityProvider);
    final range = ref.watch(activityRangeProvider);
    final metric = ref.watch(activityMetricProvider);
    final selectedDate = ref.watch(selectedActivityDateProvider);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    final primaryColor = metric == ActivityMetric.revenue
        ? scheme.primary
        : scheme.secondary;

    // Compute Date Range Title & isCurrentPeriod
    String rangeTitle;
    bool isCurrentPeriod;

    switch (range) {
      case ActivityTimeRange.day:
        final isToday = selectedDate.year == todayMidnight.year &&
            selectedDate.month == todayMidnight.month &&
            selectedDate.day == todayMidnight.day;
        final isYesterday = () {
          final y = todayMidnight.subtract(const Duration(days: 1));
          return selectedDate.year == y.year &&
              selectedDate.month == y.month &&
              selectedDate.day == y.day;
        }();

        if (isToday) {
          rangeTitle = 'Today, ${DateFormat('d MMMM').format(selectedDate)}';
        } else if (isYesterday) {
          rangeTitle = 'Yesterday, ${DateFormat('d MMMM').format(selectedDate)}';
        } else {
          rangeTitle = DateFormat('EEEE, d MMMM').format(selectedDate);
        }
        isCurrentPeriod = isToday;
        break;

      case ActivityTimeRange.week:
        final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        rangeTitle = '${DateFormat('d MMM').format(weekStart)} – ${DateFormat('d MMM').format(weekEnd)}';
        final curWeekStart = todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));
        isCurrentPeriod = weekStart.year == curWeekStart.year &&
            weekStart.month == curWeekStart.month &&
            weekStart.day == curWeekStart.day;
        break;

      case ActivityTimeRange.month:
        rangeTitle = DateFormat('MMMM yyyy').format(selectedDate);
        isCurrentPeriod = selectedDate.year == todayMidnight.year &&
            selectedDate.month == todayMidnight.month;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Activity'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_stories_outlined),
            tooltip: 'Practice Journal',
            onPressed: () {
              AppHaptics.light();
              context.push('/growth/journal');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
        children: [
          // 1. Google Fit Style Animated Sliding Segmented Tabs (Day | Week | Month)
          _ActivityTimeRangeTabs(
            selectedRange: range,
            onRangeChanged: (newRange) {
              ref.read(activityRangeProvider.notifier).state = newRange;
            },
          ),

          const SizedBox(height: Spacing.lg),

          // 2. Date Navigation Controls (< Friday, Aug 28 >)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous',
                onPressed: () {
                  AppHaptics.selection();
                  switch (range) {
                    case ActivityTimeRange.day:
                      ref.read(selectedActivityDateProvider.notifier).state =
                          DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 1);
                      break;
                    case ActivityTimeRange.week:
                      ref.read(selectedActivityDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 7));
                      break;
                    case ActivityTimeRange.month:
                      ref.read(selectedActivityDateProvider.notifier).state =
                          DateTime(selectedDate.year, selectedDate.month - 1, 1);
                      break;
                  }
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            rangeTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isCurrentPeriod) ...[
                          const SizedBox(width: Spacing.xs),
                          InkWell(
                            onTap: () {
                              AppHaptics.selection();
                              ref.read(selectedActivityDateProvider.notifier).state = todayMidnight;
                            },
                            borderRadius: Radii.smAll,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: CustomBadge(
                                label: range == ActivityTimeRange.day
                                    ? 'Today'
                                    : range == ActivityTimeRange.week
                                        ? 'This Week'
                                        : 'This Month',
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Summary Subtitle (Google Fit style: accent icon + subtle metric text)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          metric == ActivityMetric.revenue
                              ? Icons.currency_rupee
                              : Icons.person_outline,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          metric == ActivityMetric.revenue
                              ? Formatters.formatCurrency(state.totalRevenue).replaceAll('₹ ', '')
                              : '${state.totalPatients} patients',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next',
                onPressed: isCurrentPeriod
                    ? null
                    : () {
                        AppHaptics.selection();
                        switch (range) {
                          case ActivityTimeRange.day:
                            final next = DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1);
                            if (!next.isAfter(todayMidnight)) {
                              ref.read(selectedActivityDateProvider.notifier).state = next;
                            }
                            break;
                          case ActivityTimeRange.week:
                            final next = selectedDate.add(const Duration(days: 7));
                            if (!next.isAfter(todayMidnight)) {
                              ref.read(selectedActivityDateProvider.notifier).state = next;
                            }
                            break;
                          case ActivityTimeRange.month:
                            final next = DateTime(selectedDate.year, selectedDate.month + 1, 1);
                            if (!next.isAfter(todayMidnight)) {
                              ref.read(selectedActivityDateProvider.notifier).state = next;
                            }
                            break;
                        }
                      },
              ),
            ],
          ),

          const SizedBox(height: Spacing.md),

          // 3. Main Dynamic Chart Container
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: Radii.lgAll,
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: () {
              switch (range) {
                case ActivityTimeRange.day:
                  return HourlyRushChart(
                    bins: state.hourlyBins,
                    metric: metric,
                    peakRushDescription: state.peakRushDescription,
                  );
                case ActivityTimeRange.week:
                  return WeeklyBenchmarkChart(
                    bins: state.weeklyBins,
                    metric: metric,
                    targetValue: state.weeklyTargetValue,
                    achievementPercent: state.weeklyAchievementPercent,
                  );
                case ActivityTimeRange.month:
                  return MonthlyBubbleMatrix(
                    bubbleDays: state.monthlyBubbleDays,
                    weeklySubtotals: state.monthlyWeeklySubtotals,
                    metric: metric,
                    onDaySelected: (date) {
                      ref.read(selectedActivityDateProvider.notifier).state = date;
                      ref.read(activityRangeProvider.notifier).state = ActivityTimeRange.day;
                    },
                  );
              }
            }(),
          ),

          const SizedBox(height: Spacing.md),

          // 4. Metric Pill Switcher (Revenue vs Patients)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetricPill(
                context,
                ref,
                label: 'Revenue',
                icon: Icons.currency_rupee,
                color: scheme.primary,
                isSelected: metric == ActivityMetric.revenue,
                onTap: () {
                  AppHaptics.selection();
                  ref.read(activityMetricProvider.notifier).state = ActivityMetric.revenue;
                },
              ),
              const SizedBox(width: Spacing.sm),
              _buildMetricPill(
                context,
                ref,
                label: 'Patients',
                icon: Icons.people_outline,
                color: scheme.secondary,
                isSelected: metric == ActivityMetric.patients,
                onTap: () {
                  AppHaptics.selection();
                  ref.read(activityMetricProvider.notifier).state = ActivityMetric.patients;
                },
              ),
            ],
          ),

          const SizedBox(height: Spacing.sm),

          // 5. Contextual Insight Description
          Text(
            metric == ActivityMetric.revenue
                ? 'Revenue visualizes clinic cash flow and fees collected across practice operating hours.'
                : 'Patient volume tracks consultation footfall and clinic rush periods across the day.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: Spacing.lg),

          // 6. Restored Google Fit Style Feed / Breakdown
          if (range == ActivityTimeRange.week)
            _buildWeeklyDaysList(context, ref, state, primaryColor)
          else
            ActivityJournalFeed(items: state.timelineItems),
        ],
      ),
    );
  }

  Widget _buildWeeklyDaysList(
    BuildContext context,
    WidgetRef ref,
    PracticeActivityState state,
    Color primaryColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final metric = state.metric;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.weeklyBins.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: Spacing.sm,
        endIndent: Spacing.sm,
        color: scheme.outlineVariant.withValues(alpha: 0.25),
      ),
      itemBuilder: (context, index) {
        final bin = state.weeklyBins[index];
        final fullDateStr = DateFormat('EEEE, d MMMM yyyy').format(bin.date);
        final valStr = metric == ActivityMetric.revenue
            ? Formatters.formatCurrency(bin.revenue)
            : '${bin.patients} patients';

        return InkWell(
          onTap: () {
            AppHaptics.selection();
            ref.read(selectedActivityDateProvider.notifier).state = bin.date;
            ref.read(activityRangeProvider.notifier).state = ActivityTimeRange.day;
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullDateStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        valStr,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (bin.isTargetMet)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricPill(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : scheme.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTimeRangeTabs extends StatelessWidget {
  final ActivityTimeRange selectedRange;
  final ValueChanged<ActivityTimeRange> onRangeChanged;

  const _ActivityTimeRangeTabs({
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final selectedIndex = selectedRange.index; // 0: Day, 1: Week, 2: Month
    final alignX = selectedIndex == 0 ? -1.0 : (selectedIndex == 1 ? 0.0 : 1.0);

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3.0;

          return Stack(
            children: [
              // Smooth Sliding Floating Pill Background
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment(alignX, 0),
                child: Container(
                  width: tabWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              // 3 Interactive Tabs
              Row(
                children: [
                  _buildTab(context, scheme, theme, 'Day', ActivityTimeRange.day),
                  _buildTab(context, scheme, theme, 'Week', ActivityTimeRange.week),
                  _buildTab(context, scheme, theme, 'Month', ActivityTimeRange.month),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
    String label,
    ActivityTimeRange range,
  ) {
    final isSelected = selectedRange == range;

    return Expanded(
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onRangeChanged(range);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
