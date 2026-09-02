import 'package:flutter/material.dart';
import '../design/tokens.dart';

/// Lightweight, pure Flutter shimmer effect that pulses smoothly
/// using the active theme's surface color scheme.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? Radii.smAll,
            color: scheme.surfaceContainerHighest.withValues(
              alpha: _animation.value,
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer skeleton loader for list tiles.
class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Row(
        children: [
          ShimmerBox(width: 44, height: 44, borderRadius: Radii.pillAll),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: Radii.smAll,
                ),
                const SizedBox(height: Spacing.sm),
                ShimmerBox(width: 140, height: 11, borderRadius: Radii.smAll),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton loader for the dashboard metrics and cards.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting placeholder
          const ShimmerBox(width: 160, height: 18),
          const SizedBox(height: Spacing.sm),
          const ShimmerBox(width: 220, height: 12),
          const SizedBox(height: Spacing.xl),
          // Metric strip placeholder
          Row(
            children: [
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 80,
                  borderRadius: Radii.mdAll,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ShimmerBox(
                  width: double.infinity,
                  height: 80,
                  borderRadius: Radii.mdAll,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          // Card placeholder
          ShimmerBox(
            width: double.infinity,
            height: 120,
            borderRadius: Radii.lgAll,
          ),
        ],
      ),
    );
  }
}
