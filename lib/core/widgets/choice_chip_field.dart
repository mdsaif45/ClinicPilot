import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Labelled row of choice chips with standardized geometry.
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
    final scheme = theme.colorScheme;

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
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            for (final o in options)
              ChoiceChip(
                label: Text(labelOf(o)),
                avatar: iconOf?.call(o) == null
                    ? null
                    : Icon(iconOf!(o), size: 16),
                selected: o == value,
                onSelected: (_) => onChanged(o),
              ),
          ],
        ),
      ],
    );
  }
}
