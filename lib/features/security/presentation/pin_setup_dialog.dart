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

  int _autoLockMinutes = 5;
  bool _submitting = false;

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
        enableBiometrics: false,
        autoLockMinutes: _autoLockMinutes,
      );

      AppHaptics.success();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isChangingPin ? '4-digit PIN updated successfully' : 'App Lock enabled'),
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
      title: widget.isChangingPin ? 'Change 4-Digit PIN' : 'Set Up 4-Digit PIN',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isChangingPin) ...[
              TextFormField(
                controller: _oldPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Current 4-Digit PIN *',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().length != 4 ? 'Enter exactly 4 digits' : null,
              ),
              const SizedBox(height: Spacing.sm),
            ],

            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'New 4-Digit PIN *',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
              validator: (v) {
                final text = v?.trim() ?? '';
                if (text.length != 4 || int.tryParse(text) == null) {
                  return 'PIN must be exactly 4 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.sm),

            TextFormField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Confirm 4-Digit PIN *',
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

            if (!widget.isChangingPin)
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
    );
  }
}