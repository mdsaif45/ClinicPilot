import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Weekday picker backed by the stored `"1,3,5"` format.
class DaySelectorField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const DaySelectorField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static Set<int> parse(String raw) => raw
      .split(',')
      .map((e) => int.tryParse(e.trim()))
      .whereType<int>()
      .where((d) => d >= 1 && d <= 7)
      .toSet();

  static String format(Set<int> days) =>
      (days.toList()..sort()).join(',');

  static String describe(String raw) {
    final days = parse(raw).toList()..sort();
    if (days.isEmpty) return 'Not set';
    if (days.length == 7) return 'Every day';
    return days.map((d) => _labels[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = parse(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            if (selected.isNotEmpty)
              Text(
                '${selected.length} ${selected.length == 1 ? 'day' : 'days'} a week',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            for (var d = 1; d <= 7; d++)
              ChoiceChip(
                label: Text(
                  _labels[d - 1],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight:
                        selected.contains(d) ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: selected.contains(d),
                visualDensity: VisualDensity.compact,
                onSelected: (yes) {
                  final next = Set<int>.from(selected);
                  if (yes) {
                    next.add(d);
                  } else {
                    next.remove(d);
                  }
                  onChanged(format(next));
                },
              ),
          ],
        ),
      ],
    );
  }
}
