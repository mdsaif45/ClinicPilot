import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/new_cash_memo_dialog.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/widgets/prescription_dispense_review_sheet.dart';
import 'package:clinic_pilot/features/cashmemo/services/prescription_dispense_matcher.dart';
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

  Future<void> seedPrescription({
    required String id,
    required String remedyName,
    required String potency,
    required DateTime date,
    int remedyIndex = 1,
    String patientId = 'pat-1',
    bool isDeleted = false,
  }) async {
    await db
        .into(db.prescriptions)
        .insert(
          PrescriptionsCompanion.insert(
            id: id,
            patientId: patientId,
            remedyName: remedyName,
            potency: potency,
            prescriptionDate: Value(date),
            remedyIndex: Value(remedyIndex),
            isDeleted: Value(isDeleted),
          ),
        );
  }

  Future<Prescription> rx(String id) =>
      (db.select(db.prescriptions)..where((t) => t.id.equals(id))).getSingle();

  Future<Medicine> med(String id) =>
      (db.select(db.medicines)..where((t) => t.id.equals(id))).getSingle();

  group('PrescriptionDispenseMatcher.normalize', () {
    test('collapses case, spacing and punctuation differences', () {
      expect(
        PrescriptionDispenseMatcher.normalize('Nux Vomica'),
        equals(PrescriptionDispenseMatcher.normalize('nux-vomica')),
      );
      expect(
        PrescriptionDispenseMatcher.normalize('  Arnica  Montana '),
        equals(PrescriptionDispenseMatcher.normalize('ArnicaMontana')),
      );
      expect(
        PrescriptionDispenseMatcher.normalize('200 C'),
        equals(PrescriptionDispenseMatcher.normalize('200c')),
      );
    });

    test('keeps genuinely different remedies distinct', () {
      expect(
        PrescriptionDispenseMatcher.normalize('Arnica'),
        isNot(equals(PrescriptionDispenseMatcher.normalize('Arsenicum'))),
      );
    });
  });

  group('PrescriptionDispenseMatcher.activePrescription', () {
    test('returns empty list when the patient has no prescriptions', () {
      expect(PrescriptionDispenseMatcher.activePrescription([]), isEmpty);
    });

    test(
      'selects only the newest prescription batch, ordered by index',
      () async {
        await seedClinicAndPatient();
        final old = DateTime(2026, 1, 10);
        final recent = DateTime(2026, 3, 20);

        await seedPrescription(
          id: 'rx-old',
          remedyName: 'Belladonna',
          potency: '30C',
          date: old,
        );
        await seedPrescription(
          id: 'rx-new-2',
          remedyName: 'Rhus Tox',
          potency: '200C',
          date: recent,
          remedyIndex: 2,
        );
        await seedPrescription(
          id: 'rx-new-1',
          remedyName: 'Arnica Montana',
          potency: '200C',
          date: recent,
          remedyIndex: 1,
        );

        final all = await db.select(db.prescriptions).get();
        final active = PrescriptionDispenseMatcher.activePrescription(all);

        expect(active.length, equals(2));
        expect(active[0].remedyName, equals('Arnica Montana'));
        expect(active[1].remedyName, equals('Rhus Tox'));
        expect(active.any((p) => p.remedyName == 'Belladonna'), isFalse);
      },
    );

    test('groups same-day rows written seconds apart into one batch', () async {
      await seedClinicAndPatient();
      await seedPrescription(
        id: 'rx-a',
        remedyName: 'Arnica Montana',
        potency: '200C',
        date: DateTime(2026, 3, 20, 10, 15, 3),
        remedyIndex: 1,
      );
      await seedPrescription(
        id: 'rx-b',
        remedyName: 'Rhus Tox',
        potency: '200C',
        date: DateTime(2026, 3, 20, 10, 15, 47),
        remedyIndex: 2,
      );

      final all = await db.select(db.prescriptions).get();
      expect(
        PrescriptionDispenseMatcher.activePrescription(all).length,
        equals(2),
      );
    });

    test('ignores soft-deleted prescriptions', () async {
      await seedClinicAndPatient();
      await seedPrescription(
        id: 'rx-live',
        remedyName: 'Belladonna',
        potency: '30C',
        date: DateTime(2026, 1, 10),
      );
      await seedPrescription(
        id: 'rx-dead',
        remedyName: 'Nux Vomica',
        potency: '30C',
        date: DateTime(2026, 5, 1),
        isDeleted: true,
      );

      final all = await db.select(db.prescriptions).get();
      final active = PrescriptionDispenseMatcher.activePrescription(all);

      // The newest row is deleted, so the older live batch is active.
      expect(active.length, equals(1));
      expect(active.first.remedyName, equals('Belladonna'));
    });
  });

  group('PrescriptionDispenseMatcher.match', () {
    test(
      'matches remedy on name and potency when stock is sufficient',
      () async {
        await seedClinicAndPatient();
        final medId = await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 10.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
        );
        await seedPrescription(
          id: 'rx-1',
          remedyName: 'arnica  montana',
          potency: '200 C',
          date: DateTime(2026, 3, 20),
        );

        final matches = PrescriptionDispenseMatcher.match(
          prescriptions: [await rx('rx-1')],
          inventory: [await med(medId)],
        );

        expect(matches.single.status, equals(DispenseMatchStatus.matched));
        expect(matches.single.medicine!.id, equals(medId));
        expect(matches.single.availableQuantity, equals(1.0));
        expect(matches.single.isDispensable, isTrue);
        expect(matches.single.statusLabel, equals('In stock'));
      },
    );

    test('flags notStocked when the remedy is absent from inventory', () async {
      await seedClinicAndPatient();
      final medId = await inventoryController.addMedicine(
        name: 'Rhus Tox',
        category: 'Dilution',
        potency: '200C',
        currentStock: 5.0,
        unit: 'Bottles',
        sellingPrice: 100.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Lycopodium',
        potency: '1M',
        date: DateTime(2026, 3, 20),
      );

      final matches = PrescriptionDispenseMatcher.match(
        prescriptions: [await rx('rx-1')],
        inventory: [await med(medId)],
      );

      expect(matches.single.status, equals(DispenseMatchStatus.notStocked));
      expect(matches.single.medicine, isNull);
      expect(matches.single.isDispensable, isFalse);
      expect(matches.single.statusLabel, equals('Not in inventory'));
    });

    test(
      'flags potencyMismatch when only a different potency is carried',
      () async {
        await seedClinicAndPatient();
        final medId = await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '30C',
          currentStock: 10.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
        );
        await seedPrescription(
          id: 'rx-1',
          remedyName: 'Arnica Montana',
          potency: '1M',
          date: DateTime(2026, 3, 20),
        );

        final matches = PrescriptionDispenseMatcher.match(
          prescriptions: [await rx('rx-1')],
          inventory: [await med(medId)],
        );

        // Substituting a potency is a clinical call, so it is never auto-billed.
        expect(
          matches.single.status,
          equals(DispenseMatchStatus.potencyMismatch),
        );
        expect(matches.single.medicine, isNotNull);
        expect(matches.single.isDispensable, isFalse);
        expect(matches.single.availableQuantity, equals(0));
      },
    );

    test('reports partialStock and caps quantity at what remains', () async {
      await seedClinicAndPatient();
      final medId = await inventoryController.addMedicine(
        name: 'Bryonia Alba',
        category: 'Dilution',
        potency: '30C',
        currentStock: 0.5,
        unit: 'Bottles',
        sellingPrice: 90.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Bryonia Alba',
        potency: '30C',
        date: DateTime(2026, 3, 20),
      );

      final matches = PrescriptionDispenseMatcher.match(
        prescriptions: [await rx('rx-1')],
        inventory: [await med(medId)],
      );

      expect(matches.single.status, equals(DispenseMatchStatus.partialStock));
      expect(matches.single.availableQuantity, equals(0.5));
      expect(matches.single.isDispensable, isTrue);
    });

    test('zero stock is not dispensable', () async {
      await seedClinicAndPatient();
      final medId = await inventoryController.addMedicine(
        name: 'Nux Vomica',
        category: 'Dilution',
        potency: '30C',
        currentStock: 0.0,
        unit: 'Bottles',
        sellingPrice: 90.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Nux Vomica',
        potency: '30C',
        date: DateTime(2026, 3, 20),
      );

      final matches = PrescriptionDispenseMatcher.match(
        prescriptions: [await rx('rx-1')],
        inventory: [await med(medId)],
      );

      expect(matches.single.availableQuantity, equals(0.0));
      expect(matches.single.isDispensable, isFalse);
    });

    test(
      'prefers the soonest-expiring batch that can cover the dose',
      () async {
        await seedClinicAndPatient();
        final laterId = await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 8.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
          expiryDate: DateTime(2027, 12, 1),
        );
        final soonerId = await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 4.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
          expiryDate: DateTime(2026, 10, 1),
        );
        await seedPrescription(
          id: 'rx-1',
          remedyName: 'Arnica Montana',
          potency: '200C',
          date: DateTime(2026, 3, 20),
        );

        final matches = PrescriptionDispenseMatcher.match(
          prescriptions: [await rx('rx-1')],
          inventory: [await med(laterId), await med(soonerId)],
        );

        expect(matches.single.medicine!.id, equals(soonerId));
      },
    );

    test(
      'skips an out-of-stock batch in favour of one that can cover',
      () async {
        await seedClinicAndPatient();
        final emptyId = await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 0.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
          expiryDate: DateTime(2026, 9, 1),
        );
        final stockedId = await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 6.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
          expiryDate: DateTime(2027, 9, 1),
        );
        await seedPrescription(
          id: 'rx-1',
          remedyName: 'Arnica Montana',
          potency: '200C',
          date: DateTime(2026, 3, 20),
        );

        final matches = PrescriptionDispenseMatcher.match(
          prescriptions: [await rx('rx-1')],
          inventory: [await med(emptyId), await med(stockedId)],
        );

        expect(matches.single.medicine!.id, equals(stockedId));
        expect(matches.single.status, equals(DispenseMatchStatus.matched));
      },
    );

    test('excludes soft-deleted inventory items from matching', () async {
      await seedClinicAndPatient();
      final medId = await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 150.0,
      );
      await inventoryController.deleteMedicine(medId);
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Arnica Montana',
        potency: '200C',
        date: DateTime(2026, 3, 20),
      );

      final matches = PrescriptionDispenseMatcher.match(
        prescriptions: [await rx('rx-1')],
        inventory: [await med(medId)],
      );

      expect(matches.single.status, equals(DispenseMatchStatus.notStocked));
    });

    test('resolves a mixed prescription into per-remedy statuses', () async {
      await seedClinicAndPatient();
      final okId = await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 150.0,
      );
      final wrongPotencyId = await inventoryController.addMedicine(
        name: 'Rhus Tox',
        category: 'Dilution',
        potency: '30C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 120.0,
      );

      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Arnica Montana',
        potency: '200C',
        date: DateTime(2026, 3, 20),
        remedyIndex: 1,
      );
      await seedPrescription(
        id: 'rx-2',
        remedyName: 'Rhus Tox',
        potency: '1M',
        date: DateTime(2026, 3, 20),
        remedyIndex: 2,
      );
      await seedPrescription(
        id: 'rx-3',
        remedyName: 'Lycopodium',
        potency: '1M',
        date: DateTime(2026, 3, 20),
        remedyIndex: 3,
      );

      final all = await db.select(db.prescriptions).get();
      final matches = PrescriptionDispenseMatcher.match(
        prescriptions: PrescriptionDispenseMatcher.activePrescription(all),
        inventory: [await med(okId), await med(wrongPotencyId)],
      );

      expect(matches.length, equals(3));
      expect(matches[0].status, equals(DispenseMatchStatus.matched));
      expect(matches[1].status, equals(DispenseMatchStatus.potencyMismatch));
      expect(matches[2].status, equals(DispenseMatchStatus.notStocked));
      expect(matches.where((m) => m.isDispensable).length, equals(1));
    });
  });

  group('Prescription-to-Dispense pipeline in NewCashMemoDialog', () {
    /// Taps text that may sit below the fold.
    ///
    /// The cash memo body is a [SingleChildScrollView], so controls near the
    /// bottom are off-screen at the default test viewport size.
    Future<void> tapText(WidgetTester tester, String label) async {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> pumpDialog(WidgetTester tester, AppDatabase database) async {
      final patient =
          await (database.select(database.patients)
            ..where((t) => t.id.equals('pat-1'))).getSingle();

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
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
    }

    testWidgets('shortcut is hidden when the patient has no prescription', (
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
      );

      await pumpDialog(tester, db);

      expect(find.text('Dispense from Inventory'), findsOneWidget);
      expect(
        find.textContaining('Dispense from Active Prescription'),
        findsNothing,
      );
    });

    testWidgets(
      'one tap pulls the prescription, bills it, and deducts stock on save',
      (tester) async {
        await seedClinicAndPatient();

        final arnicaId = await inventoryController.addMedicine(
          name: 'Arnica Montana',
          category: 'Dilution',
          potency: '200C',
          currentStock: 10.0,
          unit: 'Bottles',
          sellingPrice: 150.0,
        );
        final rhusId = await inventoryController.addMedicine(
          name: 'Rhus Tox',
          category: 'Dilution',
          potency: '30C',
          currentStock: 4.0,
          unit: 'Bottles',
          sellingPrice: 120.0,
        );
        // Prescribed but not stocked -> must be surfaced, never billed.
        await seedPrescription(
          id: 'rx-3',
          remedyName: 'Lycopodium',
          potency: '1M',
          date: DateTime(2026, 3, 20),
          remedyIndex: 3,
        );
        await seedPrescription(
          id: 'rx-1',
          remedyName: 'Arnica Montana',
          potency: '200C',
          date: DateTime(2026, 3, 20),
          remedyIndex: 1,
        );
        await seedPrescription(
          id: 'rx-2',
          remedyName: 'Rhus Tox',
          potency: '30C',
          date: DateTime(2026, 3, 20),
          remedyIndex: 2,
        );

        await pumpDialog(tester, db);

        // Shortcut appears and counts all three prescribed remedies.
        expect(
          find.text('Dispense from Active Prescription (3)'),
          findsOneWidget,
        );

        await tapText(tester, 'Dispense from Active Prescription (3)');

        // Review sheet lists every remedy with its resolved status.
        expect(find.text('Dispense from Prescription'), findsOneWidget);
        expect(find.text('Arnica Montana 200C'), findsOneWidget);
        expect(find.text('Rhus Tox 30C'), findsOneWidget);
        expect(find.text('Lycopodium 1M'), findsOneWidget);
        expect(find.text('Not in inventory'), findsOneWidget);
        expect(find.textContaining('1 remedy is unavailable'), findsOneWidget);

        // Only the two matched remedies are billable: 150 + 120 = 270.
        expect(find.text('Total  ₹270'), findsOneWidget);

        await tapText(tester, 'Dispense 2');

        // Fee auto-filled; total = 300 consult + 270 medicine.
        expect(find.text('2 remedies selected'), findsOneWidget);
        expect(find.textContaining('570'), findsWidgets);

        await tapText(tester, 'Save & Issue Memo');

        final memos = await db.select(db.cashMemos).get();
        expect(memos.length, equals(1));
        expect(memos.first.medicineFee, equals(270.0));
        expect(memos.first.total, equals(570.0));
        expect(memos.first.notes, contains('Arnica Montana 200C (1 Bottles)'));
        expect(memos.first.notes, contains('Rhus Tox 30C (1 Bottles)'));
        // The unstocked remedy must not appear as dispensed.
        expect(memos.first.notes, isNot(contains('Lycopodium')));

        expect((await med(arnicaId)).currentStock, equals(9.0));
        expect((await med(rhusId)).currentStock, equals(3.0));
      },
    );

    testWidgets('deselecting a remedy in review excludes it from the bill', (
      tester,
    ) async {
      await seedClinicAndPatient();
      final arnicaId = await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 150.0,
      );
      final rhusId = await inventoryController.addMedicine(
        name: 'Rhus Tox',
        category: 'Dilution',
        potency: '30C',
        currentStock: 4.0,
        unit: 'Bottles',
        sellingPrice: 120.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Arnica Montana',
        potency: '200C',
        date: DateTime(2026, 3, 20),
        remedyIndex: 1,
      );
      await seedPrescription(
        id: 'rx-2',
        remedyName: 'Rhus Tox',
        potency: '30C',
        date: DateTime(2026, 3, 20),
        remedyIndex: 2,
      );

      await pumpDialog(tester, db);

      await tapText(tester, 'Dispense from Active Prescription (2)');

      expect(find.text('Total  ₹270'), findsOneWidget);

      // Uncheck Rhus Tox.
      await tapText(tester, 'Rhus Tox 30C');

      expect(find.text('Total  ₹150'), findsOneWidget);

      await tapText(tester, 'Dispense 1');

      await tapText(tester, 'Save & Issue Memo');

      final memos = await db.select(db.cashMemos).get();
      expect(memos.first.medicineFee, equals(150.0));
      expect(memos.first.notes, isNot(contains('Rhus Tox')));

      // Only the dispensed remedy's stock moves.
      expect((await med(arnicaId)).currentStock, equals(9.0));
      expect((await med(rhusId)).currentStock, equals(4.0));
    });

    testWidgets('cancelling the review sheet bills and deducts nothing', (
      tester,
    ) async {
      await seedClinicAndPatient();
      final arnicaId = await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 150.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Arnica Montana',
        potency: '200C',
        date: DateTime(2026, 3, 20),
      );

      await pumpDialog(tester, db);

      await tapText(tester, 'Dispense from Active Prescription (1)');

      // The cash memo dialog has its own Cancel action, so scope the finder
      // to the review sheet's button.
      final sheetCancel = find.descendant(
        of: find.byType(PrescriptionDispenseReviewSheet),
        matching: find.text('Cancel'),
      );
      await tester.tap(sheetCancel);
      await tester.pumpAndSettle();

      expect(find.byType(PrescriptionDispenseReviewSheet), findsNothing);
      expect(find.text('Dispense from Inventory'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
      expect((await med(arnicaId)).currentStock, equals(10.0));
    });

    testWidgets('a partially stocked remedy is capped at available quantity', (
      tester,
    ) async {
      await seedClinicAndPatient();
      final medId = await inventoryController.addMedicine(
        name: 'Bryonia Alba',
        category: 'Dilution',
        potency: '30C',
        currentStock: 0.5,
        unit: 'Bottles',
        sellingPrice: 100.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Bryonia Alba',
        potency: '30C',
        date: DateTime(2026, 3, 20),
      );

      await pumpDialog(tester, db);

      await tapText(tester, 'Dispense from Active Prescription (1)');

      expect(find.text('Only 1 left'), findsOneWidget);

      await tapText(tester, 'Dispense 1');

      await tapText(tester, 'Save & Issue Memo');

      // Billed for the 0.5 actually dispensed, and stock lands exactly at 0.
      final memos = await db.select(db.cashMemos).get();
      expect(memos.first.medicineFee, equals(50.0));
      expect((await med(medId)).currentStock, equals(0.0));
    });

    testWidgets('prescription items merge with manually picked remedies', (
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
      );
      await inventoryController.addMedicine(
        name: 'Calendula Q',
        category: 'Mother Tincture',
        currentStock: 5.0,
        unit: 'Bottles',
        sellingPrice: 200.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Arnica Montana',
        potency: '200C',
        date: DateTime(2026, 3, 20),
      );

      await pumpDialog(tester, db);

      // Add an over-the-counter item by hand first.
      await tapText(tester, 'Dispense from Inventory');
      await tapText(tester, 'Calendula Q');
      await tapText(tester, 'Confirm Dispensed');

      expect(find.text('1 remedy selected'), findsOneWidget);

      // Then pull the prescription; it must add, not replace.
      await tapText(tester, 'Dispense from Active Prescription (1)');
      await tapText(tester, 'Dispense 1');

      expect(find.text('2 remedies selected'), findsOneWidget);

      await tapText(tester, 'Save & Issue Memo');

      final memos = await db.select(db.cashMemos).get();
      expect(memos.first.medicineFee, equals(350.0));
      expect(memos.first.notes, contains('Calendula Q'));
      expect(memos.first.notes, contains('Arnica Montana'));
    });

    testWidgets('pulling the prescription twice does not double-bill', (
      tester,
    ) async {
      await seedClinicAndPatient();
      final medId = await inventoryController.addMedicine(
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles',
        sellingPrice: 150.0,
      );
      await seedPrescription(
        id: 'rx-1',
        remedyName: 'Arnica Montana',
        potency: '200C',
        date: DateTime(2026, 3, 20),
      );

      await pumpDialog(tester, db);

      for (var i = 0; i < 2; i++) {
        await tapText(tester, 'Dispense from Active Prescription (1)');
        await tapText(tester, 'Dispense 1');
      }

      expect(find.text('1 remedy selected'), findsOneWidget);

      await tapText(tester, 'Save & Issue Memo');

      final memos = await db.select(db.cashMemos).get();
      expect(memos.first.medicineFee, equals(150.0));
      expect((await med(medId)).currentStock, equals(9.0));
    });
  });
}
