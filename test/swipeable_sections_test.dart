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

  testWidgets('tapping the second label animates to the second page', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 1.0);
  });

  testWidgets('swiping does not change page (swipe disabled by design)', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 0.0);

    final switcher = tester.widget<SectionSwitch>(find.byType(SectionSwitch));
    expect(switcher.index, 0);
  });
}
