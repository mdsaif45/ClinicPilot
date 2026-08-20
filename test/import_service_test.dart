import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/import_service.dart';
import 'package:clinic_pilot/core/services/import_template_service.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_clinics.dart';

/// Builds a workbook matching the template shape by hand, standing in for
/// what a doctor would produce by filling the downloaded template - this
/// keeps the tests independent of ImportTemplateService's own example-row
/// styling while still exercising the exact header contract the two agree
/// on via ImportTemplateSchema.
xlsx.Excel _buildWorkbook({
  required List<List<Object?>> patientRows,
  List<List<Object?>> visitRows = const [],
  List<List<Object?>> memoRows = const [],
  List<List<Object?>> expenseRows = const [],
}) {
  final book = xlsx.Excel.createExcel();
  book.rename('Sheet1', ImportTemplateSchema.patientsSheet);

  void writeSheet(
      String name, List<String> headers, List<List<Object?>> rows) {
    final sheet = book[name];
    sheet.appendRow(headers.map((h) => xlsx.TextCellValue(h)).toList());
    for (final row in rows) {
      sheet.appendRow(row.map((c) {
        if (c == null) return null;
        if (c is num) return xlsx.DoubleCellValue(c.toDouble());
        return xlsx.TextCellValue(c.toString());
      }).toList());
    }
  }

  writeSheet(ImportTemplateSchema.patientsSheet,
      ImportTemplateSchema.patientsHeaders, patientRows);
  writeSheet(ImportTemplateSchema.visitsSheet,
      ImportTemplateSchema.visitsHeaders, visitRows);
  writeSheet(ImportTemplateSchema.cashMemosSheet,
      ImportTemplateSchema.cashMemosHeaders, memoRows);
  writeSheet(ImportTemplateSchema.expensesSheet,
      ImportTemplateSchema.expensesHeaders, expenseRows);

  return book;
}

void main() {
  late AppDatabase db;
  late ImportService service;
  const clinicNames = {'Old Clinic': 'clinic_old', 'New Clinic': 'clinic_new'};

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTestClinics(db);
    service = ImportService(db);
  });

  tearDown(() async => db.close());

  group('structure verification', () {
    test('rejects a workbook missing a required sheet', () async {
      final book = xlsx.Excel.createExcel();
      final bytes = book.encode()!;

      final preview = await ImportService.validate(bytes, clinicNames);
      expect(preview.hasImportableData, isFalse);
      expect(preview.errors, isNotEmpty);
      expect(preview.errors.first.reason, contains('Patients'));
    });

    test('rejects a workbook whose headers were edited', () async {
      final book = _buildWorkbook(patientRows: []);
      book[ImportTemplateSchema.patientsSheet]
          .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = xlsx.TextCellValue('Renamed Column');
      final bytes = book.encode()!;

      final preview = await ImportService.validate(bytes, clinicNames);
      expect(preview.errors.first.reason, contains('do not match'));
    });
  });

  group('Patients validation', () {
    test('a fully valid row imports cleanly', () async {
      final book = _buildWorkbook(patientRows: [
        [
          '14',
          'Old Clinic',
          'Asha Rao',
          '9800000001',
          '',
          34,
          'Female',
          'Kharagpur',
          'Migraine',
          'Walk-in'
        ],
      ]);
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.patientCount, 1);
      expect(preview.errors, isEmpty);
    });

    test('skips the example row', () async {
      final book = _buildWorkbook(patientRows: [
        [
          'DELETE-THIS-EXAMPLE-1',
          'Old Clinic',
          'Example',
          '1',
          '',
          30,
          'Male',
          '',
          'X',
          ''
        ],
        [
          '14',
          'Old Clinic',
          'Asha Rao',
          '9800000001',
          '',
          34,
          'Female',
          '',
          'Migraine',
          ''
        ],
      ]);
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.patientCount, 1);
      expect(preview.errors, isEmpty);
    });

    test('reports a missing required field with a row number', () async {
      final book = _buildWorkbook(patientRows: [
        [
          '14',
          'Old Clinic',
          '',
          '9800000001',
          '',
          34,
          'Female',
          '',
          'Migraine',
          ''
        ],
      ]);
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.patientCount, 0);
      expect(preview.errors, hasLength(1));
      expect(preview.errors.first.rowNumber, 2); // header is row 1
      expect(preview.errors.first.reason, contains('Name'));
    });

    test('reports an unknown clinic by name, not silently dropping the row',
        () async {
      final book = _buildWorkbook(patientRows: [
        ['14', 'Nonexistent Clinic', 'Asha', '1', '', 30, 'Male', '', 'X', ''],
      ]);
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.errors.first.reason, contains('Nonexistent Clinic'));
      expect(preview.errors.first.reason, contains('not found'));
    });

    test('rejects an invalid Gender value', () async {
      final book = _buildWorkbook(patientRows: [
        ['14', 'Old Clinic', 'Asha', '1', '', 30, 'Unspecified', '', 'X', ''],
      ]);
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);
      expect(preview.errors.first.reason, contains('Gender'));
    });

    test('the same serial is valid at two different clinics', () async {
      final book = _buildWorkbook(patientRows: [
        ['14', 'Old Clinic', 'Asha', '1', '', 30, 'Male', '', 'X', ''],
        ['14', 'New Clinic', 'Bilal', '2', '', 40, 'Male', '', 'Y', ''],
      ]);
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.patientCount, 2);
      expect(preview.errors, isEmpty);
    });

    test('the same serial twice at the SAME clinic in one sheet is rejected',
        () async {
      final book = _buildWorkbook(patientRows: [
        ['14', 'Old Clinic', 'Asha', '1', '', 30, 'Male', '', 'X', ''],
        ['14', 'Old Clinic', 'Bilal', '2', '', 40, 'Male', '', 'Y', ''],
      ]);
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.patientCount, 1);
      expect(preview.errors, hasLength(1));
      expect(preview.errors.first.reason, contains('used twice'));
    });
  });

  group('Visits and Cash Memos linking', () {
    test('a visit links to its patient by Serial No. + Clinic', () async {
      final book = _buildWorkbook(
        patientRows: [
          [
            '14',
            'Old Clinic',
            'Asha',
            '1',
            '',
            30,
            'Female',
            '',
            'Migraine',
            ''
          ],
        ],
        visitRows: [
          [
            '14',
            'Old Clinic',
            '2026-03-14',
            'new',
            'clinic',
            'Migraine',
            'improved'
          ],
        ],
      );
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.patientCount, 1);
      expect(preview.visitCount, 1);
      expect(preview.errors, isEmpty);
    });

    test('a visit referencing a serial with no matching patient row fails',
        () async {
      final book = _buildWorkbook(
        patientRows: [],
        visitRows: [
          ['99', 'Old Clinic', '2026-03-14', 'new', 'clinic', 'Migraine', ''],
        ],
      );
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.visitCount, 0);
      expect(
        preview.errors.any((e) =>
            e.sheet == ImportTemplateSchema.visitsSheet &&
            e.reason.contains('No valid patient')),
        isTrue,
      );
    });

    test(
        'a visit referencing a patient row that itself failed validation '
        'fails too, with a reason pointing at that', () async {
      final book = _buildWorkbook(
        // This patient row is invalid (bad gender), so it never enters the
        // lookup pass 2 checks against.
        patientRows: [
          [
            '14',
            'Old Clinic',
            'Asha',
            '1',
            '',
            30,
            'NotAGender',
            '',
            'X',
            ''
          ],
        ],
        visitRows: [
          ['14', 'Old Clinic', '2026-03-14', 'new', 'clinic', 'Migraine', ''],
        ],
      );
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.patientCount, 0);
      expect(preview.visitCount, 0);
      expect(
        preview.errors
            .any((e) => e.sheet == ImportTemplateSchema.visitsSheet),
        isTrue,
        reason: 'the visit should be reported too, not silently dropped '
            'because its patient failed separately',
      );
    });

    test('a cash memo links to its patient the same way', () async {
      final book = _buildWorkbook(
        patientRows: [
          [
            '14',
            'Old Clinic',
            'Asha',
            '1',
            '',
            30,
            'Female',
            '',
            'Migraine',
            ''
          ],
        ],
        memoRows: [
          ['14', 'Old Clinic', '2026-03-14', 300, 100, 0, 0, 400, 'Cash'],
        ],
      );
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.memoCount, 1);
      expect(preview.errors, isEmpty);
    });
  });

  group('Expenses', () {
    test('an expense needs only a clinic, not a patient link', () async {
      final book = _buildWorkbook(
        patientRows: [],
        expenseRows: [
          ['Old Clinic', '2026-03-01', 'Rent', '', 3000, 'Cash'],
        ],
      );
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);

      expect(preview.expenseCount, 1);
      expect(preview.errors, isEmpty);
    });

    test('rejects an unrecognised category', () async {
      final book = _buildWorkbook(
        patientRows: [],
        expenseRows: [
          ['Old Clinic', '2026-03-01', 'Golf', '', 3000, 'Cash'],
        ],
      );
      final preview =
          await ImportService.validate(book.encode()!, clinicNames);
      expect(preview.errors.first.reason, contains('Category'));
    });
  });

  group('commit', () {
    test(
        'writes every valid row, links visits and memos to the right '
        'patient id, and skips the invalid one', () async {
      final book = _buildWorkbook(
        patientRows: [
          [
            '14',
            'Old Clinic',
            'Asha Rao',
            '9800000001',
            '',
            34,
            'Female',
            '',
            'Migraine',
            ''
          ],
          ['bad-row', 'Old Clinic', '', '', '', 0, 'X', '', '', ''],
        ],
        visitRows: [
          [
            '14',
            'Old Clinic',
            '2026-03-14',
            'new',
            'clinic',
            'Migraine',
            'improved'
          ],
        ],
        memoRows: [
          ['14', 'Old Clinic', '2026-03-14', 300, 100, 0, 0, 400, 'Cash'],
        ],
        expenseRows: [
          ['Old Clinic', '2026-03-01', 'Rent', '', 3000, 'Cash'],
        ],
      );

      final result = await service.commit(book.encode()!, clinicNames);

      expect(result.patientCount, 1);
      expect(result.visitCount, 1);
      expect(result.memoCount, 1);
      expect(result.expenseCount, 1);
      expect(result.errors, hasLength(1),
          reason: 'the second patient row is invalid and must be reported');

      final patients = await db.select(db.patients).get();
      expect(patients, hasLength(1));
      final patient = patients.single;
      expect(patient.serialNo, '14');
      expect(patient.name, 'Asha Rao');

      final visits = await db.select(db.visits).get();
      expect(visits, hasLength(1));
      expect(visits.single.patientId, patient.id,
          reason: 'the visit must attach to the patient just created by '
              'this same import, not some other row');

      final memos = await db.select(db.cashMemos).get();
      expect(memos, hasLength(1));
      expect(memos.single.patientId, patient.id);
      expect(memos.single.total, 400); // 300 + 100 + 0 - 0

      final expenses = await db.select(db.expenses).get();
      expect(expenses, hasLength(1));
      expect(expenses.single.amount, 3000);
    });

    test('writes nothing when there is not a single valid patient row',
        () async {
      final book = _buildWorkbook(patientRows: [
        ['', '', '', '', '', 0, '', '', '', ''],
      ]);

      final result = await service.commit(book.encode()!, clinicNames);

      expect(result.patientCount, 0);
      final patients = await db.select(db.patients).get();
      expect(patients, isEmpty);
    });

    test(
        'two patients at different clinics with the same serial both '
        'import, keeping their visits distinct', () async {
      final book = _buildWorkbook(
        patientRows: [
          ['14', 'Old Clinic', 'Asha', '1', '', 30, 'Female', '', 'X', ''],
          ['14', 'New Clinic', 'Bilal', '2', '', 40, 'Male', '', 'Y', ''],
        ],
        visitRows: [
          ['14', 'Old Clinic', '2026-03-14', 'new', 'clinic', 'X', ''],
          ['14', 'New Clinic', '2026-03-15', 'new', 'clinic', 'Y', ''],
        ],
      );

      final result = await service.commit(book.encode()!, clinicNames);
      expect(result.patientCount, 2);
      expect(result.visitCount, 2);

      final visits = await db.select(db.visits).get();
      final patients = await db.select(db.patients).get();
      final ashaId = patients.firstWhere((p) => p.name == 'Asha').id;
      final bilalId = patients.firstWhere((p) => p.name == 'Bilal').id;

      expect(visits.firstWhere((v) => v.disease == 'X').patientId, ashaId);
      expect(visits.firstWhere((v) => v.disease == 'Y').patientId, bilalId);
    });
  });
}
