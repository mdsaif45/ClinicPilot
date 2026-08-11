import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../theme/app_theme.dart';

/// One cell of a [MetricStrip].
class Metric {
  final String label;
  final String value;

  /// When set, the value is coloured by sign (profit green / loss red).
  final double? signedAmount;

  const Metric({required this.label, required this.value, this.signedAmount});
}

/// A row of headline numbers separated by thin dividers.
///
/// Deliberately card-less and border-less: at a glance the doctor should read
/// the numbers, not the container around them. Scrolls horizontally rather than
/// wrapping, so the row stays one line on narrow screens.
class MetricStrip extends StatelessWidget {
  final List<Metric> metrics;

  const MetricStrip({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: VerticalDivider(width: 1),
                ),
              _MetricCell(metric: metrics[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final Metric metric;

  const _MetricCell({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signed = metric.signedAmount;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.value,
            style: AppTheme.tabularFigures(
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: signed == null
                    ? theme.colorScheme.onSurface
                    : AppTheme.moneyColor(context, signed),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(metric.label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
