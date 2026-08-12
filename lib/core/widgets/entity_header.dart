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

  /// Optional back button. When present the header also reserves room for the
  /// status bar, since a screen using this instead of an AppBar has nothing
  /// else holding that space.
  final Widget? leading;

  const EntityHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarText,
    this.accent,
    this.badges = const [],
    this.actions = const [],
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tint = accent ?? scheme.primary;

    final topInset = leading == null ? 0.0 : MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg + topInset,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null || actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Row(
                children: [
                  if (leading != null) leading!,
                  const Spacer(),
                  ...actions,
                ],
              ),
            ),
          Row(
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
            ],
          ),
        ],
      ),
    );
  }
}
