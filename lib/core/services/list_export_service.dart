import 'dart:convert';

import 'package:excel/excel.dart' as xlsx;

/// One column of a list export: how to label it and how to read it off a row.
///
/// Generic over the row type so the same machinery serves Patients,
/// CashMemoWithDetails, ExpenseWithClinic and whatever Growth exports later -
/// each screen supplies its own column list rather than this service knowing
/// about any particular table.
class ExportColumn<T> {
  final String header;
  final Object? Function(T row) value;

  /// How this column's value should print in a rendered PDF, if plain
  /// toString() is wrong for it - e.g. a currency figure, since the PDF
  /// font used here has no Rupee glyph and needs "Rs." instead. CSV and
  /// XLSX ignore this: they write the raw value, not a rendering of it.
  final String Function(Object? value)? pdfFormat;

  const ExportColumn(this.header, this.value, {this.pdfFormat});
}

/// A totals row appended after the data - e.g. total revenue, total expense.
/// Cells align with the column list positionally; a column with no total
/// passes null, which prints as a blank cell rather than a stray zero.
class ExportTotals<T> {
  final List<Object?> Function(List<T> rows) build;

  const ExportTotals(this.build);
}

/// Builds an export file for a screen's current row set - what's shown after
/// its own search/filter has already been applied, not the whole table.
///
/// CSV only for now; XLSX and PDF share this same column spec once they land,
/// so a screen that wires up columns once gets every format for free.
class ListExportService {
  const ListExportService._();

  /// Escapes a single CSV field.
  ///
  /// Patient names and notes routinely contain commas and apostrophes, and
  /// notes can hold newlines, so quoting is not optional.
  static String _cell(Object? value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<Object?> cells) => cells.map(_cell).join(',');

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

  /// Metric/value pairs rather than one row per record - for a screen like
  /// Growth whose provider already returns one aggregated summary object,
  /// not a list of rows the `ExportColumn` shape could iterate over.
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
          .cellStyle = xlsx.CellStyle(bold: true);
    }

    for (final e in entries) {
      sheet.appendRow([xlsx.TextCellValue(e.key), _cellValue(e.value)]);
    }

    return book.encode()!;
  }

  static List<int> encodeCsv(String csv) => utf8.encode(csv);

  /// Converts a raw column value into the CellValue subtype the excel
  /// package needs. Numbers and dates keep their type - so a spreadsheet can
  /// sort or sum them - rather than every column landing as text the way
  /// CSV's plain strings do.
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

  static List<int> buildXlsx<T>(
    List<T> rows,
    List<ExportColumn<T>> columns, {
    ExportTotals<T>? totals,
    String sheetName = 'Sheet1',
  }) {
    final book = xlsx.Excel.createExcel();
    // createExcel() ships a default "Sheet1"; renaming rather than deleting
    // and re-adding keeps exactly one sheet instead of leaving a stray blank
    // one behind when sheetName differs from the default.
    if (sheetName != 'Sheet1') {
      book.rename('Sheet1', sheetName);
    }
    final sheet = book[sheetName];

    sheet.appendRow(
      columns.map((c) => xlsx.TextCellValue(c.header)).toList(),
    );
    for (var col = 0; col < columns.length; col++) {
      sheet
          .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .cellStyle = xlsx.CellStyle(bold: true);
    }

    for (final row in rows) {
      sheet.appendRow(
        columns.map((c) => _cellValue(c.value(row))).toList(),
      );
    }

    if (totals != null && rows.isNotEmpty) {
      final cells = totals.build(rows);
      final totalsRowIndex = rows.length + 1;
      sheet.appendRow(cells.map(_cellValue).toList());
      for (var col = 0; col < cells.length; col++) {
        sheet
            .cell(xlsx.CellIndex.indexByColumnRow(
                columnIndex: col, rowIndex: totalsRowIndex))
            .cellStyle = xlsx.CellStyle(bold: true);
      }
    }

    return book.encode()!;
  }

  /// Suggested filename for a per-list export, stamped so exports of the
  /// same screen on different days do not collide.
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
