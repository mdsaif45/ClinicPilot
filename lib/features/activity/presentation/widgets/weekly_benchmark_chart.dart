import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

/// Modern, interactive, and animated Google Fit Weekly Benchmark Chart with target line and tick checkmarks.
class WeeklyBenchmarkChart extends StatefulWidget {
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
  State<WeeklyBenchmarkChart> createState() => _WeeklyBenchmarkChartState();
}

class _WeeklyBenchmarkChartState extends State<WeeklyBenchmarkChart> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barGrowthAnim;
  int? _hoveredDayIndex;

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
  void didUpdateWidget(covariant WeeklyBenchmarkChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metric != widget.metric || oldWidget.bins != widget.bins || oldWidget.targetValue != widget.targetValue) {
      _animController.reset();
      _animController.forward();
      _hoveredDayIndex = null;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTouch(Offset localPosition, double plotWidth) {
    if (plotWidth <= 0 || widget.bins.isEmpty) return;
    final slotWidth = plotWidth / widget.bins.length;
    final index = (localPosition.dx / slotWidth).floor().clamp(0, widget.bins.length - 1);
    if (index != _hoveredDayIndex) {
      AppHaptics.selection();
      setState(() {
        _hoveredDayIndex = index;
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

    final dailyTarget = widget.targetValue / 6; // 6 working days benchmark

    final rawMax = widget.bins.fold<double>(
      dailyTarget * 1.3,
      (max, b) => math.max(
        max,
        widget.metric == ActivityMetric.revenue ? b.revenue : b.patients.toDouble(),
      ),
    );

    // Calculate rounded ceiling for Y-axis (e.g. 60 / 20)
    final maxVal = rawMax > 0
        ? (widget.metric == ActivityMetric.revenue
            ? (rawMax <= 3000 ? 3000.0 : (rawMax / 1000).ceil() * 1000.0)
            : (rawMax <= 10 ? 10.0 : (rawMax / 5).ceil() * 5.0))
        : (widget.metric == ActivityMetric.revenue ? 3000.0 : 10.0);

    final midVal = maxVal * 0.35; // Google Fit mid grid height

    final maxLabel = widget.metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(maxVal).replaceAll('.00', '').replaceAll('₹ ', '₹')
        : maxVal.toInt().toString();

    final midLabel = widget.metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(midVal).replaceAll('.00', '').replaceAll('₹ ', '₹')
        : midVal.toInt().toString();

    final targetLabel = widget.metric == ActivityMetric.revenue
        ? Formatters.formatCurrency(dailyTarget).replaceAll('.00', '').replaceAll('₹ ', '₹')
        : dailyTarget.toInt().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Interactive 7-Day Bar Chart Area with Scrubber and Animated Bars
        SizedBox(
          height: 205,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chart Plot Canvas
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
                            _hoveredDayIndex = null;
                          });
                        },
                        child: AnimatedBuilder(
                          animation: _barGrowthAnim,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _GoogleFitWeekChartPainter(
                                bins: widget.bins,
                                maxVal: maxVal,
                                midVal: midVal,
                                dailyTarget: dailyTarget,
                                progress: _barGrowthAnim.value,
                                primaryColor: primaryColor,
                                gridColor: scheme.outlineVariant.withValues(alpha: 0.35),
                                axisColor: scheme.outlineVariant.withValues(alpha: 0.65),
                                labelColor: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                                tooltipBgColor: scheme.surfaceContainerHighest,
                                tooltipTextColor: scheme.onSurface,
                                selectedDayIndex: _hoveredDayIndex,
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

              // Right Y-Axis Labels (Max, Target, Mid)
              Padding(
                padding: const EdgeInsets.only(top: 26, bottom: 34),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalH = constraints.maxHeight;
                    final targetYRatio = (dailyTarget / maxVal).clamp(0.0, 1.0);
                    final targetTop = totalH * (1.0 - targetYRatio);

                    return Stack(
                      children: [
                        // Max Label at Top
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            maxLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // Target Benchmark Label
                        Positioned(
                          top: (targetTop - 6).clamp(16.0, totalH - 24.0),
                          right: 0,
                          child: Text(
                            targetLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        // Mid Label
                        Positioned(
                          bottom: totalH * 0.35 - 6,
                          right: 0,
                          child: Text(
                            midLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Spacing.sm),

        // 2. Google Fit Celebration Card (Like ❤️ You hit the magic number! 150)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: Radii.mdAll,
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  widget.achievementPercent >= 1.0 ? Icons.favorite_outline : Icons.track_changes,
                  size: 20,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.achievementPercent >= 1.0
                          ? 'You hit the weekly target!'
                          : 'Weekly Practice Pace',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(widget.achievementPercent * 100).toStringAsFixed(0)}% of goal (${widget.metric == ActivityMetric.revenue ? Formatters.formatCurrency(widget.targetValue) : '${widget.targetValue.toInt()} patients'})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(widget.achievementPercent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoogleFitWeekChartPainter extends CustomPainter {
  final List<DailyActivityBin> bins;
  final double maxVal;
  final double midVal;
  final double dailyTarget;
  final double progress; // 0.0 to 1.0
  final Color primaryColor;
  final Color gridColor;
  final Color axisColor;
  final Color labelColor;
  final Color tooltipBgColor;
  final Color tooltipTextColor;
  final int? selectedDayIndex;
  final ActivityMetric metric;

  const _GoogleFitWeekChartPainter({
    required this.bins,
    required this.maxVal,
    required this.midVal,
    required this.dailyTarget,
    required this.progress,
    required this.primaryColor,
    required this.gridColor,
    required this.axisColor,
    required this.labelColor,
    required this.tooltipBgColor,
    required this.tooltipTextColor,
    required this.selectedDayIndex,
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

    final targetDashedPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final barPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // 1. Top and Mid Horizontal Grid Lines
    canvas.drawLine(Offset(0, topMargin), Offset(plotWidth, topMargin), gridPaint);
    final midY = baselineY - ((midVal / maxVal) * plotHeight);
    canvas.drawLine(Offset(0, midY), Offset(plotWidth, midY), gridPaint);

    // 2. Target Benchmark Dashed Horizontal Line
    final targetYRatio = (dailyTarget / maxVal).clamp(0.0, 1.0);
    final targetY = baselineY - (targetYRatio * plotHeight);

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < plotWidth) {
      final endX = math.min(startX + dashWidth, plotWidth);
      canvas.drawLine(Offset(startX, targetY), Offset(endX, targetY), targetDashedPaint);
      startX += dashWidth + dashSpace;
    }

    // 3. Draw Bottom Baseline Axis Line
    canvas.drawLine(Offset(0, baselineY), Offset(plotWidth, baselineY), axisPaint);

    // 4. Draw 7 Daily Bars with Tick Icons for Target Met
    final dayCount = bins.length;
    final slotWidth = plotWidth / dayCount;
    final barWidth = math.min(slotWidth * 0.42, 14.0);

    double? selectedCenterX;
    double? selectedBarTopY;

    for (int i = 0; i < dayCount; i++) {
      final bin = bins[i];
      final val = metric == ActivityMetric.revenue ? bin.revenue : bin.patients.toDouble();
      final ratio = (val / maxVal).clamp(0.0, 1.0);
      final barHeight = ratio * plotHeight * progress;
      final centerX = (i + 0.5) * slotWidth;
      final topY = baselineY - barHeight;

      if (i == selectedDayIndex) {
        selectedCenterX = centerX;
        selectedBarTopY = topY;
      }

      if (barHeight > 0) {
        final barRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(centerX - (barWidth / 2), topY, barWidth, barHeight),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(barRect, barPaint);

        // Checkmark Icon on top of bar if target met (Google Fit style)
        if (bin.isTargetMet && progress > 0.8) {
          final checkPaint = Paint()
            ..color = tooltipBgColor
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

          final checkY = topY + 7.0;
          final checkPath = Path()
            ..moveTo(centerX - 3.5, checkY)
            ..lineTo(centerX - 1.0, checkY + 2.5)
            ..lineTo(centerX + 3.5, checkY - 2.5);

          canvas.drawPath(checkPath, checkPaint);
        }
      }

      // Day Label below baseline
      final textSpan = TextSpan(
        text: bin.dayLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: labelColor,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(centerX - (textPainter.width / 2), baselineY + 8.0),
      );
    }

    // 5. Draw Interactive Scrubber Cursor & Floating Tooltip
    if (selectedDayIndex != null && selectedCenterX != null && selectedDayIndex! < bins.length) {
      final bin = bins[selectedDayIndex!];
      final cursorX = selectedCenterX;
      final cursorY = selectedBarTopY ?? baselineY;

      // Vertical Dashed Cursor Line
      final dashedPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.8)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      const dashHeight = 3.5;
      const dashSpace = 2.5;
      double cursorStartY = topMargin;
      while (cursorStartY < baselineY) {
        final endY = math.min(cursorStartY + dashHeight, baselineY);
        canvas.drawLine(Offset(cursorX, cursorStartY), Offset(cursorX, endY), dashedPaint);
        cursorStartY += dashHeight + dashSpace;
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

      // Tooltip Text: e.g. "₹ 2,800 on Thursday" or "12 patients on Thursday"
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
            text: 'on ${DateFormat('EEEE').format(bin.date)}',
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

      final bubbleLeft = (cursorX - (bubbleWidth / 2)).clamp(4.0, plotWidth - bubbleWidth - 4.0);
      const bubbleTop = 0.0;

      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleLeft, bubbleTop, bubbleWidth, bubbleHeight),
        const Radius.circular(16),
      );

      // Shadow
      final shadowPaint = Paint()
        ..color = tooltipTextColor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(bubbleRect.shift(const Offset(0, 2)), shadowPaint);

      final bubbleBgPaint = Paint()
        ..color = tooltipBgColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(bubbleRect, bubbleBgPaint);

      // Pointer
      final pointerPath = Path();
      final pointerCenterX = cursorX.clamp(bubbleLeft + 8.0, bubbleLeft + bubbleWidth - 8.0);
      pointerPath.moveTo(pointerCenterX - 4.5, bubbleHeight);
      pointerPath.lineTo(pointerCenterX, bubbleHeight + 4.5);
      pointerPath.lineTo(pointerCenterX + 4.5, bubbleHeight);
      pointerPath.close();
      canvas.drawPath(pointerPath, bubbleBgPaint);

      // Outline
      final borderPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.35)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(bubbleRect, borderPaint);

      tooltipPainter.paint(
        canvas,
        Offset(bubbleLeft + bubblePaddingH, bubbleTop + bubblePaddingV),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleFitWeekChartPainter oldDelegate) {
    return oldDelegate.bins != bins ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.dailyTarget != dailyTarget ||
        oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.selectedDayIndex != selectedDayIndex ||
        oldDelegate.metric != metric ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.axisColor != axisColor;
  }
}
