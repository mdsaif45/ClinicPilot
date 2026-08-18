import 'package:clinic_pilot/core/widgets/section_switch.dart';
import 'package:clinic_pilot/core/widgets/swipeable_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// SwipeableSections replaced IndexedStack on the Finances and Patients tabs
/// so a section switch could also be driven by a swipe, not just a tap on the
/// label. Both paths have to land in the same place.
void main() {
  Widget harness() => MaterialApp(
        home: Scaffold(
          body: SwipeableSections(
            labels: const ['One', 'Two'],
            children: [
              Container(key: const Key('page-one'), color: Colors.red),
              Container(key: const Key('page-two'), color: Colors.blue),
            ],
          ),
        ),
      );

  testWidgets('opens on the first page', (tester) async {
    await tester.pumpWidget(harness());

    expect(find.byKey(const Key('page-one')), findsOneWidget);
  });

  testWidgets('tapping the second label animates to the second page',
      (tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 1.0);
  });

  testWidgets('swiping left moves to the second page and updates the label',
      (tester) async {
    await tester.pumpWidget(harness());

    // fling rather than drag: a plain drag() doesn't reliably carry enough
    // velocity to cross the page-turn threshold, which is a property of the
    // gesture simulation, not of PageView - a real swipe has velocity.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 1.0);

    // The label bar has to agree with what a swipe just did, not only with
    // what a tap did - onPageChanged is what keeps it in sync.
    final switcher = tester.widget<SectionSwitch>(find.byType(SectionSwitch));
    expect(switcher.index, 1);
  });

  testWidgets('swiping back right returns to the first page', (tester) async {
    await tester.pumpWidget(harness());

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(400, 0), 800);
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 0.0);
  });
}
