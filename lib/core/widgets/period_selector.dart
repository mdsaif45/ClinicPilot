import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/tokens.dart';
import '../providers/period_provider.dart';
import '../utils/formatters.dart';

/// Period picker for the analytics screens.
///
/// Lives next to the numbers it changes rather than in the app bar: a filter
/// in the toolbar silently rescoped screens that were not even visible, and
/// gave no clue which figures it affected.
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(periodProvider);
    final theme = Theme.of(context);
    final range = state.dateRange;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Showing', style: theme.textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.formatDate(range.start)} — '
                  '${Formatters.formatDate(range.end)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          ActionChip(
            avatar: const Icon(Icons.calendar_today, size: 16),
            label: Text(state.filter.label),
            onPressed: () => _pick(context, ref, state.filter),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    PeriodFilter current,
  ) async {
    final chosen = await showModalBottomSheet<PeriodFilter>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Text(
                'Period',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            for (final f in PeriodFilter.values)
              ListTile(
                leading: Icon(
                  f == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: f == current
                      ? Theme.of(ctx).colorScheme.primary
                      : Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
                title: Text(f.label),
                onTap: () => Navigator.of(ctx).pop(f),
              ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );

    if (chosen == null) return;

    if (chosen == PeriodFilter.custom) {
      if (!context.mounted) return;
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 1),
        initialDateRange: ref.read(periodProvider).dateRange,
      );
      if (picked != null) {
        ref
            .read(periodProvider.notifier)
            .setFilter(PeriodFilter.custom, customRange: picked);
      }
      return;
    }

    ref.read(periodProvider.notifier).setFilter(chosen);
  }
}
