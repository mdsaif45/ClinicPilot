import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Bottom-navigation icon that inverts on selection.
///
/// The stock NavigationBar only swaps outlined for filled and tints the pill.
/// On a five-tab bar that change is easy to miss mid-consultation, so the
/// selected icon here also lifts, scales slightly and flips to the inverse
/// colour pair - a filled disc rather than a tinted glyph.
class AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;

  const AnimatedNavIcon({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final animate = !MediaQuery.of(context).disableAnimations;
    final duration = animate ? Motion.base : Duration.zero;

    return AnimatedContainer(
      duration: duration,
      curve: Motion.curve,
      padding: EdgeInsets.symmetric(
        horizontal: selected ? Spacing.lg : Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? scheme.primary : Colors.transparent,
        borderRadius: Radii.pillAll,
      ),
      child: AnimatedScale(
        duration: duration,
        curve: Motion.curve,
        scale: selected ? 1.1 : 1.0,
        child: AnimatedSwitcher(
          duration: duration,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            selected ? selectedIcon : icon,
            // Inverted: on the filled pill the glyph takes the onPrimary
            // colour, so selection reads as a solid block rather than a tint.
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            key: ValueKey(selected),
            size: 22,
          ),
        ),
      ),
    );
  }
}
