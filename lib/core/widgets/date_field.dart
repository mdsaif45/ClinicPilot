import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../utils/formatters.dart';

/// Labelled date selector that opens the calendar picker.
/// Matches [CustomTextField] and [PickerField] geometry.
class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final IconData prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.prefixIcon = Icons.event_outlined,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final today = _dayOf(DateTime.now());
    final selected = _dayOf(value);
    final isToday = selected == today;
    final isYesterday = selected == today.subtract(const Duration(days: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        InkWell(
          borderRadius: Radii.mdAll,
          onTap: () => _pick(context),
          child: InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(prefixIcon, size: 20, color: scheme.onSurfaceVariant),
              suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: 14,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Formatters.formatDate(value),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isToday || isYesterday)
                  Text(
                    isToday ? 'Today' : 'Yesterday',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Wrap(
          spacing: Spacing.sm,
          children: [
            _Shortcut(
              label: 'Today',
              selected: isToday,
              onTap: () => onChanged(_carryTime(today)),
            ),
            _Shortcut(
              label: 'Yesterday',
              selected: isYesterday,
              onTap: () => onChanged(
                _carryTime(today.subtract(const Duration(days: 1))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
    );
    if (picked != null) {
      onChanged(_carryTime(picked));
    }
  }

  DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _carryTime(DateTime d) =>
      DateTime(d.year, d.month, d.day, value.hour, value.minute, value.second);
}

class _Shortcut extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Shortcut({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
