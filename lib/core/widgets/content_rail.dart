import 'package:flutter/material.dart';

import '../design/tokens.dart';
import 'section_header.dart';

/// Section header plus a horizontally scrolling row.
///
/// Keeps pages short: a rail shows the most recent few items sideways instead
/// of pushing everything else off the bottom of the screen.
class ContentRail extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final List<Widget> children;
  final double height;
  final Widget? emptyState;

  const ContentRail({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.onAction,
    this.height = 132,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: subtitle, onAction: onAction),
        if (children.isEmpty && emptyState != null)
          emptyState!
        else
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.md),
              itemBuilder: (_, i) => children[i],
            ),
          ),
      ],
    );
  }
}
