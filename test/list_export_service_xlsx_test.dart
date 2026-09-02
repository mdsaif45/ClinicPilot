import 'package:clinic_pilot/core/services/list_export_service.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';

class _Row {
  final String name;
  final double amount;

  const _Row(this.name, this.amount);
}

/// XLSX's underlying number storage does not distinguish int from double -
/// a whole-number double like 100.0 round-trips through decodeBytes as
/// IntCellValue(100), since the written string has no fractional part. A
/// spreadsheet reads both as the same number, so tests compare the numeric
/// value through this rather than pinning to whichever CellValue subtype
/// happened to come back.
num? _numericValue(xlsx.CellValue? value) => switch (value) {
  xlsx.IntCellValue v => v.value,
  xlsx.DoubleCellValue v => v.value,
  _ => null,
};

void main() {
  final columns = [
    ExportColumn<_Row>('Name', (r) => r.name),
    ExportColumn<_Row>('Amount', (r) => r.amount),
  ];

  group('ListExportService.buildXlsx', () {
    test('decodes back to the header, every row, and the sheet name', () {
      final bytes = ListExportService.buildXlsx(
        [const _Row('Alice', 100), const _Row('Bob', 200.5)],
        columns,
        sheetName: 'patients',
      );

      final book = xlsx.Excel.decodeBytes(bytes);
      expect(book.tables.keys, contains('patients'));

      final rows = book.tables['patients']!.rows;
      expect(rows.length, 3); // header + 2 data rows

      expect(rows[0][0]!.value, xlsx.TextCellValue('Name'));
      expect(rows[0][1]!.value, xlsx.TextCellValue('Amount'));

      expect(rows[1][0]!.value, xlsx.TextCellValue('Alice'));
      expect(_numericValue(rows[1][1]!.value), 100);

      expect(rows[2][0]!.value, xlsx.TextCellValue('Bob'));
      expect(_numericValue(rows[2][1]!.value), 200.5);
    });

    test('the header row is bold', () {
      final bytes = ListExportService.buildXlsx(
        [const _Row('Alice', 100)],
        columns,
        sheetName: 'patients',
      );
      final rows = xlsx.Excel.decodeBytes(bytes).tables['patients']!.rows;

      expect(rows[0][0]!.cellStyle?.isBold, isTrue);
      // A data row must not inherit the header's styling.
      expect(rows[1][0]!.cellStyle?.isBold ?? false, isFalse);
    });

    test('a totals row is appended, bold, and sums correctly', () {
      final totals = ExportTotals<_Row>((rows) {
        final sum = rows.fold<double>(0, (a, r) => a + r.amount);
        return ['TOTAL', sum];
      });

      final bytes = ListExportService.buildXlsx(
        [const _Row('Alice', 100), const _Row('Bob', 200)],
        columns,
        totals: totals,
        sheetName: 'patients',
      );
      final rows = xlsx.Excel.decodeBytes(bytes).tables['patients']!.rows;

      expect(rows.length, 4); // header + 2 rows + totals
      expect(rows[3][0]!.value, xlsx.TextCellValue('TOTAL'));
      expect(_numericValue(rows[3][1]!.value), 300);
      expect(rows[3][0]!.cellStyle?.isBold, isTrue);
    });

    test('an empty row set produces just the header, no totals row', () {
      final totals = ExportTotals<_Row>((rows) => ['TOTAL', 0]);
      final bytes = ListExportService.buildXlsx(
        <_Row>[],
        columns,
        totals: totals,
        sheetName: 'patients',
      );
      final rows = xlsx.Excel.decodeBytes(bytes).tables['patients']!.rows;

      expect(rows.length, 1);
    });
  });

  group('ListExportService.buildKeyValueXlsx', () {
    test('writes a title row, a header row, and every metric', () {
      final bytes = ListExportService.buildKeyValueXlsx(
        [
          const MapEntry('New Patients', 12),
          const MapEntry('Total Revenue', 45000.0),
        ],
        title: 'Growth summary: 2026-08-01 to 2026-08-31',
        sheetName: 'Growth',
      );

      final rows = xlsx.Excel.decodeBytes(bytes).tables['Growth']!.rows;

      expect(
        rows[0][0]!.value,
        xlsx.TextCellValue('Growth summary: 2026-08-01 to 2026-08-31'),
      );
      expect(rows[0][0]!.cellStyle?.isBold, isTrue);

      expect(rows[1][0]!.value, xlsx.TextCellValue('Metric'));
      expect(rows[1][1]!.value, xlsx.TextCellValue('Value'));

      expect(rows[2][0]!.value, xlsx.TextCellValue('New Patients'));
      expect(_numericValue(rows[2][1]!.value), 12);

      expect(rows[3][0]!.value, xlsx.TextCellValue('Total Revenue'));
      expect(_numericValue(rows[3][1]!.value), 45000);
    });
  });
}
