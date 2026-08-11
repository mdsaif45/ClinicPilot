import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Title above a block of content, with an optional trailing action.
///
/// Use for every section on every screen so headings stay consistent.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final IconData actionIcon;

  /// Drops the top padding for a header that is already the first thing in a
  /// panel, so it does not sit lower than panels starting with other widgets.
  final bool tightTop;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionIcon = Icons.arrow_forward,
    this.tightTop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        tightTop ? 0 : Spacing.lg,
        Spacing.sm,
        Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null)
                  Text(subtitle!, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          if (onAction != null)
            IconButton(
              icon: Icon(actionIcon),
              onPressed: onAction,
              visualDensity: VisualDensity.compact,
              tooltip: 'See all',
            ),
        ],
      ),
    );
  }
}
