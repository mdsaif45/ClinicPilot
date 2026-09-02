import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart' as xlsx;

/// A single column in a list export.
class ExportColumn<T> {
  final String header;
  final Object? Function(T row) value;

  /// Optional formatter for PDF table cells (e.g. adding 'Rs. ' or date format).
  final String Function(Object? value)? pdfFormat;

  const ExportColumn(this.header, this.value, {this.pdfFormat});
}

/// Optional totals row builder for lists that end in a summary row (e.g.
/// Cash Memos, Expenses, Split).
class ExportTotals<T> {
  final List<Object?> Function(List<T> rows) build;

  const ExportTotals(this.build);
}

/// Pure Dart service that turns a list of domain objects plus a column spec
/// into a CSV string or an Excel (.xlsx) byte buffer.
class ListExportService {
  const ListExportService._();

  static xlsx.CellStyle get headerStyle => xlsx.CellStyle(
        backgroundColorHex: xlsx.ExcelColor.fromHexString('#8CB5F9'),
        fontColorHex: xlsx.ExcelColor.fromHexString('#000000'),
        bold: true,
        fontFamily: xlsx.getFontFamily(xlsx.FontFamily.Calibri),
      );

  static xlsx.CellStyle get totalsStyle => xlsx.CellStyle(
        bold: true,
        fontFamily: xlsx.getFontFamily(xlsx.FontFamily.Calibri),
      );

  /// Injects Excel `<autoFilter>` and `<pane state="frozen">` (sticky top header row) into each worksheet.
  static List<int> enableAutoFilter(List<int> excelBytes) {
    try {
      final archive = ZipDecoder().decodeBytes(excelBytes);
      final newArchive = Archive();

      for (final file in archive) {
        if (file.name.startsWith('xl/worksheets/sheet') &&
            file.name.endsWith('.xml') &&
            !file.name.contains('_rels')) {
          var content = utf8.decode(file.content as List<int>);

          // 1. Freeze top row (Sticky Header)
          if (!content.contains('<pane')) {
            const frozenPaneTag = '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>';
            if (content.contains('<sheetView workbookViewId="0"/>')) {
              content = content.replaceFirst(
                '<sheetView workbookViewId="0"/>',
                '<sheetView workbookViewId="0">$frozenPaneTag</sheetView>',
              );
            } else if (content.contains('</sheetView>')) {
              content = content.replaceFirst(
                '</sheetView>',
                '$frozenPaneTag</sheetView>',
              );
            } else if (content.contains('<sheetViews>')) {
              content = content.replaceFirst(
                '<sheetViews>',
                '<sheetViews><sheetView workbookViewId="0">$frozenPaneTag</sheetView>',
              );
            }
          }

          // 2. AutoFilter Dropdowns on Row 1
          if (!content.contains('<autoFilter')) {
            final headerColMatch = RegExp(r'<c\s+r="([A-Z]+)1"').allMatches(content);
            final rowMatch = RegExp(r'<row\s+r="(\d+)"').allMatches(content);

            if (headerColMatch.isNotEmpty && rowMatch.isNotEmpty) {
              final lastCol = headerColMatch.last.group(1);
              final lastRow = rowMatch.last.group(1);

              if (lastCol != null && lastRow != null) {
                final autoFilterTag = '<autoFilter ref="A1:$lastCol$lastRow"/>';
                if (content.contains('</sheetData>')) {
                  content = content.replaceFirst('</sheetData>', '</sheetData>$autoFilterTag');
                } else if (content.contains('</worksheet>')) {
                  content = content.replaceFirst('</worksheet>', '$autoFilterTag</worksheet>');
                }
              }
            }
          }
          final newBytes = utf8.encode(content);
          newArchive.addFile(ArchiveFile(file.name, newBytes.length, newBytes));
        } else {
          newArchive.addFile(file);
        }
      }

      return ZipEncoder().encode(newArchive) ?? excelBytes;
    } catch (_) {
      return excelBytes;
    }
  }

  /// Escapes a single cell for CSV output per RFC 4180.
  static String _cell(Object? value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<Object?> cells) => cells.map(_cell).join(',');

  /// Converts a typed row list into a CSV document string.
  static String buildCsv<T>(
    List<T> rows,
    List<ExportColumn<T>> columns, {
    ExportTotals<T>? totals,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(_row(columns.map((c) => c.header).toList()));
    for (final row in rows) {
      buffer.writeln(_row(columns.map((c) => c.value(row)).toList()));
    }
    if (totals != null && rows.isNotEmpty) {
      buffer.writeln(_row(totals.build(rows)));
    }
    return buffer.toString();
  }

  /// Metric/value pairs rather than one row per record.
  static String buildKeyValueCsv(
    List<MapEntry<String, Object?>> entries, {
    String? title,
  }) {
    final buffer = StringBuffer();
    if (title != null) {
      buffer.writeln(_row([title]));
      buffer.writeln();
    }
    buffer.writeln(_row(['Metric', 'Value']));
    for (final e in entries) {
      buffer.writeln(_row([e.key, e.value]));
    }
    return buffer.toString();
  }

  /// XLSX equivalent of [buildKeyValueCsv].
  static List<int> buildKeyValueXlsx(
    List<MapEntry<String, Object?>> entries, {
    String? title,
    String sheetName = 'Sheet1',
  }) {
    final book = xlsx.Excel.createExcel();
    if (sheetName != 'Sheet1') {
      book.rename('Sheet1', sheetName);
    }
    final sheet = book[sheetName];

    var row = 0;
    if (title != null) {
      sheet.appendRow([xlsx.TextCellValue(title)]);
      sheet
          .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .cellStyle = xlsx.CellStyle(bold: true);
      row += 1;
    }

    sheet.appendRow(
      [xlsx.TextCellValue('Metric'), xlsx.TextCellValue('Value')],
    );
    for (var col = 0; col < 2; col++) {
      sheet
          .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
          .cellStyle = headerStyle;
    }

    for (final e in entries) {
      sheet.appendRow([xlsx.TextCellValue(e.key), _cellValue(e.value)]);
    }

    final rawBytes = book.encode()!;
    return enableAutoFilter(rawBytes);
  }

  static List<int> encodeCsv(String csv) => utf8.encode(csv);

  /// Converts a raw column value into the CellValue subtype the excel package needs.
  static xlsx.CellValue? _cellValue(Object? value) {
    return switch (value) {
      null => null,
      int v => xlsx.IntCellValue(v),
      double v => xlsx.DoubleCellValue(v),
      DateTime v => xlsx.DateTimeCellValue.fromDateTime(v),
      bool v => xlsx.BoolCellValue(v),
      _ => xlsx.TextCellValue(value.toString()),
    };
  }

  /// Builds a fully styled Excel workbook (.xlsx) with styled header row and auto-filter.
  static List<int> buildXlsx<T>(
    List<T> rows,
    List<ExportColumn<T>> columns, {
    ExportTotals<T>? totals,
    String sheetName = 'Sheet1',
  }) {
    final book = xlsx.Excel.createExcel();
    if (sheetName != 'Sheet1') {
      book.rename('Sheet1', sheetName);
    }
    final sheet = book[sheetName];

    // Header Row
    sheet.appendRow(
      columns.map((c) => xlsx.TextCellValue(c.header)).toList(),
    );
    for (var col = 0; col < columns.length; col++) {
      sheet
          .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .cellStyle = headerStyle;
    }

    // Data Rows
    for (final row in rows) {
      sheet.appendRow(
        columns.map((c) => _cellValue(c.value(row))).toList(),
      );
    }

    // Totals Row
    if (totals != null && rows.isNotEmpty) {
      final cells = totals.build(rows);
      final totalsRowIndex = rows.length + 1;
      sheet.appendRow(cells.map(_cellValue).toList());
      for (var col = 0; col < cells.length; col++) {
        sheet
            .cell(xlsx.CellIndex.indexByColumnRow(
                columnIndex: col, rowIndex: totalsRowIndex))
            .cellStyle = totalsStyle;
      }
    }

    final rawBytes = book.encode()!;
    return enableAutoFilter(rawBytes);
  }

  /// Suggested filename for a per-list export.
  static String suggestedFileName(
    String screenSlug,
    DateTime now, {
    String extension = 'csv',
  }) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'clinicpilot-$screenSlug-'
        '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}.$extension';
  }
}
