import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/providers/security_provider.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../core/widgets/picker_field.dart';
import 'pin_setup_dialog.dart';

class SecurityPrivacyScreen extends ConsumerWidget {
  const SecurityPrivacyScreen({super.key});

  void _openPinSetup(BuildContext context, {bool isChanging = false}) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => PinSetupDialog(isChangingPin: isChanging),
    );
  }

  void _confirmDisable(BuildContext context, WidgetRef ref) {
    final pinController = TextEditingController();
    AppHaptics.error();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable App Lock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your current 4-digit PIN to turn off App Lock:'),
            const SizedBox(height: Spacing.sm),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Current 4-Digit PIN',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              try {
                await ref.read(appLockProvider.notifier).disableLock(pinController.text.trim());
                AppHaptics.success();
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App Lock disabled')),
                  );
                }
              } catch (_) {
                AppHaptics.error();
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect 4-digit PIN')),
                  );
                }
              }
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(appLockProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security & Privacy',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          SettingsGroup(
            title: 'App Lock & Access Control',
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                secondary: Icon(
                  lockState.isEnabled ? Icons.lock_outline : Icons.lock_open_outlined,
                  color: lockState.isEnabled ? scheme.primary : scheme.onSurfaceVariant,
                ),
                title: const Text('Enable App Lock'),
                subtitle: Text(
                  lockState.isEnabled
                      ? '4-digit PIN protection active'
                      : 'Protect patient records with a 4-digit PIN',
                ),
                value: lockState.isEnabled,
                onChanged: (val) {
                  if (val) {
                    _openPinSetup(context);
                  } else {
                    _confirmDisable(context, ref);
                  }
                },
              ),
              if (lockState.isEnabled) ...[
                AppListTile(
                  icon: Icons.password,
                  title: 'Change 4-Digit PIN',
                  subtitle: 'Update your 4-digit security PIN',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openPinSetup(context, isChanging: true),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
                  child: PickerField<int>(
                    label: 'Auto-Lock Inactivity Timeout',
                    value: lockState.autoLockMinutes,
                    options: const [
                      PickerOption(value: 0, label: 'Immediately on background'),
                      PickerOption(value: 1, label: 'After 1 minute'),
                      PickerOption(value: 5, label: 'After 5 minutes (Recommended)'),
                      PickerOption(value: 15, label: 'After 15 minutes'),
                      PickerOption(value: 30, label: 'After 30 minutes'),
                    ],
                    onChanged: (val) {
                      AppHaptics.selection();
                      ref.read(appLockProvider.notifier).setAutoLockMinutes(val);
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
