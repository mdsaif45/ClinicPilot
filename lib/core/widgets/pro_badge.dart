import 'package:flutter/material.dart';
import '../design/tokens.dart';

/// Reusable PRO badge for annotating advanced automation, letterhead,
/// or analytics features.
class ProBadge extends StatelessWidget {
  final String label;
  final bool compact;
  final VoidCallback? onTap;

  const ProBadge({
    super.key,
    this.label = 'PRO',
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.tertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.pillAll,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? Spacing.xs : Spacing.sm,
            vertical: compact ? 1.5 : 3.0,
          ),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: Radii.pillAll,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 11, color: accentColor),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
