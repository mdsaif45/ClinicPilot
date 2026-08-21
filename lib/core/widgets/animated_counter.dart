import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../utils/formatters.dart';

/// Animated counter that smoothly interpolates numbers/currency values
/// with an ease-out curve on initial load and value updates.
class AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final String Function(double value)? formatter;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.formatter,
  });

  /// Formats value as currency (e.g. ₹ 1,200).
  factory AnimatedCounter.currency({
    Key? key,
    required double value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      AnimatedCounter(
        key: key,
        value: value,
        style: style,
        duration: duration,
        formatter: (v) => Formatters.formatCurrency(v),
      );

  /// Formats value as whole integer (e.g. 42).
  factory AnimatedCounter.count({
    Key? key,
    required int value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 600),
  }) =>
      AnimatedCounter(
        key: key,
        value: value.toDouble(),
        style: style,
        duration: duration,
        formatter: (v) => '${v.round()}',
      );

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Motion.curve),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Motion.curve),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.titleMedium;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final text = widget.formatter != null
            ? widget.formatter!(_animation.value)
            : _animation.value.toStringAsFixed(0);
        return Text(text, style: style);
      },
    );
  }
}
