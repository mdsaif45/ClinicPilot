import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../services/app_haptics.dart';

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

/// A row of icon pills with a single body that swaps beneath them and supports
/// horizontal swiping left and right between tabs.
///
/// This is how a screen surfaces a lot of data without pushing the user through
/// extra navigation: everything about one entity stays on one page, one tap
/// or swipe away. The label is exposed to screen readers via [Tooltip]/semantics even
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
  final ScrollController _pillScrollController = ScrollController();
  final List<GlobalKey> _pillKeys = [];
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _pillKeys.addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(SegmentedTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _pillKeys.clear();
      _pillKeys.addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
    }
  }

  @override
  void dispose() {
    _pillScrollController.dispose();
    super.dispose();
  }

  void _selectTab(int i) {
    if (i < 0 || i >= widget.tabs.length) return;
    if (_index == i) return;
    setState(() => _index = i);
    AppHaptics.selection();
    _scrollToPill(i);
  }

  void _scrollToPill(int i) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || i >= _pillKeys.length) return;
      final pillContext = _pillKeys[i].currentContext;
      if (pillContext != null) {
        Scrollable.ensureVisible(
          pillContext,
          duration: Motion.base,
          curve: Motion.curve,
          alignment: 0.5,
        );
      }
    });
  }

  void _nextTab() {
    if (_index < widget.tabs.length - 1) {
      _selectTab(_index + 1);
    }
  }

  void _prevTab() {
    if (_index > 0) {
      _selectTab(_index - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tabs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          controller: _pillScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              for (var i = 0; i < widget.tabs.length; i++)
                Padding(
                  key: i < _pillKeys.length ? _pillKeys[i] : null,
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: _TabPill(
                    tab: widget.tabs[i],
                    selected: i == _index,
                    onTap: () => _selectTab(i),
                  ),
                ),
            ],
          ),
        ),
        // Fixed gap, and the body swaps instantly on tap or swipe.
        //
        // The pill morph carries the feedback on its own. Animating the panel
        // as well made each tab's content start from a different height and
        // settle at a different moment, so the spacing under the selector
        // looked inconsistent from tab to tab.
        //
        // The gap lives here rather than inside each tab so every panel begins
        // at exactly the same offset, whatever widget it happens to start with.
        const SizedBox(height: Spacing.lg),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => _dragDistance = 0.0,
          onHorizontalDragUpdate: (details) {
            _dragDistance += details.primaryDelta ?? 0.0;
          },
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0.0;
            if (velocity < -150 || _dragDistance < -50) {
              _nextTab();
            } else if (velocity > 150 || _dragDistance > 50) {
              _prevTab();
            }
            _dragDistance = 0.0;
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_index),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final animate = !MediaQuery.of(context).disableAnimations;
    final duration = animate ? Motion.base : Duration.zero;

    return Semantics(
      label: tab.label,
      selected: selected,
      button: true,
      // The selected tab expands to show its name beside the icon, so the
      // panel below never needs a separate heading repeating it. Unselected
      // tabs stay icon-only, which keeps five of them on a phone width.
      child: AnimatedContainer(
        duration: duration,
        curve: Motion.curve,
        height: 44,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? Spacing.lg : Spacing.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius:
              BorderRadius.circular(selected ? Radii.pill : Radii.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab.icon,
                  size: 20,
                  color: selected
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant,
                ),
                // Width animates from zero, so the label slides out of the
                // icon rather than appearing beside it.
                AnimatedSize(
                  duration: duration,
                  curve: Motion.curve,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: Spacing.sm),
                          child: Text(
                            tab.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}