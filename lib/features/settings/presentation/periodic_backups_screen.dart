import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/periodic_backup_runner.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_list_tile.dart';

class PeriodicBackupsScreen extends ConsumerStatefulWidget {
  const PeriodicBackupsScreen({super.key});

  @override
  ConsumerState<PeriodicBackupsScreen> createState() =>
      _PeriodicBackupsScreenState();
}

class _PeriodicBackupsScreenState extends ConsumerState<PeriodicBackupsScreen> {
  late Box _settingsBox;

  bool _enabled = false;
  String _directory = '';
  String _frequency = 'Once per week';
  bool _deleteOld = true;
  double _maxBackups = 10;
  String? _lastRunStr;
  int _existingBackupsCount = 0;
  bool _isRunningManualBackup = false;

  static const _frequencies = [
    'Every 6 hours',
    'Every day',
    'Every 2 days',
    'Once per week',
    'Twice per month',
    'Once per month',
  ];

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _enabled =
        _settingsBox.get('periodic_backup_enabled', defaultValue: false) ==
        true;
    _directory =
        _settingsBox.get('periodic_backup_directory', defaultValue: '')
            as String;
    _frequency =
        _settingsBox.get(
              'periodic_backup_frequency',
              defaultValue: 'Once per week',
            )
            as String;
    _deleteOld =
        _settingsBox.get('periodic_backup_delete_old', defaultValue: true) ==
        true;
    _maxBackups =
        (_settingsBox.get('periodic_backup_max_count', defaultValue: 10) as num)
            .toDouble();
    _lastRunStr = _settingsBox.get('periodic_backup_last_run') as String?;

    _loadExistingBackups();
  }

  Future<void> _loadExistingBackups() async {
    if (kIsWeb) return;
    final resolvedDir = await PeriodicBackupRunner.resolveBackupDirectory(
      customPath: _directory,
    );
    if (resolvedDir != null) {
      if (_directory.isEmpty) {
        _directory = resolvedDir.path;
      }
      final backups = await PeriodicBackupRunner.getExistingBackups();
      if (mounted) {
        setState(() {
          _existingBackupsCount = backups.length;
        });
      }
    }
  }

  void _save() {
    _settingsBox.put('periodic_backup_enabled', _enabled);
    _settingsBox.put('periodic_backup_directory', _directory);
    _settingsBox.put('periodic_backup_frequency', _frequency);
    _settingsBox.put('periodic_backup_delete_old', _deleteOld);
    _settingsBox.put('periodic_backup_max_count', _maxBackups.round());
  }

  Future<void> _pickDirectory() async {
    if (kIsWeb) return;
    final selected = await FilePicker.platform.getDirectoryPath();
    if (selected != null && mounted) {
      setState(() {
        _directory = selected;
        _save();
      });
      await _loadExistingBackups();
    }
  }

  Future<void> _runManualBackup() async {
    if (_isRunningManualBackup) return;
    setState(() => _isRunningManualBackup = true);

    final messenger = ScaffoldMessenger.of(context);
    final db = ref.read(databaseProvider);

    try {
      final file = await PeriodicBackupRunner.executeBackup(
        db,
        isManualTrigger: true,
      );
      if (!mounted) return;

      if (file != null) {
        _lastRunStr = DateTime.now().toIso8601String();
        await _loadExistingBackups();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Automated backup created: ${file.path.split(Platform.pathSeparator).last}',
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Backup skipped: storage directory unavailable.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    } finally {
      if (mounted) setState(() => _isRunningManualBackup = false);
    }
  }

  Future<void> _showFrequencyDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String current = _frequency;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: const Text('Backup creation frequency'),
              contentPadding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    _frequencies.map((freq) {
                      return RadioListTile<String>(
                        title: Text(freq, style: theme.textTheme.bodyMedium),
                        value: freq,
                        groupValue: current,
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => current = val);
                            Navigator.of(ctx).pop(val);
                          }
                        },
                      );
                    }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _frequency = selected;
        _save();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    String lastRunFormatted = 'Never';
    if (_lastRunStr != null && _lastRunStr!.isNotEmpty) {
      final dt = DateTime.tryParse(_lastRunStr!);
      if (dt != null) {
        lastRunFormatted = Formatters.formatFullDate(dt);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Periodic backups')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          SettingsGroup(
            title: 'Schedule',
            children: [
              AppSwitchTile(
                icon: Icons.autorenew_outlined,
                title: 'Enable periodic backups',
                subtitle:
                    _enabled
                        ? 'Automated backups active'
                        : 'Turn on to run backups automatically',
                value: _enabled,
                onChanged: (val) {
                  setState(() {
                    _enabled = val;
                    _save();
                  });
                },
              ),
            ],
          ),
          if (_enabled) ...[
            SettingsGroup(
              title: 'Status & Execution',
              children: [
                AppListTile(
                  icon: Icons.history_outlined,
                  title: 'Last automated backup',
                  subtitle: lastRunFormatted,
                ),
                AppListTile(
                  icon: Icons.folder_zip_outlined,
                  title: 'Backups in storage',
                  subtitle:
                      '$_existingBackupsCount .cpbak backup archive${_existingBackupsCount == 1 ? '' : 's'}',
                ),
                AppListTile(
                  icon: Icons.play_arrow_outlined,
                  iconColor: scheme.primary,
                  title: 'Run backup now',
                  subtitle: 'Manually trigger scheduled backup immediately',
                  trailing:
                      _isRunningManualBackup
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : null,
                  onTap: _isRunningManualBackup ? null : _runManualBackup,
                ),
              ],
            ),
            SettingsGroup(
              title: 'Preferences',
              children: [
                AppListTile(
                  icon: Icons.folder_outlined,
                  title: 'Backups output directory',
                  subtitle:
                      _directory.isNotEmpty
                          ? _directory
                          : 'Default App Storage',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDirectory,
                ),
                AppListTile(
                  icon: Icons.schedule_outlined,
                  title: 'Backup creation frequency',
                  subtitle: _frequency,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showFrequencyDialog,
                ),
                AppSwitchTile(
                  icon: Icons.auto_delete_outlined,
                  title: 'Delete old backups',
                  subtitle:
                      'Automatically delete old backup files to save storage space',
                  value: _deleteOld,
                  onChanged: (val) {
                    setState(() {
                      _deleteOld = val;
                      _save();
                    });
                  },
                ),
                AppSliderTile(
                  icon: Icons.storage_outlined,
                  title: 'Max number of backups',
                  value: _maxBackups,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  valueLabel: (v) => '${v.round()}',
                  onChanged: (val) {
                    setState(() {
                      _maxBackups = val;
                      _save();
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
