import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/dashboard/presentation/widgets/clinic_health_score_card.dart';
import 'package:clinic_pilot/features/growth/providers/health_score_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Clinic Health Score Unit Tests', () {
    test('calculates composite score and assigns proper grade', () {
      const p1 = HealthScorePillar(
        title: 'Revenue Performance',
        score: 22.0,
        maxScore: 25.0,
        detail: 'Good revenue',
      );
      const p2 = HealthScorePillar(
        title: 'New Patient Flow',
        score: 20.0,
        maxScore: 25.0,
        detail: '8 new patients',
      );
      const p3 = HealthScorePillar(
        title: 'Patient Retention',
        score: 18.0,
        maxScore: 20.0,
        detail: '36% repeat rate',
      );
      const p4 = HealthScorePillar(
        title: 'Operating Profit Margin',
        score: 12.0,
        maxScore: 15.0,
        detail: '40% profit margin',
      );
      const p5 = HealthScorePillar(
        title: 'Reputation & Growth',
        score: 10.0,
        maxScore: 15.0,
        detail: '3 reviews',
      );

      final pillars = [p1, p2, p3, p4, p5];
      final total =
          pillars.fold<double>(0.0, (sum, p) => sum + p.score).round();

      expect(total, equals(82));

      final score = ClinicHealthScore(
        totalScore: total,
        grade: 'Excellent',
        summaryReason:
            '82 / 100 (Excellent) • 8 new pts, 36% repeat, ₹15000 net',
        pillars: pillars,
      );

      expect(score.totalScore, equals(82));
      expect(score.grade, equals('Excellent'));
      expect(score.pillars.length, equals(5));
      expect(score.pillars.first.percentage, equals(88.0));
    });
  });

  group('ClinicHealthScoreCard Widget Tests', () {
    testWidgets('renders score badge and opens breakdown sheet on tap', (
      tester,
    ) async {
      const score = ClinicHealthScore(
        totalScore: 85,
        grade: 'Excellent',
        summaryReason: '85 / 100 (Excellent) • 12 new pts',
        pillars: [
          HealthScorePillar(
            title: 'Revenue Performance',
            score: 25.0,
            maxScore: 25.0,
            detail: '₹35000 revenue earned',
          ),
          HealthScorePillar(
            title: 'New Patient Flow',
            score: 25.0,
            maxScore: 25.0,
            detail: '12 new patients registered',
          ),
          HealthScorePillar(
            title: 'Patient Retention',
            score: 15.0,
            maxScore: 20.0,
            detail: '30% repeat rate',
          ),
          HealthScorePillar(
            title: 'Operating Profit Margin',
            score: 10.0,
            maxScore: 15.0,
            detail: '35% margin',
          ),
          HealthScorePillar(
            title: 'Reputation & Growth',
            score: 10.0,
            maxScore: 15.0,
            detail: '3 reviews',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clinicHealthScoreProvider.overrideWithValue(const AsyncData(score)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: ClinicHealthScoreCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Practice Health Score'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('Excellent'), findsOneWidget);

      // Tap card to open breakdown sheet
      await tester.tap(find.byType(ClinicHealthScoreCard));
      await tester.pumpAndSettle();

      expect(find.text('Practice Health Breakdown'), findsOneWidget);
      expect(find.text('Revenue Performance'), findsOneWidget);
      expect(find.text('₹35000 revenue earned'), findsOneWidget);
    });
  });
}
