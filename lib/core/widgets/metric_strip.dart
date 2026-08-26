import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../theme/app_theme.dart';

/// One cell of a [MetricStrip].
class Metric {
  final String label;
  final String value;

  /// When set, the value is coloured by sign (profit green / loss red).
  final double? signedAmount;

  /// Optional icon displayed alongside the metric value.
  final IconData? icon;

  /// Optional custom tint for the icon and value.
  final Color? color;

  /// Optional secondary caption.
  final String? subtitle;

  const Metric({
    required this.label,
    required this.value,
    this.signedAmount,
    this.icon,
    this.color,
    this.subtitle,
  });
}

/// A structured container of headline metrics, formatted as a polished summary
/// card with icon badges, bold tabular figures, and balanced distribution.
class MetricStrip extends StatelessWidget {
  final List<Metric> metrics;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool asCard;

  const MetricStrip({
    super.key,
    required this.metrics,
    this.margin,
    this.padding,
    this.asCard = true,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget content;

    if (metrics.length <= 4) {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              Expanded(
                child: _MetricCell(metric: metrics[i]),
              ),
            ],
          ],
        ),
      );
    } else {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 84),
                  child: _MetricCell(metric: metrics[i]),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (!asCard) {
      return Padding(
        padding: margin ?? const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: content,
      );
    }

    return Container(
      margin: margin ??
          const EdgeInsets.fromLTRB(
            Spacing.lg,
            0,
            Spacing.lg,
            Spacing.md,
          ),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.lgAll,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: content,
    );
  }
}

class _MetricCell extends StatelessWidget {
  final Metric metric;

  const _MetricCell({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final signed = metric.signedAmount;
    final accent = metric.color ?? scheme.primary;

    final valueColor = metric.color ??
        (signed == null
            ? scheme.onSurface
            : AppTheme.moneyColor(context, signed));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (metric.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(Spacing.xs + 1),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: Radii.mdAll,
              ),
              child: Icon(
                metric.icon,
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: Spacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metric.value,
                  style: AppTheme.tabularFigures(
                    theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                      fontSize: 17,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  metric.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (metric.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    metric.subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
