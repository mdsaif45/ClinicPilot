import 'package:clinic_pilot/core/design/breakpoints.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/app_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Responsive Breakpoints & Context Helpers', () {
    testWidgets('identifies 5-inch compact phone correctly (< 600dp)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isCompact;
      late bool isTablet;
      late bool isExpanded;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isCompact = context.isCompact;
              isTablet = context.isTablet;
              isExpanded = context.isExpanded;
              return const Scaffold(body: Text('5in Phone'));
            },
          ),
        ),
      );

      expect(isCompact, isTrue);
      expect(isTablet, isFalse);
      expect(isExpanded, isFalse);
    });

    testWidgets('identifies 6.5-inch standard phone correctly (< 600dp)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isCompact;
      late bool isTablet;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isCompact = context.isCompact;
              isTablet = context.isTablet;
              return const Scaffold(body: Text('6.5in Phone'));
            },
          ),
        ),
      );

      expect(isCompact, isTrue);
      expect(isTablet, isFalse);
    });

    testWidgets('identifies 10-inch tablet correctly (>= 840dp)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isCompact;
      late bool isTablet;
      late bool isExpanded;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isCompact = context.isCompact;
              isTablet = context.isTablet;
              isExpanded = context.isExpanded;
              return const Scaffold(body: Text('10in Tablet'));
            },
          ),
        ),
      );

      expect(isCompact, isFalse);
      expect(isTablet, isTrue);
      expect(isExpanded, isTrue);
    });
  });

  group('ResponsiveContent', () {
    testWidgets('clamps width on wide screens to maxContentWidth', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContent(
              child: SizedBox(
                key: Key('content-box'),
                width: double.infinity,
                height: 100,
              ),
            ),
          ),
        ),
      );

      final boxFinder = find.byKey(const Key('content-box'));
      final renderBox = tester.renderObject<RenderBox>(boxFinder);
      expect(renderBox.size.width, equals(Breakpoints.maxContentWidth));
    });
  });

  group('AppFormDialog Responsive Sizing', () {
    testWidgets('renders cleanly on 5-inch phone without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder:
                            (_) => AppFormDialog(
                              title: 'Patient Details',
                              actions: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () {},
                                  child: const Text('Save'),
                                ),
                              ],
                              child: Column(
                                children: List.generate(
                                  8,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Field $i',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ),
                  child: const Text('Open Dialog'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Patient Details'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders cleanly on 10-inch tablet without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder:
                            (_) => AppFormDialog(
                              title: 'New Visit',
                              actions: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () {},
                                  child: const Text('Save'),
                                ),
                              ],
                              child: const Text('Visit Form Content'),
                            ),
                      ),
                  child: const Text('Open Dialog'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('New Visit'), findsOneWidget);
      expect(find.text('Visit Form Content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
