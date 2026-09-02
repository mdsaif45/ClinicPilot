import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/tokens.dart';
import '../providers/period_provider.dart';
import '../services/app_haptics.dart';
import '../utils/formatters.dart';

/// Compact month & period navigator for analytics and growth screens.
///
/// Styled like the primary month navigation bar: `< [ 🗓 September 2026 ⌵ ] >`
/// with previous/next chevrons for rapid 1-tap period switching, and a
/// centered pill that opens the period selection sheet (Today, This Week,
/// This Month, Last Month, Pick Month, Custom Range).
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(periodProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Previous Period (<) ──
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 22),
              tooltip: 'Previous Period',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                AppHaptics.selection();
                ref.read(periodProvider.notifier).previousPeriod();
              },
            ),
            const SizedBox(width: Spacing.xxs),

            // ── Center Period Pill [ 🗓 Month / Period ⌵ ] ──
            InkWell(
              onTap: () {
                AppHaptics.light();
                _pick(context, ref, state);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm + 4,
                  vertical: Spacing.xs + 1,
                ),
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
                      state.displayLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: Spacing.xxs),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Spacing.xxs),

            // ── Next Period (>) ──
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 22),
              tooltip: state.canGoForward ? 'Next Period' : 'Future period not available',
              visualDensity: VisualDensity.compact,
              onPressed: state.canGoForward
                  ? () {
                      AppHaptics.selection();
                      ref.read(periodProvider.notifier).nextPeriod();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    PeriodState state,
  ) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentFilter = state.filter;

    final now = DateTime.now();
    final isFullMonth = state.isFullMonth;
    final isThisMonth = isFullMonth &&
        state.dateRange.start.year == now.year &&
        state.dateRange.start.month == now.month;
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final isLastMonth = isFullMonth &&
        state.dateRange.start.year == lastMonth.year &&
        state.dateRange.start.month == lastMonth.month;
    final isSpecificMonth = isFullMonth && !isThisMonth && !isLastMonth;
    final isCustomRange = currentFilter == PeriodFilter.custom &&
        !isFullMonth &&
        !state.isSingleDay &&
        currentFilter != PeriodFilter.thisWeek;

    final chosen = await showModalBottomSheet<dynamic>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  0,
                  Spacing.lg,
                  Spacing.sm,
                ),
                child: Text(
                  'Period',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(height: 1),
            // Today
            ListTile(
              dense: true,
              leading: Icon(
                currentFilter == PeriodFilter.today
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: currentFilter == PeriodFilter.today
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              title: const Text('Today'),
              onTap: () => Navigator.of(ctx).pop(PeriodFilter.today),
            ),
            // This Week
            ListTile(
              dense: true,
              leading: Icon(
                currentFilter == PeriodFilter.thisWeek
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: currentFilter == PeriodFilter.thisWeek
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              title: const Text('This Week'),
              onTap: () => Navigator.of(ctx).pop(PeriodFilter.thisWeek),
            ),
            // This Month
            ListTile(
              dense: true,
              leading: Icon(
                isThisMonth
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isThisMonth
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              title: const Text('This Month'),
              subtitle: Text(Formatters.formatMonthYear(now)),
              onTap: () => Navigator.of(ctx).pop(PeriodFilter.thisMonth),
            ),
            // Last Month
            ListTile(
              dense: true,
              leading: Icon(
                isLastMonth
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isLastMonth
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              title: const Text('Last Month'),
              subtitle: Text(Formatters.formatMonthYear(lastMonth)),
              onTap: () => Navigator.of(ctx).pop(PeriodFilter.lastMonth),
            ),
            // Pick Specific Month (Calendar Year/Month jump)
            ListTile(
              dense: true,
              leading: Icon(
                isSpecificMonth
                    ? Icons.radio_button_checked
                    : Icons.calendar_view_month,
                color: isSpecificMonth
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              title: Text(
                isSpecificMonth
                    ? 'Specific Month (${Formatters.formatMonthYear(state.dateRange.start)})'
                    : 'Select Specific Month...',
                style: isSpecificMonth
                    ? TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      )
                    : null,
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => Navigator.of(ctx).pop('pick_month'),
            ),
            // Custom Date Range
            ListTile(
              dense: true,
              leading: Icon(
                isCustomRange
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isCustomRange
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
              title: const Text('Custom Range...'),
              trailing: const Icon(Icons.date_range, size: 20),
              onTap: () => Navigator.of(ctx).pop(PeriodFilter.custom),
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    ),
  );

    if (chosen == null || !context.mounted) return;

    if (chosen == 'pick_month') {
      final initial = state.dateRange.start.isAfter(now) ? now : state.dateRange.start;
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2020),
        lastDate: DateTime(now.year, now.month, 1),
        initialDatePickerMode: DatePickerMode.year,
        helpText: 'Select Practice Month',
      );
      if (picked != null && context.mounted) {
        ref.read(periodProvider.notifier).setMonth(picked);
      }
      return;
    }

    if (chosen == PeriodFilter.custom) {
      final start = state.dateRange.start.isAfter(now) ? now : state.dateRange.start;
      final end = state.dateRange.end.isAfter(now) ? now : state.dateRange.end;
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year, now.month, now.day),
        initialDateRange: DateTimeRange(start: start, end: end),
      );
      if (picked != null && context.mounted) {
        ref
            .read(periodProvider.notifier)
            .setFilter(PeriodFilter.custom, customRange: picked);
      }
      return;
    }

    if (chosen is PeriodFilter) {
      ref.read(periodProvider.notifier).setFilter(chosen);
    }
  }
}
