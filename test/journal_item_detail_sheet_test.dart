import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/activity/presentation/widgets/journal_item_detail_sheet.dart';
import 'package:clinic_pilot/features/activity/providers/practice_journal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JournalItemDetailSheet Widget Tests', () {
    testWidgets(
      'renders consultation details with hero metrics and patient info',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final entry = PracticeJournalEntry(
          id: 'v_1',
          timestamp: DateTime(2026, 8, 28, 10, 30),
          type: JournalEventType.consultation,
          title: 'Sara Khan • New Consultation',
          subtitle: 'Condition: Allergic Rhinitis',
          patientName: 'Sara Khan',
          patientId: 'p_1',
          patientCode: 'P-001',
          disease: 'Allergic Rhinitis',
          notes: 'Advised warm water steam',
          visitType: 'New Consultation',
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Builder(
                builder:
                    (ctx) => ElevatedButton(
                      onPressed: () => JournalItemDetailSheet.show(ctx, entry),
                      child: const Text('Open Sheet'),
                    ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Verify Header & Hero
        expect(find.text('Sara Khan'), findsWidgets);
        expect(find.text('Consultation Logged'), findsOneWidget);

        // Verify Metric Rows
        expect(find.text('P-001'), findsOneWidget);
        expect(find.text('Allergic Rhinitis'), findsOneWidget);
        expect(find.text('Advised warm water steam'), findsOneWidget);
        expect(find.text('Open Patient Profile & Records'), findsOneWidget);
      },
    );

    testWidgets('renders invoice details with payment method and amount', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final entry = PracticeJournalEntry(
        id: 'm_1',
        timestamp: DateTime(2026, 8, 28, 11, 00),
        type: JournalEventType.dispense,
        title: 'Invoice #CM-2026-00001 • Tariq Mahmood',
        subtitle: 'Payment: UPI',
        amount: 2800,
        paymentMethod: 'UPI',
        patientName: 'Tariq Mahmood',
        patientId: 'p_2',
        patientCode: 'P-002',
        memoNumber: 'CM-2026-00001',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder:
                  (ctx) => ElevatedButton(
                    onPressed: () => JournalItemDetailSheet.show(ctx, entry),
                    child: const Text('Open Sheet'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(
        find.text('Invoice #CM-2026-00001 • Tariq Mahmood'),
        findsOneWidget,
      );
      expect(find.text('Payment & Dispense Settled'), findsOneWidget);
      expect(find.text('#CM-2026-00001'), findsOneWidget);
      expect(find.text('UPI'), findsWidgets);
    });
  });
}
