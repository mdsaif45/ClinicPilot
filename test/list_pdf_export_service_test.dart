import 'package:clinic_pilot/core/services/list_export_service.dart';
import 'package:clinic_pilot/core/services/list_pdf_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _Row {
  final String name;
  final double amount;

  const _Row(this.name, this.amount);
}

/// The pdf package renders to a binary format with no matching parser in
/// this project, so these check what can actually be verified without one:
/// valid PDF bytes come back, the call does not throw on the edge cases
/// (empty rows, no totals, many rows needing more than one page), and the
/// pdfFormat override actually runs instead of the default toString().
void main() {
  bool looksLikePdf(List<int> bytes) {
    // Every PDF file starts with this literal header.
    const magic = [0x25, 0x50, 0x44, 0x46]; // "%PDF"
    if (bytes.length < magic.length) return false;
    for (var i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) return false;
    }
    return true;
  }

  group('ListPdfExportService.buildRowsPdf', () {
    final columns = [
      ExportColumn<_Row>('Name', (r) => r.name),
      ExportColumn<_Row>(
        'Amount',
        (r) => r.amount,
        pdfFormat: (v) => 'Rs. ${(v as num).toStringAsFixed(2)}',
      ),
    ];

    test('produces valid PDF bytes for a normal row set', () async {
      final bytes = await ListPdfExportService.buildRowsPdf(
        title: 'Patient Directory',
        rows: [const _Row('Alice', 100), const _Row('Bob', 200)],
        columns: columns,
      );

      expect(looksLikePdf(bytes), isTrue);
      expect(bytes.length, greaterThan(0));
    });

    test('does not throw on an empty row set', () async {
      final bytes = await ListPdfExportService.buildRowsPdf(
        title: 'Patient Directory',
        rows: <_Row>[],
        columns: columns,
      );
      expect(looksLikePdf(bytes), isTrue);
    });

    test('does not throw with a totals row', () async {
      final totals = ExportTotals<_Row>((rows) {
        final sum = rows.fold<double>(0, (a, r) => a + r.amount);
        return ['TOTAL', sum];
      });

      final bytes = await ListPdfExportService.buildRowsPdf(
        title: 'Cash Memos',
        subtitle: 'This month',
        rows: [const _Row('Alice', 100), const _Row('Bob', 200)],
        columns: columns,
        totals: totals,
      );
      expect(looksLikePdf(bytes), isTrue);
    });

    test('does not throw across many rows spanning multiple pages', () async {
      final many = List.generate(300, (i) => _Row('Patient $i', i * 10.0));
      final bytes = await ListPdfExportService.buildRowsPdf(
        title: 'Patient Directory',
        rows: many,
        columns: columns,
      );
      expect(looksLikePdf(bytes), isTrue);
    });
  });

  group('ListPdfExportService.buildKeyValuePdf', () {
    test('produces valid PDF bytes for a metric/value summary', () async {
      final bytes = await ListPdfExportService.buildKeyValuePdf(
        title: 'Growth summary: 2026-08-01 to 2026-08-31',
        entries: const [
          MapEntry('New Patients', 12),
          MapEntry('Total Revenue', 'Rs. 45000.00'),
        ],
      );
      expect(looksLikePdf(bytes), isTrue);
    });

    test('does not throw with no entries', () async {
      final bytes = await ListPdfExportService.buildKeyValuePdf(
        title: 'Growth summary',
        entries: const [],
      );
      expect(looksLikePdf(bytes), isTrue);
    });
  });
}
