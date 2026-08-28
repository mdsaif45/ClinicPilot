import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

/// Modern, animated, and interactive Google Fit Hourly Activity Rush Chart with touch scrubber cursor and speech-bubble tooltip.
class HourlyRushChart extends StatefulWidget {
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
  State<HourlyRushChart> createState() => _HourlyRushChartState();
}

class _HourlyRushChartState extends State<HourlyRushChart> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barGrowthAnim;
  int? _hoveredHourIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _barGrowthAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant HourlyRushChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metric != widget.metric || oldWidget.bins != widget.bins) {
      _animController.reset();
      _animController.forward();
      _hoveredHourIndex = null;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTouch(Offset localPosition, double plotWidth) {
    if (plotWidth <= 0 || widget.bins.isEmpty) return;
    final fraction = (localPosition.dx / plotWidth).clamp(0.0, 1.0);
    final index = (fraction * 24).round().clamp(0, widget.bins.length - 1);
    if (index != _hoveredHourIndex) {
      AppHaptics.selection();
      setState(() {
        _hoveredHourIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final primaryColor = widget.metric == ActivityMetric.revenue
        ? scheme.primary
        : scheme.secondary;

    final rawMax = widget.bins.fold<double>(
      0.0,
      (max, b) => math.max(
        max,
        widget.metric == ActivityMetric.revenue ? b.revenue : b.patients.toDouble(),
      ),
    );

    // Calculate rounded ceiling for Y-axis (e.g. 1400, 700)
    final maxVal = rawMax > 0
        ? (widget.metric == ActivityMetric.revenue
            ? (rawMax <= 1000 ? 1000.0 : (rawMax / 500).ceil() * 500.0)
            : (rawMax <= 6 ? 6.0 : (rawMax / 2).ceil() * 2.0))
        : (widget.metric == ActivityMetric.revenue ? 1000.0 : 6.0);

    final midVal = maxVal / 2;

    final maxLabel = widget.metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(maxVal).replaceAll('.00', '').replaceAll('₹ ', '₹')
        : maxVal.toInt().toString();

    final midLabel = widget.metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(midVal).replaceAll('.00', '').replaceAll('₹ ', '₹')
        : midVal.toInt().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Interactive Chart Plot Area with Scrubber and Animated Bars
        SizedBox(
          height: 205,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Chart Plot Area
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final plotWidth = constraints.maxWidth;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) => _handleTouch(details.localPosition, plotWidth),
                      onHorizontalDragStart: (details) => _handleTouch(details.localPosition, plotWidth),
                      onHorizontalDragUpdate: (details) => _handleTouch(details.localPosition, plotWidth),
                      onHorizontalDragEnd: (_) {},
                      child: MouseRegion(
                        onHover: (event) => _handleTouch(event.localPosition, plotWidth),
                        onExit: (_) {
                          setState(() {
                            _hoveredHourIndex = null;
                          });
                        },
                        child: AnimatedBuilder(
                          animation: _barGrowthAnim,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _GoogleFitInteractiveChartPainter(
                                bins: widget.bins,
                                maxVal: maxVal,
                                progress: _barGrowthAnim.value,
                                primaryColor: primaryColor,
                                gridColor: scheme.outlineVariant.withValues(alpha: 0.35),
                                axisColor: scheme.outlineVariant.withValues(alpha: 0.65),
                                dotColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                                labelColor: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                                tooltipBgColor: scheme.surfaceContainerHighest,
                                tooltipTextColor: scheme.onSurface,
                                selectedHourIndex: _hoveredHourIndex,
                                metric: widget.metric,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 6),

              // 2. Right Y-Axis Labels (1400 / 700)
              Padding(
                padding: const EdgeInsets.only(top: 26, bottom: 34),
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
        if (widget.peakRushDescription != null) ...[
          const SizedBox(height: Spacing.xs),
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
                    widget.peakRushDescription!,
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

class _GoogleFitInteractiveChartPainter extends CustomPainter {
  final List<HourlyActivityBin> bins;
  final double maxVal;
  final double progress; // 0.0 to 1.0 bar growth
  final Color primaryColor;
  final Color gridColor;
  final Color axisColor;
  final Color dotColor;
  final Color labelColor;
  final Color tooltipBgColor;
  final Color tooltipTextColor;
  final int? selectedHourIndex;
  final ActivityMetric metric;

  const _GoogleFitInteractiveChartPainter({
    required this.bins,
    required this.maxVal,
    required this.progress,
    required this.primaryColor,
    required this.gridColor,
    required this.axisColor,
    required this.dotColor,
    required this.labelColor,
    required this.tooltipBgColor,
    required this.tooltipTextColor,
    required this.selectedHourIndex,
    required this.metric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const topMargin = 28.0; // Space for speech bubble tooltip
    const bottomLabelHeight = 34.0;
    final plotHeight = size.height - topMargin - bottomLabelHeight;
    final plotWidth = size.width;
    final baselineY = topMargin + plotHeight;

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
    canvas.drawLine(Offset(0, topMargin), Offset(plotWidth, topMargin), gridPaint);
    canvas.drawLine(Offset(0, topMargin + (plotHeight / 2)), Offset(plotWidth, topMargin + (plotHeight / 2)), gridPaint);

    // 2. Draw Bottom Baseline Axis Line
    canvas.drawLine(Offset(0, baselineY), Offset(plotWidth, baselineY), axisPaint);

    // 3. Draw 24 Slender Activity Bars precisely aligned with hour checkpoints
    const barWidth = 4.0;
    double? selectedCenterX;
    double? selectedBarTopY;

    for (int i = 0; i < bins.length && i < 24; i++) {
      final bin = bins[i];
      final val = math.max(bin.revenue, bin.patients.toDouble());
      final ratio = (val / maxVal).clamp(0.0, 1.0);
      final barHeight = ratio * plotHeight * progress;
      // Exact alignment: hour h corresponds to x = (h / 24.0) * plotWidth
      final centerX = (bin.hour / 24.0) * plotWidth;
      final topY = baselineY - barHeight;

      if (i == selectedHourIndex) {
        selectedCenterX = centerX;
        selectedBarTopY = topY;
      }

      if (barHeight > 0) {
        final barRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(centerX - (barWidth / 2), topY, barWidth, barHeight),
          topLeft: const Radius.circular(2.0),
          topRight: const Radius.circular(2.0),
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

      // Two-line Text Column (e.g. "12\nAM")
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

      final textLeft = (tickX - (textPainter.width / 2))
          .clamp(0.0, plotWidth - textPainter.width);

      textPainter.paint(canvas, Offset(textLeft, baselineY + 6.0));
    }

    // 6. Draw Google Fit Scrubber Cursor & Speech-Bubble Tooltip on Selected Hour
    if (selectedHourIndex != null && selectedHourIndex! < bins.length) {
      final bin = bins[selectedHourIndex!];
      final cursorX = selectedCenterX ?? ((bin.hour / 24.0) * plotWidth);
      final cursorY = selectedBarTopY ?? baselineY;

      // Vertical Dashed Cursor Line (aligned 100% with tickX)
      final dashedPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.8)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      const dashHeight = 3.5;
      const dashSpace = 2.5;
      double startY = topMargin;
      while (startY < baselineY) {
        final endY = math.min(startY + dashHeight, baselineY);
        canvas.drawLine(Offset(cursorX, startY), Offset(cursorX, endY), dashedPaint);
        startY += dashHeight + dashSpace;
      }

      // Indicator Dot (Glowing ring on bar/axis)
      final dotRingPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      final dotSolidPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      final dotCenterWhitePaint = Paint()
        ..color = tooltipBgColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(cursorX, cursorY), 6.0, dotRingPaint);
      canvas.drawCircle(Offset(cursorX, cursorY), 3.8, dotSolidPaint);
      canvas.drawCircle(Offset(cursorX, cursorY), 1.6, dotCenterWhitePaint);

      // Prepare Tooltip Content: e.g. "₹ 1,500 at 10 AM" or "3 patients at 10 AM"
      final valStr = metric == ActivityMetric.revenue
          ? Formatters.formatCurrency(bin.revenue)
          : '${bin.patients} ${bin.patients == 1 ? 'patient' : 'patients'}';

      final tooltipTextSpan = TextSpan(
        children: [
          TextSpan(
            text: '$valStr ',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          TextSpan(
            text: 'at ${bin.label}',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: tooltipTextColor,
            ),
          ),
        ],
      );

      final tooltipPainter = TextPainter(
        text: tooltipTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      const bubblePaddingH = 10.0;
      const bubblePaddingV = 5.0;
      final bubbleWidth = tooltipPainter.width + (bubblePaddingH * 2);
      final bubbleHeight = tooltipPainter.height + (bubblePaddingV * 2);

      // Tooltip position clamped within plot bounds
      final bubbleLeft = (cursorX - (bubbleWidth / 2)).clamp(4.0, plotWidth - bubbleWidth - 4.0);
      const bubbleTop = 0.0;

      // Draw Speech Bubble Background (Pill + Bottom Triangle Pointer)
      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleLeft, bubbleTop, bubbleWidth, bubbleHeight),
        const Radius.circular(16),
      );

      // Drop shadow for bubble
      final shadowPaint = Paint()
        ..color = tooltipTextColor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(bubbleRect.shift(const Offset(0, 2)), shadowPaint);

      final bubbleBgPaint = Paint()
        ..color = tooltipBgColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(bubbleRect, bubbleBgPaint);

      // Triangle pointer pointing to cursorX
      final pointerPath = Path();
      final pointerCenterX = cursorX.clamp(bubbleLeft + 8.0, bubbleLeft + bubbleWidth - 8.0);
      pointerPath.moveTo(pointerCenterX - 4.5, bubbleHeight);
      pointerPath.lineTo(pointerCenterX, bubbleHeight + 4.5);
      pointerPath.lineTo(pointerCenterX + 4.5, bubbleHeight);
      pointerPath.close();
      canvas.drawPath(pointerPath, bubbleBgPaint);

      // Border outline
      final borderPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.35)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(bubbleRect, borderPaint);

      // Paint Text
      tooltipPainter.paint(
        canvas,
        Offset(bubbleLeft + bubblePaddingH, bubbleTop + bubblePaddingV),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleFitInteractiveChartPainter oldDelegate) {
    return oldDelegate.bins != bins ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.selectedHourIndex != selectedHourIndex ||
        oldDelegate.metric != metric ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.axisColor != axisColor;
  }
}
