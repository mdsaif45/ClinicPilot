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
  final Color? iconColor;
  final Color? leadingBackgroundColor;
  final Color? titleColor;

  const AppListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.leadingBackgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final effectiveIconColor = iconColor ?? scheme.primary;
    final effectiveLeadingBg = leadingBackgroundColor ??
        scheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: 2,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: effectiveLeadingBg,
          borderRadius: Radii.smAll,
        ),
        child: Icon(icon, size: 20, color: effectiveIconColor),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: titleColor,
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

/// A switch row inside a [SettingsGroup] matching [AppListTile] metrics.
class AppSwitchTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;
  final Color? leadingBackgroundColor;

  const AppSwitchTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
    this.leadingBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final effectiveIconColor = iconColor ?? scheme.primary;
    final effectiveLeadingBg = leadingBackgroundColor ??
        scheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: effectiveLeadingBg,
                borderRadius: Radii.smAll,
              ),
              child: Icon(icon, size: 20, color: effectiveIconColor),
            ),
            const SizedBox(width: Spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A slider row inside a [SettingsGroup] matching [AppListTile] metrics.
class AppSliderTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? valueLabel;
  final ValueChanged<double> onChanged;
  final Color? iconColor;
  final Color? leadingBackgroundColor;

  const AppSliderTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.valueLabel,
    required this.onChanged,
    this.iconColor,
    this.leadingBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final effectiveIconColor = iconColor ?? scheme.primary;
    final effectiveLeadingBg = leadingBackgroundColor ??
        scheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: effectiveLeadingBg,
                    borderRadius: Radii.smAll,
                  ),
                  child: Icon(icon, size: 20, color: effectiveIconColor),
                ),
                const SizedBox(width: Spacing.md),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  valueLabel != null ? valueLabel!(value) : '${value.round()}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Spacing.xs),
            Padding(
              padding: EdgeInsets.only(left: icon != null ? 52 : 0),
              child: Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: Spacing.xs),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
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
