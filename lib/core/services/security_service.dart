import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  static const _pinHashKey = 'clinicpilot_pin_hash';
  static const _saltKey = 'clinicpilot_pin_salt';
  static const _lockEnabledKey = 'clinicpilot_lock_enabled';
  static const _biometricsEnabledKey = 'clinicpilot_biometrics_enabled';
  static const _autoLockMinutesKey = 'clinicpilot_auto_lock_minutes';

  final FlutterSecureStorage _storage;
  final LocalAuthentication _auth;

  SecurityService({
    FlutterSecureStorage? storage,
    LocalAuthentication? auth,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _auth = auth ?? LocalAuthentication();

  Future<bool> isAppLockEnabled() async {
    final val = await _storage.read(key: _lockEnabledKey);
    return val == 'true';
  }

  Future<bool> isBiometricsEnabled() async {
    final val = await _storage.read(key: _biometricsEnabledKey);
    return val == 'true';
  }

  Future<int> getAutoLockMinutes() async {
    final val = await _storage.read(key: _autoLockMinutesKey);
    return int.tryParse(val ?? '5') ?? 5;
  }

  Future<bool> hasPinSet() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin, {bool enableBiometrics = false, int autoLockMinutes = 5}) async {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _hashPin(pin, salt);

    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _lockEnabledKey, value: 'true');
    await _storage.write(key: _biometricsEnabledKey, value: enableBiometrics ? 'true' : 'false');
    await _storage.write(key: _autoLockMinutesKey, value: autoLockMinutes.toString());
  }

  Future<bool> verifyPin(String pin) async {
    final savedHash = await _storage.read(key: _pinHashKey);
    final salt = await _storage.read(key: _saltKey);

    if (savedHash == null || salt == null) return false;
    final inputHash = _hashPin(pin, salt);
    return inputHash == savedHash;
  }

  Future<void> disableAppLock() async {
    await _storage.write(key: _lockEnabledKey, value: 'false');
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _biometricsEnabledKey);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _biometricsEnabledKey, value: enabled ? 'true' : 'false');
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _storage.write(key: _autoLockMinutesKey, value: minutes.toString());
  }

  Future<bool> isBiometricsSupported() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics({String reason = 'Unlock ClinicPilot'}) async {
    try {
      final supported = await isBiometricsSupported();
      if (!supported) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt:clinic_pilot_secure_layer');
    return sha256.convert(bytes).toString();
  }
}
