import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Flat label/value row: muted label on the left, strong value on the right.
/// Supports customizable padding and tap actions.
class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final rowPadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.sm + 2,
        );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: rowPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: Spacing.md),
            ],
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              flex: 6,
              child: Text(
                v,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
