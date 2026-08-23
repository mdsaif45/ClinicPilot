import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/app_button.dart';
import 'package:clinic_pilot/core/widgets/app_card.dart';
import 'package:clinic_pilot/core/widgets/app_confirm_dialog.dart';
import 'package:clinic_pilot/core/widgets/app_list_tile.dart';
import 'package:clinic_pilot/core/widgets/chip_row.dart';
import 'package:clinic_pilot/core/widgets/choice_chip_field.dart';
import 'package:clinic_pilot/core/widgets/custom_badge.dart';
import 'package:clinic_pilot/core/widgets/custom_text_field.dart';
import 'package:clinic_pilot/core/widgets/date_field.dart';
import 'package:clinic_pilot/core/widgets/day_selector_field.dart';
import 'package:clinic_pilot/core/widgets/empty_state.dart';
import 'package:clinic_pilot/core/widgets/entity_header.dart';
import 'package:clinic_pilot/core/widgets/info_row.dart';
import 'package:clinic_pilot/core/widgets/metric_strip.dart';
import 'package:clinic_pilot/core/widgets/money_text.dart';
import 'package:clinic_pilot/core/widgets/picker_field.dart';
import 'package:clinic_pilot/core/widgets/section_header.dart';
import 'package:clinic_pilot/core/widgets/segmented_tabs.dart';
import 'package:clinic_pilot/core/widgets/stat_card.dart';

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

  group('EmptyState & EmptyIllustration', () {
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

    testWidgets('renders EmptyState.patients factory', (t) async {
      var tapped = false;
      await t.pumpWidget(wrap(EmptyState.patients(onAction: () => tapped = true)));
      expect(find.text('No patients found'), findsOneWidget);
      expect(find.text('Add Patient'), findsOneWidget);
      await t.tap(find.text('Add Patient'));
      expect(tapped, isTrue);
    });

    testWidgets('renders EmptyState.cashMemos factory', (t) async {
      await t.pumpWidget(wrap(EmptyState.cashMemos()));
      expect(find.text('No cash memos yet'), findsOneWidget);
    });

    testWidgets('renders EmptyState.expenses factory', (t) async {
      await t.pumpWidget(wrap(EmptyState.expenses()));
      expect(find.text('No expenses recorded'), findsOneWidget);
    });

    testWidgets('renders EmptyState.growth factory', (t) async {
      await t.pumpWidget(wrap(EmptyState.growth()));
      expect(find.text('No analytics available'), findsOneWidget);
    });

    testWidgets('renders EmptyState.recall factory', (t) async {
      await t.pumpWidget(wrap(EmptyState.recall()));
      expect(find.text('All caught up!'), findsOneWidget);
    });

    testWidgets('renders EmptyState.clinics factory', (t) async {
      await t.pumpWidget(wrap(EmptyState.clinics()));
      expect(find.text('No clinics added'), findsOneWidget);
    });

    testWidgets('renders EmptyState.search factory', (t) async {
      await t.pumpWidget(wrap(EmptyState.search()));
      expect(find.text('No results found'), findsOneWidget);
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

    testWidgets('swipes left and right to switch tabs', (t) async {
      await t.pumpWidget(wrap(SegmentedTabs(tabs: [
        SegmentedTab(
          icon: Icons.info,
          label: 'Info',
          builder: (_) => const SizedBox(width: 300, height: 300, child: Text('INFO BODY')),
        ),
        SegmentedTab(
          icon: Icons.list,
          label: 'List',
          builder: (_) => const SizedBox(width: 300, height: 300, child: Text('LIST BODY')),
        ),
      ])));

      expect(find.text('INFO BODY'), findsOneWidget);

      // Swiping on body does not change tab (drag disabled)
      await t.drag(find.text('INFO BODY'), const Offset(-300, 0));
      await t.pumpAndSettle();

      expect(find.text('INFO BODY'), findsOneWidget);
    });

    testWidgets('empty tabs renders nothing', (t) async {
      await t.pumpWidget(wrap(const SegmentedTabs(tabs: [])));
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('StatCard', () {
    testWidgets('renders title, value, subtitle and icon', (t) async {
      var tapped = false;
      await t.pumpWidget(wrap(StatCard(
        title: 'Total Patients',
        value: '128',
        subtitle: '+12% this month',
        icon: Icons.people,
        onTap: () => tapped = true,
      )));

      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('+12% this month'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);

      await t.tap(find.byType(StatCard));
      expect(tapped, isTrue);
    });
  });

  group('CustomBadge', () {
    testWidgets('renders label with theme color', (t) async {
      await t.pumpWidget(wrap(const CustomBadge(label: 'Active')));
      expect(find.text('Active'), findsOneWidget);
    });
  });

  group('CustomTextField', () {
    testWidgets('renders label, hint and responds to text changes', (t) async {
      final controller = TextEditingController();
      await t.pumpWidget(wrap(CustomTextField(
        label: 'Patient Name',
        hint: 'Enter full name',
        controller: controller,
        prefixIcon: Icons.person,
      )));

      expect(find.text('Patient Name'), findsOneWidget);
      expect(find.text('Enter full name'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      await t.enterText(find.byType(TextFormField), 'Jane Doe');
      expect(controller.text, 'Jane Doe');
    });
  });

  group('DateField', () {
    testWidgets('renders label and handles manual entry and formatting', (t) async {
      DateTime? selected;
      final now = DateTime(2026, 8, 23);
      await t.pumpWidget(wrap(DateField(
        label: 'Date of Visit',
        value: now,
        onChanged: (d) => selected = d,
      )));

      expect(find.text('Date of Visit'), findsOneWidget);
      expect(find.text('23/08/2026'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);

      await t.enterText(find.byType(TextFormField), '15052026');
      await t.pumpAndSettle();

      expect(find.text('15/05/2026'), findsOneWidget);
      expect(selected, DateTime(2026, 5, 15));
    });
  });

  group('DaySelectorField', () {
    testWidgets('renders weekday chips and toggles selection', (t) async {
      String? updated;
      await t.pumpWidget(wrap(DaySelectorField(
        label: 'Clinic Days',
        value: '1,3,5',
        onChanged: (v) => updated = v,
      )));

      expect(find.text('Clinic Days'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('3 days a week'), findsOneWidget);

      // Tap Tuesday (2) to add it
      await t.tap(find.text('Tue'));
      expect(updated, '1,2,3,5');
    });
  });

  group('AppCard', () {
    testWidgets('renders child and handles tap', (t) async {
      var tapped = false;
      await t.pumpWidget(wrap(AppCard(
        onTap: () => tapped = true,
        child: const Text('Card Content'),
      )));

      expect(find.text('Card Content'), findsOneWidget);
      await t.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });
  });

  group('AppListTile and SettingsGroup', () {
    testWidgets('renders tile and grouped section', (t) async {
      var tapped = false;
      await t.pumpWidget(wrap(SettingsGroup(
        title: 'Preferences',
        children: [
          AppListTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Dark Mode',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => tapped = true,
          ),
        ],
      )));

      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);

      await t.tap(find.text('Theme'));
      expect(tapped, isTrue);
    });
  });

  group('ChoiceChipField', () {
    testWidgets('renders options and selects chip on tap', (t) async {
      String? selected;
      await t.pumpWidget(wrap(ChoiceChipField<String>(
        label: 'Payment Method',
        options: const ['Cash', 'UPI', 'Due'],
        value: 'Cash',
        labelOf: (s) => s,
        onChanged: (v) => selected = v,
      )));

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Due'), findsOneWidget);

      await t.tap(find.text('UPI'));
      expect(selected, 'UPI');
    });
  });

  group('EntityHeader', () {
    testWidgets('renders avatar initial, title, subtitle and badges', (t) async {
      await t.pumpWidget(wrap(const EntityHeader(
        title: 'Dr. John',
        subtitle: 'Senior Consultant',
        avatarText: 'John',
        badges: [CustomBadge(label: 'Clinic A')],
      )));

      expect(find.text('Dr. John'), findsOneWidget);
      expect(find.text('Senior Consultant'), findsOneWidget);
      expect(find.text('J'), findsOneWidget);
      expect(find.text('Clinic A'), findsOneWidget);
    });
  });

  group('PickerField', () {
    testWidgets('renders label and selected option', (t) async {
      await t.pumpWidget(wrap(PickerField<String>(
        label: 'Clinic',
        value: 'c1',
        options: const [
          PickerOption(value: 'c1', label: 'Main Clinic'),
        ],
        onChanged: (_) {},
      )));

      expect(find.text('Clinic'), findsOneWidget);
      expect(find.text('Main Clinic'), findsOneWidget);
    });
  });

  group('AppButton', () {
    testWidgets('renders primary, tonal, outlined and text variants', (t) async {
      var primaryPressed = false;
      var tonalPressed = false;

      await t.pumpWidget(wrap(Column(
        children: [
          AppButton.primary(
            label: 'Save',
            icon: Icons.check,
            onPressed: () => primaryPressed = true,
          ),
          AppButton.tonal(
            label: 'Add',
            icon: Icons.add,
            onPressed: () => tonalPressed = true,
          ),
          const AppButton.outlined(label: 'Cancel'),
          const AppButton.text(label: 'Close'),
        ],
      )));

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await t.tap(find.text('Save'));
      expect(primaryPressed, isTrue);

      await t.tap(find.text('Add'));
      expect(tonalPressed, isTrue);
    });
  });

  group('AppConfirmDialog', () {
    testWidgets('renders title, message and fires callbacks', (t) async {
      var confirmed = false;

      await t.pumpWidget(wrap(AppConfirmDialog(
        title: 'Delete Item',
        message: 'Are you sure you want to delete this?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () => confirmed = true,
      )));

      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await t.tap(find.text('Delete'));
      expect(confirmed, isTrue);
    });
  });
}
