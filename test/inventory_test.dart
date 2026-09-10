import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/inventory/presentation/inventory_screen.dart';
import 'package:clinic_pilot/features/inventory/presentation/widgets/add_edit_medicine_dialog.dart';
import 'package:clinic_pilot/features/inventory/providers/inventory_provider.dart';

void main() {
  late AppDatabase db;
  late InventoryController controller;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    controller = InventoryController(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Inventory Database & Controller CRUD Tests', () {
    test('addMedicine stores record correctly in sqlite', () async {
      final id = await controller.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        form: 'Liquid Dilution',
        currentStock: 15.0,
        unit: 'Bottles (30ml)',
        reorderLevel: 5.0,
        costPrice: 120.0,
        sellingPrice: 180.0,
        batchNumber: 'BATCH-2026-A1',
        notes: 'Shelf 3B',
      );

      final med =
          await (db.select(db.medicines)
            ..where((tbl) => tbl.id.equals(id))).getSingle();

      expect(med.name, equals('Arnica Montana'));
      expect(med.category, equals('Dilution'));
      expect(med.potency, equals('200C'));
      expect(med.form, equals('Liquid Dilution'));
      expect(med.currentStock, equals(15.0));
      expect(med.unit, equals('Bottles (30ml)'));
      expect(med.reorderLevel, equals(5.0));
      expect(med.costPrice, equals(120.0));
      expect(med.sellingPrice, equals(180.0));
      expect(med.batchNumber, equals('BATCH-2026-A1'));
      expect(med.notes, equals('Shelf 3B'));
      expect(med.isDeleted, isFalse);
    });

    test('updateMedicine modifies fields accurately', () async {
      final id = await controller.addMedicine(
        name: 'Nux Vomica',
        category: 'Dilution',
        potency: '30C',
        currentStock: 8.0,
        unit: 'Bottles (30ml)',
      );

      final item =
          await (db.select(db.medicines)
            ..where((tbl) => tbl.id.equals(id))).getSingle();

      final updated = item.copyWith(
        potency: const Value('200C'),
        currentStock: 12.0,
        sellingPrice: const Value(150.0),
      );

      await controller.updateMedicine(updated);

      final retrieved =
          await (db.select(db.medicines)
            ..where((tbl) => tbl.id.equals(id))).getSingle();

      expect(retrieved.potency, equals('200C'));
      expect(retrieved.currentStock, equals(12.0));
      expect(retrieved.sellingPrice, equals(150.0));
    });

    test('adjustStock handles restock, dispense, and clamp to 0', () async {
      final id = await controller.addMedicine(
        name: 'Belladonna',
        category: 'Dilution',
        currentStock: 5.0,
        unit: 'Bottles (30ml)',
      );

      // +3 Restock
      final stockAfterRestock = await controller.adjustStock(id, 3.0);
      expect(stockAfterRestock, equals(8.0));

      // -2 Dispense
      final stockAfterDispense = await controller.adjustStock(id, -2.0);
      expect(stockAfterDispense, equals(6.0));

      // Dispense more than available clamps to 0
      final stockClamped = await controller.adjustStock(id, -10.0);
      expect(stockClamped, equals(0.0));

      // Attempt adjust non-existing throws ArgumentError
      expect(
        () => controller.adjustStock('non-existent-id', 1.0),
        throwsArgumentError,
      );
    });

    test('deleteMedicine soft deletes record', () async {
      final id = await controller.addMedicine(
        name: 'Aconitum Napellus',
        category: 'Dilution',
        currentStock: 10.0,
        unit: 'Bottles (30ml)',
      );

      await controller.deleteMedicine(id);

      final item =
          await (db.select(db.medicines)
            ..where((tbl) => tbl.id.equals(id))).getSingle();

      expect(item.isDeleted, isTrue);
    });

    test('clearAllPracticeData cleans up medicines table', () async {
      await controller.addMedicine(
        name: 'Bryonia Alba',
        category: 'Dilution',
        currentStock: 4.0,
        unit: 'Bottles (30ml)',
      );

      await db.clearAllPracticeData();

      final allMedicines = await db.select(db.medicines).get();
      expect(allMedicines, isEmpty);
    });
  });

  group('InventoryValuation & Metrics Tests', () {
    test(
      'computes correct valuation, low-stock, and expiring alerts',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        // 1. Initially empty
        var val = container.read(inventoryValuationProvider);
        expect(val.totalItems, equals(0));
        expect(val.totalUnits, equals(0.0));
        expect(val.totalCostValue, equals(0.0));
        expect(val.totalSellingValue, equals(0.0));
        expect(val.lowStockCount, equals(0));
        expect(val.outOfStockCount, equals(0));
        expect(val.expiringCount, equals(0));

        // 2. Add sample medicines
        await controller.addMedicine(
          name: 'Arnica 200C',
          category: 'Dilution',
          currentStock: 10.0,
          reorderLevel: 3.0,
          costPrice: 100.0,
          sellingPrice: 150.0,
          unit: 'Bottles',
        );

        await controller.addMedicine(
          name: 'Rhus Tox 30C',
          category: 'Dilution',
          currentStock: 2.0,
          reorderLevel: 5.0,
          costPrice: 80.0,
          sellingPrice: 120.0,
          unit: 'Bottles',
        );

        await controller.addMedicine(
          name: 'Thuja 1M',
          category: 'Dilution',
          currentStock: 0.0,
          reorderLevel: 3.0,
          costPrice: 150.0,
          sellingPrice: 200.0,
          unit: 'Bottles',
        );

        await controller.addMedicine(
          name: 'Echinacea Q',
          category: 'Mother Tincture',
          currentStock: 4.0,
          reorderLevel: 2.0,
          costPrice: 200.0,
          sellingPrice: 300.0,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
          unit: 'Bottles',
        );

        List<Medicine> items = [];
        final sub = container.listen(inventoryStreamProvider, (_, next) {
          if (next.hasValue) items = next.value!;
        });
        for (int i = 0; i < 50 && items.length < 4; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        sub.close();

        val = container.read(inventoryValuationProvider);
        expect(val.totalItems, equals(4));
        expect(val.totalUnits, equals(16.0));
        expect(val.totalCostValue, equals(1960.0));
        expect(val.totalSellingValue, equals(2940.0));
        expect(val.lowStockCount, equals(1));
        expect(val.outOfStockCount, equals(1));
        expect(val.expiringCount, equals(1));
      },
    );
  });

  group('Inventory Filter & Search Logic Tests', () {
    test(
      'filters correctly by category, stock alert status, and search query',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        await controller.addMedicine(
          name: 'Sulphur',
          category: 'Dilution',
          potency: '200C',
          currentStock: 10.0,
          reorderLevel: 3.0,
          unit: 'Bottles',
        );

        await controller.addMedicine(
          name: 'Calcarea Carb',
          category: 'Dilution',
          potency: '30C',
          currentStock: 2.0,
          reorderLevel: 5.0,
          unit: 'Bottles',
        );

        await controller.addMedicine(
          name: 'Azadirachta Indica Q',
          category: 'Mother Tincture',
          potency: 'Q',
          currentStock: 0.0,
          reorderLevel: 2.0,
          unit: 'Bottles',
        );

        await controller.addMedicine(
          name: 'Biochemic Calc Fluor 6X',
          category: 'Biochemic / Trituration',
          potency: '6X',
          currentStock: 5.0,
          expiryDate: DateTime.now().add(const Duration(days: 15)),
          unit: 'Bottles',
        );

        List<Medicine> items = [];
        final sub = container.listen(inventoryStreamProvider, (_, next) {
          if (next.hasValue) items = next.value!;
        });
        for (int i = 0; i < 50 && items.length < 4; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        sub.close();

        // Default: All
        var list = container.read(filteredInventoryProvider).value!;
        expect(list.length, equals(4));

        // Filter: Low Stock
        container.read(inventoryCategoryFilterProvider.notifier).state =
            'Low Stock';
        list = container.read(filteredInventoryProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.name, equals('Calcarea Carb'));

        // Filter: Out of Stock
        container.read(inventoryCategoryFilterProvider.notifier).state =
            'Out of Stock';
        list = container.read(filteredInventoryProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.name, equals('Azadirachta Indica Q'));

        // Filter: Expiring Soon
        container.read(inventoryCategoryFilterProvider.notifier).state =
            'Expiring Soon';
        list = container.read(filteredInventoryProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.name, equals('Biochemic Calc Fluor 6X'));

        // Filter: Specific Category
        container.read(inventoryCategoryFilterProvider.notifier).state =
            'Mother Tincture';
        list = container.read(filteredInventoryProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.name, equals('Azadirachta Indica Q'));

        // Reset Category to All and Test Text Search
        container.read(inventoryCategoryFilterProvider.notifier).state = 'All';
        container.read(inventorySearchQueryProvider.notifier).state = 'sulph';
        list = container.read(filteredInventoryProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.name, equals('Sulphur'));

        // Text search by potency
        container.read(inventorySearchQueryProvider.notifier).state = '6X';
        list = container.read(filteredInventoryProvider).value!;
        expect(list.length, equals(1));
        expect(list.first.name, equals('Biochemic Calc Fluor 6X'));
      },
    );
  });

  group('Inventory UI & Widget Tests', () {
    testWidgets('InventoryScreen shows empty state when no medicines exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryStreamProvider.overrideWith(
              (ref) => Stream.value(<Medicine>[]),
            ),
            clinicsStreamProvider.overrideWith(
              (ref) => Stream.value(<Clinic>[]),
            ),
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(home: InventoryScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Medicine Inventory'), findsOneWidget);
      expect(find.text('No Medicines in Inventory Yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('InventoryScreen displays medicine cards and +1 / -1 buttons', (
      tester,
    ) async {
      final sampleMed = Medicine(
        id: 'med-123',
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        form: 'Liquid Dilution',
        currentStock: 8.0,
        unit: 'Bottles (30ml)',
        reorderLevel: 3.0,
        costPrice: 100.0,
        sellingPrice: 150.0,
        isDeleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryStreamProvider.overrideWith(
              (ref) => Stream.value([sampleMed]),
            ),
            clinicsStreamProvider.overrideWith(
              (ref) => Stream.value(<Clinic>[]),
            ),
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(home: InventoryScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Arnica Montana'), findsOneWidget);
      expect(find.text('200C'), findsOneWidget);
      expect(find.text('8 Bottles (30ml)'), findsOneWidget);
      expect(find.text('In Stock'), findsOneWidget);
      expect(find.text('1 Restock'), findsOneWidget);
      expect(find.text('1 Dispense'), findsOneWidget);
    });

    testWidgets('AddEditMedicineDialog validates and saves new medicine', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clinicsStreamProvider.overrideWith(
              (ref) => Stream.value(<Clinic>[]),
            ),
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(body: AddEditMedicineDialog()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Medicine to Inventory'), findsOneWidget);

      // Attempt submit without name
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      expect(find.text('Enter medicine name'), findsOneWidget);

      // Enter name and save
      await tester.enterText(find.byType(TextFormField).first, 'Bryonia Alba');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();

      final medicines = await db.select(db.medicines).get();
      expect(medicines.length, equals(1));
      expect(medicines.first.name, equals('Bryonia Alba'));
    });
  });
}
