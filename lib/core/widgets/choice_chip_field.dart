import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Labelled row of choice chips.
///
/// Preferred over a dropdown for short, fixed option sets: every choice is
/// visible without opening anything, and selecting one is a single tap rather
/// than tap-scroll-tap. Payment method in particular is chosen on nearly every
/// memo, so the two saved taps add up across an evening.
class ChoiceChipField<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;
  final IconData? Function(T)? iconOf;

  const ChoiceChipField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.labelOf,
    this.iconOf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final o in options)
              ChoiceChip(
                label: Text(labelOf(o)),
                avatar: iconOf?.call(o) == null
                    ? null
                    : Icon(iconOf!(o), size: 16),
                selected: o == value,
                showCheckmark: false,
                onSelected: (_) => onChanged(o),
              ),
          ],
        ),
      ],
    );
  }
}
