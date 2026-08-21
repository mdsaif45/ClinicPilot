import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/providers/security_provider.dart';
import '../../../core/services/app_haptics.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  String? _errorMessage;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricUnlock();
    });
  }

  Future<void> _tryBiometricUnlock() async {
    final lockState = ref.read(appLockProvider);
    if (!lockState.isEnabled || !lockState.isBiometricsEnabled || _authenticating) return;

    setState(() => _authenticating = true);
    final success = await ref.read(appLockProvider.notifier).unlockWithBiometrics();
    if (!mounted) return;
    setState(() => _authenticating = false);

    if (success) {
      AppHaptics.success();
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length >= 6) return;
    AppHaptics.selection();
    setState(() {
      _enteredPin += digit;
      _errorMessage = null;
    });

    if (_enteredPin.length >= 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    AppHaptics.light();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    final valid = await ref.read(appLockProvider.notifier).verifyAndUnlock(_enteredPin);
    if (!mounted) return;

    if (valid) {
      AppHaptics.success();
    } else {
      if (_enteredPin.length >= 6) {
        AppHaptics.error();
        setState(() {
          _errorMessage = 'Incorrect PIN';
          _enteredPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lockState = ref.watch(appLockProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Shield Icon & Title
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'ClinicPilot Locked',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Enter security PIN to access clinical records',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? scheme.primary : scheme.surfaceContainerHighest,
                      border: Border.all(
                        color: isFilled ? scheme.primary : scheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: Spacing.md),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // Numeric Keypad Grid (1-9, Biometric/Clear, 0, Backspace)
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3']),
                    const SizedBox(height: Spacing.md),
                    _buildRow(['4', '5', '6']),
                    const SizedBox(height: Spacing.md),
                    _buildRow(['7', '8', '9']),
                    const SizedBox(height: Spacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (lockState.isBiometricsEnabled)
                          _buildIconButton(
                            icon: Icons.fingerprint,
                            onTap: _tryBiometricUnlock,
                          )
                        else
                          const SizedBox(width: 64, height: 64),
                        _buildDigitButton('0'),
                        _buildIconButton(
                          icon: Icons.backspace_outlined,
                          onTap: _onBackspace,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitButton(d)).toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        child: Text(
          digit,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Icon(icon, size: 28, color: scheme.onSurfaceVariant),
      ),
    );
  }
}