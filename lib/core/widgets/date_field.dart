import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../utils/formatters.dart';

/// Labelled date selector that opens the calendar picker.
///
/// Label placement and field decoration match [PickerField] and
/// CustomTextField, so a form mixing all three lines up.
///
/// Offers "Today" and "Yesterday" shortcuts because those two cover almost
/// every entry - the doctor is usually recording either this evening's clinic
/// or last night's, and both should be one tap rather than a trip through a
/// calendar.
class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final IconData prefixIcon;

  /// Earliest selectable date. Defaults to five years back, which comfortably
  /// covers backdating an old receipt.
  final DateTime? firstDate;

  /// Latest selectable date. Defaults to today: a memo or expense dated in the
  /// future would sit in the reports as money that has not moved yet.
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
    final isYesterday =
        selected == today.subtract(const Duration(days: 1));

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
        InkWell(
          borderRadius: Radii.mdAll,
          onTap: () => _pick(context),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon),
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Formatters.formatDate(value),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                // Naming the common cases saves reading the date back to work
                // out whether it is the one you meant.
                if (isToday || isYesterday)
                  Text(
                    isToday ? 'Today' : 'Yesterday',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
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
                  _carryTime(today.subtract(const Duration(days: 1)))),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? now,
    );
    if (picked != null) onChanged(_carryTime(picked));
  }

  /// Keeps the clock time already on the value while moving the calendar day.
  ///
  /// The picker returns midnight. Storing that would make every backdated row
  /// land at 00:00, and a "today" row stamped midnight sits outside a range
  /// that starts at the current moment.
  DateTime _carryTime(DateTime day) {
    final now = DateTime.now();
    final t = _dayOf(value) == _dayOf(now) ? now : value;
    return DateTime(day.year, day.month, day.day, t.hour, t.minute, t.second);
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
    );
  }
}
