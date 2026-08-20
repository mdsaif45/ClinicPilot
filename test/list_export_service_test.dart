import 'package:clinic_pilot/core/services/list_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  final String name;
  final double amount;
  final String? note;

  const _Row(this.name, this.amount, [this.note]);
}

void main() {
  group('ListExportService.buildCsv', () {
    final columns = [
      ExportColumn<_Row>('Name', (r) => r.name),
      ExportColumn<_Row>('Amount', (r) => r.amount),
      ExportColumn<_Row>('Note', (r) => r.note),
    ];

    test('writes a header row and one row per record', () {
      final csv = ListExportService.buildCsv(
        [const _Row('Alice', 100), const _Row('Bob', 200)],
        columns,
      );
      final lines = csv.trim().split('\n');

      expect(lines[0], 'Name,Amount,Note');
      expect(lines[1], 'Alice,100.0,');
      expect(lines[2], 'Bob,200.0,');
    });

    test('quotes a value containing a comma', () {
      final csv = ListExportService.buildCsv(
        [const _Row('Doe, John', 50)],
        columns,
      );
      expect(csv, contains('"Doe, John"'));
    });

    test('quotes and escapes a value containing a double quote', () {
      final csv = ListExportService.buildCsv(
        [const _Row('Say "hi"', 50)],
        columns,
      );
      expect(csv, contains('"Say ""hi"""'));
    });

    test('quotes a value containing a newline', () {
      final csv = ListExportService.buildCsv(
        [const _Row('Multi\nline', 50)],
        columns,
      );
      expect(csv, contains('"Multi\nline"'));
    });

    test('null values print as an empty cell, not the string "null"', () {
      final csv = ListExportService.buildCsv(
        [const _Row('No note', 50, null)],
        columns,
      );
      expect(csv, isNot(contains('null')));
      expect(csv.trim().split('\n')[1], 'No note,50.0,');
    });

    test('an empty row set produces just the header', () {
      final csv = ListExportService.buildCsv(<_Row>[], columns);
      expect(csv.trim(), 'Name,Amount,Note');
    });

    test('a totals row is appended when rows are non-empty', () {
      final totals = ExportTotals<_Row>((rows) {
        final sum = rows.fold<double>(0, (a, r) => a + r.amount);
        return ['TOTAL', sum, null];
      });

      final csv = ListExportService.buildCsv(
        [const _Row('Alice', 100), const _Row('Bob', 200)],
        columns,
        totals: totals,
      );
      final lines = csv.trim().split('\n');

      expect(lines.length, 4); // header + 2 rows + totals
      expect(lines.last, 'TOTAL,300.0,');
    });

    test('no totals row is appended when there are no rows to total',
        () {
      final totals = ExportTotals<_Row>((rows) => ['TOTAL', 0, null]);

      final csv = ListExportService.buildCsv(<_Row>[], columns, totals: totals);
      // Just the header - a totals row summing nothing would misleadingly
      // read as a real zero rather than "there was nothing to add up".
      expect(csv.trim().split('\n').length, 1);
    });
  });

  group('ListExportService.buildKeyValueCsv', () {
    test('writes metric/value pairs with a header row', () {
      final csv = ListExportService.buildKeyValueCsv([
        const MapEntry('New Patients', 12),
        const MapEntry('Total Revenue', 45000.0),
      ]);
      final lines = csv.trim().split('\n');

      expect(lines[0], 'Metric,Value');
      expect(lines[1], 'New Patients,12');
      expect(lines[2], 'Total Revenue,45000.0');
    });

    test('an optional title is written above the header, with a blank line',
        () {
      final csv = ListExportService.buildKeyValueCsv(
        title: 'Growth summary: 2026-08-01 to 2026-08-31',
        [const MapEntry('New Patients', 12)],
      );
      final lines = csv.trim().split('\n');

      expect(lines[0], 'Growth summary: 2026-08-01 to 2026-08-31');
      expect(lines[1], '');
      expect(lines[2], 'Metric,Value');
    });
  });

  group('ListExportService.suggestedFileName', () {
    test('embeds the screen slug and a timestamp', () {
      final name = ListExportService.suggestedFileName(
        'patients',
        DateTime(2026, 3, 5, 14, 30),
      );
      expect(name, 'clinicpilot-patients-20260305-1430.csv');
    });
  });
}
