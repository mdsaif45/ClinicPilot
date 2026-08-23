import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/file_saver/file_saver.dart';
import '../../../core/services/import_template_service.dart';
import '../../../core/services/sample_data_seeder.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../clinics/presentation/clinics_screen.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../security/presentation/security_settings_card.dart';
import '../providers/doctor_profile_provider.dart';
import '../providers/release_provider.dart';
import '../providers/update_provider.dart';
import 'appearance_section.dart';
import 'app_version_screen.dart';
import 'backup_restore_screen.dart';
import 'import_preview_screen.dart';

/// Whether the database is empty - the gate on the whole import feature.
final _isDatabaseEmptyProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await ExportService(db).countRows();
  return rows == 0;
});

enum BackupFormat {
  xlsx('Excel Workbook (.xlsx)', 'Recommended (Default) • Separate tabs for Clinics, Patients, Visits, Memos & Expenses', Icons.grid_on_outlined),
  csv('CSV Archive (.csv)', 'Universal plain text format compatible with all spreadsheet apps', Icons.table_chart_outlined);

  final String label;
  final String description;
  final IconData icon;

  const BackupFormat(this.label, this.description, this.icon);
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clinics = ref.watch(clinicsStreamProvider).value ?? [];
    final isEmpty = ref.watch(_isDatabaseEmptyProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          const _DoctorProfileHeader(),
          const AppearanceSection(),
          SettingsGroup(
            title: 'Clinics',
            children: [
              AppListTile(
                icon: Icons.local_hospital_outlined,
                title: 'Manage clinics',
                subtitle: clinics.isEmpty
                    ? 'No clinics yet'
                    : '${clinics.length} ${clinics.length == 1 ? 'clinic' : 'clinics'}',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClinicsScreen()),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Data',
            children: [
              AppListTile(
                icon: Icons.history,
                title: 'Backup and restore',
                subtitle: 'Create or restore a backup, Periodic backups',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BackupRestoreScreen(),
                  ),
                ),
              ),
              AppListTile(
                icon: Icons.download_outlined,
                title: 'Export backup',
                subtitle: 'Choose Excel (default) or CSV format',
                onTap: _exportData,
              ),
              if (isEmpty) ...[
                AppListTile(
                  icon: Icons.description_outlined,
                  title: 'Download import template',
                  subtitle: 'A blank spreadsheet to fill in and import back',
                  onTap: _downloadImportTemplate,
                ),
                AppListTile(
                  icon: Icons.upload_file_outlined,
                  title: 'Import practice data',
                  subtitle: 'Populate from a filled spreadsheet template',
                  onTap: () async {
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
                        ref.invalidate(_isDatabaseEmptyProvider);
                        ref.invalidate(clinicsStreamProvider);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Practice data imported successfully.')),
                        );
                      }
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Could not read file: $e')),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
          const SecuritySettingsCard(),
          SettingsGroup(
            title: 'Information',
            children: [
              AppListTile(
                icon: Icons.code,
                title: 'GitHub repository',
                onTap: () => _openUrl(
                  'https://github.com/mdsaif45/ClinicPilot',
                ),
              ),
              const AppListTile(
                icon: Icons.favorite_outline,
                title: 'Developed by mdsaif45',
              ),
              Consumer(builder: (context, ref, _) {
                final running =
                    ref.watch(runningVersionProvider).value ?? '…';
                final updateWaiting =
                    ref.watch(availableUpdateProvider).value != null;
                return AppListTile(
                  icon: Icons.smartphone,
                  title: 'App Version',
                  subtitle: 'v$running',
                  trailing: updateWaiting
                      ? Icon(Icons.circle,
                          size: 10, color: Theme.of(context).colorScheme.tertiary)
                      : const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AppVersionScreen(),
                    ),
                  ),
                );
              }),
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

  Future<BackupFormat?> _pickBackupFormat(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return showModalBottomSheet<BackupFormat>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, Spacing.xs, 0, Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Text(
                  'Choose Export Format',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              for (final format in BackupFormat.values)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl,
                    vertical: Spacing.xs,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: format == BackupFormat.xlsx
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    foregroundColor: format == BackupFormat.xlsx
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                    child: Icon(format.icon),
                  ),
                  title: Row(
                    children: [
                      Text(
                        format.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (format == BackupFormat.xlsx) ...[
                        const SizedBox(width: Spacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    format.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).pop(format),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    final messenger = ScaffoldMessenger.of(context);
    final service = ExportService(ref.read(databaseProvider));

    try {
      final chosenFormat = await _pickBackupFormat(context);
      if (chosenFormat == null || !mounted) return;

      final rows = await service.countRows();
      if (!mounted) return;
      if (rows == 0) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Nothing to export yet.')),
        );
        return;
      }

      final now = DateTime.now();
      List<int> bytes;
      String fileName;
      String mimeType;

      if (chosenFormat == BackupFormat.xlsx) {
        bytes = await service.buildXlsx();
        fileName = ExportService.suggestedFileName(now, extension: 'xlsx');
        mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else {
        final csv = await service.buildCsv();
        bytes = ExportService.encode(csv);
        fileName = ExportService.suggestedFileName(now, extension: 'csv');
        mimeType = 'text/csv';
      }

      if (!mounted) return;
      final savedPath = await FileSaverService.save(
        context: context,
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        dialogTitle: 'Save practice backup',
        shareSubject: 'ClinicPilot Backup ${Formatters.formatDate(now)}',
      );

      if (savedPath == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Export cancelled.')),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Exported $rows records to $fileName'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _downloadImportTemplate() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = ImportTemplateService.build();
      const fileName = 'clinicpilot-import-template.xlsx';
      const mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

      if (!mounted) return;
      final savedPath = await FileSaverService.save(
        context: context,
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        dialogTitle: 'Save import template',
        shareSubject: 'ClinicPilot Import Template',
      );

      if (savedPath != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Import template saved.')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not download template: $e')),
      );
    }
  }
}

class _DoctorProfileHeader extends ConsumerWidget {
  const _DoctorProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(doctorProfileStreamProvider).value ?? const DoctorProfile();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final displayName = profile.displayName;
    final initial = profile.name.isNotEmpty
        ? profile.name.replaceFirst(RegExp(r'^Dr\\.?\\s*', caseSensitive: false), '').trim()
        : (profile.firstName.isNotEmpty
            ? profile.firstName.replaceFirst(RegExp(r'^Dr\\.?\\s*', caseSensitive: false), '').trim()
            : 'D');
    final avatarLetter = initial.isNotEmpty ? initial[0].toUpperCase() : 'D';

    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.xs,
        Spacing.lg,
        Spacing.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      onTap: () => context.push('/settings/profile'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.primary,
            child: Text(
              avatarLetter,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.qualification.isNotEmpty
                      ? profile.qualification
                      : 'Tap to view credentials & contact info',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: scheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
