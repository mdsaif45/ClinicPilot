import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Wrapped row of outlined pills — diseases, referral sources, categories.
class ChipRow extends StatelessWidget {
  final List<String> labels;
  final EdgeInsetsGeometry padding;
  final void Function(String label)? onTap;

  const ChipRow({
    super.key,
    required this.labels,
    this.padding = const EdgeInsets.symmetric(horizontal: Spacing.lg),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visible = labels.where((l) => l.trim().isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: visible
            .map((l) => onTap == null
                ? Chip(label: Text(l))
                : ActionChip(label: Text(l), onPressed: () => onTap!(l)))
            .toList(),
      ),
    );
  }
}
