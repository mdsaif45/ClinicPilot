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
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
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
        action:
            savedPath.isNotEmpty && !savedPath.startsWith('http')
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
  final List<ExportColumn<T>>? pdfColumns;
  final ExportTotals<T>? totals;
  final Future<List<int>> Function()? customXlsxBuilder;

  const ExportAction({
    super.key,
    required this.screenSlug,
    required this.title,
    this.subtitle,
    required this.rows,
    required this.columns,
    this.pdfColumns,
    this.totals,
    this.customXlsxBuilder,
  });

  Future<void> _export(BuildContext context) async {
    if (rows.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to export yet.')));
      return;
    }

    final options = await pickExportOptions(context, hasPatientData: true);
    if (options == null || !context.mounted) return;

    final format = options.format;
    final effectiveColumns =
        options.redactSensitiveData
            ? ListExportService.redactColumns(columns)
            : columns;
    final effectivePdfColumns =
        options.redactSensitiveData
            ? ListExportService.redactColumns(pdfColumns ?? columns)
            : (pdfColumns ?? columns);

    final now = DateTime.now();
    final rawBytes = switch (format) {
      ExportFormat.csv => ListExportService.encodeCsv(
        ListExportService.buildCsv(rows, effectiveColumns, totals: totals),
      ),
      ExportFormat.xlsx =>
        customXlsxBuilder != null && !options.redactSensitiveData
            ? await customXlsxBuilder!()
            : ListExportService.buildXlsx(
              rows,
              effectiveColumns,
              totals: totals,
              sheetName: screenSlug,
            ),
      ExportFormat.pdf => await ListPdfExportService.buildRowsPdf(
        title: options.redactSensitiveData ? '$title (De-Identified)' : title,
        subtitle: subtitle,
        rows: rows,
        columns: effectivePdfColumns,
        totals: totals,
      ),
    };

    final rawFileName = ListExportService.suggestedFileName(
      screenSlug,
      now,
      extension: format.name,
    );

    List<int> finalBytes = rawBytes;
    String finalFileName = rawFileName;
    String finalExtension = format.name;

    if (options.isPasswordProtected &&
        options.password != null &&
        options.password!.isNotEmpty) {
      finalBytes = ListExportService.encryptToZip(
        fileBytes: rawBytes,
        fileName: rawFileName,
        password: options.password!,
      );
      finalFileName = ListExportService.suggestedFileName(
        '$screenSlug-protected',
        now,
        extension: 'zip',
      );
      finalExtension = 'zip';
    }

    if (!context.mounted) return;
    await saveExportFile(
      context,
      bytes: finalBytes,
      fileName: finalFileName,
      extension: finalExtension,
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
