import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/dashboard/presentation/widgets/goal_tracker_card.dart';
import 'package:clinic_pilot/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Goal Tracker DashboardStats Unit Tests', () {
    test('calculates revenue and new patient progress accurately', () {
      const stats = DashboardStats(
        todayRevenue: 2000,
        todayExpense: 500,
        todayNetProfit: 1500,
        todayPatients: 4,
        monthlyRevenue: 25000,
        monthlyExpense: 5000,
        monthlyNetProfit: 20000,
        monthlyRevenueGoal: 50000,
        totalPatients: 100,
        monthlyNewPatients: 8,
        monthlyRepeatPatients: 12,
        monthlyNewPatientGoal: 10,
      );

      expect(stats.revenueGoalProgress, equals(0.5));
      expect(stats.newPatientGoalProgress, equals(0.8));
    });
  });

  group('GoalTrackerCard Widget Tests', () {
    testWidgets('renders revenue and new patient goal progress bars', (
      tester,
    ) async {
      final now = DateTime(2026, 8, 15);
      const stats = DashboardStats(
        todayRevenue: 1500,
        todayExpense: 300,
        todayNetProfit: 1200,
        todayPatients: 3,
        monthlyRevenue: 18500,
        monthlyExpense: 4000,
        monthlyNetProfit: 14500,
        monthlyRevenueGoal: 50000,
        totalPatients: 60,
        monthlyNewPatients: 6,
        monthlyRepeatPatients: 9,
        monthlyNewPatientGoal: 15,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(body: GoalTrackerCard(stats: stats, now: now)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Monthly Practice Targets'), findsOneWidget);
      expect(find.text('₹ 18,500'), findsOneWidget);
      expect(find.text('of ₹ 50,000'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('of 15 new patients'), findsOneWidget);

      // Verify tune icon button opens Edit Goals dialog
      expect(find.byIcon(Icons.tune_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.tune_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Set Monthly Targets'), findsOneWidget);
      expect(find.text('Monthly Revenue Goal (₹)'), findsOneWidget);
      expect(find.text('Monthly New Patient Goal'), findsOneWidget);
    });
  });
}
