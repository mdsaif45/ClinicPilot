import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/features/onboarding/presentation/onboarding_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('the name field is focused as soon as onboarding opens', (
    tester,
  ) async {
    await pump(tester);
    // The post-frame callback that requests focus needs one more frame.
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('submitting an empty name does not advance the page', (
    tester,
  ) async {
    await pump(tester);
    await tester.pump();

    // Matches what tapping a disabled Continue button would do: nothing.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Where do you practice?'), findsNothing);
    expect(find.text('Welcome to ClinicPilot'), findsOneWidget);
  });

  testWidgets('submitting the name field advances to the clinics page', (
    tester,
  ) async {
    await pump(tester);
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Dr. Sarah');
    await tester.enterText(find.byType(TextField).at(1), 'Rao');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Where do you practice?'), findsOneWidget);
  });

  testWidgets('arriving on the clinics page focuses the first clinic field', (
    tester,
  ) async {
    await pump(tester);
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Dr. Sarah');
    await tester.enterText(find.byType(TextField).at(1), 'Rao');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    // The focus request on arrival is itself scheduled a frame later.
    await tester.pump();

    final clinicField = tester.widget<TextField>(
      find.widgetWithText(TextField, '').first,
    );
    expect(find.text('Where do you practice?'), findsOneWidget);
    expect(clinicField.focusNode!.hasFocus, isTrue);
  });

  testWidgets(
    'going Back to the name page and forward again does not steal focus '
    'from the clinics page a second time',
    (tester) async {
      await pump(tester);
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'Dr. Sarah');
      await tester.enterText(find.byType(TextField).at(1), 'Rao');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.pump();

      // Move focus somewhere else on the clinics page, simulating the doctor
      // already having tapped ahead to a later field.
      final areaFields = find.widgetWithText(TextField, '');
      await tester.tap(areaFields.last);
      await tester.pump();

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.pump();

      // The first clinic field must not have reclaimed focus this time.
      final clinicField = tester.widget<TextField>(
        find.widgetWithText(TextField, '').first,
      );
      expect(clinicField.focusNode!.hasFocus, isFalse);
    },
  );
}
