import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Concentric double activity ring inspired by Google Fit / Apple Health.
///
/// - Outer Ring: Patient Volume Goal Progress ([outerColor])
/// - Inner Ring: Revenue Goal Progress ([innerColor])
class DoubleActivityRing extends StatelessWidget {
  final double innerProgress; // 0.0 to 1.0+ (Revenue)
  final double outerProgress; // 0.0 to 1.0+ (Patients)
  final Color innerColor;
  final Color outerColor;
  final double size;

  const DoubleActivityRing({
    super.key,
    required this.innerProgress,
    required this.outerProgress,
    required this.innerColor,
    required this.outerColor,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DoubleActivityRingPainter(
          innerProgress: innerProgress.clamp(0.0, 1.0),
          outerProgress: outerProgress.clamp(0.0, 1.0),
          innerColor: innerColor,
          outerColor: outerColor,
        ),
      ),
    );
  }
}

class _DoubleActivityRingPainter extends CustomPainter {
  final double innerProgress;
  final double outerProgress;
  final Color innerColor;
  final Color outerColor;

  const _DoubleActivityRingPainter({
    required this.innerProgress,
    required this.outerProgress,
    required this.innerColor,
    required this.outerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.11; // ~2.4 for 22px
    final gap = strokeWidth * 0.55;

    final outerRadius = (size.width - strokeWidth) / 2;
    final innerRadius = outerRadius - strokeWidth - gap;

    // 1. Outer Track (Background)
    final outerTrackPaint =
        Paint()
          ..color = outerColor.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, outerRadius, outerTrackPaint);

    // 2. Outer Progress Arc
    if (outerProgress > 0) {
      final outerArcPaint =
          Paint()
            ..color = outerColor
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = strokeWidth;

      const startAngle = -math.pi / 2; // 12 o'clock
      final sweepAngle = 2 * math.pi * outerProgress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
        false,
        outerArcPaint,
      );
    }

    // 3. Inner Track (Background)
    if (innerRadius > 0) {
      final innerTrackPaint =
          Paint()
            ..color = innerColor.withValues(alpha: 0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, innerRadius, innerTrackPaint);

      // 4. Inner Progress Arc
      if (innerProgress > 0) {
        final innerArcPaint =
            Paint()
              ..color = innerColor
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = strokeWidth;

        const startAngle = -math.pi / 2; // 12 o'clock
        final sweepAngle = 2 * math.pi * innerProgress;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle,
          sweepAngle,
          false,
          innerArcPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DoubleActivityRingPainter oldDelegate) {
    return oldDelegate.innerProgress != innerProgress ||
        oldDelegate.outerProgress != outerProgress ||
        oldDelegate.innerColor != innerColor ||
        oldDelegate.outerColor != outerColor;
  }
}
