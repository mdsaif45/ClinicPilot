import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/widgets/dispense_medicine_picker_sheet.dart';
import 'package:clinic_pilot/features/inventory/providers/inventory_provider.dart';

void main() {
  late AppDatabase db;
  late InventoryController inventoryController;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    inventoryController = InventoryController(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedClinicAndPatient({
    String clinicId = 'clinic-1',
    String patientId = 'pat-1',
  }) async {
    await db
        .into(db.clinics)
        .insert(
          ClinicsCompanion.insert(
            id: clinicId,
            name: 'Homeo Care Clinic',
            defaultConsultationFee: const Value(300.0),
          ),
        );

    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: patientId,
            name: 'Rahul Sharma',
            phone: '9876543210',
            gender: 'Male',
            age: 34,
            primaryClinicId: Value(clinicId),
          ),
        );
  }

  Future<void> pumpPicker(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder:
                  (ctx) => ElevatedButton(
                    onPressed: () => DispenseMedicinePickerSheet.show(ctx),
                    child: const Text('Open Picker'),
                  ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();
  }

  group('Batch expiry amber alerts in DispenseMedicinePickerSheet', () {
    testWidgets(
      'shows an amber expiry chip for a batch expiring within 30 days',
      (tester) async {
        await seedClinicAndPatient();
        final soonDate = DateTime.now().add(const Duration(days: 10));
        await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 10.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
          expiryDate: soonDate,
        );

        await pumpPicker(tester);

        final expectedLabel = 'Expires ${DateFormat('d MMM').format(soonDate)}';
        expect(find.text(expectedLabel), findsOneWidget);
      },
    );

    testWidgets('does not flag a batch expiring well beyond 30 days', (
      tester,
    ) async {
      await seedClinicAndPatient();
      await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 150.0,
        expiryDate: DateTime.now().add(const Duration(days: 200)),
      );

      await pumpPicker(tester);

      expect(find.textContaining('Expires '), findsNothing);
    });

    testWidgets('does not flag a batch with no expiry date set', (
      tester,
    ) async {
      await seedClinicAndPatient();
      await inventoryController.addMedicine(
        name: 'Calendula Q',
        category: 'Mother Tincture',
        currentStock: 5.0,
        unit: 'Bottles',
        sellingPrice: 200.0,
      );

      await pumpPicker(tester);

      expect(find.textContaining('Expires '), findsNothing);
    });

    testWidgets('an already-expired batch is not shown as "expiring soon"', (
      tester,
    ) async {
      await seedClinicAndPatient();
      await inventoryController.addMedicine(
        name: 'Rhus Tox',
        category: 'Dilution',
        potency: '200C',
        currentStock: 4.0,
        unit: 'Bottles',
        sellingPrice: 120.0,
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      await pumpPicker(tester);

      // The picker's job is dispensing, not lifecycle management, so an
      // already-expired batch is left to the inventory screen rather than
      // relabeled here as "expiring soon".
      expect(find.textContaining('Expires '), findsNothing);
    });

    testWidgets('low stock and expiring soon badges can appear together', (
      tester,
    ) async {
      await seedClinicAndPatient();
      final soonDate = DateTime.now().add(const Duration(days: 5));
      await inventoryController.addMedicine(
        name: 'Bryonia Alba',
        category: 'Dilution',
        potency: '30C',
        currentStock: 2.0,
        unit: 'Bottles',
        sellingPrice: 90.0,
        expiryDate: soonDate,
      );

      await pumpPicker(tester);

      expect(find.text('Low Stock'), findsOneWidget);
      expect(
        find.text('Expires ${DateFormat('d MMM').format(soonDate)}'),
        findsOneWidget,
      );
    });

    testWidgets('a batch exactly on the 30-day boundary is not yet flagged', (
      tester,
    ) async {
      await seedClinicAndPatient();
      await inventoryController.addMedicine(
        name: 'Nux Vomica',
        category: 'Dilution',
        potency: '30C',
        currentStock: 5.0,
        unit: 'Bottles',
        sellingPrice: 90.0,
        expiryDate: DateTime.now().add(const Duration(days: 30, hours: 1)),
      );

      await pumpPicker(tester);

      expect(find.textContaining('Expires '), findsNothing);
    });
  });
}
