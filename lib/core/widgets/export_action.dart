import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/file_saver/file_saver.dart';
import '../services/list_export_service.dart';
import '../services/list_pdf_export_service.dart';
import 'export_format_sheet.dart';

/// Writes export bytes to a doctor-chosen location and offers to share it.
Future<void> saveExportFile(
  BuildContext context, {
  required List<int> bytes,
  required String fileName,
  required String extension,
  required int rowCount,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    final mimeType = switch (extension.toLowerCase()) {
      'csv' => 'text/csv',
      'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };

    final savedPath = await FileSaverService.save(
      context: context,
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      dialogTitle: 'Save export',
      shareSubject: 'ClinicPilot Export $fileName',
    );

    if (savedPath == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Export cancelled.')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('Exported $rowCount rows to $fileName'),
        action: savedPath.isNotEmpty && !savedPath.startsWith('http')
            ? SnackBarAction(
                label: 'Share',
                onPressed: () => Share.shareXFiles([XFile(savedPath)]),
              )
            : null,
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
  }
}

/// Icon button that exports a screen's current row set, in a format the
/// doctor picks from a sheet.
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
