import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Reusable status and category pill badge with standardized geometry.
class CustomBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  const CustomBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.pillAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: Radii.pillAll,
            border: Border.all(color: c.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: c),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
