import 'package:flutter/material.dart';

import '../design/tokens.dart';
import 'app_card.dart';

/// Icon + title + subtitle row in iOS / Material 3 style.
///
/// In settings the subtitle carries the CURRENT VALUE ("Theme / Follow system"),
/// so the user reads state without opening the row.
class AppListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: 2,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: Radii.smAll,
        ),
        child: Icon(icon, size: 20, color: scheme.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                )
              : null),
      onTap: onTap,
    );
  }
}

/// Muted section header wrapping an iOS-style inset grouped [AppCard] of list tiles.
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final validChildren = children.where((w) => w is! SizedBox || (w.height != 0 && w.width != 0)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg,
            Spacing.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              fontSize: 12,
              color: scheme.primary,
            ),
          ),
        ),
        AppCard(
          margin: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.xs,
          ),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < validChildren.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 56,
                    color: scheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                validChildren[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
