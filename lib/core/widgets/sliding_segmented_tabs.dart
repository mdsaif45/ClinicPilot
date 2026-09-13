import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../services/app_haptics.dart';

/// Item definition for [SlidingSegmentedTabs].
class SlidingTabItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SlidingTabItem({required this.value, required this.label, this.icon});
}

/// A smooth, sliding pill segmented tab switch that glides across tabs
/// with fluid [AnimatedAlign] animation.
///
/// Designed to provide consistent sliding tab behavior across screens
/// (e.g. Practice Activity time-range tabs, Clinical Case Sheet sub-tabs).
class SlidingSegmentedTabs<T> extends StatelessWidget {
  final List<SlidingTabItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? selectedColor;

  const SlidingSegmentedTabs({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.height = 44,
    this.padding = const EdgeInsets.all(4),
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final selectedIndex = items.indexWhere(
      (item) => item.value == selectedValue,
    );
    final validIndex = selectedIndex >= 0 ? selectedIndex : 0;
    final count = items.length;
    final alignX = count > 1 ? -1.0 + (2.0 * validIndex) / (count - 1) : 0.0;

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / count;

          return Stack(
            children: [
              // Smooth Sliding Floating Pill Background
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment(alignX, 0),
                child: Container(
                  width: tabWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Tabs
              Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (item.value != selectedValue) {
                            AppHaptics.selection();
                            onChanged(item.value);
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.icon != null) ...[
                                Icon(
                                  item.icon,
                                  size: 16,
                                  color:
                                      item.value == selectedValue
                                          ? (selectedColor ?? scheme.primary)
                                          : scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: Spacing.xs),
                              ],
                              Flexible(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: (theme.textTheme.labelMedium ??
                                          const TextStyle())
                                      .copyWith(
                                        fontSize: 13,
                                        fontWeight:
                                            item.value == selectedValue
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                        color:
                                            item.value == selectedValue
                                                ? (selectedColor ??
                                                    (item.icon != null
                                                        ? scheme.primary
                                                        : scheme.onSurface))
                                                : scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
