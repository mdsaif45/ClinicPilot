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
/// card with icon badges, bold tabular figures, and responsive distribution.
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

    Widget buildContent(BoxConstraints constraints) {
      final availableWidth =
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;

      final textScale = MediaQuery.textScalerOf(context).scale(1.0);
      // Comfortable cell with icon badge (28px) + gap (8px) + text column requires >= 104px * textScale
      final minWidthForIcon = 104.0 * textScale;
      final cellWidth = availableWidth / metrics.length;
      final showIcons = cellWidth >= minWidthForIcon;

      if (metrics.length <= 4) {
        return IntrinsicHeight(
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
                  child: _MetricCell(metric: metrics[i], showIcon: showIcons),
                ),
              ],
            ],
          ),
        );
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < metrics.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                      ),
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 84),
                    child: _MetricCell(metric: metrics[i], showIcon: true),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    if (!asCard) {
      return Padding(
        padding: margin ?? const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) => buildContent(constraints),
        ),
      );
    }

    return Container(
      margin:
          margin ??
          const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.md),
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.lgAll,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => buildContent(constraints),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final Metric metric;
  final bool showIcon;

  const _MetricCell({required this.metric, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final signed = metric.signedAmount;
    final accent = metric.color ?? scheme.primary;

    final valueColor =
        metric.color ??
        (signed == null
            ? scheme.onSurface
            : AppTheme.moneyColor(context, signed));

    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            metric.value,
            style: AppTheme.tabularFigures(
              theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
                fontSize: 16,
              ),
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            metric.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            maxLines: 1,
          ),
        ),
        if (metric.subtitle != null) ...[
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.subtitle!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: accent,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ],
    );

    if (!showIcon || metric.icon == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.xs,
        ),
        child: textContent,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.xs + 1),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: Radii.mdAll,
            ),
            child: Icon(metric.icon, size: 18, color: accent),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(child: textContent),
        ],
      ),
    );
  }
}
