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

  const SwipeableSections({
    super.key,
    required this.labels,
    required this.children,
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
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionSwitch(
          labels: widget.labels,
          index: _index,
          onChanged: _goTo,
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            // The label bar is the primary indicator of which page is open;
            // this only needs to keep it in sync when a swipe (rather than a
            // tap) changes the page.
            onPageChanged: (i) => setState(() => _index = i),
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
