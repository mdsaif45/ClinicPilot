import 'package:flutter/material.dart';

import '../design/tokens.dart';
import 'animated_counter.dart';

enum MetricTone {
  neutral,
  positive,
  negative,
}

/// Standardized card for dashboard & analytics metrics.
/// Provides consistent typography, container tints, iconography, and animations.
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final double? numericValue;
  final IconData? icon;
  final MetricTone tone;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.numericValue,
    this.icon,
    this.tone = MetricTone.neutral,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (bg, border, text, iconColor) = switch (tone) {
      MetricTone.positive => (
          scheme.primaryContainer.withValues(alpha: 0.35),
          scheme.primary.withValues(alpha: 0.25),
          scheme.primary,
          scheme.primary,
        ),
      MetricTone.negative => (
          scheme.errorContainer.withValues(alpha: 0.35),
          scheme.error.withValues(alpha: 0.25),
          scheme.error,
          scheme.error,
        ),
      MetricTone.neutral => (
          scheme.surfaceContainerLowest,
          scheme.outlineVariant.withValues(alpha: 0.5),
          scheme.onSurface,
          scheme.onSurfaceVariant,
        ),
    };

    return Material(
      color: bg,
      borderRadius: Radii.lgAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.lgAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: Radii.lgAll,
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: Spacing.xs),
                    Icon(icon, size: 16, color: iconColor),
                  ],
                ],
              ),
              const SizedBox(height: Spacing.sm),
              if (numericValue != null)
                AnimatedCounter(
                  value: numericValue!,
                  formatter: (_) => value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                )
              else
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
