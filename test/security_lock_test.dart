import 'package:clinic_pilot/core/providers/security_provider.dart';
import 'package:clinic_pilot/core/services/security_service.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/security/presentation/lock_screen.dart';
import 'package:clinic_pilot/features/security/presentation/security_settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MemorySecurityService extends SecurityService {
  final Map<String, String> _mem = {};
  bool biometricsSupported = true;
  bool biometricsResult = true;

  @override
  Future<bool> isAppLockEnabled() async => _mem['clinicpilot_lock_enabled'] == 'true';

  @override
  Future<bool> isBiometricsEnabled() async => _mem['clinicpilot_biometrics_enabled'] == 'true';

  @override
  Future<int> getAutoLockMinutes() async => int.tryParse(_mem['clinicpilot_auto_lock_minutes'] ?? '5') ?? 5;

  @override
  Future<bool> hasPinSet() async => _mem.containsKey('clinicpilot_pin_hash');

  @override
  Future<void> setPin(String pin, {bool enableBiometrics = false, int autoLockMinutes = 5}) async {
    _mem['clinicpilot_pin_hash'] = 'hash_$pin';
    _mem['clinicpilot_pin_salt'] = 'salt_123';
    _mem['clinicpilot_lock_enabled'] = 'true';
    _mem['clinicpilot_biometrics_enabled'] = enableBiometrics ? 'true' : 'false';
    _mem['clinicpilot_auto_lock_minutes'] = autoLockMinutes.toString();
  }

  @override
  Future<bool> verifyPin(String pin) async {
    return _mem['clinicpilot_pin_hash'] == 'hash_$pin';
  }

  @override
  Future<void> disableAppLock() async {
    _mem.clear();
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    _mem['clinicpilot_biometrics_enabled'] = enabled ? 'true' : 'false';
  }

  @override
  Future<void> setAutoLockMinutes(int minutes) async {
    _mem['clinicpilot_auto_lock_minutes'] = minutes.toString();
  }

  @override
  Future<bool> isBiometricsSupported() async => biometricsSupported;

  @override
  Future<bool> authenticateWithBiometrics({String reason = 'Unlock ClinicPilot'}) async => biometricsResult;
}

void main() {
  group('App Lock & Security Service Unit Tests', () {
    test('sets PIN, verifies and disables lock successfully', () async {
      final service = MemorySecurityService();
      final notifier = AppLockNotifier(service);

      expect(notifier.state.isEnabled, isFalse);

      await notifier.setupPin('1234', enableBiometrics: true, autoLockMinutes: 5);
      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.isBiometricsEnabled, isTrue);
      expect(notifier.state.isLocked, isFalse);

      // Lock app
      notifier.lockNow();
      expect(notifier.state.isLocked, isTrue);

      // Invalid PIN
      final failUnlock = await notifier.verifyAndUnlock('9999');
      expect(failUnlock, isFalse);
      expect(notifier.state.isLocked, isTrue);

      // Valid PIN
      final successUnlock = await notifier.verifyAndUnlock('1234');
      expect(successUnlock, isTrue);
      expect(notifier.state.isLocked, isFalse);

      // Disable lock
      await notifier.disableLock('1234');
      expect(notifier.state.isEnabled, isFalse);
    });

    test('auto-locks app on background after configured timeout', () async {
      final service = MemorySecurityService();
      final notifier = AppLockNotifier(service);

      await notifier.setupPin('5678', enableBiometrics: false, autoLockMinutes: 5);
      expect(notifier.state.isLocked, isFalse);

      // Paused now
      notifier.onAppPaused();

      // Immediately resumed (< 5 min)
      notifier.onAppResumed();
      expect(notifier.state.isLocked, isFalse);

      // Simulate background time > 5 min
      notifier.state = notifier.state.copyWith(
        lastBackgroundTime: DateTime.now().subtract(const Duration(minutes: 6)),
      );
      notifier.onAppResumed();
      expect(notifier.state.isLocked, isTrue);
    });
  });

  group('Security Lock Widget Tests', () {
    testWidgets('renders LockScreen and keypad digits', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = MemorySecurityService();
      await service.setPin('1234', enableBiometrics: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            securityServiceProvider.overrideWithValue(service),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LockScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ClinicPilot Locked'), findsOneWidget);
      expect(find.text('Enter security PIN to access clinical records'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Tap 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
    });

    testWidgets('renders SecuritySettingsCard and opens PinSetupDialog', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final service = MemorySecurityService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            securityServiceProvider.overrideWithValue(service),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SecuritySettingsCard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SECURITY & PRIVACY'), findsOneWidget);
      expect(find.text('Enable App Lock'), findsOneWidget);

      await tester.tap(find.text('Enable App Lock'));
      await tester.pumpAndSettle();

      expect(find.text('Set Up App Lock PIN'), findsOneWidget);
      expect(find.text('New PIN (4-6 digits) *'), findsOneWidget);
      expect(find.text('Confirm PIN *'), findsOneWidget);
    });
  });
}