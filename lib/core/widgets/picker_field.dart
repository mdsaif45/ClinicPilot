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

/// Labelled selector that opens a bottom sheet.
///
/// Replaces DropdownButtonFormField for anything with a handful of options.
/// The floating `labelText` a dropdown uses sits on the border and clips when
/// the field has a prefix icon, and the popup menu it opens has no room for a
/// second line, so options can only ever be a bare string.
///
/// Label placement matches CustomTextField, so a form mixing the two lines up.
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
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: Radii.mdAll,
          onTap: options.isEmpty ? null : () => _open(context),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
              suffixIcon: const Icon(Icons.expand_more),
              errorText: errorText,
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
                    style: selected == null
                        ? TextStyle(color: theme.hintColor)
                        : const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _open(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;

    final picked = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Text(label, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            const SizedBox(height: Spacing.sm),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in options)
                    ListTile(
                      leading: o.colour != null
                          ? Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: o.colour,
                                shape: BoxShape.circle,
                              ),
                            )
                          : (o.icon == null ? null : Icon(o.icon)),
                      title: Text(o.label),
                      subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                      trailing: o.value == value
                          ? Icon(Icons.check_circle, color: scheme.primary)
                          : null,
                      onTap: () => Navigator.of(ctx).pop(o.value),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );

    if (picked != null) onChanged(picked);
  }
}
