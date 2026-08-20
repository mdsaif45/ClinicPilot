import 'dart:convert';

/// One column of a list export: how to label it and how to read it off a row.
///
/// Generic over the row type so the same machinery serves Patients,
/// CashMemoWithDetails, ExpenseWithClinic and whatever Growth exports later -
/// each screen supplies its own column list rather than this service knowing
/// about any particular table.
class ExportColumn<T> {
  final String header;
  final Object? Function(T row) value;

  const ExportColumn(this.header, this.value);
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

  static List<int> encodeCsv(String csv) => utf8.encode(csv);

  /// Suggested filename for a per-list export, stamped so exports of the
  /// same screen on different days do not collide.
  static String suggestedFileName(String screenSlug, DateTime now) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'clinicpilot-$screenSlug-'
        '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}.csv';
  }
}
