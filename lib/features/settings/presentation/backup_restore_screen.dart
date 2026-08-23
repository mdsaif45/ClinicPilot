import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/file_saver/file_saver.dart';
import '../../../core/services/sample_data_seeder.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../clinics/providers/clinic_provider.dart';
import 'import_preview_screen.dart';
import 'periodic_backups_screen.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isExporting = false;

  Future<void> _createBackup() async {
    setState(() => _isExporting = true);
    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);

    try {
      final bytes = await ExportService(db).buildXlsx();
      final date = Formatters.formatDate(DateTime.now()).replaceAll(' ', '_');
      final fileName = 'ClinicPilot_FullBackup_$date.xlsx';

      if (!mounted) return;
      final savedPath = await FileSaverService.save(
        context: context,
        bytes: bytes,
        fileName: fileName,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      if (savedPath != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Backup saved: $fileName')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to create backup: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _restoreBackup() async {
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
      final fileBytes = picked.bytes ?? (picked.path != null ? await File(picked.path!).readAsBytes() : null);
      if (fileBytes == null) return;

      final clinicList = ref.read(clinicsStreamProvider).value ?? [];
      final clinicIdsByName = {for (final c in clinicList) c.name: c.id};

      if (!mounted) return;
      final imported = await nav.push<bool>(
        MaterialPageRoute(
          builder: (_) => ImportPreviewScreen(
            bytes: fileBytes,
            clinicIdsByName: clinicIdsByName,
          ),
        ),
      );

      if (imported == true) {
        ref.invalidate(clinicsStreamProvider);
        messenger.showSnackBar(
          const SnackBar(content: Text('Practice data restored successfully.')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to restore backup: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup and restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          SettingsGroup(
            title: 'Backup and restore',
            children: [
              AppListTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Create data backup',
                subtitle: 'Create backup of clinical records, memos and expenses',
                trailing: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isExporting ? null : _createBackup,
              ),
              AppListTile(
                icon: Icons.restore_outlined,
                title: 'Restore from backup',
                subtitle: 'Restore previously created backup file',
                onTap: _restoreBackup,
              ),
              AppListTile(
                icon: Icons.history_outlined,
                title: 'Periodic backups',
                subtitle: 'Configure automated periodic backup schedule',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PeriodicBackupsScreen(),
                  ),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Testing',
            children: [
              AppListTile(
                icon: Icons.auto_awesome,
                title: 'Load Demo Practice Data',
                subtitle: 'Populate realistic patients, case records, and finances',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await SampleDataSeeder.seedRealisticData(ref);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Realistic practice demo data loaded!')),
                  );
                },
              ),
              AppListTile(
                icon: Icons.delete_sweep_outlined,
                iconColor: scheme.error,
                leadingBackgroundColor: scheme.errorContainer.withValues(alpha: 0.5),
                titleColor: scheme.error,
                title: 'Clear All Practice Data',
                subtitle: 'Wipe all records and start fresh onboarding',
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
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
                            backgroundColor: Theme.of(ctx).colorScheme.error,
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
