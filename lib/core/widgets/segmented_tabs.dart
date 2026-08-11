import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// One tab of a [SegmentedTabs].
class SegmentedTab {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  const SegmentedTab({
    required this.icon,
    required this.label,
    required this.builder,
  });
}

/// A row of icon pills with a single body that swaps beneath them.
///
/// This is how a screen surfaces a lot of data without pushing the user through
/// extra navigation: everything about one entity stays on one page, one tap
/// away. The label is exposed to screen readers via [Tooltip]/semantics even
/// though only the icon is drawn.
class SegmentedTabs extends StatefulWidget {
  final List<SegmentedTab> tabs;
  final int initialIndex;

  const SegmentedTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
  });

  @override
  State<SegmentedTabs> createState() => _SegmentedTabsState();
}

class _SegmentedTabsState extends State<SegmentedTabs> {
  late int _index = widget.initialIndex.clamp(0, widget.tabs.length - 1);

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              for (var i = 0; i < widget.tabs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: _TabPill(
                    tab: widget.tabs[i],
                    selected: i == _index,
                    onTap: () => setState(() => _index = i),
                  ),
                ),
            ],
          ),
        ),
        // Fixed gap, and the body swaps instantly.
        //
        // The pill morph carries the feedback on its own. Animating the panel
        // as well made each tab's content start from a different height and
        // settle at a different moment, so the spacing under the selector
        // looked inconsistent from tab to tab.
        //
        // The gap lives here rather than inside each tab so every panel begins
        // at exactly the same offset, whatever widget it happens to start with.
        const SizedBox(height: Spacing.lg),
        Builder(builder: widget.tabs[_index].builder),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final SegmentedTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final animate = !MediaQuery.of(context).disableAnimations;
    final duration = animate ? Motion.base : Duration.zero;

    return Tooltip(
      message: tab.label,
      child: Semantics(
        label: tab.label,
        selected: selected,
        button: true,
        // The selected tab widens into a pill while the others stay as
        // squircles, and the shape morphs between the two states rather than
        // snapping - the movement is what makes the selection legible at a
        // glance on a small icon.
        child: AnimatedContainer(
          duration: duration,
          curve: Motion.curve,
          height: 44,
          width: selected ? 68 : 52,
          decoration: BoxDecoration(
            color: selected
                ? scheme.secondaryContainer
                : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(selected ? Radii.pill : Radii.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: AnimatedScale(
                  duration: duration,
                  curve: Motion.curve,
                  scale: selected ? 1.08 : 1.0,
                  child: Icon(
                    tab.icon,
                    size: 20,
                    color: selected
                        ? scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
