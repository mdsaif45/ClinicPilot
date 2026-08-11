import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Consistent surface for grouped content. Use instead of raw Card/Container
/// so padding, radius and border stay uniform across screens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.margin = const EdgeInsets.symmetric(horizontal: Spacing.lg),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: margin,
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: Radii.lgAll,
              border: Border.all(color: scheme.outlineVariant),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
