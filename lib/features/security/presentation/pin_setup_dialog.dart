import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/providers/security_provider.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/picker_field.dart';

class PinSetupDialog extends ConsumerStatefulWidget {
  final bool isChangingPin;

  const PinSetupDialog({super.key, this.isChangingPin = false});

  @override
  ConsumerState<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends ConsumerState<PinSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _enableBiometrics = true;
  int _autoLockMinutes = 5;
  bool _biometricsAvailable = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final service = ref.read(securityServiceProvider);
    final supported = await service.isBiometricsSupported();
    if (mounted) {
      setState(() => _biometricsAvailable = supported);
    }
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    final notifier = ref.read(appLockProvider.notifier);
    final service = ref.read(securityServiceProvider);

    try {
      if (widget.isChangingPin) {
        final oldValid = await service.verifyPin(_oldPinController.text.trim());
        if (!oldValid) {
          AppHaptics.error();
          if (mounted) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Current PIN is incorrect')),
            );
          }
          return;
        }
      }

      await notifier.setupPin(
        _pinController.text.trim(),
        enableBiometrics: _enableBiometrics && _biometricsAvailable,
        autoLockMinutes: _autoLockMinutes,
      );

      AppHaptics.success();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isChangingPin ? 'App PIN updated successfully' : 'App Lock enabled'),
          ),
        );
      }
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: widget.isChangingPin ? 'Change Security PIN' : 'Set Up App Lock PIN',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(widget.isChangingPin ? 'Update PIN' : 'Enable Lock'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isChangingPin) ...[
                TextFormField(
                  controller: _oldPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Current PIN *',
                    hintText: 'Enter current PIN',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().length < 4 ? 'Enter at least 4 digits' : null,
                ),
                const SizedBox(height: Spacing.sm),
              ],

              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'New PIN (4-6 digits) *',
                  hintText: 'Enter 4-6 digit numeric PIN',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.length < 4 || text.length > 6) {
                    return 'PIN must be between 4 and 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.sm),

              TextFormField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN *',
                  hintText: 'Re-enter same PIN',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (v) {
                  if (v?.trim() != _pinController.text.trim()) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Spacing.md),

              if (_biometricsAvailable) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _enableBiometrics,
                  onChanged: (val) => setState(() => _enableBiometrics = val),
                  title: const Text('Enable Biometric Unlock'),
                  subtitle: const Text('Unlock with Fingerprint or Face ID'),
                  secondary: const Icon(Icons.fingerprint),
                ),
                const SizedBox(height: Spacing.sm),
              ],

              PickerField<int>(
                label: 'Auto-Lock Timeout',
                value: _autoLockMinutes,
                options: const [
                  PickerOption(value: 0, label: 'Immediately on background'),
                  PickerOption(value: 1, label: 'After 1 minute'),
                  PickerOption(value: 5, label: 'After 5 minutes (Recommended)'),
                  PickerOption(value: 15, label: 'After 15 minutes'),
                  PickerOption(value: 30, label: 'After 30 minutes'),
                ],
                onChanged: (val) => setState(() => _autoLockMinutes = val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}