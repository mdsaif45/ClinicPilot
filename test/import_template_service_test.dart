import 'package:clinic_pilot/core/services/import_template_service.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';

/// The template is the entire safety net for import: nothing is accepted
/// unless it started from this exact shape. These pin that the generated
/// workbook actually has the sheets and headers the importer will expect
/// back, so the two can never silently drift apart.
void main() {
  late xlsx.Excel book;

  setUp(() {
    final bytes = ImportTemplateService.build();
    book = xlsx.Excel.decodeBytes(bytes);
  });

  test('has all five expected sheets', () {
    expect(book.tables.keys.toSet(), {
      ImportTemplateSchema.patientsSheet,
      ImportTemplateSchema.visitsSheet,
      ImportTemplateSchema.cashMemosSheet,
      ImportTemplateSchema.expensesSheet,
      ImportTemplateSchema.readMeSheet,
    });
  });

  void expectHeaderRow(String sheetName, List<String> expected) {
    final rows = book.tables[sheetName]!.rows;
    final actual =
        rows[0]
            .map((cell) => (cell?.value as xlsx.TextCellValue?)?.value.text)
            .toList();
    expect(actual, expected);
  }

  test(
    'Patients sheet header matches ImportTemplateSchema.patientsHeaders',
    () {
      expectHeaderRow(
        ImportTemplateSchema.patientsSheet,
        ImportTemplateSchema.patientsHeaders,
      );
    },
  );

  test('Visits sheet header matches ImportTemplateSchema.visitsHeaders', () {
    expectHeaderRow(
      ImportTemplateSchema.visitsSheet,
      ImportTemplateSchema.visitsHeaders,
    );
  });

  test(
    'Cash Memos sheet header matches ImportTemplateSchema.cashMemosHeaders',
    () {
      expectHeaderRow(
        ImportTemplateSchema.cashMemosSheet,
        ImportTemplateSchema.cashMemosHeaders,
      );
    },
  );

  test(
    'Expenses sheet header matches ImportTemplateSchema.expensesHeaders',
    () {
      expectHeaderRow(
        ImportTemplateSchema.expensesSheet,
        ImportTemplateSchema.expensesHeaders,
      );
    },
  );

  test('every data sheet carries an example row marked for deletion', () {
    for (final sheetName in [
      ImportTemplateSchema.patientsSheet,
      ImportTemplateSchema.visitsSheet,
      ImportTemplateSchema.cashMemosSheet,
    ]) {
      final rows = book.tables[sheetName]!.rows;
      expect(
        rows.length,
        greaterThanOrEqualTo(2),
        reason: '$sheetName should have a header plus an example row',
      );
      final firstCell =
          (rows[1][0]?.value as xlsx.TextCellValue?)?.value.text ?? '';
      expect(firstCell, contains('DELETE-THIS-EXAMPLE'));
    }
  });

  test(
    'the Read Me sheet is non-empty and mentions every accepted value set',
    () {
      final rows = book.tables[ImportTemplateSchema.readMeSheet]!.rows;
      final text = rows
          .map(
            (r) =>
                (r.isEmpty
                    ? ''
                    : (r[0]?.value as xlsx.TextCellValue?)?.value.text ?? ''),
          )
          .join('\n');

      expect(text, contains('Male'));
      expect(text, contains('Cash'));
      expect(text, contains('Rent'));
      expect(text, contains('does not create clinics'));
    },
  );
}
