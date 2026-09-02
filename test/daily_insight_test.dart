import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/dashboard/presentation/widgets/daily_insight_card.dart';
import 'package:clinic_pilot/features/growth/providers/daily_insight_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Daily Insight Provider & Rules Unit Tests', () {
    test('instantiates coach insights with correct properties', () {
      const insight = CoachInsight(
        id: 'recall_overdue',
        title: '3 Patients Overdue for Follow-up',
        message:
            'Send WhatsApp check-ins to ensure continuous homeopathic care.',
        actionLabel: 'View Follow-ups',
        actionRoute: '/patients',
        icon: Icons.notifications_active_outlined,
        priority: 5,
      );

      expect(insight.id, equals('recall_overdue'));
      expect(insight.priority, equals(5));
      expect(insight.actionRoute, equals('/patients'));
      expect(insight.title, contains('3 Patients Overdue'));
    });
  });

  group('DailyInsightCard Widget Tests', () {
    testWidgets('renders coach insight card and action CTA', (tester) async {
      const insight = CoachInsight(
        id: 'camp_roi',
        title: 'Health Camps Yielded +150% ROI',
        message: '12 patients acquired generated follow-up revenue.',
        actionLabel: 'Open Camp Manager',
        actionRoute: '/growth/camps',
        icon: Icons.campaign_outlined,
        priority: 4,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [dailyInsightProvider.overrideWithValue(insight)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: DailyInsightCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("TODAY'S INSIGHT"), findsOneWidget);
      expect(find.text('Health Camps Yielded +150% ROI'), findsOneWidget);
      expect(find.text('Open Camp Manager'), findsOneWidget);
      expect(
        find.text('12 patients acquired generated follow-up revenue.'),
        findsOneWidget,
      );
    });
  });
}
