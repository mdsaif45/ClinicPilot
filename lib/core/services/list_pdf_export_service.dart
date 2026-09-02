import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'list_export_service.dart';

/// Renders a per-list export as a printable table report - title, an
/// optional subtitle (the period or filter the rows were pulled under), the
/// data itself, and a totals row where the screen has one. Same colour and
/// spacing language as the cash memo receipt (pdf_service.dart), since that
/// is the one PDF a doctor already knows how this app's paper looks.
///
/// Separate file from ListExportService rather than folding this in: CSV and
/// XLSX only need dart:convert and the excel package, while this pulls in
/// the much heavier pdf/widgets rendering tree, and a screen exporting to
/// CSV should not pay for that import.
class ListPdfExportService {
  const ListPdfExportService._();

  static final _primaryColor = PdfColor.fromHex('#0F5132');
  static final _textMuted = PdfColor.fromHex('#6C757D');

  static String _cellText<T>(ExportColumn<T> column, Object? raw) {
    final format = column.pdfFormat;
    if (format != null) return format(raw);
    return raw?.toString() ?? '';
  }

  /// Table report over a row set - Patients, Cash Memo, Expenses.
  static Future<Uint8List> buildRowsPdf<T>({
    required String title,
    String? subtitle,
    required List<T> rows,
    required List<ExportColumn<T>> columns,
    ExportTotals<T>? totals,
  }) async {
    final doc = pw.Document();

    final headerRow = columns.map((c) => c.header).toList();
    final dataRows =
        rows
            .map(
              (row) => columns.map((c) => _cellText(c, c.value(row))).toList(),
            )
            .toList();

    List<String>? totalsRow;
    if (totals != null && rows.isNotEmpty) {
      final cells = totals.build(rows);
      totalsRow = [
        for (var i = 0; i < columns.length; i++)
          _cellText(columns[i], i < cells.length ? cells[i] : null),
      ];
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header:
            (context) =>
                context.pageNumber == 1
                    ? pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        if (subtitle != null)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 2),
                            child: pw.Text(
                              subtitle,
                              style: pw.TextStyle(
                                fontSize: 11,
                                color: _textMuted,
                              ),
                            ),
                          ),
                        pw.SizedBox(height: 12),
                        pw.Divider(color: _primaryColor, thickness: 1.2),
                        pw.SizedBox(height: 8),
                      ],
                    )
                    : pw.SizedBox(),
        footer:
            (context) => pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 9, color: _textMuted),
              ),
            ),
        build:
            (context) => [
              pw.TableHelper.fromTextArray(
                headers: headerRow,
                data: dataRows,
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                headerDecoration: pw.BoxDecoration(color: _primaryColor),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 5,
                ),
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.6,
                ),
                rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                oddRowDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8F9FA'),
                ),
              ),
              if (totalsRow != null) ...[
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                  headers: null,
                  data: [totalsRow],
                  cellStyle: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                  cellPadding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  border: pw.TableBorder.all(color: _primaryColor, width: 0.8),
                ),
              ],
            ],
      ),
    );

    return doc.save();
  }

  /// Table report for a single aggregated summary - Growth, which has no
  /// per-row list, just metric/value pairs.
  static Future<Uint8List> buildKeyValuePdf({
    required String title,
    required List<MapEntry<String, Object?>> entries,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header:
            (context) =>
                context.pageNumber == 1
                    ? pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Divider(color: _primaryColor, thickness: 1.2),
                        pw.SizedBox(height: 8),
                      ],
                    )
                    : pw.SizedBox(),
        build:
            (context) => [
              pw.TableHelper.fromTextArray(
                headers: const ['Metric', 'Value'],
                data:
                    entries
                        .map((e) => [e.key, e.value?.toString() ?? ''])
                        .toList(),
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
                headerDecoration: pw.BoxDecoration(color: _primaryColor),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.6,
                ),
                oddRowDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8F9FA'),
                ),
              ),
            ],
      ),
    );

    return doc.save();
  }
}
