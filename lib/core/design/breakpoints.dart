import 'package:flutter/material.dart';

/// Screen size breakpoints following Material 3 window size classes.
///
/// Ensures layout adapts cleanly across:
/// - 5" compact phones (< 600dp width)
/// - 6.5" modern standard phones (< 600dp width)
/// - 7"-8" mini tablets & foldables (600dp - 840dp)
/// - 10"+ full tablets & desktops (840dp+)
abstract class Breakpoints {
  /// Phone width boundary.
  static const double compact = 600;

  /// Foldable & small tablet boundary.
  static const double medium = 840;

  /// Full tablet and desktop boundary.
  static const double expanded = 1200;

  /// Maximum comfortable width for forms and entity sheets.
  static const double maxFormWidth = 560;

  /// Maximum content width for lists and dashboard cards.
  static const double maxContentWidth = 960;
}

/// Convenience helpers on [BuildContext] for responsive layout decisions.
extension ResponsiveContext on BuildContext {
  /// True on phone screen widths (< 600dp).
  bool get isCompact => MediaQuery.sizeOf(this).width < Breakpoints.compact;

  /// True on tablets, foldables, and desktops (>= 600dp).
  bool get isTablet => MediaQuery.sizeOf(this).width >= Breakpoints.compact;

  /// True on large tablets and desktop displays (>= 840dp).
  bool get isExpanded => MediaQuery.sizeOf(this).width >= Breakpoints.medium;

  /// Current screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Current screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;
}

/// Centered wrapper that restricts content to a readable maximum width on wide displays.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
