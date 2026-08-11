import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/chip_row.dart';
import 'package:clinic_pilot/core/widgets/empty_state.dart';
import 'package:clinic_pilot/core/widgets/info_row.dart';
import 'package:clinic_pilot/core/widgets/metric_strip.dart';
import 'package:clinic_pilot/core/widgets/money_text.dart';
import 'package:clinic_pilot/core/widgets/section_header.dart';
import 'package:clinic_pilot/core/widgets/segmented_tabs.dart';

Widget wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: brightness == Brightness.light
        ? AppTheme.lightTheme
        : AppTheme.darkTheme,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('InfoRow', () {
    testWidgets('renders label and value', (t) async {
      await t.pumpWidget(wrap(const InfoRow(label: 'Phone', value: '98000')));
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('98000'), findsOneWidget);
    });

    testWidgets('renders nothing when value is null or blank', (t) async {
      await t.pumpWidget(wrap(const InfoRow(label: 'Area', value: null)));
      expect(find.text('Area'), findsNothing);

      await t.pumpWidget(wrap(const InfoRow(label: 'Area', value: '   ')));
      expect(find.text('Area'), findsNothing);
    });
  });

  group('MetricStrip', () {
    testWidgets('renders every metric', (t) async {
      await t.pumpWidget(wrap(const MetricStrip(metrics: [
        Metric(label: 'Visits', value: '4'),
        Metric(label: 'Lifetime', value: 'Rs 1,200'),
      ])));
      expect(find.text('Visits'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Lifetime'), findsOneWidget);
    });

    testWidgets('empty list renders nothing', (t) async {
      await t.pumpWidget(wrap(const MetricStrip(metrics: [])));
      expect(find.byType(VerticalDivider), findsNothing);
    });
  });

  group('ChipRow', () {
    testWidgets('skips blank labels', (t) async {
      await t.pumpWidget(wrap(const ChipRow(labels: ['Thyroid', '', '  '])));
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('Thyroid'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('shows title, message and action', (t) async {
      var tapped = false;
      await t.pumpWidget(wrap(EmptyState(
        icon: Icons.info,
        title: 'Nothing here',
        message: 'Add something',
        actionLabel: 'Add',
        onAction: () => tapped = true,
      )));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Add something'), findsOneWidget);
      await t.tap(find.text('Add'));
      expect(tapped, isTrue);
    });
  });

  group('SectionHeader', () {
    testWidgets('action only rendered when provided', (t) async {
      await t.pumpWidget(wrap(const SectionHeader(title: 'Recent')));
      expect(find.byType(IconButton), findsNothing);

      await t.pumpWidget(wrap(SectionHeader(title: 'Recent', onAction: () {})));
      expect(find.byType(IconButton), findsOneWidget);
    });
  });

  group('MoneyText', () {
    testWidgets('renders in dark theme without error', (t) async {
      await t.pumpWidget(wrap(
        const MoneyText(amount: -250, colorBySign: true),
        brightness: Brightness.dark,
      ));
      expect(find.byType(MoneyText), findsOneWidget);
    });
  });

  group('SegmentedTabs', () {
    testWidgets('swaps body when a tab is tapped', (t) async {
      await t.pumpWidget(wrap(SegmentedTabs(tabs: [
        SegmentedTab(
          icon: Icons.info,
          label: 'Info',
          builder: (_) => const Text('INFO BODY'),
        ),
        SegmentedTab(
          icon: Icons.list,
          label: 'List',
          builder: (_) => const Text('LIST BODY'),
        ),
      ])));

      expect(find.text('INFO BODY'), findsOneWidget);

      await t.tap(find.byIcon(Icons.list));
      await t.pumpAndSettle();

      expect(find.text('LIST BODY'), findsOneWidget);
    });

    testWidgets('empty tabs renders nothing', (t) async {
      await t.pumpWidget(wrap(const SegmentedTabs(tabs: [])));
      expect(find.byType(Icon), findsNothing);
    });
  });
}
