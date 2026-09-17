import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/entitlement/entitlement_dev_override.dart';
import 'package:clinic_pilot/core/entitlement/entitlement_model.dart';
import 'package:clinic_pilot/core/entitlement/entitlement_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/export_format_sheet.dart';
import 'package:clinic_pilot/core/widgets/feature_lock.dart';
import 'package:clinic_pilot/features/clinics/presentation/add_edit_clinic_dialog.dart';
import 'package:clinic_pilot/features/clinics/presentation/clinics_screen.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/growth/presentation/clinic_comparison_screen.dart';
import 'package:clinic_pilot/features/growth/presentation/profit_summary_screen.dart';
import 'package:clinic_pilot/features/growth/providers/clinic_comparison_provider.dart';
import 'package:clinic_pilot/features/growth/providers/profit_provider.dart';
import 'package:clinic_pilot/features/settings/presentation/widgets/pro_upgrade_sheet.dart';

class _FakeActiveClinicIdNotifier extends ActiveClinicIdNotifier {
  _FakeActiveClinicIdNotifier(super.db) {
    state = 'c1';
  }
  @override
  Future<void> setClinicId(String newId) async {
    state = newId;
  }
}

/// Overrides [entitlementStreamProvider] with a fixed state and short-circuits
/// the data providers behind each gated screen, so these tests exercise only
/// the gate itself rather than needing a seeded database.
///
/// Both data streams emit a real (empty-of-clinics/zeroed) value rather than
/// [Stream.empty] — an unlocked screen renders its `loading` state forever
/// against a stream that never emits, which hangs `pumpAndSettle`.
List<Override> _overridesFor(EntitlementState state) => [
  entitlementStreamProvider.overrideWith((ref) => Stream.value(state)),
  profitSummaryProvider.overrideWith(
    (ref) => Stream.value(
      const ProfitSummary(
        totalIncome: 0,
        totalExpenses: 0,
        netProfit: 0,
        dailyProfit: {},
        daysWithActivity: 0,
      ),
    ),
  ),
  clinicComparisonProvider.overrideWith((ref) => Stream.value(const [])),
];

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  EntitlementState state, {
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [..._overridesFor(state), ...extraOverrides],
      child: MaterialApp(theme: AppTheme.lightTheme, home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('forceProInDebug dev override', () {
    test('is off by default so isProProvider reflects real entitlement state, '
        'not a switch left on accidentally', () async {
      // _forceProSwitch ships committed to false, so this must be false
      // even though `flutter test` itself runs in a debug-like mode.
      // If this ever flips true, the switch was left on in the source
      // file rather than reverted after local testing.
      expect(forceProInDebug, isFalse);

      final container = ProviderContainer(
        overrides: [
          entitlementStreamProvider.overrideWith(
            (ref) => Stream.value(const EntitlementState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      // StreamProvider emits asynchronously even for Stream.value, so wait
      // for the first emission before reading — otherwise `.value` is still
      // null and this would pass for the wrong reason (null ?? false ==
      // false, not a real free-tier check).
      await container.read(entitlementStreamProvider.future);

      // A free-tier doctor stays free-tier: the override does not leak
      // into isProProvider by default.
      expect(container.read(isProProvider), isFalse);
    });
  });

  group('featureUnlockedProvider', () {
    test('free tier has no Pro features unlocked', () async {
      final container = ProviderContainer(
        overrides: [
          entitlementStreamProvider.overrideWith(
            (ref) => Stream.value(const EntitlementState()),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(entitlementStreamProvider.future);

      expect(
        container.read(featureUnlockedProvider(AppFeature.taxAnalytics)),
        isFalse,
      );
      expect(
        container.read(
          featureUnlockedProvider(AppFeature.multiClinicComparison),
        ),
        isFalse,
      );
    });

    test('active Pro tier unlocks every feature', () async {
      final container = ProviderContainer(
        overrides: [
          entitlementStreamProvider.overrideWith(
            (ref) => Stream.value(
              EntitlementState(
                tier: SubscriptionTier.proActive,
                subscriptionExpiryDate: DateTime.now().add(
                  const Duration(days: 30),
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(entitlementStreamProvider.future);

      for (final feature in AppFeature.values) {
        expect(container.read(featureUnlockedProvider(feature)), isTrue);
      }
    });
  });

  group('Profit Summary — taxAnalytics gate', () {
    testWidgets('free tier sees an upgrade prompt, not the report', (
      tester,
    ) async {
      await _pump(
        tester,
        const ProfitSummaryScreen(),
        const EntitlementState(),
      );

      expect(find.byType(FeatureLockedView), findsOneWidget);
      expect(
        find.text('Practice Tax & P&L Analytics is a Pro feature'),
        findsOneWidget,
      );
      expect(find.text('Upgrade to ClinicPilot Pro'), findsOneWidget);

      await tester.tap(find.text('Upgrade to ClinicPilot Pro'));
      await tester.pumpAndSettle();

      expect(find.byType(ProUpgradeSheet), findsOneWidget);
    });

    testWidgets('Pro tier reaches the real screen, not the lock', (
      tester,
    ) async {
      await _pump(
        tester,
        const ProfitSummaryScreen(),
        EntitlementState(
          tier: SubscriptionTier.proActive,
          subscriptionExpiryDate: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      expect(find.byType(FeatureLockedView), findsNothing);
      expect(find.text('Profit Summary'), findsOneWidget);
    });
  });

  group('Clinic Comparison — multiClinicComparison gate', () {
    testWidgets('free tier sees an upgrade prompt, not the comparison table', (
      tester,
    ) async {
      await _pump(
        tester,
        const ClinicComparisonScreen(),
        const EntitlementState(),
      );

      expect(find.byType(FeatureLockedView), findsOneWidget);
      expect(
        find.text('Multi-Clinic Benchmarking is a Pro feature'),
        findsOneWidget,
      );
    });

    testWidgets('active 30-day trial reaches the real screen', (tester) async {
      await _pump(
        tester,
        const ClinicComparisonScreen(),
        EntitlementState(
          tier: SubscriptionTier.proTrial,
          trialStartDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
      );

      expect(find.byType(FeatureLockedView), findsNothing);
    });

    testWidgets('expired trial is treated as free and stays locked', (
      tester,
    ) async {
      await _pump(
        tester,
        const ClinicComparisonScreen(),
        EntitlementState(
          tier: SubscriptionTier.proTrial,
          trialStartDate: DateTime.now().subtract(const Duration(days: 40)),
        ),
      );

      expect(find.byType(FeatureLockedView), findsOneWidget);
    });
  });

  group('Multi-Clinic Practice — multiClinicManagement gate', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    final dummyClinic = Clinic(
      id: 'c1',
      name: 'Downtown Clinic',
      address: 'Main Road',
      phone: '9876543210',
      monthlyRent: 10000,
      defaultConsultationFee: 500,
      openDays: '1,2,3,4,5,6',
      colorHex: '#0F5132',
      isActive: true,
      isDeleted: false,
      createdAt: DateTime(2026, 1, 1),
    );

    testWidgets(
      'free tier with 1 clinic shows Pro banner and locks adding second clinic',
      (tester) async {
        await _pump(
          tester,
          const ClinicsScreen(),
          const EntitlementState(),
          extraOverrides: [
            databaseProvider.overrideWithValue(db),
            clinicsStreamProvider.overrideWith(
              (ref) => Stream.value([dummyClinic]),
            ),
            activeClinicIdProvider.overrideWith(
              (ref) => _FakeActiveClinicIdNotifier(db),
            ),
          ],
        );

        // Pro banner shown on Free tier
        expect(find.text('Multi-Clinic Practice'), findsOneWidget);
        expect(find.text('Downtown Clinic'), findsOneWidget);

        // Tap "+ Add Clinic" FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Should show Pro upgrade sheet instead of dialog
        expect(find.byType(ProUpgradeSheet), findsOneWidget);
        expect(find.byType(AddEditClinicDialog), findsNothing);
      },
    );

    testWidgets('pro tier allows adding multiple clinics and hides banner', (
      tester,
    ) async {
      await _pump(
        tester,
        const ClinicsScreen(),
        EntitlementState(
          tier: SubscriptionTier.proActive,
          subscriptionExpiryDate: DateTime.now().add(const Duration(days: 30)),
        ),
        extraOverrides: [
          databaseProvider.overrideWithValue(db),
          clinicsStreamProvider.overrideWith(
            (ref) => Stream.value([dummyClinic]),
          ),
          activeClinicIdProvider.overrideWith(
            (ref) => _FakeActiveClinicIdNotifier(db),
          ),
        ],
      );

      // Pro banner is hidden when unlocked
      expect(find.text('Multi-Clinic Practice'), findsNothing);

      // Tap "+ Add Clinic" FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should open AddEditClinicDialog
      expect(find.byType(AddEditClinicDialog), findsOneWidget);
      expect(find.byType(ProUpgradeSheet), findsNothing);
    });
  });

  group('Bulk Export — bulkExportXlsx gate', () {
    testWidgets('free tier tapping Excel (XLSX) opens upgrade sheet', (
      tester,
    ) async {
      await _pump(
        tester,
        const Scaffold(body: ExportOptionsSheet()),
        const EntitlementState(),
      );

      expect(find.text('Choose Format'), findsOneWidget);
      expect(find.text('XLSX'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);

      // Tap Excel (XLSX) option
      await tester.tap(find.text('XLSX'));
      await tester.pumpAndSettle();

      // Pro upgrade sheet opens
      expect(find.byType(ProUpgradeSheet), findsOneWidget);
    });

    testWidgets(
      'pro tier allows selecting Excel (XLSX) without opening upgrade sheet',
      (tester) async {
        await _pump(
          tester,
          const Scaffold(body: ExportOptionsSheet()),
          EntitlementState(
            tier: SubscriptionTier.proActive,
            subscriptionExpiryDate: DateTime.now().add(
              const Duration(days: 30),
            ),
          ),
        );

        // Tap Excel (XLSX) option
        await tester.tap(find.text('XLSX'));
        await tester.pumpAndSettle();

        // Does not open upgrade sheet
        expect(find.byType(ProUpgradeSheet), findsNothing);
      },
    );
  });
}
