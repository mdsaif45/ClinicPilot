import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/features/activity/providers/practice_activity_provider.dart';
import 'package:clinic_pilot/features/dashboard/providers/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
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

  group('PracticeActivityProvider Unit Tests', () {
    test('computes hourly rush bins for Day view accurately', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      // Seed clinic & patient
      await db.into(db.clinics).insert(
            ClinicsCompanion.insert(
              id: 'c1',
              name: 'Main Clinic',
              address: const drift.Value('City Center'),
            ),
          );

      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p1',
              patientCode: const drift.Value('P-001'),
              name: 'Ali Khan',
              age: 28,
              phone: '9876543210',
              primaryClinicId: const drift.Value('c1'),
              gender: 'Male',
            ),
          );

      // Insert 2 visits at 10 AM and 1 visit at 5 PM (17:00)
      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v1',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: todayMidnight.add(const Duration(hours: 10, minutes: 15)),
              disease: 'Allergy',
              visitType: 'new',
            ),
          );

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v2',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: todayMidnight.add(const Duration(hours: 10, minutes: 45)),
              disease: 'Cough',
              visitType: 'repeat',
            ),
          );

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v3',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: todayMidnight.add(const Duration(hours: 17, minutes: 30)),
              disease: 'Fever',
              visitType: 'new',
            ),
          );

      // Insert Cash Memos at 10 AM (₹1,200) and 5 PM (₹800)
      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'cm1',
              memoNumber: 'CM-001',
              patientId: 'p1',
              clinicId: const drift.Value('c1'),
              memoDate: drift.Value(todayMidnight.add(const Duration(hours: 10, minutes: 20))),
              total: 1200,
              paymentMethod: 'cash',
            ),
          );

      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'cm2',
              memoNumber: 'CM-002',
              patientId: 'p1',
              clinicId: const drift.Value('c1'),
              memoDate: drift.Value(todayMidnight.add(const Duration(hours: 17, minutes: 35))),
              total: 800,
              paymentMethod: 'upi',
            ),
          );

      await container.read(dashboardRawStreamsProvider.future);

      container.read(selectedActivityDateProvider.notifier).state = todayMidnight;
      container.read(activityRangeProvider.notifier).state = ActivityTimeRange.day;
      container.read(activityMetricProvider.notifier).state = ActivityMetric.revenue;

      final state = container.read(practiceActivityProvider);

      expect(state.totalRevenue, equals(2000.0));
      expect(state.totalPatients, equals(3));
      expect(state.hourlyBins.length, equals(96)); // 96 fifteen-minute slots

      // Bin at 10:15 AM
      final bin1015 = state.hourlyBins.firstWhere((b) => b.hour == 10 && b.minute == 15);
      expect(bin1015.patients, equals(1));
      expect(bin1015.revenue, equals(1200.0));

      // Bin at 5:30 PM (hour 17, min 30)
      final bin1730 = state.hourlyBins.firstWhere((b) => b.hour == 17 && b.minute == 30);
      expect(bin1730.patients, equals(1));
      expect(bin1730.revenue, equals(800.0));

      // Peak hour description
      expect(state.peakRushDescription, contains('10:00 AM'));
    });

    test('computes weekly and monthly bubble matrix data', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      await container.read(dashboardRawStreamsProvider.future);

      container.read(selectedActivityDateProvider.notifier).state = todayMidnight;
      container.read(activityRangeProvider.notifier).state = ActivityTimeRange.month;
      container.read(activityMetricProvider.notifier).state = ActivityMetric.patients;

      final state = container.read(practiceActivityProvider);

      expect(state.monthlyBubbleDays.isNotEmpty, isTrue);
      expect(state.monthlyWeeklySubtotals.isNotEmpty, isTrue);
    });
  });
}
