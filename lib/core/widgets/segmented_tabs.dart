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

    // Honour the OS "remove animations" accessibility setting.
    final animate = !MediaQuery.of(context).disableAnimations;

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
        const SizedBox(height: Spacing.lg),
        AnimatedSwitcher(
          duration: animate ? Motion.base : Duration.zero,
          switchInCurve: Motion.curve,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: Builder(builder: widget.tabs[_index].builder),
          ),
        ),
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

    return Tooltip(
      message: tab.label,
      child: Semantics(
        label: tab.label,
        selected: selected,
        button: true,
        child: Material(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: Radii.mdAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.md,
              ),
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
    );
  }
}
