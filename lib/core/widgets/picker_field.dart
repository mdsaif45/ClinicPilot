import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Option shown in a [PickerField] sheet.
class PickerOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? colour;

  const PickerOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.colour,
  });
}

/// Standard labelled selector that opens a bottom sheet.
/// Matches [CustomTextField] geometry down to the pixel.
class PickerField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<PickerOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? prefixIcon;
  final String hint;
  final String? errorText;

  const PickerField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.prefixIcon,
    this.hint = 'Select',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    PickerOption<T>? selected;
    for (final o in options) {
      if (o.value == value) {
        selected = o;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        InkWell(
          borderRadius: Radii.mdAll,
          onTap: options.isEmpty ? null : () => _open(context),
          child: InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, size: 20, color: scheme.onSurfaceVariant),
              suffixIcon: const Icon(Icons.expand_more, size: 20),
              errorText: errorText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: 14,
              ),
            ),
            child: Row(
              children: [
                if (selected?.colour != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: selected!.colour,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                ],
                Expanded(
                  child: Text(
                    selected?.label ?? hint,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: selected != null
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: Spacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  0,
                  Spacing.lg,
                  Spacing.sm,
                ),
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final o in options)
                ListTile(
                  leading: o.icon != null
                      ? Icon(o.icon, size: 20, color: scheme.primary)
                      : (o.colour != null
                          ? Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: o.colour,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null),
                  title: Text(
                    o.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          o.value == value ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                  trailing: o.value == value
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: () {
                    onChanged(o.value);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
