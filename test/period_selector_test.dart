import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/widgets/period_selector.dart';

void main() {
  testWidgets(
    'PeriodSelector renders Image 3 UI with navigation chevrons, future restrictions and clean day labels',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: PeriodSelector())),
        ),
      );

      // 1. Verify previous and next chevrons
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      // 2. Center pill displays current month
      expect(find.text('September 2026'), findsOneWidget);

      // 3. Future restriction: On current month, next chevron (>) is disabled
      final nextBtnOnCurrentMonth = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextBtnOnCurrentMonth.onPressed, isNull);

      // 4. Tap previous chevron (<) to navigate back 1 month to August 2026
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('August 2026'), findsOneWidget);

      // Now in past month, next chevron is enabled!
      final nextBtnOnPastMonth = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextBtnOnPastMonth.onPressed, isNotNull);

      // 5. Tap next chevron (>) to return to current month
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);

      // 6. Tap the center pill to open Period bottom sheet
      await tester.tap(find.text('September 2026'));
      await tester.pumpAndSettle();

      // Verify modal options are present
      expect(find.text('Period'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Month'), findsOneWidget);
      expect(find.text('Select Specific Month...'), findsOneWidget);
      expect(find.text('Custom Range...'), findsOneWidget);

      // 7. Select "Today"
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);

      // Future restriction on Today: next chevron is disabled!
      final nextBtnOnToday = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextBtnOnToday.onPressed, isNull);

      // 8. Tap previous (<) from Today: should display "Yesterday", NEVER "01 Sep 2026 — 01 Sep 2026"!
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Yesterday'), findsOneWidget);
      // Confirm no duplicate range format
      expect(find.textContaining('—'), findsNothing);

      // Tap previous (<) again: should display single date e.g. "31 Aug 2026"
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('31 Aug 2026'), findsOneWidget);
      expect(find.textContaining('—'), findsNothing);

      // Now we can go forward back to Yesterday and Today
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('Yesterday'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);

      // Once at Today, cannot go forward anymore
      final nextBtnBackAtToday = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextBtnBackAtToday.onPressed, isNull);

      // 9. Switch to July 2026 (two months ago)
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('This Month'));
      await tester.pumpAndSettle();

      // Tap (<) twice: September -> August -> July
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('July 2026'), findsOneWidget);

      // Open period sheet when on July 2026
      await tester.tap(find.text('July 2026'));
      await tester.pumpAndSettle();

      // Verify "Specific Month (July 2026)" is present and marked active, NOT Custom Range!
      expect(find.text('Specific Month (July 2026)'), findsOneWidget);
    },
  );
}
