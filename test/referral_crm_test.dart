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
      final activeList = await (db.select(db.referralContacts)..where((t) => t.isDeleted.equals(false))).get();
      expect(activeList, isEmpty);
    });
  });

  group('ReferralCrmScreen Widget Tests', () {
    testWidgets('renders empty state and opens add partner dialog', (tester) async {
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
  });
}