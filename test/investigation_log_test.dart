import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinical/models/investigation_templates.dart';
import 'package:clinic_pilot/features/clinical/presentation/widgets/investigation_list_view.dart';
import 'package:clinic_pilot/features/clinical/providers/investigation_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Investigation Auto-Flagging & Unit Tests', () {
    test('computes High, Low, Normal auto-flags correctly', () {
      expect(computeLabFlag(145.0, 70.0, 100.0), equals('High'));
      expect(computeLabFlag(55.0, 70.0, 100.0), equals('Low'));
      expect(computeLabFlag(85.0, 70.0, 100.0), equals('Normal'));
      expect(computeLabFlag(null, 70.0, 100.0), equals('Normal'));
    });

    test('adds, updates and soft-deletes investigation reports', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // Create a test patient
      await db
          .into(db.patients)
          .insert(
            PatientsCompanion.insert(
              id: 'p_lab_1',
              name: 'John Doe',
              phone: '9999999999',
              age: 42,
              gender: 'Male',
              serialNo: const drift.Value('001'),
            ),
          );

      final notifier = container.read(investigationNotifierProvider.notifier);

      final invId = await notifier.addInvestigation(
        patientId: 'p_lab_1',
        testCategory: 'Diabetes / Glycemia',
        testName: 'Fasting Blood Sugar (FBS)',
        numericValue: 165.0,
        unit: 'mg/dL',
        refRangeMin: 70.0,
        refRangeMax: 100.0,
        labName: 'Lal PathLabs',
        notes: 'High FBS, monitor closely',
      );

      final list = await db.select(db.investigations).get();
      expect(list.length, equals(1));
      expect(list.first.testName, equals('Fasting Blood Sugar (FBS)'));
      expect(list.first.numericValue, equals(165.0));
      expect(list.first.flag, equals('High'));

      // Update investigation to normal value
      await notifier.updateInvestigation(
        id: invId,
        testCategory: 'Diabetes / Glycemia',
        testName: 'Fasting Blood Sugar (FBS)',
        numericValue: 92.0,
        unit: 'mg/dL',
        refRangeMin: 70.0,
        refRangeMax: 100.0,
        labName: 'Lal PathLabs',
        notes: 'Normalized after remedy',
      );

      final updated =
          await (db.select(db.investigations)
            ..where((t) => t.id.equals(invId))).getSingle();
      expect(updated.numericValue, equals(92.0));
      expect(updated.flag, equals('Normal'));

      // Soft delete
      await notifier.deleteInvestigation(invId);
      final activeList =
          await (db.select(db.investigations)
            ..where((t) => t.isDeleted.equals(false))).get();
      expect(activeList, isEmpty);
    });
  });

  group('InvestigationListView & AddEditInvestigationDialog Widget Tests', () {
    testWidgets('renders empty state and opens record lab test dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final patient = Patient(
        id: 'p_widget_lab_1',
        patientCode: 'P-2026-00004',
        name: 'Jane Smith',
        phone: '8888888888',
        age: 32,
        gender: 'Female',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '004',
        referralSource: 'Walk-in',
        reviewGiven: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientInvestigationsProvider(
              patient.id,
            ).overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(body: InvestigationListView(patient: patient)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No lab tests recorded'), findsOneWidget);
      expect(find.text('Record Lab Test'), findsOneWidget);

      await tester.tap(find.text('Record Lab Test'));
      await tester.pumpAndSettle();

      expect(find.text('Add Investigation / Lab Test'), findsOneWidget);
      expect(find.text('Test Parameter Name *'), findsOneWidget);
      expect(find.text('Measured Value *'), findsOneWidget);
      expect(find.text('NORMAL'), findsOneWidget);
    });
  });
}
