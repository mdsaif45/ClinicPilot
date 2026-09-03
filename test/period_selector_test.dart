import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/utils/formatters.dart';
import 'package:clinic_pilot/core/widgets/period_selector.dart';

void main() {
  testWidgets(
    'PeriodSelector renders Image 3 UI with navigation chevrons, future restrictions and clean day labels',
    (tester) async {
      final now = DateTime.now();
      final currentMonthText = Formatters.formatMonthYear(
        DateTime(now.year, now.month, 1),
      );
      final lastMonthText = Formatters.formatMonthYear(
        DateTime(now.year, now.month - 1, 1),
      );
      final twoMonthsAgoText = Formatters.formatMonthYear(
        DateTime(now.year, now.month - 2, 1),
      );
      final twoDaysAgoText = Formatters.formatDate(
        now.subtract(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: PeriodSelector())),
        ),
      );

      // 1. Verify previous and next chevrons
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      // 2. Center pill displays current month
      expect(find.text(currentMonthText), findsOneWidget);

      // 3. Future restriction: On current month, next chevron (>) is disabled
      final nextBtnOnCurrentMonth = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextBtnOnCurrentMonth.onPressed, isNull);

      // 4. Tap previous chevron (<) to navigate back 1 month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text(lastMonthText), findsOneWidget);

      // Now in past month, next chevron is enabled!
      final nextBtnOnPastMonth = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextBtnOnPastMonth.onPressed, isNotNull);

      // 5. Tap next chevron (>) to return to current month
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text(currentMonthText), findsOneWidget);

      // 6. Tap the center pill to open Period bottom sheet
      await tester.tap(find.text(currentMonthText));
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

      // 8. Tap previous (<) from Today: should display "Yesterday", NEVER duplicate range!
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Yesterday'), findsOneWidget);
      // Confirm no duplicate range format
      expect(find.textContaining('—'), findsNothing);

      // Tap previous (<) again: should display single date e.g. two days ago
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text(twoDaysAgoText), findsOneWidget);
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

      // 9. Switch to two months ago
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('This Month'));
      await tester.pumpAndSettle();

      // Tap (<) twice: Current Month -> Last Month -> Two Months Ago
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text(twoMonthsAgoText), findsOneWidget);

      // Open period sheet when on two months ago
      await tester.tap(find.text(twoMonthsAgoText));
      await tester.pumpAndSettle();

      // Verify "Specific Month ($twoMonthsAgoText)" is present and marked active, NOT Custom Range!
      expect(find.text('Specific Month ($twoMonthsAgoText)'), findsOneWidget);
    },
  );
}
