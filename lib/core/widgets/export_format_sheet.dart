import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// The file formats a per-list export can be saved as.
enum ExportFormat {
  csv('CSV', 'Opens in any spreadsheet app.', Icons.table_chart_outlined),
  xlsx(
    'Excel (XLSX)',
    'Keeps numbers as numbers, not text.',
    Icons.grid_on_outlined,
  ),
  pdf(
    'PDF',
    'A printable report, not for re-importing.',
    Icons.picture_as_pdf_outlined,
  );

  final String label;
  final String description;
  final IconData icon;

  const ExportFormat(this.label, this.description, this.icon);
}

/// Bottom sheet offering a choice of export format.
///
/// Returns the chosen format, or null if the sheet was dismissed without a
/// choice - callers treat that the same as a cancelled export.
Future<ExportFormat?> pickExportFormat(BuildContext context) {
  return showModalBottomSheet<ExportFormat>(
    context: context,
    showDragHandle: true,
    builder:
        (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  Spacing.xl,
                  Spacing.xs,
                  Spacing.xl,
                  Spacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Export as',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              for (final format in ExportFormat.values)
                ListTile(
                  leading: Icon(format.icon),
                  title: Text(format.label),
                  subtitle: Text(format.description),
                  onTap: () => Navigator.of(ctx).pop(format),
                ),
            ],
          ),
        ),
  );
}
