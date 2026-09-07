import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/new_cash_memo_dialog.dart';
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

  group('DispensedMedicineItem & Dispense Flow Unit Tests', () {
    test('DispensedMedicineItem calculates total correctly', () async {
      await seedClinicAndPatient();
      final medId = await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 150.0,
      );

      final med =
          await (db.select(db.medicines)
            ..where((tbl) => tbl.id.equals(medId))).getSingle();

      final item = DispensedMedicineItem(
        medicine: med,
        quantity: 2.0,
        unitPrice: 150.0,
      );

      expect(item.totalPrice, equals(300.0));
      item.quantity = 3.5;
      expect(item.totalPrice, equals(525.0));
    });
  });

  group('DispenseMedicinePickerSheet Widget Tests', () {
    testWidgets('searches remedies, selects item, and updates quantities', (
      tester,
    ) async {
      await seedClinicAndPatient();
      final med1Id = await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 120.0,
      );

      await inventoryController.addMedicine(
        name: 'Bryonia Alba',
        category: 'Dilution',
        potency: '30C',
        currentStock: 2.0,
        unit: 'Bottles',
        sellingPrice: 90.0,
      );

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      List<DispensedMedicineItem>? returnedItems;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Builder(
                builder:
                    (ctx) => ElevatedButton(
                      onPressed: () async {
                        returnedItems = await DispenseMedicinePickerSheet.show(
                          ctx,
                        );
                      },
                      child: const Text('Open Picker'),
                    ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Dispense from Inventory'), findsOneWidget);
      expect(find.text('Arnica Montana'), findsOneWidget);
      expect(find.text('Bryonia Alba'), findsOneWidget);
      expect(find.text('Low Stock'), findsOneWidget); // Bryonia is 2 <= 3

      // Test Search filtering
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Bryonia');
      await tester.pumpAndSettle();

      expect(find.text('Bryonia Alba'), findsOneWidget);
      expect(find.text('Arnica Montana'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(find.text('Arnica Montana'), findsOneWidget);

      // Select Arnica
      await tester.tap(find.text('Arnica Montana'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('₹120 total'), findsOneWidget);

      // Increase quantity of Arnica to 2
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('₹240 total'), findsOneWidget);

      // Confirm selection
      await tester.tap(find.text('Confirm Dispensed'));
      await tester.pumpAndSettle();

      expect(returnedItems, isNotNull);
      expect(returnedItems!.length, equals(1));
      expect(returnedItems!.first.medicine.id, equals(med1Id));
      expect(returnedItems!.first.quantity, equals(2.0));
      expect(returnedItems!.first.totalPrice, equals(240.0));
    });
  });

  group('NewCashMemoDialog Direct Dispense Integration Tests', () {
    testWidgets(
      'dispensing remedies populates medicine fee and decrements inventory on save',
      (tester) async {
        await seedClinicAndPatient();

        final med1Id = await inventoryController.addMedicine(
          name: 'Rhus Tox',
          category: 'Dilution',
          potency: '200C',
          currentStock: 12.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
        );

        final med2Id = await inventoryController.addMedicine(
          name: 'Calendula Q',
          category: 'Mother Tincture',
          currentStock: 5.0,
          unit: 'Bottles',
          sellingPrice: 200.0,
        );

        final patient =
            await (db.select(db.patients)
              ..where((tbl) => tbl.id.equals('pat-1'))).getSingle();

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(body: NewCashMemoDialog(initialPatient: patient)),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify dispense button is present
        expect(find.text('Dispense from Inventory'), findsOneWidget);

        // Open dispense picker
        await tester.tap(find.text('Dispense from Inventory'));
        await tester.pumpAndSettle();

        // Select Rhus Tox
        await tester.tap(find.text('Rhus Tox'));
        await tester.pumpAndSettle();

        // Select Calendula Q
        await tester.tap(find.text('Calendula Q'));
        await tester.pumpAndSettle();

        // Confirm dispensed (1 Rhus Tox @ 150 + 1 Calendula @ 200 = 350)
        await tester.tap(find.text('Confirm Dispensed'));
        await tester.pumpAndSettle();

        // Check that medicine fee is auto-populated with 350
        // Total payable = 300 (consult) + 350 (medicine) = 650
        expect(find.text('2 remedies selected'), findsOneWidget);
        expect(find.textContaining('650'), findsWidgets);

        // Verify chips are shown
        expect(find.textContaining('Rhus Tox 200C × 1 (₹150)'), findsOneWidget);
        expect(find.textContaining('Calendula Q × 1 (₹200)'), findsOneWidget);

        // Save Cash Memo
        await tester.tap(find.text('Save & Issue Memo'));
        await tester.pumpAndSettle();

        // Verify Cash Memo in database
        final memos = await db.select(db.cashMemos).get();
        expect(memos.length, equals(1));
        final memo = memos.first;
        expect(memo.medicineFee, equals(350.0));
        expect(memo.total, equals(650.0));
        expect(memo.notes, contains('Dispensed:'));
        expect(memo.notes, contains('Rhus Tox 200C (1 Bottles)'));
        expect(memo.notes, contains('Calendula Q (1 Bottles)'));

        // Verify inventory stock was automatically decremented
        final updatedMed1 =
            await (db.select(db.medicines)
              ..where((tbl) => tbl.id.equals(med1Id))).getSingle();
        final updatedMed2 =
            await (db.select(db.medicines)
              ..where((tbl) => tbl.id.equals(med2Id))).getSingle();

        expect(updatedMed1.currentStock, equals(11.0)); // 12 - 1
        expect(updatedMed2.currentStock, equals(4.0)); // 5 - 1
      },
    );

    testWidgets('removing dispensed chip recalculates medicine fee', (
      tester,
    ) async {
      await seedClinicAndPatient();

      await inventoryController.addMedicine(
        name: 'Aconite Nap',
        category: 'Dilution',
        potency: '30C',
        currentStock: 8.0,
        unit: 'Bottles',
        sellingPrice: 100.0,
      );

      final patient =
          await (db.select(db.patients)
            ..where((tbl) => tbl.id.equals('pat-1'))).getSingle();

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(body: NewCashMemoDialog(initialPatient: patient)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open picker and select Aconite
      await tester.tap(find.text('Dispense from Inventory'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aconite Nap'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm Dispensed'));
      await tester.pumpAndSettle();

      expect(find.textContaining('100'), findsWidgets);

      // Now click "Clear"
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsNothing);
      expect(find.text('Dispense from Inventory'), findsOneWidget);
    });
  });
}
