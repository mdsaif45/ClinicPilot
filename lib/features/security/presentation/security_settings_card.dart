import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/providers/security_provider.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/picker_field.dart';
import 'pin_setup_dialog.dart';

class SecuritySettingsCard extends ConsumerWidget {
  const SecuritySettingsCard({super.key});

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
            const Text('Enter your current PIN to turn off App Lock:'),
            const SizedBox(height: Spacing.sm),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Current PIN',
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
                    const SnackBar(content: Text('Incorrect PIN')),
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: scheme.primary, size: 20),
              const SizedBox(width: Spacing.sm),
              Text(
                'Security & Privacy',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Protect patient health data with PIN & biometric authentication.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Enable Lock Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: lockState.isEnabled,
            title: const Text('Enable App Lock'),
            subtitle: Text(
              lockState.isEnabled
                  ? 'PIN protection is active'
                  : 'Require PIN to open app',
            ),
            secondary: Icon(
              lockState.isEnabled ? Icons.lock : Icons.lock_open,
              color: lockState.isEnabled ? scheme.primary : scheme.onSurfaceVariant,
            ),
            onChanged: (val) {
              if (val) {
                _openPinSetup(context);
              } else {
                _confirmDisable(context, ref);
              }
            },
          ),

          if (lockState.isEnabled) ...[
            const Divider(height: Spacing.lg),

            // Change PIN Button
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.password),
              title: const Text('Change Security PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openPinSetup(context, isChanging: true),
            ),

            // Biometrics Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: lockState.isBiometricsEnabled,
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Unlock with Fingerprint or Face ID'),
              secondary: const Icon(Icons.fingerprint),
              onChanged: (val) {
                AppHaptics.selection();
                ref.read(appLockProvider.notifier).toggleBiometrics(val);
              },
            ),

            // Auto-lock dropdown
            const SizedBox(height: Spacing.xs),
            PickerField<int>(
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
            const SizedBox(height: Spacing.md),

            // Lock Now Button
            OutlinedButton.icon(
              onPressed: () {
                AppHaptics.medium();
                ref.read(appLockProvider.notifier).lockNow();
              },
              icon: const Icon(Icons.lock_clock, size: 16),
              label: const Text('Lock App Now'),
            ),
          ],
        ],
      ),
    );
  }
}