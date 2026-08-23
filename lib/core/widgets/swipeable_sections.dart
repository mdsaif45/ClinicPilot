import 'package:flutter/material.dart';

import 'section_switch.dart';

/// [SectionSwitch] plus the pages it switches between, connected two ways:
/// tapping a label jumps to that page, and swiping left or right moves
/// between them - the same page-turn gesture as flipping between tabs on any
/// other screen, so a doctor mid-clinic isn't forced to reach for the label
/// every time.
///
/// Replaces the IndexedStack every section-switch screen used before: a
/// PageView keeps each child's state alive the same way IndexedStack did
/// (scroll position, whatever is typed in a search box), it just also
/// responds to a drag.
class SwipeableSections extends StatefulWidget {
  final List<String> labels;
  final List<Widget> children;

  /// Builds the trailing action for the currently selected section - a
  /// builder rather than a fixed widget, since e.g. Finances exports memos
  /// or expenses depending on which half is showing, not the same thing
  /// either way.
  final Widget? Function(int index)? trailingBuilder;

  const SwipeableSections({
    super.key,
    required this.labels,
    required this.children,
    this.trailingBuilder,
  });

  @override
  State<SwipeableSections> createState() => _SwipeableSectionsState();
}

class _SwipeableSectionsState extends State<SwipeableSections> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    assert(widget.labels.length == widget.children.length);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    setState(() => _index = i);
    _controller.jumpToPage(i);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionSwitch(
          labels: widget.labels,
          index: _index,
          onChanged: _goTo,
          trailing: widget.trailingBuilder?.call(_index),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _index = i),
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
