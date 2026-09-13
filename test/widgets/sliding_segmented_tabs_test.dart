import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/sliding_segmented_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlidingSegmentedTabs Widget Tests', () {
    testWidgets(
      'renders 2 tabs with icons and triggers onChanged when tapping',
      (tester) async {
        int selectedTab = 0;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SlidingSegmentedTabs<int>(
                    selectedValue: selectedTab,
                    onChanged: (val) {
                      setState(() => selectedTab = val);
                    },
                    items: const [
                      SlidingTabItem(
                        value: 0,
                        icon: Icons.assignment_outlined,
                        label: 'Master Baseline Record',
                      ),
                      SlidingTabItem(
                        value: 1,
                        icon: Icons.timeline_outlined,
                        label: 'Follow-Up Visits History',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify both tabs are visible
        expect(find.text('Master Baseline Record'), findsOneWidget);
        expect(find.text('Follow-Up Visits History'), findsOneWidget);
        expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
        expect(find.byIcon(Icons.timeline_outlined), findsOneWidget);

        // Verify AnimatedAlign initial position for 2 items is left (-1.0)
        final alignFinder = find.byType(AnimatedAlign);
        expect(alignFinder, findsOneWidget);
        AnimatedAlign alignWidget = tester.widget(alignFinder);
        expect(alignWidget.alignment, const Alignment(-1.0, 0.0));

        // Tap second tab
        await tester.tap(find.text('Follow-Up Visits History'));
        await tester.pump(); // Start animation
        await tester.pumpAndSettle(); // Complete animation

        expect(selectedTab, 1);

        // Verify AnimatedAlign moved to right (1.0)
        alignWidget = tester.widget(alignFinder);
        expect(alignWidget.alignment, const Alignment(1.0, 0.0));
      },
    );

    testWidgets('renders 3 tabs and calculates 3-way alignment correctly', (
      tester,
    ) async {
      String selectedRange = 'week';
      int changeCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SlidingSegmentedTabs<String>(
                  selectedValue: selectedRange,
                  onChanged: (val) {
                    changeCount++;
                    setState(() => selectedRange = val);
                  },
                  items: const [
                    SlidingTabItem(value: 'day', label: 'Day'),
                    SlidingTabItem(value: 'week', label: 'Week'),
                    SlidingTabItem(value: 'month', label: 'Month'),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final alignFinder = find.byType(AnimatedAlign);
      expect(alignFinder, findsOneWidget);

      // 'week' is index 1 of 3 -> alignment should be (0.0, 0.0)
      AnimatedAlign alignWidget = tester.widget(alignFinder);
      expect(alignWidget.alignment, const Alignment(0.0, 0.0));

      // Tap 'day'
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();

      expect(selectedRange, 'day');
      expect(changeCount, 1);
      alignWidget = tester.widget(alignFinder);
      expect(alignWidget.alignment, const Alignment(-1.0, 0.0));

      // Tap 'month'
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      expect(selectedRange, 'month');
      expect(changeCount, 2);
      alignWidget = tester.widget(alignFinder);
      expect(alignWidget.alignment, const Alignment(1.0, 0.0));

      // Tap 'month' again (already selected) -> should not trigger onChanged
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();
      expect(changeCount, 2);
    });
  });
}
