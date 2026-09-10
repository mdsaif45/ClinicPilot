import 'dart:io';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/dashboard/presentation/widgets/medicine_inventory_card.dart';
import 'package:clinic_pilot/features/inventory/presentation/inventory_screen.dart';
import 'package:clinic_pilot/features/inventory/presentation/widgets/add_edit_medicine_dialog.dart';
import 'package:clinic_pilot/features/inventory/presentation/widgets/inventory_clinic_filter_pill.dart';
import 'package:clinic_pilot/features/inventory/providers/inventory_clinic_filter_provider.dart';
import 'package:clinic_pilot/features/inventory/providers/inventory_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late AppDatabase db;
  late InventoryController controller;

  final clinicA = Clinic(
    id: 'clinic-a',
    name: 'Downtown Clinic',
    address: '123 Market St',
    monthlyRent: 15000,
    defaultConsultationFee: 500,
    openDays: 'Mon-Fri',
    colorHex: '#008080',
    isActive: true,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  final clinicB = Clinic(
    id: 'clinic-b',
    name: 'Westside Branch',
    address: '456 West Ave',
    monthlyRent: 12000,
    defaultConsultationFee: 400,
    openDays: 'Tue-Sat',
    colorHex: '#4A90E2',
    isActive: true,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync('cp_multi_inv_test_');
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    controller = InventoryController(db);
    await db.into(db.clinics).insert(clinicA);
    await db.into(db.clinics).insert(clinicB);
    await db
        .into(db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'active_clinic_id',
            value: 'clinic-a',
            updatedAt: Value(DateTime.now()),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Model B — Multi-Clinic Scoped Inventory Unit & Provider Tests', () {
    test(
      'filteredInventoryProvider includes clinic-specific items and shared items when filtered',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        // Medicine at Clinic A
        await controller.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          currentStock: 10.0,
          clinicId: 'clinic-a',
          unit: 'Bottles',
        );

        // Medicine at Clinic B
        await controller.addMedicine(
          name: 'Nux Vomica',
          category: 'Dilution',
          currentStock: 5.0,
          clinicId: 'clinic-b',
          unit: 'Bottles',
        );

        // Shared Medicine across all clinics (clinicId == null)
        await controller.addMedicine(
          name: 'Rescue Remedy',
          category: 'Dilution',
          currentStock: 8.0,
          clinicId: null,
          unit: 'Bottles',
        );

        // Wait for inventory stream to emit items
        List<Medicine> items = [];
        final sub = container.listen(inventoryStreamProvider, (_, next) {
          if (next.hasValue) items = next.value!;
        });
        for (int i = 0; i < 50 && items.length < 3; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        sub.close();

        // 1. Consolidated view (filter == null) => Shows all 3
        container.read(inventoryClinicFilterProvider.notifier).state = null;
        var filtered = container.read(filteredInventoryProvider).value!;
        expect(filtered.length, equals(3));

        // 2. Filter Clinic A => Shows Arnica (clinic-a) + Rescue Remedy (shared)
        container.read(inventoryClinicFilterProvider.notifier).state =
            'clinic-a';
        filtered = container.read(filteredInventoryProvider).value!;
        expect(filtered.length, equals(2));
        expect(filtered.map((m) => m.name), contains('Arnica Montana'));
        expect(filtered.map((m) => m.name), contains('Rescue Remedy'));
        expect(filtered.map((m) => m.name), isNot(contains('Nux Vomica')));

        // 3. Filter Clinic B => Shows Nux Vomica (clinic-b) + Rescue Remedy (shared)
        container.read(inventoryClinicFilterProvider.notifier).state =
            'clinic-b';
        filtered = container.read(filteredInventoryProvider).value!;
        expect(filtered.length, equals(2));
        expect(filtered.map((m) => m.name), contains('Nux Vomica'));
        expect(filtered.map((m) => m.name), contains('Rescue Remedy'));
        expect(filtered.map((m) => m.name), isNot(contains('Arnica Montana')));
      },
    );

    test(
      'scopedInventoryValuationProvider computes metrics correctly per clinic',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        // Clinic A: 10 units @ 100 selling price = 1000
        await controller.addMedicine(
          name: 'Arnica',
          category: 'Dilution',
          currentStock: 10.0,
          sellingPrice: 100.0,
          clinicId: 'clinic-a',
          unit: 'Bottles',
        );

        // Clinic B: 5 units @ 200 selling price = 1000
        await controller.addMedicine(
          name: 'Belladonna',
          category: 'Dilution',
          currentStock: 5.0,
          sellingPrice: 200.0,
          clinicId: 'clinic-b',
          unit: 'Bottles',
        );

        // Shared: 2 units @ 150 selling price = 300
        await controller.addMedicine(
          name: 'Shared Kit',
          category: 'Dilution',
          currentStock: 2.0,
          sellingPrice: 150.0,
          clinicId: null,
          unit: 'Bottles',
        );

        List<Medicine> items = [];
        final sub = container.listen(inventoryStreamProvider, (_, next) {
          if (next.hasValue) items = next.value!;
        });
        for (int i = 0; i < 50 && items.length < 3; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
        sub.close();

        // Total consolidated valuation: 1000 + 1000 + 300 = 2300, 17 units
        final consolidated = container.read(
          scopedInventoryValuationProvider(null),
        );
        expect(consolidated.totalItems, equals(3));
        expect(consolidated.totalUnits, equals(17.0));
        expect(consolidated.totalSellingValue, equals(2300.0));

        // Clinic A valuation: 1000 + 300 (shared) = 1300, 12 units
        final valClinicA = container.read(
          scopedInventoryValuationProvider('clinic-a'),
        );
        expect(valClinicA.totalItems, equals(2));
        expect(valClinicA.totalUnits, equals(12.0));
        expect(valClinicA.totalSellingValue, equals(1300.0));

        // Clinic B valuation: 1000 + 300 (shared) = 1300, 7 units
        final valClinicB = container.read(
          scopedInventoryValuationProvider('clinic-b'),
        );
        expect(valClinicB.totalItems, equals(2));
        expect(valClinicB.totalUnits, equals(7.0));
        expect(valClinicB.totalSellingValue, equals(1300.0));
      },
    );
  });

  group('Model B — Multi-Clinic Inventory UI Tests', () {
    testWidgets('InventoryClinicFilterPill hides itself when < 2 clinics', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clinicsStreamProvider.overrideWith(
              (ref) => Stream.value([clinicA]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: InventoryClinicFilterPill(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All Clinics'), findsNothing);
      expect(find.text('Downtown Clinic'), findsNothing);
    });

    testWidgets(
      'InventoryClinicFilterPill shows All Clinics and opens switcher when >= 2 clinics',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              clinicsStreamProvider.overrideWith(
                (ref) => Stream.value([clinicA, clinicB]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: InventoryClinicFilterPill(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('All Clinics'), findsOneWidget);

        // Tap pill to open bottom sheet
        await tester.tap(find.text('All Clinics'));
        await tester.pumpAndSettle();

        expect(find.text('Inventory Scope'), findsOneWidget);
        expect(find.text('All Clinics (Consolidated Stock)'), findsOneWidget);
        expect(find.text('Downtown Clinic'), findsOneWidget);
        expect(find.text('Westside Branch'), findsOneWidget);
      },
    );

    testWidgets(
      'AddEditMedicineDialog renders Clinic selector when >= 2 clinics and saves clinicId',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              clinicsStreamProvider.overrideWith(
                (ref) => Stream.value([clinicA, clinicB]),
              ),
              databaseProvider.overrideWithValue(db),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const Scaffold(body: AddEditMedicineDialog()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Clinic / Branch Location'), findsOneWidget);
        expect(
          find.text('All Clinics (Shared Practice Stock)'),
          findsOneWidget,
        );

        // Enter remedy name
        await tester.enterText(
          find.byType(TextFormField).first,
          'Thuja Occidentalis',
        );
        await tester.pumpAndSettle();

        // Tap Save Item
        await tester.tap(find.text('Save Item'));
        await tester.pumpAndSettle();

        // Saved with null clinicId (Shared practice stock)
        final meds = await db.select(db.medicines).get();
        expect(meds.length, equals(1));
        expect(meds.first.name, equals('Thuja Occidentalis'));
        expect(meds.first.clinicId, isNull);
      },
    );

    testWidgets(
      'MedicineCard displays clinic attribution badge when viewing All Clinics with multiple clinics',
      (tester) async {
        final med1 = Medicine(
          id: 'med-1',
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 5.0,
          unit: 'Bottles',
          reorderLevel: 2.0,
          clinicId: 'clinic-a',
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final med2 = Medicine(
          id: 'med-2',
          name: 'Universal Spray',
          category: 'Dilution',
          potency: '30C',
          currentStock: 3.0,
          unit: 'Bottles',
          reorderLevel: 2.0,
          clinicId: null,
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              clinicsStreamProvider.overrideWith(
                (ref) => Stream.value([clinicA, clinicB]),
              ),
              inventoryStreamProvider.overrideWith(
                (ref) => Stream.value([med1, med2]),
              ),
              databaseProvider.overrideWithValue(db),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const InventoryScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Practice Stock Valuation'), findsOneWidget);
        expect(find.text('Downtown Clinic'), findsOneWidget);
        expect(find.text('Shared Practice Stock'), findsOneWidget);
      },
    );

    testWidgets(
      'MedicineInventoryCard scopes summary to activeClinic on Dashboard and sets filter on tap',
      (tester) async {
        final medA = Medicine(
          id: 'm1',
          name: 'Aconite',
          category: 'Dilution',
          currentStock: 4.0,
          unit: 'Bottles',
          reorderLevel: 2.0,
          clinicId: 'clinic-a',
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              clinicsStreamProvider.overrideWith(
                (ref) => Stream.value([clinicA, clinicB]),
              ),
              inventoryStreamProvider.overrideWith(
                (ref) => Stream.value([medA]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const Scaffold(body: MedicineInventoryCard()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Medicine Inventory'), findsOneWidget);
        expect(
          find.text('Downtown Clinic • 1 remedy • 4 units'),
          findsOneWidget,
        );
      },
    );
  });
}
