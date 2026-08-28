import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

class HourlyRushChart extends StatelessWidget {
  final List<HourlyActivityBin> bins;
  final ActivityMetric metric;
  final String? peakRushDescription;

  const HourlyRushChart({
    super.key,
    required this.bins,
    required this.metric,
    this.peakRushDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final primaryColor = metric == ActivityMetric.revenue
        ? scheme.primary
        : scheme.secondary;

    final maxVal = bins.fold<double>(
      1.0,
      (max, b) => math.max(
        max,
        metric == ActivityMetric.revenue ? b.revenue : b.patients.toDouble(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart Area
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = ((constraints.maxWidth - (bins.length * 4)) / bins.length)
                  .clamp(8.0, 24.0);

              return Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: bins.map((bin) {
                        final val = metric == ActivityMetric.revenue
                            ? bin.revenue
                            : bin.patients.toDouble();
                        final ratio = (val / maxVal).clamp(0.0, 1.0);
                        final barHeight = ratio * (180 - 45);

                        return Tooltip(
                          message: '${bin.label}: ${metric == ActivityMetric.revenue ? Formatters.formatCurrency(bin.revenue) : '${bin.patients} patients'}',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                width: barWidth,
                                height: math.max(barHeight, val > 0 ? 6.0 : 2.0),
                                decoration: BoxDecoration(
                                  color: val > 0
                                      ? primaryColor.withValues(
                                          alpha: 0.75 + (ratio * 0.25),
                                        )
                                      : scheme.outlineVariant.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Time Axis Labels (Every 2 or 3 hours)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('8 AM', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                      Text('12 PM', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                      Text('4 PM', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                      Text('8 PM', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // Peak Rush Insight Box
        if (peakRushDescription != null) ...[
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: Radii.mdAll,
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, size: 18, color: primaryColor),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    peakRushDescription!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
