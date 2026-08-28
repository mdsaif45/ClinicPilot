import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

/// Pixel-accurate Hourly Activity Rush Chart styled after Google Fit.
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

    // Calculate nice rounded ceiling for Y-axis (e.g. 1400, 700)
    final maxVal = rawMax > 0
        ? (metric == ActivityMetric.revenue
            ? (rawMax <= 1000 ? 1000.0 : (rawMax / 500).ceil() * 500.0)
            : (rawMax <= 6 ? 6.0 : (rawMax / 2).ceil() * 2.0))
        : (metric == ActivityMetric.revenue ? 1000.0 : 6.0);

    final midVal = maxVal / 2;

    final maxLabel = metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(maxVal).replaceAll('.00', '').replaceAll('₹ ', '₹')
        : maxVal.toInt().toString();

    final midLabel = metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(midVal).replaceAll('.00', '').replaceAll('₹ ', '₹')
        : midVal.toInt().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Chart Canvas with custom painter
        SizedBox(
          height: 195,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Chart Plot Area
              Expanded(
                child: CustomPaint(
                  painter: _GoogleFitChartPainter(
                    bins: bins,
                    maxVal: maxVal,
                    primaryColor: primaryColor,
                    gridColor: scheme.outlineVariant.withValues(alpha: 0.35),
                    axisColor: scheme.outlineVariant.withValues(alpha: 0.65),
                    dotColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    labelColor: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // 2. Right Y-Axis Labels
              Padding(
                padding: const EdgeInsets.only(bottom: 34),
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
                  ],
                ),
              ),
            ],
          ),
        ),

        // Peak Rush Insight Box
        if (peakRushDescription != null) ...[
          const SizedBox(height: Spacing.sm),
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

class _GoogleFitChartPainter extends CustomPainter {
  final List<HourlyActivityBin> bins;
  final double maxVal;
  final Color primaryColor;
  final Color gridColor;
  final Color axisColor;
  final Color dotColor;
  final Color labelColor;

  const _GoogleFitChartPainter({
    required this.bins,
    required this.maxVal,
    required this.primaryColor,
    required this.gridColor,
    required this.axisColor,
    required this.dotColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomLabelHeight = 34.0;
    final plotHeight = size.height - bottomLabelHeight;
    final plotWidth = size.width;
    final baselineY = plotHeight;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final barPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // 1. Draw Top and Mid Horizontal Grid Lines
    canvas.drawLine(const Offset(0, 0), Offset(plotWidth, 0), gridPaint);
    canvas.drawLine(Offset(0, plotHeight / 2), Offset(plotWidth, plotHeight / 2), gridPaint);

    // 2. Draw Bottom Baseline Axis Line
    canvas.drawLine(Offset(0, baselineY), Offset(plotWidth, baselineY), axisPaint);

    // 3. Draw 24 Slender Activity Bars
    final barSlotWidth = plotWidth / 24.0;
    final barWidth = math.min(barSlotWidth * 0.55, 4.5);

    for (int i = 0; i < bins.length && i < 24; i++) {
      final bin = bins[i];
      final val = math.max(bin.revenue, bin.patients.toDouble());
      if (val > 0) {
        final ratio = (val / maxVal).clamp(0.0, 1.0);
        final barHeight = ratio * plotHeight;
        final centerX = (i + 0.5) * barSlotWidth;

        final barRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(centerX - (barWidth / 2), baselineY - barHeight, barWidth, barHeight),
          topLeft: const Radius.circular(2.5),
          topRight: const Radius.circular(2.5),
        );
        canvas.drawRRect(barRect, barPaint);
      }
    }

    // 4. Draw Intermediate Baseline Dots (Hours 2, 6, 10, 14, 18, 22)
    final dotHours = [2, 6, 10, 14, 18, 22];
    for (final h in dotHours) {
      final dotX = (h / 24.0) * plotWidth;
      canvas.drawCircle(Offset(dotX, baselineY), 1.6, dotPaint);
    }

    // 5. Draw Major Ticks and Two-Line X-Axis Labels (Hours 0, 4, 8, 12, 16, 20, 24)
    final majorTicks = [
      (0, '12', 'AM'),
      (4, '4', 'AM'),
      (8, '8', 'AM'),
      (12, '12', 'PM'),
      (16, '4', 'PM'),
      (20, '8', 'PM'),
      (24, '12', 'AM'),
    ];

    for (final (h, numStr, periodStr) in majorTicks) {
      final tickX = (h / 24.0) * plotWidth;

      // Small vertical tick on baseline
      canvas.drawLine(Offset(tickX, baselineY), Offset(tickX, baselineY + 3.5), axisPaint);

      // Text painters for number and AM/PM below
      final textSpan = TextSpan(
        children: [
          TextSpan(
            text: '$numStr\n',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: labelColor,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: periodStr,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: labelColor,
              height: 1.1,
            ),
          ),
        ],
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      // Clamp X position so 12 AM edges don't overflow the canvas
      final textLeft = (tickX - (textPainter.width / 2))
          .clamp(0.0, plotWidth - textPainter.width);

      textPainter.paint(canvas, Offset(textLeft, baselineY + 6.0));
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleFitChartPainter oldDelegate) {
    return oldDelegate.bins != bins ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.axisColor != axisColor;
  }
}
