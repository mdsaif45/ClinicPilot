import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Weekday picker backed by the stored `"1,3,5"` format.
///
/// Replaces a free text field that asked the doctor to type day numbers and
/// remember that 1 means Monday. Nothing validated the typed value, so a typo
/// silently skewed the per-clinic-day averages that read it.
///
/// The stored format is unchanged - 1=Mon through 7=Sun, matching
/// [DateTime.weekday] - so existing rows and the comparison query still work.
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

  /// Always ascending, so a stored value never depends on tap order.
  static String format(Set<int> days) =>
      (days.toList()..sort()).join(',');

  /// Stored days as readable names, e.g. "Mon, Wed, Fri".
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
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (var day = 1; day <= 7; day++)
              FilterChip(
                label: Text(_labels[day - 1]),
                selected: selected.contains(day),
                onSelected: (on) {
                  final next = Set<int>.from(selected);
                  if (on) {
                    next.add(day);
                  } else {
                    next.remove(day);
                  }
                  onChanged(format(next));
                },
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          selected.isEmpty
              // A clinic open on no days divides by zero in the per-day
              // averages, so the comparison falls back to treating it as one.
              ? 'No days selected - per-day averages will not be meaningful'
              : '${selected.length} ${selected.length == 1 ? "day" : "days"} a week',
          style: theme.textTheme.labelMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
