import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/security_service.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

class AppLockState {
  final bool isInitialized;
  final bool isEnabled;
  final bool isBiometricsEnabled;
  final bool isLocked;
  final int autoLockMinutes;
  final DateTime? lastBackgroundTime;

  const AppLockState({
    this.isInitialized = false,
    this.isEnabled = false,
    this.isBiometricsEnabled = false,
    this.isLocked = false,
    this.autoLockMinutes = 5,
    this.lastBackgroundTime,
  });

  AppLockState copyWith({
    bool? isInitialized,
    bool? isEnabled,
    bool? isBiometricsEnabled,
    bool? isLocked,
    int? autoLockMinutes,
    DateTime? lastBackgroundTime,
    bool clearLastBackgroundTime = false,
  }) {
    return AppLockState(
      isInitialized: isInitialized ?? this.isInitialized,
      isEnabled: isEnabled ?? this.isEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isLocked: isLocked ?? this.isLocked,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      lastBackgroundTime: clearLastBackgroundTime
          ? null
          : (lastBackgroundTime ?? this.lastBackgroundTime),
    );
  }
}

class AppLockNotifier extends StateNotifier<AppLockState> {
  final SecurityService _service;

  AppLockNotifier(this._service) : super(const AppLockState()) {
    _init();
  }

  Future<void> _init() async {
    final enabled = await _service.isAppLockEnabled();
    final biometrics = await _service.isBiometricsEnabled();
    final minutes = await _service.getAutoLockMinutes();

    state = state.copyWith(
      isInitialized: true,
      isEnabled: enabled,
      isBiometricsEnabled: biometrics,
      isLocked: enabled, // Lock immediately on initial launch if enabled
      autoLockMinutes: minutes,
    );
  }

  Future<void> setupPin(String pin, {bool enableBiometrics = false, int autoLockMinutes = 5}) async {
    await _service.setPin(pin, enableBiometrics: enableBiometrics, autoLockMinutes: autoLockMinutes);
    state = state.copyWith(
      isEnabled: true,
      isBiometricsEnabled: enableBiometrics,
      isLocked: false,
      autoLockMinutes: autoLockMinutes,
    );
  }

  Future<bool> verifyAndUnlock(String pin) async {
    if (!state.isEnabled) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    final valid = await _service.verifyPin(pin);
    if (valid) {
      state = state.copyWith(isLocked: false, clearLastBackgroundTime: true);
    }
    return valid;
  }

  Future<bool> unlockWithBiometrics() async {
    if (!state.isEnabled || !state.isBiometricsEnabled) return false;
    final success = await _service.authenticateWithBiometrics();
    if (success) {
      state = state.copyWith(isLocked: false, clearLastBackgroundTime: true);
    }
    return success;
  }

  Future<void> disableLock(String pin) async {
    final valid = await _service.verifyPin(pin);
    if (!valid) throw Exception('Invalid PIN entered');

    await _service.disableAppLock();
    state = state.copyWith(
      isEnabled: false,
      isBiometricsEnabled: false,
      isLocked: false,
    );
  }

  Future<void> toggleBiometrics(bool enabled) async {
    await _service.setBiometricsEnabled(enabled);
    state = state.copyWith(isBiometricsEnabled: enabled);
  }

  Future<void> setAutoLockMinutes(int minutes) async {
    await _service.setAutoLockMinutes(minutes);
    state = state.copyWith(autoLockMinutes: minutes);
  }

  void lockNow() {
    if (state.isEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  void onAppPaused() {
    if (!state.isEnabled) return;
    state = state.copyWith(lastBackgroundTime: DateTime.now());
  }

  void onAppResumed() {
    if (!state.isEnabled || state.isLocked) return;

    final bgTime = state.lastBackgroundTime;
    if (bgTime == null) return;

    final elapsed = DateTime.now().difference(bgTime);
    if (elapsed >= Duration(minutes: state.autoLockMinutes)) {
      state = state.copyWith(isLocked: true, clearLastBackgroundTime: true);
    }
  }
}

final appLockProvider = StateNotifierProvider<AppLockNotifier, AppLockState>((ref) {
  final service = ref.watch(securityServiceProvider);
  return AppLockNotifier(service);
});
