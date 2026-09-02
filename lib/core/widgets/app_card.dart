import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Consistent surface for grouped content.
/// Provides standardized padding, radius, border, and elevation across screens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.margin = const EdgeInsets.symmetric(
      horizontal: Spacing.lg,
      vertical: Spacing.xs,
    ),
    this.borderRadius,
    this.color,
    this.borderColor,
    this.elevation,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = borderRadius ?? Radii.mdAll;
    final bg = color ?? scheme.surfaceContainerLow;
    final border = borderColor ?? scheme.outlineVariant.withValues(alpha: 0.5);

    return Padding(
      padding: margin,
      child: Material(
        color: bg,
        elevation: elevation ?? 0,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: r,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: r,
              border: Border.all(color: border),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
