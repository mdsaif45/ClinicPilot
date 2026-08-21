import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/growth/presentation/camp_manager_screen.dart';
import 'package:clinic_pilot/features/growth/providers/camp_provider.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Camp Manager & ROI Calculations Unit Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      // Seed clinic
      await db.into(db.clinics).insert(
            ClinicsCompanion.insert(
              id: 'c1',
              name: 'Main Clinic',
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('creates and updates health camp records', () async {
      final notifier = CampNotifier(db);
      final id = await notifier.addCamp(
        name: 'Eye & Health Camp',
        date: DateTime.now(),
        location: 'Community Hall',
        cost: 2000,
        attendance: 100,
        clinicId: 'c1',
      );

      var camps = await db.select(db.camps).get();
      expect(camps.length, equals(1));
      expect(camps.first.name, equals('Eye & Health Camp'));
      expect(camps.first.cost, equals(2000.0));
      expect(camps.first.attendance, equals(100));

      await notifier.updateCamp(
        id: id,
        name: 'Free Eye & Health Camp',
        date: DateTime.now(),
        cost: 2500,
        attendance: 120,
        clinicId: 'c1',
      );

      camps = await db.select(db.camps).get();
      expect(camps.first.name, equals('Free Eye & Health Camp'));
      expect(camps.first.cost, equals(2500.0));
      expect(camps.first.attendance, equals(120));
    });

    test('calculates camp ROI properly based on follow-up revenue', () async {
      final now = DateTime.now();
      // Insert Camp (Cost: 2000)
      await db.into(db.camps).insert(
            CampsCompanion.insert(
              id: 'camp-1',
              name: 'Free Checkup Camp',
              date: drift.Value(now.subtract(const Duration(days: 20))),
              cost: const drift.Value(2000.0),
              attendance: const drift.Value(50),
              clinicId: const drift.Value('c1'),
            ),
          );

      // Insert Patient acquired from camp
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p-camp-1',
              patientCode: const drift.Value('P-2026-00001'),
              serialNo: const drift.Value('1'),
              primaryClinicId: const drift.Value('c1'),
              name: 'Camp Patient',
              phone: '9876543210',
              age: 45,
              gender: 'Male',
              primaryDisease: const drift.Value('Hypertension'),
              referralSource: const drift.Value('Free Checkup Camp'),
              createdAt: drift.Value(now.subtract(const Duration(days: 20))),
            ),
          );

      // Insert Cash Memo for follow-up revenue (Paid: 5000)
      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'cm-1',
              memoNumber: 'CM-2026-00001',
              patientId: 'p-camp-1',
              clinicId: const drift.Value('c1'),
              total: 5000,
              paidAmount: const drift.Value(5000),
              paymentMethod: 'UPI',
              memoDate: drift.Value(now.subtract(const Duration(days: 10))),
            ),
          );

      // ROI = ((5000 - 2000) / 2000) * 100 = 150%
      const cost = 2000.0;
      const revenue = 5000.0;
      final roi = ((revenue - cost) / cost) * 100;
      expect(roi, equals(150.0));
      expect(revenue - cost, equals(3000.0));
    });
  });

  group('CampManagerScreen Widget Tests', () {
    testWidgets('renders camp list and metric summary correctly', (tester) async {
      final now = DateTime.now();
      final testCamp = CampWithAnalytics(
        camp: Camp(
          id: 'camp-1',
          name: 'Annual Free Health Camp',
          date: now,
          location: 'Town Center',
          cost: 3000,
          attendance: 80,
          clinicId: 'c1',
          notes: null,
          isDeleted: false,
          createdAt: now,
        ),
        clinic: Clinic(
          id: 'c1',
          name: 'Main Clinic',
          monthlyRent: 0,
          defaultConsultationFee: 0,
          openDays: '1,2,3,4,5,6',
          colorHex: '#0F5132',
          isActive: true,
          isDeleted: false,
          createdAt: now,
        ),
        patientsAcquiredCount: 12,
        followUpRevenue: 7500,
        roi: 150.0,
        netProfit: 4500,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            campsStreamProvider.overrideWith((ref) => Stream.value([testCamp])),
            campStatsProvider.overrideWithValue(
              const AsyncData(CampStats(
                totalCamps: 1,
                totalCost: 3000,
                totalFollowUpRevenue: 7500,
                totalPatientsAcquired: 12,
                aggregateRoi: 150.0,
                totalNetProfit: 4500,
              )),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CampManagerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Camp Manager & ROI'), findsOneWidget);
      expect(find.text('Annual Free Health Camp'), findsOneWidget);
      expect(find.text('+150% ROI'), findsWidgets);
      expect(find.text('₹ 7,500'), findsWidgets);
      expect(find.text('12'), findsOneWidget);
    });
  });
}
