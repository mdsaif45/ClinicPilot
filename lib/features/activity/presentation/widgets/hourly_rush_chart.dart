import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

/// Modern clean hourly activity rush chart styled after Google Fit.
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

    final rawMax = bins.fold<double>(
      0.0,
      (max, b) => math.max(
        max,
        metric == ActivityMetric.revenue ? b.revenue : b.patients.toDouble(),
      ),
    );

    // Calculate nice rounded ceiling for Y-axis
    final maxVal = rawMax > 0
        ? (metric == ActivityMetric.revenue
            ? (rawMax <= 1000 ? 1000.0 : (rawMax / 500).ceil() * 500.0)
            : (rawMax <= 5 ? 5.0 : (rawMax / 2).ceil() * 2.0))
        : (metric == ActivityMetric.revenue ? 1000.0 : 5.0);

    final midVal = maxVal / 2;

    final maxLabel = metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(maxVal).replaceAll('.00', '')
        : maxVal.toInt().toString();

    final midLabel = metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(midVal).replaceAll('.00', '')
        : midVal.toInt().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Chart Canvas with Y-Axis grid lines & right labels
        SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Chart Plot Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final chartHeight = constraints.maxHeight - 24; // reserve for x-axis
                    final barCount = bins.length;
                    final barWidth = ((constraints.maxWidth - (barCount * 6)) / barCount)
                        .clamp(6.0, 14.0);

                    return Stack(
                      children: [
                        // Background Horizontal Grid Lines
                        Positioned.fill(
                          bottom: 24,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Divider(
                                height: 1,
                                thickness: 0.8,
                                color: scheme.outlineVariant.withValues(alpha: 0.35),
                              ),
                              Divider(
                                height: 1,
                                thickness: 0.8,
                                color: scheme.outlineVariant.withValues(alpha: 0.25),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1.2,
                                color: scheme.outlineVariant.withValues(alpha: 0.45),
                              ),
                            ],
                          ),
                        ),

                        // Slender Modern Rounded Bars
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 24,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: bins.map((bin) {
                              final val = metric == ActivityMetric.revenue
                                  ? bin.revenue
                                  : bin.patients.toDouble();
                              final ratio = (val / maxVal).clamp(0.0, 1.0);
                              final barHeight = ratio * chartHeight;

                              return Tooltip(
                                message: '${bin.label}: ${metric == ActivityMetric.revenue ? Formatters.formatCurrency(bin.revenue) : '${bin.patients} patients'}',
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeOutCubic,
                                      width: barWidth,
                                      height: math.max(barHeight, val > 0 ? 4.0 : 0.0),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // X-Axis Time Labels
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('8 AM', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: scheme.onSurfaceVariant)),
                              Text('12 PM', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: scheme.onSurfaceVariant)),
                              Text('4 PM', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: scheme.onSurfaceVariant)),
                              Text('8 PM', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: scheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(width: Spacing.sm),

              // 2. Right Y-Axis Labels (Google Fit style)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maxLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      midLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Peak Rush Insight Box
        if (peakRushDescription != null) ...[
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: Radii.mdAll,
              border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, size: 16, color: primaryColor),
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
