import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/list_export_service.dart';
import '../services/list_pdf_export_service.dart';
import 'export_format_sheet.dart';

/// Writes export bytes to a doctor-chosen location and offers to share it.
///
/// Format-agnostic - the row-set export on Patients/Finances and the
/// single-summary export on Growth both end here regardless of whether they
/// built CSV or XLSX bytes, so "where the file goes" only has one
/// implementation to get right.
Future<void> saveExportFile(
  BuildContext context, {
  required List<int> bytes,
  required String fileName,
  required String extension,
  required int rowCount,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    // Same saveFile flow as the Settings backup: writes directly on
    // Android, returns a location elsewhere that this then writes to.
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save export',
      fileName: fileName,
      bytes: Uint8List.fromList(bytes),
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    if (path == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Export cancelled.')),
      );
      return;
    }

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await File(path).writeAsBytes(bytes, flush: true);
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('Exported $rowCount rows to $fileName'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () => Share.shareXFiles([XFile(path)]),
        ),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
  }
}

/// Icon button that exports a screen's current row set, in a format the
/// doctor picks from a sheet.
///
/// Deliberately per-screen rather than one export button for the whole app:
/// the rows are whatever that screen is showing right now - a search filter
/// on Patients, a category filter on Expenses - so the file matches what the
/// doctor is actually looking at, not the entire table.
class ExportAction<T> extends StatelessWidget {
  final String screenSlug;
  final String title;
  final String? subtitle;
  final List<T> rows;
  final List<ExportColumn<T>> columns;
  final ExportTotals<T>? totals;

  const ExportAction({
    super.key,
    required this.screenSlug,
    required this.title,
    this.subtitle,
    required this.rows,
    required this.columns,
    this.totals,
  });

  Future<void> _export(BuildContext context) async {
    if (rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export yet.')),
      );
      return;
    }

    final format = await pickExportFormat(context);
    if (format == null || !context.mounted) return;

    final now = DateTime.now();
    final bytes = switch (format) {
      ExportFormat.csv => ListExportService.encodeCsv(
          ListExportService.buildCsv(rows, columns, totals: totals),
        ),
      ExportFormat.xlsx => ListExportService.buildXlsx(
          rows,
          columns,
          totals: totals,
          sheetName: screenSlug,
        ),
      ExportFormat.pdf => await ListPdfExportService.buildRowsPdf(
          title: title,
          subtitle: subtitle,
          rows: rows,
          columns: columns,
          totals: totals,
        ),
    };
    final extension = format.name;

    if (!context.mounted) return;
    await saveExportFile(
      context,
      bytes: bytes,
      fileName: ListExportService.suggestedFileName(
        screenSlug,
        now,
        extension: extension,
      ),
      extension: extension,
      rowCount: rows.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.file_download_outlined),
      tooltip: 'Export',
      onPressed: () => _export(context),
    );
  }
}
