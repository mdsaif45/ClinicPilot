import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinical/presentation/widgets/prescription_list_view.dart';
import 'package:clinic_pilot/features/clinical/providers/prescription_provider.dart';
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

  group('Prescription Notifier & Database Unit Tests', () {
    test('adds, updates and deletes a prescription remedy record', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // Create a test patient
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p_rx_1',
              name: 'Jane Doe',
              phone: '9999999999',
              age: 38,
              gender: 'Female',
              serialNo: const drift.Value('001'),
            ),
          );

      final notifier = container.read(prescriptionNotifierProvider.notifier);

      final rxId = await notifier.addPrescription(
        patientId: 'p_rx_1',
        remedyIndex: 1,
        remedyName: 'Thuja Occidentalis',
        potency: '200CH',
        doseCount: '4 pills',
        frequency: 'OD (Once daily)',
        vehicle: 'Globules / Pellets',
        durationDays: '7 days',
        instructions: 'Morning empty stomach',
        dietaryAdvice: 'Avoid raw onion, garlic, camphor',
      );

      final list = await db.select(db.prescriptions).get();
      expect(list.length, equals(1));
      expect(list.first.remedyName, equals('Thuja Occidentalis'));
      expect(list.first.potency, equals('200CH'));
      expect(list.first.instructions, equals('Morning empty stomach'));

      // Update remedy
      await notifier.updatePrescription(
        id: rxId,
        remedyIndex: 1,
        remedyName: 'Thuja Occidentalis',
        potency: '1M',
        doseCount: '4 pills',
        frequency: 'Stat (Single dose)',
        vehicle: 'Globules / Pellets',
        durationDays: '1 day',
        instructions: 'Single dose in morning',
        dietaryAdvice: 'Avoid raw onion, garlic',
      );

      final updated = await (db.select(db.prescriptions)..where((t) => t.id.equals(rxId))).getSingle();
      expect(updated.potency, equals('1M'));
      expect(updated.frequency, equals('Stat (Single dose)'));

      // Soft delete
      await notifier.deletePrescription(rxId);
      final activeList = await (db.select(db.prescriptions)..where((t) => t.isDeleted.equals(false))).get();
      expect(activeList, isEmpty);
    });
  });

  group('PrescriptionListView & AddEditPrescriptionDialog Widget Tests', () {
    testWidgets('renders empty state and opens prescribe remedy dialog', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final patient = Patient(
        id: 'p_widget_rx_1',
        patientCode: 'P-2026-00003',
        name: 'Jane Smith',
        phone: '8888888888',
        age: 32,
        gender: 'Female',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '003',
        referralSource: 'Walk-in',
        reviewGiven: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientPrescriptionsProvider(patient.id).overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: PrescriptionListView(patient: patient),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No prescriptions logged'), findsOneWidget);
      expect(find.text('Prescribe Remedy'), findsOneWidget);

      await tester.tap(find.text('Prescribe Remedy'));
      await tester.pumpAndSettle();

      expect(find.text('Prescribe Homeopathic Remedy'), findsOneWidget);
      expect(find.text('Remedy (Latin Binomial) *'), findsOneWidget);
      expect(find.text('Potency'), findsOneWidget);
      expect(find.text('Dose'), findsOneWidget);
    });
  });
}