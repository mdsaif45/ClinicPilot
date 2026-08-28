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

  group('Dashboard Monthly Snapshot Date Navigation Unit Tests', () {
    test('calculates historical monthly revenue, expense, net profit and patients accurately', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      // Seed clinic
      await db.into(db.clinics).insert(
            ClinicsCompanion.insert(
              id: 'c1',
              name: 'Main Clinic',
              address: const drift.Value('City Center'),
            ),
          );

      // Seed patient
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

      // Current month: 5000 revenue, 1000 expense, 2 visits
      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'cm_curr',
              memoNumber: 'CM-001',
              patientId: 'p1',
              clinicId: const drift.Value('c1'),
              memoDate: drift.Value(currentMonth.add(const Duration(days: 5))),
              total: 5000,
              paymentMethod: 'cash',
            ),
          );

      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'exp_curr',
              clinicId: 'c1',
              date: currentMonth.add(const Duration(days: 10)),
              amount: 1000,
              category: 'Supplies',
            ),
          );

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v_curr1',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: currentMonth.add(const Duration(days: 2)),
              disease: 'Fever',
              visitType: 'new',
            ),
          );

      // Last month: 8000 revenue, 2500 expense, 1 visit
      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'cm_last',
              memoNumber: 'CM-002',
              patientId: 'p1',
              clinicId: const drift.Value('c1'),
              memoDate: drift.Value(lastMonth.add(const Duration(days: 12))),
              total: 8000,
              paymentMethod: 'cash',
            ),
          );

      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'exp_last',
              clinicId: 'c1',
              date: lastMonth.add(const Duration(days: 14)),
              amount: 2500,
              category: 'Rent',
            ),
          );

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v_last1',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: lastMonth.add(const Duration(days: 15)),
              disease: 'Cold',
              visitType: 'repeat',
            ),
          );

      // Wait for background DB streams to emit
      await container.read(dashboardRawStreamsProvider.future);

      // 1. Initial State (Current Month)
      container.read(selectedDashboardMonthProvider.notifier).state = currentMonth;
      final currentStats = container.read(monthlyStatsProvider);

      expect(currentStats.isCurrentMonth, isTrue);
      expect(currentStats.isLastMonth, isFalse);
      expect(currentStats.monthlyRevenue, equals(5000.0));
      expect(currentStats.monthlyExpense, equals(1000.0));
      expect(currentStats.monthlyNetProfit, equals(4000.0));
      expect(currentStats.monthlyNewPatients, equals(1));

      // 2. Select Last Month
      container.read(selectedDashboardMonthProvider.notifier).state = lastMonth;
      final lastStats = container.read(monthlyStatsProvider);

      expect(lastStats.isCurrentMonth, isFalse);
      expect(lastStats.isLastMonth, isTrue);
      expect(lastStats.monthlyRevenue, equals(8000.0));
      expect(lastStats.monthlyExpense, equals(2500.0));
      expect(lastStats.monthlyNetProfit, equals(5500.0));
      expect(lastStats.monthlyRepeatPatients, equals(1));
    });
  });

  group('Dashboard Monthly Snapshot Widget Navigation Tests', () {
    testWidgets('navigates to last month with <, advances with >, and restores current month with This Month shortcut', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          monthlyStatsProvider.overrideWith((ref) {
            final selected = ref.watch(selectedDashboardMonthProvider);
            final isCurr = selected.year == currentMonth.year &&
                selected.month == currentMonth.month;
            return MonthlyStats(
              selectedMonth: selected,
              monthlyRevenue: isCurr ? 15000.0 : 22000.0,
              monthlyExpense: isCurr ? 3000.0 : 5000.0,
              monthlyNetProfit: isCurr ? 12000.0 : 17000.0,
              monthlyRevenueGoal: 50000.0,
              totalPatients: 30,
              monthlyNewPatients: isCurr ? 6 : 10,
              monthlyRepeatPatients: isCurr ? 8 : 14,
              monthlyNewPatientGoal: 15,
            );
          }),
          dashboardStatsProvider.overrideWith((ref) {
            return Stream.value(
              const DashboardStats(
                todayRevenue: 1000.0,
                todayExpense: 200.0,
                todayNetProfit: 800.0,
                todayPatients: 1,
                monthlyRevenue: 15000.0,
                monthlyExpense: 3000.0,
                monthlyNetProfit: 12000.0,
                monthlyRevenueGoal: 50000.0,
                totalPatients: 30,
                monthlyNewPatients: 6,
                monthlyRepeatPatients: 8,
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

      // Current Month state
      expect(find.textContaining('This Month'), findsWidgets);
      expect(find.text('₹ 15,000'), findsOneWidget);

      // Tap Previous Month (<)
      final prevMonthBtn = find.byTooltip('Previous Month');
      expect(prevMonthBtn, findsOneWidget);
      await tester.tap(prevMonthBtn);
      await tester.pumpAndSettle();

      // Viewing Last Month
      expect(container.read(selectedDashboardMonthProvider).month, equals(lastMonth.month));
      expect(find.textContaining('Last Month'), findsOneWidget);
      expect(find.text('₹ 22,000'), findsOneWidget);
      expect(find.text('₹ 17,000'), findsOneWidget);

      // Tap "This Month" quick jump button
      final thisMonthBtn = find.text('This Month');
      expect(thisMonthBtn, findsOneWidget);
      await tester.tap(thisMonthBtn);
      await tester.pumpAndSettle();

      // Restored to Current Month
      expect(container.read(selectedDashboardMonthProvider).month, equals(currentMonth.month));
      expect(find.text('₹ 15,000'), findsOneWidget);

      // Tap Previous Month (<) again
      await tester.tap(prevMonthBtn);
      await tester.pumpAndSettle();
      expect(container.read(selectedDashboardMonthProvider).month, equals(lastMonth.month));

      // Tap Next Month (>)
      final nextMonthBtn = find.byTooltip('Next Month');
      expect(nextMonthBtn, findsOneWidget);
      await tester.tap(nextMonthBtn);
      await tester.pumpAndSettle();

      expect(container.read(selectedDashboardMonthProvider).month, equals(currentMonth.month));
      expect(find.text('₹ 15,000'), findsOneWidget);
    });
  });
}
