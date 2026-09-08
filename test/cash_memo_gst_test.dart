import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/new_cash_memo_dialog.dart';
import 'package:clinic_pilot/features/inventory/providers/inventory_provider.dart';

void main() {
  late AppDatabase db;
  late InventoryController inventory;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    inventory = InventoryController(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed({String? gstin, double defaultGstRate = 12.0}) async {
    await db
        .into(db.clinics)
        .insert(
          ClinicsCompanion.insert(
            id: 'clinic-1',
            name: 'Homeo Care Clinic',
            defaultConsultationFee: const Value(300.0),
            gstin: Value(gstin),
            defaultGstRate: Value(defaultGstRate),
          ),
        );
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: 'pat-1',
            name: 'Rahul Sharma',
            phone: '9876543210',
            gender: 'Male',
            age: 34,
            primaryClinicId: const Value('clinic-1'),
          ),
        );
  }

  Future<void> pumpDialog(WidgetTester tester) async {
    final patient =
        await (db.select(db.patients)
          ..where((t) => t.id.equals('pat-1'))).getSingle();

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
  }

  /// The cash memo body scrolls, so controls near the bottom need bringing
  /// into view before they can be tapped.
  Future<void> tapText(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> dispense(WidgetTester tester, String medicineName) async {
    await tapText(tester, 'Dispense from Inventory');
    await tapText(tester, medicineName);
    await tapText(tester, 'Confirm Dispensed');
  }

  testWidgets('a registered clinic bills CGST/SGST on dispensed medicines', (
    tester,
  ) async {
    await seed(gstin: '29ABCDE1234F1Z5');
    await inventory.addMedicine(
      name: 'Arnica Montana',
      category: 'Dilution',
      potency: '200C',
      currentStock: 10.0,
      unit: 'Bottles',
      sellingPrice: 200.0,
      gstRate: 12.0,
    );

    await pumpDialog(tester);
    await dispense(tester, 'Arnica Montana');

    // 12% of 200 = 24, split 12 + 12.
    expect(find.text('CGST @ 6%'), findsOneWidget);
    expect(find.text('SGST @ 6%'), findsOneWidget);

    await tapText(tester, 'Save & Issue Memo');

    final memo = (await db.select(db.cashMemos).get()).single;
    expect(memo.medicineFee, equals(200.0));
    expect(memo.cgstAmount, equals(12.0));
    expect(memo.sgstAmount, equals(12.0));
    expect(memo.gstin, equals('29ABCDE1234F1Z5'));
    // 300 consult + 200 medicine + 24 tax. Consultation is an exempt
    // healthcare service, so it is not itself taxed.
    expect(memo.total, equals(524.0));
  });

  testWidgets('an unregistered clinic issues no tax breakdown at all', (
    tester,
  ) async {
    await seed();
    await inventory.addMedicine(
      name: 'Arnica Montana',
      category: 'Dilution',
      potency: '200C',
      currentStock: 10.0,
      unit: 'Bottles',
      sellingPrice: 200.0,
      gstRate: 12.0,
    );

    await pumpDialog(tester);
    await dispense(tester, 'Arnica Montana');

    expect(find.textContaining('CGST'), findsNothing);
    expect(find.textContaining('SGST'), findsNothing);

    await tapText(tester, 'Save & Issue Memo');

    final memo = (await db.select(db.cashMemos).get()).single;
    expect(memo.cgstAmount, equals(0.0));
    expect(memo.sgstAmount, equals(0.0));
    expect(memo.gstin, isNull);
    expect(memo.total, equals(500.0));
  });

  testWidgets('an item without its own rate falls back to the clinic default', (
    tester,
  ) async {
    await seed(gstin: '29ABCDE1234F1Z5', defaultGstRate: 5.0);
    await inventory.addMedicine(
      name: 'Calendula Q',
      category: 'Mother Tincture',
      currentStock: 10.0,
      unit: 'Bottles',
      sellingPrice: 100.0,
    );

    await pumpDialog(tester);
    await dispense(tester, 'Calendula Q');

    expect(find.text('CGST @ 2.50%'), findsOneWidget);

    await tapText(tester, 'Save & Issue Memo');

    final memo = (await db.select(db.cashMemos).get()).single;
    expect((memo.cgstAmount ?? 0) + (memo.sgstAmount ?? 0), equals(5.0));
    expect(memo.total, equals(405.0));
  });

  testWidgets('a memo with no dispensed medicines is untaxed', (tester) async {
    await seed(gstin: '29ABCDE1234F1Z5');

    await pumpDialog(tester);
    await tapText(tester, 'Save & Issue Memo');

    final memo = (await db.select(db.cashMemos).get()).single;
    // Consultation alone is exempt, so a registered clinic still charges
    // no GST when nothing was dispensed.
    expect(memo.cgstAmount, equals(0.0));
    expect(memo.sgstAmount, equals(0.0));
    expect(memo.total, equals(300.0));
  });

  testWidgets('clearing dispensed remedies removes the tax from the total', (
    tester,
  ) async {
    await seed(gstin: '29ABCDE1234F1Z5');
    await inventory.addMedicine(
      name: 'Arnica Montana',
      category: 'Dilution',
      potency: '200C',
      currentStock: 10.0,
      unit: 'Bottles',
      sellingPrice: 200.0,
      gstRate: 12.0,
    );

    await pumpDialog(tester);
    await dispense(tester, 'Arnica Montana');
    expect(find.text('CGST @ 6%'), findsOneWidget);

    await tapText(tester, 'Clear');
    expect(find.textContaining('CGST'), findsNothing);

    await tapText(tester, 'Save & Issue Memo');

    final memo = (await db.select(db.cashMemos).get()).single;
    expect(memo.cgstAmount, equals(0.0));
    expect(memo.total, equals(300.0));
  });
}
