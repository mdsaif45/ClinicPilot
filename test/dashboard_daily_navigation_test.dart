import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/dashboard/presentation/dashboard_screen.dart';
import 'package:clinic_pilot/features/dashboard/providers/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;
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

  group('Dashboard Daily Snapshot Date Navigation Unit Tests', () {
    test('calculates historical daily revenue, expense and patients independently of monthly aggregates', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      // Seed a clinic
      await db.into(db.clinics).insert(
            ClinicsCompanion.insert(
              id: 'c1',
              name: 'Main Clinic',
              address: const drift.Value('City Center'),
            ),
          );

      // Seed a patient
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p1',
              patientCode: const drift.Value('P-001'),
              name: 'John Doe',
              age: 30,
              phone: '9876543210',
              primaryClinicId: const drift.Value('c1'),
              gender: 'Male',
            ),
          );

      // Insert 1 visit on today and 2 visits on yesterday
      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v1',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: today.add(const Duration(hours: 10)),
              disease: 'Fever',
              visitType: 'new',
            ),
          );

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v2',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: yesterday.add(const Duration(hours: 11)),
              disease: 'Cold',
              visitType: 'repeat',
            ),
          );

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v3',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: yesterday.add(const Duration(hours: 15)),
              disease: 'Headache',
              visitType: 'repeat',
            ),
          );

      // Insert Cash Memos: 1000 today, 2500 yesterday
      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'cm1',
              memoNumber: 'CM-001',
              patientId: 'p1',
              clinicId: const drift.Value('c1'),
              memoDate: drift.Value(today.add(const Duration(hours: 10))),
              total: 1000,
              paymentMethod: 'cash',
            ),
          );

      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'cm2',
              memoNumber: 'CM-002',
              patientId: 'p1',
              clinicId: const drift.Value('c1'),
              memoDate: drift.Value(yesterday.add(const Duration(hours: 12))),
              total: 2500,
              paymentMethod: 'cash',
            ),
          );

      // Insert Expense: 400 on yesterday
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'e1',
              clinicId: 'c1',
              date: yesterday.add(const Duration(hours: 14)),
              amount: 400,
              category: 'Supplies',
            ),
          );

      // 1. Initial State (Today)
      container.read(selectedDashboardDateProvider.notifier).state = today;
      final todayStats = await container.read(dashboardStatsProvider.future);

      expect(todayStats.isToday, isTrue);
      expect(todayStats.activeDailyPatients, equals(1));
      expect(todayStats.activeDailyRevenue, equals(1000.0));
      expect(todayStats.activeDailyExpense, equals(0.0));
      expect(todayStats.activeDailyNetProfit, equals(1000.0));

      // 2. Select Yesterday
      container.read(selectedDashboardDateProvider.notifier).state = yesterday;
      final yesterdayStats = await container.read(dashboardStatsProvider.future);

      expect(yesterdayStats.isToday, isFalse);
      expect(yesterdayStats.isYesterday, isTrue);
      expect(yesterdayStats.activeDailyPatients, equals(2));
      expect(yesterdayStats.activeDailyRevenue, equals(2500.0));
      expect(yesterdayStats.activeDailyExpense, equals(400.0));
      expect(yesterdayStats.activeDailyNetProfit, equals(2100.0));
    });
  });

  group('Dashboard Daily Snapshot Widget Navigation Tests', () {
    testWidgets('navigates to yesterday with < and restores today with Today shortcut', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          dashboardStatsProvider.overrideWith((ref) {
            final selected = ref.watch(selectedDashboardDateProvider);
            final isT = selected.year == today.year &&
                selected.month == today.month &&
                selected.day == today.day;
            return Stream.value(
              DashboardStats(
                selectedDate: selected,
                dailyRevenue: isT ? 2800.0 : 1500.0,
                dailyExpense: isT ? 0.0 : 300.0,
                dailyNetProfit: isT ? 2800.0 : 1200.0,
                dailyPatients: isT ? 1 : 4,
                todayRevenue: 2800.0,
                todayExpense: 0.0,
                todayNetProfit: 2800.0,
                todayPatients: 1,
                monthlyRevenue: 10000.0,
                monthlyExpense: 2000.0,
                monthlyNetProfit: 8000.0,
                monthlyRevenueGoal: 50000.0,
                totalPatients: 20,
                monthlyNewPatients: 5,
                monthlyRepeatPatients: 10,
                monthlyNewPatientGoal: 15,
              ),
            );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Today state
      expect(find.text('Today'), findsOneWidget);
      expect(find.text("Today's Patients"), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text("Today's Revenue"), findsOneWidget);
      expect(find.text('₹ 2,800'), findsWidgets);

      // Tap Previous Day (<)
      final prevBtn = find.byTooltip('Previous Day');
      expect(prevBtn, findsOneWidget);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();

      // Now viewing yesterday
      expect(container.read(selectedDashboardDateProvider).day, equals(yesterday.day));
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Revenue'), findsWidgets);
      expect(find.text('₹ 1,500'), findsOneWidget);

      // Verify "Today" quick jump badge is present and tap it
      expect(find.text('Today'), findsOneWidget);
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Back to Today
      expect(container.read(selectedDashboardDateProvider).day, equals(today.day));
      expect(find.text('Today'), findsOneWidget);
      expect(find.text("Today's Patients"), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
