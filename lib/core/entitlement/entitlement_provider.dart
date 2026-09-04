import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import 'entitlement_model.dart';
import 'entitlement_service.dart';

/// Provider for the singleton [EntitlementService].
final entitlementServiceProvider = Provider<EntitlementService>((ref) {
  return const EntitlementService();
});

/// Reactive stream provider emitting the current [EntitlementState].
/// Also ensures that new installations start with an automatic 30-day Pro trial.
final entitlementStreamProvider = StreamProvider<EntitlementState>((ref) {
  final db = ref.watch(databaseProvider);
  final service = ref.watch(entitlementServiceProvider);

  // Proactively initialize 30-day beta trial if this is first launch
  service.initializeTrialIfNeeded(db);

  return service.watchEntitlementState(db);
});

/// Quick boolean selector returning true if current user has active Pro privileges.
final isProProvider = Provider<bool>((ref) {
  final state = ref.watch(entitlementStreamProvider).value;
  return state?.isPro ?? false;
});

/// Controller providing entitlement actions (code redemption, manual upgrades, resets).
class EntitlementController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  EntitlementController(this._ref) : super(const AsyncValue.data(null));

  /// Redeem an access/voucher code. Returns true if valid and activated.
  Future<bool> redeemCode(String code) async {
    state = const AsyncValue.loading();
    try {
      final db = _ref.read(databaseProvider);
      final service = _ref.read(entitlementServiceProvider);
      final success = await service.redeemAccessCode(db, code);
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Activate a subscription plan.
  Future<void> activateSubscription({
    required String plan,
    int durationMonths = 12,
  }) async {
    state = const AsyncValue.loading();
    try {
      final db = _ref.read(databaseProvider);
      final service = _ref.read(entitlementServiceProvider);
      await service.activateSubscription(
        db,
        plan: plan,
        durationMonths: durationMonths,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset to free tier (useful for testing or debugging).
  Future<void> resetForTesting() async {
    state = const AsyncValue.loading();
    try {
      final db = _ref.read(databaseProvider);
      final service = _ref.read(entitlementServiceProvider);
      await service.resetForTesting(db);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final entitlementControllerProvider =
    StateNotifierProvider<EntitlementController, AsyncValue<void>>((ref) {
      return EntitlementController(ref);
    });
