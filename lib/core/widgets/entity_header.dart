import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Hero header identifying the thing a screen is about.
///
/// Avatar/initial, title, subtitle and badges over a tinted band — the same
/// shape used by patient profile and clinic screens so entity pages feel alike.
class EntityHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? avatarText;
  final Color? accent;
  final List<Widget> badges;
  final List<Widget> actions;

  const EntityHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarText,
    this.accent,
    this.badges = const [],
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tint = accent ?? scheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.lg,
        Spacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.16),
            tint.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: tint.withValues(alpha: 0.20),
            child: Text(
              (avatarText?.trim().isNotEmpty ?? false)
                  ? avatarText!.trim()[0].toUpperCase()
                  : '?',
              style: theme.textTheme.headlineSmall?.copyWith(color: tint),
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(subtitle!, style: theme.textTheme.labelMedium),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Wrap(spacing: Spacing.sm, runSpacing: Spacing.sm, children: badges),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
