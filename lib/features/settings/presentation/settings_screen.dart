import 'dart:io' show File, Platform;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/export_service.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../clinics/presentation/clinics_screen.dart';
import '../../clinics/providers/clinic_provider.dart';

import 'app_update_card.dart';
import 'appearance_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _revenueGoalController = TextEditingController(text: '50000');
  final _patientGoalController = TextEditingController(text: '10');

  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = 'v${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      if (mounted) setState(() => _version = 'Unknown');
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    final rev = await (db.select(db.settings)
          ..where((tbl) => tbl.key.equals('monthly_revenue_goal')))
        .getSingleOrNull();
    if (rev != null) _revenueGoalController.text = rev.value;

    final pat = await (db.select(db.settings)
          ..where((tbl) => tbl.key.equals('monthly_new_patient_goal')))
        .getSingleOrNull();
    if (pat != null) _patientGoalController.text = pat.value;
  }

  @override
  void dispose() {
    _revenueGoalController.dispose();
    _patientGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinics = ref.watch(clinicsStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          const AppearanceSection(),
          SettingsGroup(
            title: 'Goals',
            children: [
              AppListTile(
                icon: Icons.currency_rupee,
                title: 'Monthly revenue target',
                // Subtitle carries the current value, so state is readable
                // without opening the row.
                subtitle:
                    Formatters.formatCurrency(_asDouble(_revenueGoalController)),
                onTap: () => _editGoal(
                  title: 'Monthly revenue target',
                  controller: _revenueGoalController,
                ),
              ),
              AppListTile(
                icon: Icons.person_add_outlined,
                title: 'New patient target',
                subtitle: '${_revenueGoalOrZero(_patientGoalController)} '
                    'patients per month',
                onTap: () => _editGoal(
                  title: 'New patient target',
                  controller: _patientGoalController,
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Clinics',
            children: [
              AppListTile(
                icon: Icons.local_hospital_outlined,
                title: 'Manage clinics',
                subtitle: clinics.isEmpty
                    ? 'No clinics yet'
                    : '${clinics.length} '
                        '${clinics.length == 1 ? 'clinic' : 'clinics'}',
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
                icon: Icons.download_outlined,
                title: 'Export backup',
                subtitle: 'Choose where to save a CSV of all records',
                onTap: _exportData,
              ),
            ],
          ),
          SettingsGroup(
            title: 'Information',
            children: [
              AppListTile(
                icon: Icons.code,
                title: 'GitHub repository',
                subtitle: 'mdsaif45/ClinicPilot',
                onTap: () => _openUrl(
                  'https://github.com/mdsaif45/ClinicPilot',
                ),
              ),
              AppListTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: _version,
              ),
              const AppListTile(
                icon: Icons.favorite_outline,
                title: 'Developed by mdsaif45',
                subtitle: 'Know. Grow. Repeat.',
              ),
              const AppUpdateCard(),
            ],
          ),
        ],
      ),
    );
  }

  double _asDouble(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  String _revenueGoalOrZero(TextEditingController c) =>
      (int.tryParse(c.text.trim()) ?? 0).toString();

  Future<void> _editGoal({
    required String title,
    required TextEditingController controller,
  }) async {
    final draft = TextEditingController(text: controller.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: CustomTextField(
          controller: draft,
          label: title,
          prefixIcon: Icons.flag_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(() => controller.text = draft.text.trim());
      await _saveGoals();
    }
    draft.dispose();
  }

  Future<void> _saveGoals() async {
    final db = ref.read(databaseProvider);
    final rev = _revenueGoalController.text.trim();
    final pat = _patientGoalController.text.trim();

    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal',
            value: rev,
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_new_patient_goal',
            value: pat,
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target goals updated successfully!')),
      );
    }
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

      // Let the doctor choose where the backup lands. saveFile writes the
      // bytes directly on Android, and returns the chosen path elsewhere.
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save ClinicPilot backup',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );

      if (path == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Export cancelled.')),
        );
        return;
      }

      // On desktop saveFile only returns the location; the write is ours.
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        await File(path).writeAsBytes(bytes, flush: true);
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Exported $rows records to $fileName'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => Share.shareXFiles(
              [XFile(path)],
              text: 'ClinicPilot backup',
            ),
          ),
        ),
      );
    } catch (e) {
      // Never claim success on failure - this backup is what protects the
      // doctor's data through the release-signing reinstall.
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}
