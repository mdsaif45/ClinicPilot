import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// Text-only section switch: the selected label is bold and full contrast, the
/// rest are muted. Deliberately not a pill or a tab bar — at this count the
/// weight difference is enough, and it keeps the top of the screen quiet.
///
/// Shared so that a tab splitting into sections looks the same wherever it
/// happens, rather than each screen inventing its own header.
class SectionSwitch extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  /// An action that belongs beside the switch rather than inside either
  /// section - e.g. exporting whichever section is currently selected, where
  /// the action itself does not change, only what it acts on.
  final Widget? trailing;

  const SectionSwitch({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final animate = !MediaQuery.of(context).disableAnimations;

    // Its own Material, rather than relying on an ancestor: the InkWell needs
    // one, and a caller that returns a bare Column would otherwise crash only
    // once tapped.
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          labels.length > 2 ? Spacing.md : Spacing.lg,
          Spacing.md,
          labels.length > 2 ? Spacing.md : Spacing.lg,
          Spacing.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) SizedBox(width: labels.length > 2 ? Spacing.md : Spacing.xl),
              InkWell(
                borderRadius: Radii.smAll,
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                    vertical: Spacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: animate ? Motion.fast : Duration.zero,
                        curve: Motion.curve,
                        style: (theme.textTheme.titleMedium ??
                                const TextStyle())
                            .copyWith(
                          color: i == index
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                          fontWeight:
                              i == index ? FontWeight.w700 : FontWeight.w400,
                        ),
                        child: Text(labels[i]),
                      ),
                      const SizedBox(height: Spacing.xs),
                      // Underline marks the selection without adding a control
                      // the eye has to parse.
                      AnimatedContainer(
                        duration: animate ? Motion.base : Duration.zero,
                        curve: Motion.curve,
                        height: 2,
                        width: i == index ? 24 : 0,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: Radii.pillAll,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
