import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/features/inventory/providers/inventory_provider.dart';
import 'package:clinic_pilot/features/inventory/services/barcode_matcher.dart';

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

  Future<Medicine> medicine({required String name, String? barcode}) async {
    final id = await inventory.addMedicine(
      name: name,
      category: 'Dilution',
      currentStock: 10.0,
      unit: 'Bottles',
      sellingPrice: 100.0,
      barcode: barcode,
    );
    return (db.select(db.medicines)..where((t) => t.id.equals(id))).getSingle();
  }

  group('BarcodeMatcher.normalize', () {
    test('trims and upper-cases', () {
      expect(BarcodeMatcher.normalize('  abc123 '), equals('ABC123'));
    });

    test('strips the spacing and hyphens printed on a pack', () {
      expect(
        BarcodeMatcher.normalize('890 1234-567890'),
        equals('8901234567890'),
      );
    });

    test('strips the carriage return a wedge scanner appends', () {
      expect(
        BarcodeMatcher.normalize('8901234567890\r\n'),
        equals('8901234567890'),
      );
    });

    test('an empty or whitespace-only scan normalises to empty', () {
      expect(BarcodeMatcher.normalize('   '), isEmpty);
    });
  });

  group('BarcodeMatcher.isValidEan13', () {
    test('accepts a correct check digit', () {
      expect(BarcodeMatcher.isValidEan13('8901234567890'), isTrue);
    });

    test('rejects a wrong check digit', () {
      // Correct check digit for 890123456789 is 0, not 4.
      expect(BarcodeMatcher.isValidEan13('8901234567894'), isFalse);
    });

    test('rejects a truncated or misread scan', () {
      expect(BarcodeMatcher.isValidEan13('890123456789'), isFalse);
      expect(BarcodeMatcher.isValidEan13(''), isFalse);
    });

    test('rejects non-numeric input of the right length', () {
      expect(BarcodeMatcher.isValidEan13('89012345678AB'), isFalse);
    });
  });

  group('BarcodeMatcher.lookup', () {
    test('an empty scan is unknown, not a match on blank barcodes', () async {
      final med = await medicine(name: 'Arnica');
      final result = BarcodeMatcher.lookup(rawCode: '  ', inventory: [med]);

      expect(result.status, equals(BarcodeLookupStatus.unknown));
      expect(result.single, isNull);
    });

    test('matches one stocked item exactly', () async {
      final a = await medicine(name: 'Arnica', barcode: '8901234567890');
      final b = await medicine(name: 'Rhus Tox', barcode: '8909999999994');

      final result = BarcodeMatcher.lookup(
        rawCode: '8901234567890',
        inventory: [a, b],
      );

      expect(result.status, equals(BarcodeLookupStatus.matched));
      expect(result.single!.id, equals(a.id));
    });

    test('matches despite scanner spacing differences', () async {
      final med = await medicine(name: 'Arnica', barcode: '8901234567890');
      final result = BarcodeMatcher.lookup(
        rawCode: '890 1234 567890\r',
        inventory: [med],
      );

      expect(result.status, equals(BarcodeLookupStatus.matched));
    });

    test('an uncatalogued pack is unknown', () async {
      final med = await medicine(name: 'Arnica', barcode: '8901234567890');
      final result = BarcodeMatcher.lookup(
        rawCode: '1111111111116',
        inventory: [med],
      );

      expect(result.status, equals(BarcodeLookupStatus.unknown));
      expect(result.matches, isEmpty);
      expect(result.single, isNull);
    });

    test('items with no barcode never match a scan', () async {
      final med = await medicine(name: 'Decanted Dilution');
      final result = BarcodeMatcher.lookup(
        rawCode: '8901234567890',
        inventory: [med],
      );

      expect(result.status, equals(BarcodeLookupStatus.unknown));
    });

    test('a duplicated barcode is ambiguous, never auto-picked', () async {
      final a = await medicine(name: 'Arnica 30C', barcode: '8901234567890');
      final b = await medicine(name: 'Arnica 200C', barcode: '8901234567890');

      final result = BarcodeMatcher.lookup(
        rawCode: '8901234567890',
        inventory: [a, b],
      );

      expect(result.status, equals(BarcodeLookupStatus.ambiguous));
      expect(result.matches.length, equals(2));
      // Dispensing the wrong potency is a clinical error, so the scan
      // deliberately refuses to choose.
      expect(result.single, isNull);
    });

    test('a soft-deleted item is excluded from scanning', () async {
      final med = await medicine(name: 'Arnica', barcode: '8901234567890');
      await inventory.deleteMedicine(med.id);
      final deleted =
          await (db.select(db.medicines)
            ..where((t) => t.id.equals(med.id))).getSingle();

      final result = BarcodeMatcher.lookup(
        rawCode: '8901234567890',
        inventory: [deleted],
      );

      expect(result.status, equals(BarcodeLookupStatus.unknown));
    });

    test('the returned code is the normalised form', () async {
      final med = await medicine(name: 'Arnica', barcode: '8901234567890');
      final result = BarcodeMatcher.lookup(
        rawCode: ' 8901234567890 \n',
        inventory: [med],
      );

      expect(result.code, equals('8901234567890'));
    });
  });
}
