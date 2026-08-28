import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/activity/presentation/practice_journal_screen.dart';
import 'package:clinic_pilot/features/activity/presentation/widgets/double_activity_ring.dart';
import 'package:clinic_pilot/features/activity/providers/practice_journal_provider.dart';
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

  group('PracticeJournalScreen Widget Tests', () {
    testWidgets('renders Journal header, date groups, aggregate pills, and filters', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final yesterdayMidnight = todayMidnight.subtract(const Duration(days: 1));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          practiceJournalProvider.overrideWith((ref) {
            return [
              JournalDayGroup(
                date: todayMidnight,
                dayLabel: 'Today',
                totalRevenue: 3500,
                totalPatients: 3,
                totalExpense: 0,
                entries: [
                  PracticeJournalEntry(
                    id: '1',
                    timestamp: todayMidnight.add(const Duration(hours: 10)),
                    type: JournalEventType.consultation,
                    title: 'Priya Sharma • New Consultation',
                    subtitle: 'Condition: Allergic Rhinitis',
                    patientName: 'Priya Sharma',
                  ),
                  PracticeJournalEntry(
                    id: '2',
                    timestamp: todayMidnight.add(const Duration(hours: 10, minutes: 15)),
                    type: JournalEventType.dispense,
                    title: 'Invoice #CM-201 • Priya Sharma',
                    subtitle: 'Payment: UPI',
                    amount: 3500,
                    paymentMethod: 'UPI',
                    patientName: 'Priya Sharma',
                  ),
                ],
              ),
              JournalDayGroup(
                date: yesterdayMidnight,
                dayLabel: 'Yesterday',
                totalRevenue: 0,
                totalPatients: 0,
                totalExpense: 1200,
                entries: [
                  PracticeJournalEntry(
                    id: '3',
                    timestamp: yesterdayMidnight.add(const Duration(hours: 15)),
                    type: JournalEventType.expense,
                    title: 'Clinic Expense • Utilities',
                    subtitle: 'Electricity Bill',
                    amount: 1200,
                    category: 'Utilities',
                  ),
                ],
              ),
            ];
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PracticeJournalScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Header & Filter Chips
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('All Events'), findsOneWidget);
      expect(find.text('Consultations'), findsOneWidget);
      expect(find.text('Dispenses'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);

      // 2. Date Section Headers & Double Activity Rings
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.byType(DoubleActivityRing), findsWidgets);

      // 3. Entry Content
      expect(find.text('Priya Sharma • New Consultation'), findsOneWidget);
      expect(find.text('Invoice #CM-201 • Priya Sharma'), findsOneWidget);
      expect(find.text('Clinic Expense • Utilities'), findsOneWidget);

      // 4. Tap Search Icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
