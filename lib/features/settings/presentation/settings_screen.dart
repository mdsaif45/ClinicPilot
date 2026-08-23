import 'dart:io' show File, Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/import_template_service.dart';
import '../../../core/services/sample_data_seeder.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/doctor_profile_provider.dart';
import 'doctor_profile_screen.dart';
import '../../clinics/presentation/clinics_screen.dart';
import '../../clinics/providers/clinic_provider.dart';

import 'app_version_screen.dart';
import 'import_preview_screen.dart';
import '../providers/release_provider.dart';
import '../providers/update_provider.dart';
import 'appearance_section.dart';
import '../../security/presentation/security_settings_card.dart';

/// Whether the database is empty - the gate on the whole import feature.
final _isDatabaseEmptyProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await ExportService(db).countRows();
  return rows == 0;
});

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
    final clinics = ref.watch(clinicsStreamProvider).value ?? [];
    final isEmptyAsync = ref.watch(_isDatabaseEmptyProvider);
    final isEmpty = isEmptyAsync.value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                icon: Icons.download_outlined,
                title: 'Export backup',
                subtitle: 'Choose where to save a CSV of all records',
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
                  icon: Icons.upload_outlined,
                  title: 'Import from template',
                  subtitle: 'Pick a filled-in template to restore from',
                  onTap: _pickImportFile,
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
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    final messenger = ScaffoldMessenger.of(context);
    final service = ExportService(ref.read(databaseProvider));

    try {
      final rows = await service.countRows();
      if (rows == 0) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Nothing to export yet.')),
        );
        return;
      }

      final csv = await service.buildCsv();
      final bytes = Uint8List.fromList(ExportService.encode(csv));
      final fileName = ExportService.suggestedFileName(DateTime.now());

      if (kIsWeb) {
        await FilePicker.platform.saveFile(
          dialogTitle: 'Save backup CSV',
          fileName: fileName,
          bytes: bytes,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'text/csv')],
          subject: 'ClinicPilot backup ${Formatters.formatDate(DateTime.now())}',
        );
      } else {
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save backup CSV',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );
        if (path != null) {
          final file = File(path);
          await file.writeAsBytes(bytes);
          messenger.showSnackBar(
            SnackBar(content: Text('Backup saved to $path')),
          );
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _downloadImportTemplate() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = Uint8List.fromList(ImportTemplateService.build());
      const fileName = 'clinicpilot-import-template.xlsx';

      if (kIsWeb) {
        await FilePicker.platform.saveFile(
          dialogTitle: 'Save import template',
          fileName: fileName,
          bytes: bytes,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: 'ClinicPilot import template',
        );
      } else {
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save import template',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );
        if (path != null) {
          final file = File(path);
          await file.writeAsBytes(bytes);
          messenger.showSnackBar(
            SnackBar(content: Text('Template saved to $path')),
          );
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Template download failed: $e')),
      );
    }
  }

  Future<void> _pickImportFile() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      final Uint8List bytes;
      if (picked.bytes != null) {
        bytes = picked.bytes!;
      } else if (picked.path != null) {
        final file = File(picked.path!);
        bytes = await file.readAsBytes();
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not read selected file.')),
        );
        return;
      }

      final clinics = await ref.read(clinicsStreamProvider.future);
      final clinicIdsByName = {for (final c in clinics) c.name.toLowerCase().trim(): c.id};

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImportPreviewScreen(
            bytes: bytes,
            clinicIdsByName: clinicIdsByName,
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to read file: $e')),
      );
    }
  }
}

class _DoctorProfileHeader extends ConsumerWidget {
  const _DoctorProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(doctorProfileStreamProvider).value ?? const DoctorProfile();

    final displayName = profile.name.isNotEmpty ? profile.name : 'Doctor Profile';
    final initial = profile.name.isNotEmpty
        ? profile.name.replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '').trim()
        : 'D';
    final avatarLetter = initial.isNotEmpty ? initial[0].toUpperCase() : 'D';

    final subtitleParts = <String>[];
    if (profile.qualification.isNotEmpty) {
      subtitleParts.add(profile.qualification);
    }
    if (profile.email.isNotEmpty) {
      subtitleParts.add(profile.email);
    } else if (profile.phone.isNotEmpty) {
      subtitleParts.add(profile.phone);
    }

    final subtitle = subtitleParts.isNotEmpty
        ? subtitleParts.join(' • ')
        : 'Tap to view credentials & contact info';

    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
        Spacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              avatarLetter,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
