import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// A destination item definition for [FloatingBottomNavBar].
class FloatingNavDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Widget? badge;

  const FloatingNavDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badge,
  });
}

/// A modern, premium floating pill bottom navigation bar.
///
/// Encapsulates navigation items in a floating capsule container with
/// inset rounded active highlights, consistent icon weighting, and high contrast.
class FloatingBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FloatingNavDestination> destinations;
  final Color? backgroundColor;
  final Color? activeHighlightColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const FloatingBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.activeHighlightColor,
    this.activeColor,
    this.inactiveColor,
    this.margin = const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.md),
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Resolves entirely from theme ColorScheme with high contrast WCAG standards
    final barBg = backgroundColor ??
        (isDark ? scheme.surfaceContainerHigh : scheme.inverseSurface);
    final activeHighlight = activeHighlightColor ??
        (isDark
            ? scheme.primary.withValues(alpha: 0.24)
            : scheme.onInverseSurface.withValues(alpha: 0.20));
    final active = activeColor ?? (isDark ? scheme.primary : scheme.inversePrimary);
    final inactive = inactiveColor ??
        (isDark
            ? scheme.onSurfaceVariant
            : scheme.onInverseSurface.withValues(alpha: 0.85));

    return RepaintBoundary(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: margin,
          child: Container(
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: barBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: padding,
            child: Row(
              children: [
                for (int i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _FloatingNavItem(
                      destination: destinations[i],
                      isSelected: selectedIndex == i,
                      activeHighlightColor: activeHighlight,
                      activeColor: active,
                      inactiveColor: inactive,
                      onTap: () => onDestinationSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final FloatingNavDestination destination;
  final bool isSelected;
  final Color activeHighlightColor;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.destination,
    required this.isSelected,
    required this.activeHighlightColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: activeColor.withValues(alpha: 0.15),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? activeHighlightColor : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          isSelected
                              ? (destination.selectedIcon ?? destination.icon)
                              : destination.icon,
                          size: 21,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                      ),
                      if (destination.badge != null)
                        Positioned(
                          top: -2,
                          right: -4,
                          child: destination.badge!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : inactiveColor,
                    letterSpacing: 0.1,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Text(
                    destination.label,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
