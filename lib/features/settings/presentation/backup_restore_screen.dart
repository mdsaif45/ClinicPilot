import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/file_saver/file_saver.dart';
import '../../../core/utils/formatters.dart';
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
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        children: [
          // Create Data Backup
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xs,
            ),
            title: Text(
              'Create data backup',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: Text(
                'You can create backup of your history and favorites and restore it',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            trailing: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _isExporting ? null : _createBackup,
          ),
          const Divider(height: 1),

          // Restore From Backup
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xs,
            ),
            title: Text(
              'Restore from backup',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: Text(
                'Restore previously created backup',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            onTap: _restoreBackup,
          ),
          const Divider(height: 1),

          // Periodic Backups
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xs,
            ),
            title: Text(
              'Periodic backups',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: Text(
                'Configure automated periodic backup schedule',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PeriodicBackupsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
