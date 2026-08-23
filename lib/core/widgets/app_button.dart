import 'package:flutter/material.dart';

import '../design/tokens.dart';

enum _ButtonVariant { primary, tonal, outlined, text }

/// Single source of truth for all action buttons in the application.
/// Enforces standard height (46dp), radius (12dp), touch targets, and typography.
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final bool isDestructive;
  final _ButtonVariant _variant;

  const AppButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.isDestructive = false,
  }) : _variant = _ButtonVariant.primary;

  const AppButton.tonal({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.isDestructive = false,
  }) : _variant = _ButtonVariant.tonal;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.isDestructive = false,
  }) : _variant = _ButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.isDestructive = false,
  }) : _variant = _ButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final shape = RoundedRectangleBorder(borderRadius: Radii.mdAll);
    const minHeight = 46.0;

    final Color textColor = switch (_variant) {
      _ButtonVariant.primary =>
        isDestructive ? scheme.onError : scheme.onPrimary,
      _ButtonVariant.tonal => isDestructive
          ? scheme.onErrorContainer
          : scheme.onSecondaryContainer,
      _ButtonVariant.outlined =>
        isDestructive ? scheme.error : scheme.primary,
      _ButtonVariant.text => isDestructive ? scheme.error : scheme.primary,
    };

    Widget childContent;
    if (loading) {
      childContent = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: textColor,
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: Spacing.sm),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    Widget buttonWidget;

    switch (_variant) {
      case _ButtonVariant.primary:
        buttonWidget = FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? scheme.error : scheme.primary,
            foregroundColor: textColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
            shape: shape,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
          ),
          onPressed: loading ? null : onPressed,
          child: childContent,
        );
        break;

      case _ButtonVariant.tonal:
        buttonWidget = FilledButton.tonal(
          style: FilledButton.styleFrom(
            foregroundColor: textColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
            shape: shape,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
          ),
          onPressed: loading ? null : onPressed,
          child: childContent,
        );
        break;

      case _ButtonVariant.outlined:
        buttonWidget = OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
            shape: shape,
            side: BorderSide(
              color: isDestructive
                  ? scheme.error.withValues(alpha: 0.5)
                  : scheme.outlineVariant,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
          ),
          onPressed: loading ? null : onPressed,
          child: childContent,
        );
        break;

      case _ButtonVariant.text:
        buttonWidget = TextButton(
          style: TextButton.styleFrom(
            foregroundColor: textColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, minHeight),
            shape: shape,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
          ),
          onPressed: loading ? null : onPressed,
          child: childContent,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }
    return buttonWidget;
  }
}
