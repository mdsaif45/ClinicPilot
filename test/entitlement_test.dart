import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/entitlement/entitlement_model.dart';
import 'package:clinic_pilot/core/entitlement/entitlement_service.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/pro_badge.dart';
import 'package:clinic_pilot/features/settings/presentation/widgets/pro_upgrade_sheet.dart';
import 'package:clinic_pilot/features/settings/presentation/widgets/subscription_status_card.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('EntitlementState Model Unit Tests', () {
    test(
      'default state represents Free tier with core features and 0 locks',
      () {
        const state = EntitlementState();
        expect(state.tier, SubscriptionTier.free);
        expect(state.isPro, isFalse);
        expect(state.isTrial, isFalse);
        expect(state.badgeLabel, 'FREE');
        expect(state.isFeatureUnlocked(AppFeature.cloudAutoSync), isFalse);
        expect(
          state.isFeatureUnlocked(AppFeature.customLetterheadBranding),
          isFalse,
        );
        expect(
          state.isFeatureUnlocked(AppFeature.multiClinicManagement),
          isFalse,
        );
        expect(state.isFeatureUnlocked(AppFeature.bulkExportXlsx), isFalse);
      },
    );

    test('active 30-day Pro Trial has Pro access and calculates countdown', () {
      final now = DateTime.now();
      final state = EntitlementState(
        tier: SubscriptionTier.proTrial,
        trialStartDate: now.subtract(const Duration(days: 5)),
      );

      expect(state.isPro, isTrue);
      expect(state.isTrial, isTrue);
      expect(state.isTrialExpired, isFalse);
      expect(state.daysRemainingInTrial, inInclusiveRange(25, 26));
      expect(state.badgeLabel, 'PRO TRIAL');
      expect(state.isFeatureUnlocked(AppFeature.cloudAutoSync), isTrue);
      expect(
        state.isFeatureUnlocked(AppFeature.customLetterheadBranding),
        isTrue,
      );
      expect(state.isFeatureUnlocked(AppFeature.multiClinicManagement), isTrue);
      expect(state.isFeatureUnlocked(AppFeature.bulkExportXlsx), isTrue);
    });

    test('expired Pro Trial falls back gracefully without Pro privileges', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 35));
      final state = EntitlementState(
        tier: SubscriptionTier.proTrial,
        trialStartDate: pastDate,
      );

      expect(state.isTrialExpired, isTrue);
      expect(state.isPro, isFalse);
      expect(state.daysRemainingInTrial, 0);
      expect(state.badgeLabel, 'FREE');
      expect(state.isFeatureUnlocked(AppFeature.cloudAutoSync), isFalse);
      expect(
        state.isFeatureUnlocked(AppFeature.multiClinicManagement),
        isFalse,
      );
      expect(state.isFeatureUnlocked(AppFeature.bulkExportXlsx), isFalse);
    });

    test('active Pro tier has full access and PRO badge', () {
      final state = EntitlementState(
        tier: SubscriptionTier.proActive,
        subscriptionExpiryDate: DateTime.now().add(const Duration(days: 100)),
        planName: 'annual_pro',
      );

      expect(state.isPro, isTrue);
      expect(state.isTrial, isFalse);
      expect(state.badgeLabel, 'PRO');
      expect(state.isFeatureUnlocked(AppFeature.cloudAutoSync), isTrue);
      expect(state.isFeatureUnlocked(AppFeature.taxAnalytics), isTrue);
      expect(state.isFeatureUnlocked(AppFeature.multiClinicComparison), isTrue);
      expect(state.isFeatureUnlocked(AppFeature.multiClinicManagement), isTrue);
      expect(state.isFeatureUnlocked(AppFeature.bulkExportXlsx), isTrue);
    });

    test('formatted getters return clean presentation descriptors', () {
      const freeState = EntitlementState();
      expect(freeState.formattedPlanName, 'Free Plan');
      expect(freeState.formattedBillingCycle, 'Free Forever');
      expect(
        freeState.formattedExpiryDescription,
        'No expiration (Free Forever)',
      );

      final annualPro = EntitlementState(
        tier: SubscriptionTier.proActive,
        planName: 'annual_pro',
        subscriptionExpiryDate: DateTime.now().add(const Duration(days: 300)),
      );
      expect(annualPro.formattedPlanName, 'Annual Pro Plan');
      expect(annualPro.formattedBillingCycle, '₹1,999 / year');
      expect(annualPro.formattedExpiryDescription, contains('days remaining'));

      const monthlyPro = EntitlementState(
        tier: SubscriptionTier.proActive,
        planName: 'monthly_pro',
      );
      expect(monthlyPro.formattedPlanName, 'Monthly Pro Plan');
      expect(monthlyPro.formattedBillingCycle, '₹199 / month');

      const lifetime = EntitlementState(
        tier: SubscriptionTier.proActive,
        planName: 'lifetime',
      );
      expect(lifetime.formattedPlanName, 'Enterprise Lifetime License');
      expect(lifetime.formattedBillingCycle, 'One-Time License');
      expect(
        lifetime.formattedExpiryDescription,
        'Indefinite (Lifetime License)',
      );
    });
  });

  group('EntitlementService & Database Tests', () {
    const service = EntitlementService();

    test(
      'initializes 30-day Pro trial if empty and remains idempotent',
      () async {
        final before = await service.getEntitlementState(db);
        expect(before.tier, SubscriptionTier.free);

        await service.initializeTrialIfNeeded(db);
        final after = await service.getEntitlementState(db);

        expect(after.tier, SubscriptionTier.proTrial);
        expect(after.isPro, isTrue);
        expect(after.trialStartDate, isNotNull);
        expect(after.daysRemainingInTrial, 30);

        final originalStart = after.trialStartDate;

        // Second call should not overwrite existing start date
        await service.initializeTrialIfNeeded(db);
        final again = await service.getEntitlementState(db);
        expect(again.trialStartDate, originalStart);
      },
    );

    test('redeems valid promo code CLINICBETA2026 successfully', () async {
      final result = await service.redeemAccessCode(db, 'clinicbeta2026');
      expect(result, isTrue);

      final state = await service.getEntitlementState(db);
      expect(state.tier, SubscriptionTier.proActive);
      expect(state.isPro, isTrue);
      expect(state.planName, 'annual_promo');
      expect(state.redeemedCode, 'CLINICBETA2026');
      expect(state.subscriptionExpiryDate, isNotNull);
    });

    test('redeems LIFETIMEPRO voucher without expiry limitation', () async {
      final result = await service.redeemAccessCode(db, 'LIFETIMEPRO');
      expect(result, isTrue);

      final state = await service.getEntitlementState(db);
      expect(state.tier, SubscriptionTier.proActive);
      expect(state.planName, 'lifetime');
      expect(state.isPro, isTrue);
    });

    test('rejects invalid promo voucher code', () async {
      final result = await service.redeemAccessCode(db, 'INVALID_CODE_XYZ');
      expect(result, isFalse);

      final state = await service.getEntitlementState(db);
      expect(state.tier, SubscriptionTier.free);
      expect(state.isPro, isFalse);
    });

    test(
      'activates manual subscription and resets cleanly for testing',
      () async {
        await service.activateSubscription(
          db,
          plan: 'monthly_pro',
          durationMonths: 1,
        );

        var state = await service.getEntitlementState(db);
        expect(state.tier, SubscriptionTier.proActive);
        expect(state.planName, 'monthly_pro');
        expect(state.isPro, isTrue);

        await service.resetForTesting(db);
        state = await service.getEntitlementState(db);
        expect(state.tier, SubscriptionTier.free);
        expect(state.isPro, isFalse);
      },
    );

    test(
      'cancels subscription gracefully back to Free tier preserving trial record',
      () async {
        await service.initializeTrialIfNeeded(db);
        await service.activateSubscription(db, plan: 'annual_pro');

        var state = await service.getEntitlementState(db);
        expect(state.tier, SubscriptionTier.proActive);
        expect(state.isPro, isTrue);

        await service.cancelSubscription(db);
        state = await service.getEntitlementState(db);
        expect(state.tier, SubscriptionTier.free);
        expect(state.isPro, isFalse);
        expect(state.trialStartDate, isNotNull); // Initial trial preserved
      },
    );

    test('changes billing plan between annual and monthly cleanly', () async {
      await service.activateSubscription(
        db,
        plan: 'monthly_pro',
        durationMonths: 1,
      );
      var state = await service.getEntitlementState(db);
      expect(state.planName, 'monthly_pro');

      await service.changePlan(db, newPlan: 'annual_pro');
      state = await service.getEntitlementState(db);
      expect(state.planName, 'annual_pro');
      expect(state.subscriptionExpiryDate, isNotNull);
    });
  });

  group('Entitlement Widget Tests', () {
    testWidgets('ProBadge renders label and sparkles icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Center(child: ProBadge(label: 'PRO'))),
        ),
      );

      expect(find.text('PRO'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets(
      'SubscriptionStatusCard renders in Settings with trial countdown',
      (tester) async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        const service = EntitlementService();
        await service.initializeTrialIfNeeded(db);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const Scaffold(body: SubscriptionStatusCard()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Pro Beta Trial'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.byType(ProBadge), findsOneWidget);
      },
    );

    testWidgets(
      'ProUpgradeSheet renders pricing plans, guarantee, and voucher section',
      (tester) async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Builder(
                  builder:
                      (context) => ElevatedButton(
                        onPressed: () => ProUpgradeSheet.show(context),
                        child: const Text('Open Sheet'),
                      ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('ClinicPilot Pro'), findsOneWidget);
        expect(find.text('Annual Plan'), findsOneWidget);
        expect(find.text('₹1,999'), findsOneWidget);
        expect(find.text('Monthly Plan'), findsOneWidget);
        expect(find.text('₹199'), findsOneWidget);
        expect(find.text('Doctor Data Guarantee'), findsOneWidget);
        expect(
          find.text('Have a Beta Voucher or Access Code?'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ProUpgradeSheet renders Enterprise Subscription Management when doctor is Active Pro',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 1400);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const service = EntitlementService();
        await service.activateSubscription(
          db,
          plan: 'annual_pro',
          durationMonths: 12,
        );

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Builder(
                  builder:
                      (context) => ElevatedButton(
                        onPressed: () => ProUpgradeSheet.show(context),
                        child: const Text('Open Sheet'),
                      ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Enterprise Management View expectations
        expect(find.text('Subscription & License'), findsOneWidget);
        expect(find.text('ACTIVE'), findsOneWidget);
        expect(find.text('Annual Pro Plan'), findsOneWidget);
        expect(find.text('Status: Active • Auto-renewing'), findsOneWidget);
        expect(find.text('Active Enterprise Entitlements:'), findsOneWidget);
        expect(find.text('Doctor Data Guarantee'), findsOneWidget);
        expect(find.text('Manage Plan & Billing:'), findsOneWidget);
        expect(find.text('View Tax Receipt / Invoice'), findsOneWidget);
        expect(find.text('Cancel Subscription'), findsOneWidget);

        // Crucial check: Upgrade sales pitch cards should NOT appear
        expect(find.text('SAVE 17%'), findsNothing);
        expect(find.text('Continue with Free Plan'), findsNothing);

        // Open Tax Receipt Dialog
        await tester.tap(find.text('View Tax Receipt / Invoice'));
        await tester.pumpAndSettle();

        expect(find.text('Practice Tax Receipt'), findsOneWidget);
        expect(find.text('PAID'), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Open Cancel Dialog
        await tester.tap(find.text('Cancel Subscription'));
        await tester.pumpAndSettle();

        expect(find.text('Cancel Subscription?'), findsOneWidget);
        expect(find.text('Keep My Subscription'), findsOneWidget);
        expect(find.text('Confirm Cancellation'), findsOneWidget);

        await tester.tap(find.text('Keep My Subscription'));
        await tester.pumpAndSettle();
      },
    );
  });
}
