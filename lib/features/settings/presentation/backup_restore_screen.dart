import 'dart:convert';
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/backup_container_service.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/file_saver/file_saver.dart';
import '../../../core/services/sample_data_seeder.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../clinics/providers/clinic_provider.dart';
import 'import_preview_screen.dart';
import 'periodic_backups_screen.dart';
import 'restore_preview_dialog.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isCreatingBackup = false;
  bool _isExportingExcel = false;
  bool _isExportingCsv = false;
  bool _isSeedingDemo = false;

  /// Creates a 100% loss-free, compressed & verified `.cpbak` practice backup.
  Future<void> _createFullBackup() async {
    setState(() => _isCreatingBackup = true);
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);

    try {
      final bytes = await BackupContainerService(db).buildBackupBytes();
      final date = Formatters.formatDate(DateTime.now()).replaceAll(' ', '_');
      final fileName = 'ClinicPilot_Backup_$date.cpbak';

      if (!mounted) return;
      final savedPath = await FileSaverService.save(
        context: context,
        bytes: bytes,
        fileName: fileName,
        mimeType: 'application/octet-stream',
      );

      if (savedPath != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Practice backup saved: $fileName')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to create practice backup: $e')),
      );
    } finally {
      if (mounted) setState(() => _isCreatingBackup = false);
    }
  }

  /// Restores from a `.cpbak` file with pre-restore inspection modal, or legacy `.xlsx`.
  Future<void> _restoreBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final db = ref.read(databaseProvider);

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['cpbak', 'xlsx', 'json'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) return;
      final picked = res.files.first;
      final fileBytes =
          picked.bytes ??
          (picked.path != null ? await File(picked.path!).readAsBytes() : null);
      if (fileBytes == null) return;

      final extension = picked.extension?.toLowerCase() ?? '';

      // 1. Full .cpbak Container Restore Flow
      if (extension == 'cpbak' || extension == 'json') {
        try {
          final metadata = BackupContainerService.inspectBackup(fileBytes);

          if (!mounted) return;
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder:
                (ctx) => RestorePreviewDialog(
                  metadata: metadata,
                  onConfirm: () async {
                    final result = await BackupContainerService(
                      db,
                    ).restoreFromBackupBytes(fileBytes);
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop(result.success);
                    }
                  },
                ),
          );

          if (confirmed == true) {
            // Invalidate all reactive streams across the app
            ref.invalidate(clinicsStreamProvider);
            ref.invalidate(databaseProvider);

            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Practice data restored successfully! (${metadata.totalRecords} records loaded)',
                ),
              ),
            );
          }
        } catch (e) {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(content: Text('Invalid or corrupted backup file: $e')),
          );
        }
        return;
      }

      // 2. Legacy Excel (.xlsx) Import Flow
      if (extension == 'xlsx') {
        final clinicList = ref.read(clinicsStreamProvider).value ?? [];
        final clinicIdsByName = {for (final c in clinicList) c.name: c.id};

        if (!mounted) return;
        final imported = await nav.push<bool>(
          MaterialPageRoute(
            builder:
                (_) => ImportPreviewScreen(
                  bytes: fileBytes,
                  clinicIdsByName: clinicIdsByName,
                ),
          ),
        );

        if (imported == true) {
          ref.invalidate(clinicsStreamProvider);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Spreadsheet data imported successfully.'),
            ),
          );
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to read backup file: $e')),
      );
    }
  }

  /// Exports all data to a multi-sheet Excel spreadsheet for accounting and human reading.
  Future<void> _exportExcel() async {
    setState(() => _isExportingExcel = true);
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);

    try {
      final bytes = await ExportService(db).buildXlsx();
      final date = Formatters.formatDate(DateTime.now()).replaceAll(' ', '_');
      final fileName = 'ClinicPilot_Export_$date.xlsx';

      if (!mounted) return;
      final savedPath = await FileSaverService.save(
        context: context,
        bytes: bytes,
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      if (savedPath != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Excel workbook saved: $fileName')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to export Excel: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExportingExcel = false);
    }
  }

  /// Exports all tables to CSV format.
  Future<void> _exportCsv() async {
    setState(() => _isExportingCsv = true);
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);

    try {
      final csvString = await ExportService(db).buildCsv();
      final bytes = utf8.encode(csvString);
      final date = Formatters.formatDate(DateTime.now()).replaceAll(' ', '_');
      final fileName = 'ClinicPilot_FullExport_$date.csv';

      if (!mounted) return;
      final savedPath = await FileSaverService.save(
        context: context,
        bytes: bytes,
        fileName: fileName,
        mimeType: 'text/csv',
      );

      if (savedPath != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('CSV archive saved: $fileName')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExportingCsv = false);
    }
  }

  /// Imports patients from an Excel contact list.
  Future<void> _importPatientsFromExcel() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) return;
      final picked = res.files.first;
      final fileBytes =
          picked.bytes ??
          (picked.path != null ? await File(picked.path!).readAsBytes() : null);
      if (fileBytes == null) return;

      final clinicList = ref.read(clinicsStreamProvider).value ?? [];
      final clinicIdsByName = {for (final c in clinicList) c.name: c.id};

      if (!mounted) return;
      final imported = await nav.push<bool>(
        MaterialPageRoute(
          builder:
              (_) => ImportPreviewScreen(
                bytes: fileBytes,
                clinicIdsByName: clinicIdsByName,
              ),
        ),
      );

      if (imported == true) {
        ref.invalidate(clinicsStreamProvider);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Patient roster imported successfully.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to import Excel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup and restore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          // ── TIER 1: FULL PRACTICE BACKUP & MIGRATION (.cpbak) ───
          SettingsGroup(
            title: 'Full Practice Backup & Migration',
            children: [
              AppListTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Create Data Backup (.cpbak)',
                subtitle:
                    '100% loss-free backup of all 14 clinical & financial tables',
                trailing:
                    _isCreatingBackup
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                onTap: _isCreatingBackup ? null : _createFullBackup,
              ),
              AppListTile(
                icon: Icons.restore_outlined,
                title: 'Restore from Backup',
                subtitle:
                    'Inspect & restore .cpbak backup on a new or reset device',
                onTap: _restoreBackup,
              ),
              AppListTile(
                icon: Icons.history_outlined,
                title: 'Periodic Backups',
                subtitle: 'Configure automated periodic backup schedule',
                trailing: const Icon(Icons.chevron_right),
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PeriodicBackupsScreen(),
                      ),
                    ),
              ),
            ],
          ),

          // ── TIER 2: SPREADSHEET EXPORTS & REPORTS ────────────────
          SettingsGroup(
            title: 'Spreadsheet Reports & Accounting',
            children: [
              AppListTile(
                icon: Icons.table_chart_outlined,
                title: 'Export to Excel (.xlsx)',
                subtitle:
                    'Multi-sheet workbook for accounting, tax audit, and viewing',
                trailing:
                    _isExportingExcel
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                onTap: _isExportingExcel ? null : _exportExcel,
              ),
              AppListTile(
                icon: Icons.description_outlined,
                title: 'Export to CSV (.csv)',
                subtitle: 'Raw CSV export for external spreadsheets',
                trailing:
                    _isExportingCsv
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                onTap: _isExportingCsv ? null : _exportCsv,
              ),
            ],
          ),

          // ── TIER 3: PATIENT ROSTER IMPORT ────────────────────────
          SettingsGroup(
            title: 'Patient Roster Import',
            children: [
              AppListTile(
                icon: Icons.file_download_outlined,
                title: 'Import Patients from Excel',
                subtitle:
                    'Import patient contacts and past history from spreadsheet',
                onTap: _importPatientsFromExcel,
              ),
            ],
          ),

          // ── TIER 4: TESTING & RESET ──────────────────────────────
          SettingsGroup(
            title: 'Testing & Reset',
            children: [
              AppListTile(
                icon: Icons.auto_awesome,
                title: 'Load Demo Practice Data',
                subtitle:
                    'Populate 125 realistic patients, case records, and finances',
                trailing:
                    _isSeedingDemo
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                onTap:
                    _isSeedingDemo
                        ? null
                        : () async {
                          setState(() => _isSeedingDemo = true);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await SampleDataSeeder.seedRealisticData(ref);
                            ref.invalidate(clinicsStreamProvider);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '125 Patients & Multi-Clinic Demo Data Loaded!',
                                ),
                              ),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to load demo data: $e'),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _isSeedingDemo = false);
                          }
                        },
              ),
              AppListTile(
                icon: Icons.delete_sweep_outlined,
                iconColor: scheme.error,
                leadingBackgroundColor: scheme.errorContainer.withValues(
                  alpha: 0.5,
                ),
                titleColor: scheme.error,
                title: 'Clear All Practice Data',
                subtitle: 'Wipe all records and start fresh onboarding',
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Reset All Practice Data?'),
                          content: const Text(
                            'This will delete all patients, visits, cash memos, expenses, and clinics, resetting the app to a clean initial state. This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(ctx).colorScheme.error,
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Reset Everything'),
                            ),
                          ],
                        ),
                  );
                  if (confirmed == true) {
                    await ref.read(databaseProvider).clearAllPracticeData();
                    if (context.mounted) {
                      context.go('/onboarding');
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
