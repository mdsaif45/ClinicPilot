import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

class WeeklyBenchmarkChart extends StatelessWidget {
  final List<DailyActivityBin> bins;
  final ActivityMetric metric;
  final double targetValue;
  final double achievementPercent;

  const WeeklyBenchmarkChart({
    super.key,
    required this.bins,
    required this.metric,
    required this.targetValue,
    required this.achievementPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final primaryColor = metric == ActivityMetric.revenue
        ? scheme.primary
        : scheme.secondary;

    final maxVal = math.max(
      targetValue * 1.2,
      bins.fold<double>(
        1.0,
        (max, b) => math.max(
          max,
          metric == ActivityMetric.revenue ? b.revenue : b.patients.toDouble(),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Target Achievement Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm + 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: Radii.mdAll,
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Icon(
                    achievementPercent >= 1.0 ? Icons.emoji_events : Icons.track_changes,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievementPercent >= 1.0
                          ? 'Target Exceeded!'
                          : 'Weekly Practice Pace',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(achievementPercent * 100).toStringAsFixed(0)}% of weekly goal (${metric == ActivityMetric.revenue ? Formatters.formatCurrency(targetValue) : '${targetValue.toInt()} patients'})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(achievementPercent * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Spacing.lg),

        // 7-Day Bar Chart Area
        Container(
          height: 170,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = 24.0;
              final chartHeight = 130.0;

              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // Benchmark Target Line
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: ((targetValue / 6) / maxVal).clamp(0.0, 1.0) * chartHeight,
                          child: Container(
                            height: 1.5,
                            color: scheme.outlineVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        // Bars
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: bins.map((bin) {
                            final val = metric == ActivityMetric.revenue
                                ? bin.revenue
                                : bin.patients.toDouble();
                            final ratio = (val / maxVal).clamp(0.0, 1.0);
                            final barH = ratio * chartHeight;

                            return Tooltip(
                              message: '${bin.dayLabel}: ${metric == ActivityMetric.revenue ? Formatters.formatCurrency(bin.revenue) : '${bin.patients} patients'}',
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
                                    width: barWidth,
                                    height: math.max(barH, val > 0 ? 8.0 : 3.0),
                                    decoration: BoxDecoration(
                                      color: bin.isTargetMet
                                          ? primaryColor
                                          : primaryColor.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  // Day Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: bins.map((b) {
                      return SizedBox(
                        width: barWidth,
                        child: Text(
                          b.dayLabel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
