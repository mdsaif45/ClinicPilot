import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/activity/presentation/practice_activity_screen.dart';
import 'package:clinic_pilot/features/activity/providers/practice_activity_provider.dart';
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

  group('PracticeActivityScreen Widget Tests', () {
    testWidgets('renders Day, Week, and Month tabs and switches charts on tap', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          practiceActivityProvider.overrideWith((ref) {
            final range = ref.watch(activityRangeProvider);
            final metric = ref.watch(activityMetricProvider);
            return PracticeActivityState(
              selectedDate: todayMidnight,
              range: range,
              metric: metric,
              totalRevenue: 5000,
              totalPatients: 10,
              totalExpense: 1000,
              netProfit: 4000,
              hourlyBins: [
                const HourlyActivityBin(hour: 10, label: '10 AM', revenue: 2000, patients: 4),
                const HourlyActivityBin(hour: 17, label: '5 PM', revenue: 3000, patients: 6),
              ],
              peakRushDescription: 'Peak rush 10:00 AM – 12:00 PM',
              weeklyBins: [
                DailyActivityBin(date: todayMidnight, dayLabel: 'Fri', revenue: 5000, patients: 10, isTargetMet: true),
              ],
              weeklyTargetValue: 18000,
              weeklyAchievementPercent: 0.85,
              monthlyBubbleDays: [
                BubbleCalendarDay(date: todayMidnight, dayNumber: 28, revenue: 5000, patients: 10, intensity: 0.9, isInSelectedMonth: true, isToday: true),
              ],
              monthlyWeeklySubtotals: [
                const WeeklySubtotal(label: 'Aug 1 – 7', revenue: 15000, patients: 25),
              ],
              timelineItems: [
                TimelineActivityItem(
                  id: '1',
                  timestamp: todayMidnight.add(const Duration(hours: 10)),
                  type: ActivityEventType.consultation,
                  title: 'Sara Khan • New Consultation',
                  subtitle: 'Condition: Fever',
                ),
              ],
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PracticeActivityScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Initial State: Day View
      expect(find.text('Practice Activity'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Revenue'), findsWidgets);
      expect(find.text('Patients'), findsWidgets);
      expect(find.text('Sara Khan • New Consultation'), findsOneWidget);

      // 2. Switch to Week View
      await tester.tap(find.text('Week'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(activityRangeProvider), equals(ActivityTimeRange.week));
      expect(find.text('Weekly Practice Pace'), findsOneWidget);

      // 3. Switch to Month View (Bubble Matrix)
      await tester.tap(find.text('Month'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(activityRangeProvider), equals(ActivityTimeRange.month));
      expect(find.text('Weekly Summary'), findsOneWidget);

      // 4. Toggle Metric: Switch to Patients
      final patientsPills = find.widgetWithText(InkWell, 'Patients');
      expect(patientsPills, findsWidgets);
      await tester.tap(patientsPills.first, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(activityMetricProvider), equals(ActivityMetric.patients));
    });
  });
}
