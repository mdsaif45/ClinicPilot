import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_card.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodic backups'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          // Top Switch Header Card
          AppCard(
            color: _enabled
                ? scheme.primaryContainer.withValues(alpha: 0.40)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Enable periodic backups',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
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
          ),
          const SizedBox(height: Spacing.xl),

          if (_enabled) ...[
            // Output Directory
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Backups output directory',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  _directory,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              onTap: _pickDirectory,
            ),
            const Divider(),

            // Backup Frequency
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Backup creation frequency',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  _frequency,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              onTap: _showFrequencyDialog,
            ),
            const Divider(),

            // Delete old backups
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Delete old backups',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  'Automatically delete old backup files to save storage space',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              value: _deleteOld,
              onChanged: (val) {
                setState(() {
                  _deleteOld = val;
                  _save();
                });
              },
            ),
            const Divider(),

            // Max Number of Backups
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max number of backups',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_maxBackups.round()}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Slider(
                    value: _maxBackups,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    onChanged: (val) {
                      setState(() {
                        _maxBackups = val;
                        _save();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
