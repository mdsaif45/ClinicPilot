import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/growth/presentation/referral_crm_screen.dart';
import 'package:clinic_pilot/features/growth/providers/referral_crm_provider.dart';
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

  group('Referral CRM Notifier & Stats Unit Tests', () {
    test('adds, updates, logs visit and increments referrals', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(referralCrmNotifierProvider.notifier);

      final contactId = await notifier.addContact(
        name: 'City Meds Pharmacy',
        contactPerson: 'Mr. Kumar',
        category: 'Pharmacy',
        phone: '9876543210',
        address: 'Opposite Main Hospital',
        notes: 'Promised to refer chronic arthritis cases.',
      );

      var list = await db.select(db.referralContacts).get();
      expect(list.length, equals(1));
      expect(list.first.name, equals('City Meds Pharmacy'));
      expect(list.first.category, equals('Pharmacy'));
      expect(list.first.visitCount, equals(0));
      expect(list.first.referralCount, equals(0));

      // Log Outreach Visit
      await notifier.logOutreachVisit(contactId);
      list = await db.select(db.referralContacts).get();
      expect(list.first.visitCount, equals(1));
      expect(list.first.lastVisitedDate, isNotNull);

      // Increment referral
      await notifier.incrementReferralCount(contactId);
      list = await db.select(db.referralContacts).get();
      expect(list.first.referralCount, equals(1));

      // Soft delete
      await notifier.deleteContact(contactId);
      final activeList =
          await (db.select(db.referralContacts)
            ..where((t) => t.isDeleted.equals(false))).get();
      expect(activeList, isEmpty);
    });
  });

  group('ReferralCrmScreen Widget Tests', () {
    testWidgets('renders empty state and opens add partner dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralContactsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ReferralCrmScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Referral Network CRM'), findsOneWidget);
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Referrals Sent'), findsOneWidget);
      expect(find.text('Doctor Visits'), findsOneWidget);
      expect(find.text('No referral partners found'), findsOneWidget);

      await tester.tap(find.text('Add Partner').first);
      await tester.pumpAndSettle();

      expect(find.text('Partner / Organization Name *'), findsOneWidget);
      expect(find.text('Partner Category'), findsOneWidget);
      expect(find.text('Contact Person / Manager'), findsOneWidget);
    });

    testWidgets(
      'renders partner card with 3-layer hierarchy and progressive disclosure',
      (tester) async {
        final testPartner = ReferralContact(
          id: 'ref-1',
          name: 'City Care Pharmacy',
          contactPerson: 'Mr. Rajesh Kumar',
          category: 'Pharmacy',
          phone: '9876543210',
          address: 'MG Road, Near Bus Stand',
          notes: 'Active partner referring chronic cases.',
          referralCount: 8,
          visitCount: 3,
          lastVisitedDate: DateTime(2026, 8, 20),
          isActive: true,
          isDeleted: false,
          createdAt: DateTime(2026, 8, 1),
          updatedAt: DateTime(2026, 8, 20),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              referralContactsProvider.overrideWith(
                (ref) => Stream.value([testPartner]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ReferralCrmScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Layer 1: Identity & Category
        expect(find.text('City Care Pharmacy'), findsOneWidget);
        expect(find.text('Pharmacy'), findsWidgets);
        expect(find.text('MG Road, Near Bus Stand'), findsOneWidget);

        // Layer 2: Key Operational Metrics
        expect(find.text('8 Referrals'), findsOneWidget);
        expect(find.text('3 Doctor Visits'), findsOneWidget);
        expect(find.text('Last: 20 Aug 2026'), findsOneWidget);

        // Layer 3: Primary Actions are immediately visible and unobstructed
        expect(find.text('Log Visit'), findsOneWidget);
        expect(find.text('+1 Referral'), findsOneWidget);

        // Progressive disclosure: full contact details & notes are initially collapsed
        expect(
          find.text('Notes: Active partner referring chronic cases.'),
          findsNothing,
        );

        // Tap to expand secondary details
        await tester.tap(find.text('View contact & notes'));
        await tester.pumpAndSettle();

        // Now secondary details are revealed
        expect(find.text('Contact: Mr. Rajesh Kumar'), findsOneWidget);
        expect(find.text('9876543210'), findsOneWidget);
        expect(
          find.text('Notes: Active partner referring chronic cases.'),
          findsOneWidget,
        );

        // Tap to collapse
        await tester.tap(find.text('Hide details'));
        await tester.pumpAndSettle();

        expect(
          find.text('Notes: Active partner referring chronic cases.'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'responsive layout renders without overflow across compact, standard, and tablet screens',
      (tester) async {
        final partners = <ReferralContact>[
          ReferralContact(
            id: 'ref-1',
            name: 'Apex Diagnostic & Pathology Center',
            contactPerson: 'Dr. Sharma',
            category: 'Diagnostic Lab',
            phone: '9811122233',
            address: 'Shop 4, Medical Square, Ring Road',
            notes: 'Special discounts for routine lipid profiles.',
            referralCount: 15,
            visitCount: 5,
            lastVisitedDate: DateTime(2026, 8, 25),
            isActive: true,
            isDeleted: false,
            createdAt: DateTime(2026, 8, 1),
            updatedAt: DateTime(2026, 8, 25),
          ),
        ];

        for (final width in [320.0, 360.0, 412.0, 800.0]) {
          tester.view.physicalSize = Size(width, 1000.0);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                referralContactsProvider.overrideWith(
                  (ref) => Stream.value(partners),
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                home: const ReferralCrmScreen(),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason: 'Overflow occurred on width: $width',
          );
          expect(
            find.text('Apex Diagnostic & Pathology Center'),
            findsOneWidget,
          );
          expect(find.text('Log Visit'), findsOneWidget);
          expect(find.text('+1 Referral'), findsOneWidget);
        }
      },
    );
  });
}
