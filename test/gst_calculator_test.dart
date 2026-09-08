import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/widgets/dispense_medicine_picker_sheet.dart';
import 'package:clinic_pilot/features/cashmemo/services/gst_calculator.dart';
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

  Future<Medicine> medicine({
    required String name,
    double? gstRate,
    double sellingPrice = 100.0,
  }) async {
    final id = await inventory.addMedicine(
      name: name,
      category: 'Dilution',
      currentStock: 50.0,
      unit: 'Bottles',
      sellingPrice: sellingPrice,
      gstRate: gstRate,
    );
    return (db.select(db.medicines)..where((t) => t.id.equals(id))).getSingle();
  }

  DispensedMedicineItem item(Medicine med, {double qty = 1.0}) =>
      DispensedMedicineItem(
        medicine: med,
        quantity: qty,
        unitPrice: med.sellingPrice ?? 0.0,
      );

  group('GstCalculator.forDispensedItems', () {
    test('no dispensed items means no tax', () {
      final breakdown = GstCalculator.forDispensedItems(
        const [],
        defaultRate: 12.0,
      );
      expect(breakdown.isEmpty, isTrue);
      expect(breakdown.totalTax, equals(0.0));
    });

    test('splits a single slab evenly into CGST and SGST', () async {
      final med = await medicine(name: 'Arnica', gstRate: 12.0);
      final breakdown = GstCalculator.forDispensedItems([
        item(med),
      ], defaultRate: 5.0);

      expect(breakdown.lines.length, equals(1));
      expect(breakdown.taxableValue, equals(100.0));
      // 12% of 100 = 12, split 6 + 6.
      expect(breakdown.cgstAmount, equals(6.0));
      expect(breakdown.sgstAmount, equals(6.0));
      expect(breakdown.totalTax, equals(12.0));
    });

    test(
      'falls back to the clinic default when the item has no rate',
      () async {
        final med = await medicine(name: 'Belladonna');
        final breakdown = GstCalculator.forDispensedItems([
          item(med),
        ], defaultRate: 5.0);

        expect(breakdown.lines.single.rate, equals(5.0));
        expect(breakdown.totalTax, equals(5.0));
      },
    );

    test('an item rate overrides the clinic default', () async {
      final med = await medicine(name: 'Nux Vomica', gstRate: 18.0);
      final breakdown = GstCalculator.forDispensedItems([
        item(med),
      ], defaultRate: 5.0);

      expect(breakdown.lines.single.rate, equals(18.0));
      expect(breakdown.totalTax, equals(18.0));
    });

    test('groups items into one line per slab, sorted by rate', () async {
      final a = await medicine(name: 'A', gstRate: 12.0, sellingPrice: 100);
      final b = await medicine(name: 'B', gstRate: 5.0, sellingPrice: 200);
      final c = await medicine(name: 'C', gstRate: 12.0, sellingPrice: 50);

      final breakdown = GstCalculator.forDispensedItems([
        item(a),
        item(b),
        item(c),
      ], defaultRate: 12.0);

      expect(breakdown.lines.length, equals(2));
      expect(breakdown.lines[0].rate, equals(5.0));
      expect(breakdown.lines[0].taxableValue, equals(200.0));
      // The two 12% items are merged into one slab line: 100 + 50.
      expect(breakdown.lines[1].rate, equals(12.0));
      expect(breakdown.lines[1].taxableValue, equals(150.0));
      expect(breakdown.lines[1].totalTax, equals(18.0));
    });

    test('quantity multiplies the taxable value', () async {
      final med = await medicine(name: 'Rhus Tox', gstRate: 12.0);
      final breakdown = GstCalculator.forDispensedItems([
        item(med, qty: 3),
      ], defaultRate: 12.0);

      expect(breakdown.taxableValue, equals(300.0));
      expect(breakdown.totalTax, equals(36.0));
    });

    test('a zero-rated item contributes no tax and no slab line', () async {
      final med = await medicine(name: 'Exempt Item', gstRate: 0.0);
      final breakdown = GstCalculator.forDispensedItems([
        item(med),
      ], defaultRate: 12.0);

      expect(breakdown.isEmpty, isTrue);
      expect(breakdown.lines, isEmpty);
    });

    test(
      'a zero clinic default zero-rates items that have no own rate',
      () async {
        final med = await medicine(name: 'Unrated');
        final breakdown = GstCalculator.forDispensedItems([
          item(med),
        ], defaultRate: 0.0);

        expect(breakdown.isEmpty, isTrue);
      },
    );

    test('CGST and SGST always re-add to the slab tax on odd paise', () async {
      // 5% of 66.65 = 3.3325 -> 3.33, which cannot split evenly in paise.
      final med = await medicine(
        name: 'Odd Paise',
        gstRate: 5.0,
        sellingPrice: 66.65,
      );
      final breakdown = GstCalculator.forDispensedItems([
        item(med),
      ], defaultRate: 5.0);

      final line = breakdown.lines.single;
      expect(line.cgst + line.sgst, equals(line.totalTax));
      expect(breakdown.totalTax, equals(3.33));
      // The extra paise goes to CGST rather than being lost.
      expect(line.cgst, equals(1.67));
      expect(line.sgst, equals(1.66));
    });

    test('rounds to paise rather than leaving binary fraction tails', () async {
      final med = await medicine(
        name: 'Fractional',
        gstRate: 12.0,
        sellingPrice: 10.10,
      );
      final breakdown = GstCalculator.forDispensedItems([
        item(med, qty: 3),
      ], defaultRate: 12.0);

      expect(breakdown.taxableValue, equals(30.30));
      expect(breakdown.totalTax, equals(3.64));
    });
  });

  group('GstCalculator.isGstRegistered', () {
    Future<Clinic> clinic({String? gstin}) async {
      await db
          .into(db.clinics)
          .insert(
            ClinicsCompanion.insert(
              id: 'c1',
              name: 'Test Clinic',
              gstin: Value(gstin),
            ),
          );
      return (db.select(db.clinics)
        ..where((t) => t.id.equals('c1'))).getSingle();
    }

    test('a null clinic is not registered', () {
      expect(GstCalculator.isGstRegistered(null), isFalse);
    });

    test('no GSTIN means not registered', () async {
      expect(GstCalculator.isGstRegistered(await clinic()), isFalse);
    });

    test('a blank or whitespace GSTIN does not count as registered', () async {
      expect(
        GstCalculator.isGstRegistered(await clinic(gstin: '   ')),
        isFalse,
      );
    });

    test('a real GSTIN counts as registered', () async {
      expect(
        GstCalculator.isGstRegistered(await clinic(gstin: '29ABCDE1234F1Z5')),
        isTrue,
      );
    });
  });
}
