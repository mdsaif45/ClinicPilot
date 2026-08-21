import 'package:clinic_pilot/core/services/app_haptics.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/animated_counter.dart';
import 'package:clinic_pilot/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppHaptics Tests', () {
    test('AppHaptics methods run without throwing exceptions', () async {
      await AppHaptics.light();
      await AppHaptics.medium();
      await AppHaptics.selection();
      await AppHaptics.success();
      await AppHaptics.error();
    });
  });

  group('AnimatedCounter Tests', () {
    testWidgets('renders initial and target currency values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AnimatedCounter.currency(value: 5000),
          ),
        ),
      );

      // Initially starts from 0 or progresses towards 5000
      expect(find.byType(AnimatedCounter), findsOneWidget);

      // Settle animation to completion
      await tester.pumpAndSettle();
      expect(find.text('₹ 5,000'), findsOneWidget);
    });

    testWidgets('renders whole count integer values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AnimatedCounter.count(value: 42),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });
  });

  group('ShimmerLoading Skeletons', () {
    testWidgets('ListTileShimmer renders shimmer boxes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: ListTileShimmer(),
          ),
        ),
      );

      expect(find.byType(ShimmerBox), findsWidgets);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('DashboardShimmer renders dashboard skeleton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: DashboardShimmer(),
          ),
        ),
      );

      expect(find.byType(DashboardShimmer), findsOneWidget);
      expect(find.byType(ShimmerBox), findsWidgets);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
