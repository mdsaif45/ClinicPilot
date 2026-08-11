import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Icon + title + subtitle row.
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: theme.textTheme.labelMedium),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// Muted section header wrapping a group of [AppListTile]s.
class SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.xl,
            Spacing.lg,
            Spacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
