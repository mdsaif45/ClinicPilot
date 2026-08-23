import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_list_tile.dart';

class PeriodicBackupsScreen extends StatefulWidget {
  const PeriodicBackupsScreen({super.key});

  @override
  State<PeriodicBackupsScreen> createState() => _PeriodicBackupsScreenState();
}

class _PeriodicBackupsScreenState extends State<PeriodicBackupsScreen> {
  late Box _settingsBox;

  bool _enabled = false;
  String _directory = '/Documents/ClinicPilot/backups';
  String _frequency = 'Once per week';
  bool _deleteOld = true;
  double _maxBackups = 10;

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
    _enabled = _settingsBox.get('periodic_backup_enabled', defaultValue: false) == true;
    _directory = _settingsBox.get('periodic_backup_directory', defaultValue: '/Documents/ClinicPilot/backups') as String;
    _frequency = _settingsBox.get('periodic_backup_frequency', defaultValue: 'Once per week') as String;
    _deleteOld = _settingsBox.get('periodic_backup_delete_old', defaultValue: true) == true;
    _maxBackups = (_settingsBox.get('periodic_backup_max_count', defaultValue: 10) as num).toDouble();
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
                children: _frequencies.map((freq) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodic backups'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          SettingsGroup(
            title: 'Schedule',
            children: [
              AppSwitchTile(
                icon: Icons.autorenew_outlined,
                title: 'Enable periodic backups',
                subtitle: _enabled
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
          if (_enabled)
            SettingsGroup(
              title: 'Preferences',
              children: [
                AppListTile(
                  icon: Icons.folder_outlined,
                  title: 'Backups output directory',
                  subtitle: _directory,
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
                  subtitle: 'Automatically delete old backup files to save storage space',
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
      ),
    );
  }
}
