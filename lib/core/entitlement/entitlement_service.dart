import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import 'entitlement_model.dart';

const kSubscriptionTierKey = 'subscription_tier';
const kTrialStartDateKey = 'trial_start_date';
const kSubscriptionExpiryKey = 'subscription_expiry_date';
const kSubscriptionPlanKey = 'subscription_plan';
const kRedeemedCodeKey = 'redeemed_access_code';

/// Known promo / access voucher codes for beta launches, conferences, and manual UPI activations.
final Map<String, ({String plan, int durationMonths})> kValidPromoCodes = {
  'CLINICBETA2026': (plan: 'annual_promo', durationMonths: 12),
  'LIFETIMEPRO': (plan: 'lifetime', durationMonths: 1200), // 100 years
  'PRO1YEAR': (plan: 'annual_voucher', durationMonths: 12),
  'AYUSH2026': (plan: 'ayush_scholarship', durationMonths: 12),
  'TESTPRO': (plan: 'qa_testing', durationMonths: 1),
};

/// Service managing doctor subscription tiers, 30-day Pro trials,
/// and voucher redemption.
class EntitlementService {
  const EntitlementService();

  /// Parse the current entitlement state from the local SQLite settings table.
  Future<EntitlementState> getEntitlementState(AppDatabase db) async {
    final rows =
        await (db.select(db.settings)..where(
          (t) => t.key.isIn([
            kSubscriptionTierKey,
            kTrialStartDateKey,
            kSubscriptionExpiryKey,
            kSubscriptionPlanKey,
            kRedeemedCodeKey,
          ]),
        )).get();

    return _parseRows(rows);
  }

  /// Watch reactive entitlement state changes via Drift stream.
  Stream<EntitlementState> watchEntitlementState(AppDatabase db) {
    return (db.select(db.settings)..where(
      (t) => t.key.isIn([
        kSubscriptionTierKey,
        kTrialStartDateKey,
        kSubscriptionExpiryKey,
        kSubscriptionPlanKey,
        kRedeemedCodeKey,
      ]),
    )).watch().map(_parseRows);
  }

  EntitlementState _parseRows(List<Setting> rows) {
    String? tierStr;
    DateTime? trialStart;
    DateTime? expiry;
    String? plan;
    String? code;

    for (final row in rows) {
      if (row.key == kSubscriptionTierKey) tierStr = row.value;
      if (row.key == kTrialStartDateKey && row.value.isNotEmpty) {
        trialStart = DateTime.tryParse(row.value);
      }
      if (row.key == kSubscriptionExpiryKey && row.value.isNotEmpty) {
        expiry = DateTime.tryParse(row.value);
      }
      if (row.key == kSubscriptionPlanKey) plan = row.value;
      if (row.key == kRedeemedCodeKey) code = row.value;
    }

    SubscriptionTier tier = SubscriptionTier.free;
    if (tierStr != null) {
      switch (tierStr) {
        case 'proActive':
        case 'pro':
          tier = SubscriptionTier.proActive;
          break;
        case 'proTrial':
        case 'trial':
          tier = SubscriptionTier.proTrial;
          break;
        case 'proExpired':
        case 'expired':
          tier = SubscriptionTier.proExpired;
          break;
        default:
          tier = SubscriptionTier.free;
      }
    }

    return EntitlementState(
      tier: tier,
      trialStartDate: trialStart,
      subscriptionExpiryDate: expiry,
      planName: plan,
      redeemedCode: code,
    );
  }

  /// Ensure a 30-day Pro trial is automatically started for new doctors
  /// upon first check if no prior trial was initialized.
  Future<void> initializeTrialIfNeeded(AppDatabase db) async {
    final existingStart =
        await (db.select(db.settings)
          ..where((t) => t.key.equals(kTrialStartDateKey))).getSingleOrNull();

    if (existingStart == null) {
      final now = DateTime.now();
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: kTrialStartDateKey,
              value: now.toIso8601String(),
              updatedAt: drift.Value(now),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: kSubscriptionTierKey,
              value: SubscriptionTier.proTrial.name,
              updatedAt: drift.Value(now),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: kSubscriptionPlanKey,
              value: 'beta_30day_trial',
              updatedAt: drift.Value(now),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
    }
  }

  /// Redeem an access or promo code. Returns true if the code was valid and applied.
  Future<bool> redeemAccessCode(AppDatabase db, String rawCode) async {
    final normalized = rawCode.trim().toUpperCase();
    final promo = kValidPromoCodes[normalized];
    if (promo == null) {
      return false;
    }

    final now = DateTime.now();
    final expiry = now.add(Duration(days: promo.durationMonths * 30));

    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kSubscriptionTierKey,
            value: SubscriptionTier.proActive.name,
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kSubscriptionPlanKey,
            value: promo.plan,
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kSubscriptionExpiryKey,
            value: expiry.toIso8601String(),
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kRedeemedCodeKey,
            value: normalized,
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );

    return true;
  }

  /// Manually activate a subscription (e.g. following Google Play In-App Purchase or Razorpay).
  Future<void> activateSubscription(
    AppDatabase db, {
    required String plan,
    int durationMonths = 12,
  }) async {
    final now = DateTime.now();
    final expiry = now.add(Duration(days: durationMonths * 30));

    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kSubscriptionTierKey,
            value: SubscriptionTier.proActive.name,
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kSubscriptionPlanKey,
            value: plan,
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kSubscriptionExpiryKey,
            value: expiry.toIso8601String(),
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  /// Reset entitlement back to Free for testing or downgrades.
  Future<void> resetForTesting(AppDatabase db) async {
    final now = DateTime.now();
    await (db.delete(db.settings)..where(
      (t) => t.key.isIn([
        kSubscriptionTierKey,
        kTrialStartDateKey,
        kSubscriptionExpiryKey,
        kSubscriptionPlanKey,
        kRedeemedCodeKey,
      ]),
    )).go();

    await db
        .into(db.settings)
        .insert(
          SettingsCompanion.insert(
            key: kSubscriptionTierKey,
            value: SubscriptionTier.free.name,
            updatedAt: drift.Value(now),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }
}
