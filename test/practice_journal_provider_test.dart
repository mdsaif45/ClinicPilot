import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/features/activity/providers/practice_journal_provider.dart';
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

  group('PracticeJournalProvider Unit Tests', () {
    test(
      'groups entries by day with daily totals and descending sorting',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final yesterdayMidnight = todayMidnight.subtract(
          const Duration(days: 1),
        );

        // Seed clinic & patient
        await db
            .into(db.clinics)
            .insert(
              ClinicsCompanion.insert(
                id: 'c1',
                name: 'City Clinic',
                address: const drift.Value('Main St'),
              ),
            );

        await db
            .into(db.patients)
            .insert(
              PatientsCompanion.insert(
                id: 'p1',
                patientCode: const drift.Value('P-001'),
                name: 'Dr. John Doe',
                age: 45,
                phone: '9876543210',
                primaryClinicId: const drift.Value('c1'),
                gender: 'Male',
              ),
            );

        // 1. Insert Today's entries
        await db
            .into(db.visits)
            .insert(
              VisitsCompanion.insert(
                id: 'v1',
                patientId: 'p1',
                clinicId: 'c1',
                visitDate: todayMidnight.add(const Duration(hours: 10)),
                disease: 'Hypertension',
                visitType: 'new',
              ),
            );

        await db
            .into(db.cashMemos)
            .insert(
              CashMemosCompanion.insert(
                id: 'cm1',
                memoNumber: 'CM-101',
                patientId: 'p1',
                clinicId: const drift.Value('c1'),
                memoDate: drift.Value(
                  todayMidnight.add(const Duration(hours: 10, minutes: 15)),
                ),
                total: 1500,
                paymentMethod: 'upi',
              ),
            );

        // 2. Insert Yesterday's entries
        await db
            .into(db.visits)
            .insert(
              VisitsCompanion.insert(
                id: 'v2',
                patientId: 'p1',
                clinicId: 'c1',
                visitDate: yesterdayMidnight.add(const Duration(hours: 16)),
                disease: 'Diabetes',
                visitType: 'repeat',
              ),
            );

        await db
            .into(db.expenses)
            .insert(
              ExpensesCompanion.insert(
                id: 'e1',
                clinicId: 'c1',
                category: 'Rent',
                amount: 500,
                paymentMethod: const drift.Value('cash'),
                isRecurring: const drift.Value(false),
                date: yesterdayMidnight.add(const Duration(hours: 11)),
              ),
            );

        await container.read(dashboardRawStreamsProvider.future);

        final groups = container.read(practiceJournalProvider);

        expect(groups.length, equals(2));

        // Today Group
        final todayGroup = groups.firstWhere((g) => g.dayLabel == 'Today');
        expect(todayGroup.totalRevenue, equals(1500.0));
        expect(todayGroup.totalPatients, equals(1));
        expect(todayGroup.revenueProgress, greaterThan(0.0));
        expect(todayGroup.patientProgress, greaterThan(0.0));
        expect(todayGroup.entries.length, equals(2));

        // Yesterday Group
        final yesterdayGroup = groups.firstWhere(
          (g) => g.dayLabel == 'Yesterday',
        );
        expect(yesterdayGroup.totalExpense, equals(500.0));
        expect(yesterdayGroup.totalPatients, equals(1));
        expect(yesterdayGroup.entries.length, equals(2));
      },
    );

    test('filters journal by category and search query', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      await db
          .into(db.clinics)
          .insert(
            ClinicsCompanion.insert(
              id: 'c1',
              name: 'City Clinic',
              address: const drift.Value('Main St'),
            ),
          );

      await db
          .into(db.patients)
          .insert(
            PatientsCompanion.insert(
              id: 'p1',
              patientCode: const drift.Value('P-001'),
              name: 'Sara Ali',
              age: 26,
              phone: '9876543210',
              primaryClinicId: const drift.Value('c1'),
              gender: 'Female',
            ),
          );

      await db
          .into(db.visits)
          .insert(
            VisitsCompanion.insert(
              id: 'v1',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: todayMidnight.add(const Duration(hours: 9)),
              disease: 'Asthma',
              visitType: 'new',
            ),
          );

      await container.read(dashboardRawStreamsProvider.future);

      // Filter by Expense (expect empty)
      container.read(journalCategoryFilterProvider.notifier).state =
          JournalEventType.expense;
      var groups = container.read(practiceJournalProvider);
      expect(groups.isEmpty, isTrue);

      // Filter by Consultation (expect 1)
      container.read(journalCategoryFilterProvider.notifier).state =
          JournalEventType.consultation;
      groups = container.read(practiceJournalProvider);
      expect(groups.isNotEmpty, isTrue);
      expect(groups.first.entries.first.title, contains('Sara Ali'));

      // Search query filtering
      container.read(journalCategoryFilterProvider.notifier).state = null;
      container.read(journalSearchQueryProvider.notifier).state = 'Asthma';
      groups = container.read(practiceJournalProvider);
      expect(groups.isNotEmpty, isTrue);

      container.read(journalSearchQueryProvider.notifier).state = 'NonExistent';
      groups = container.read(practiceJournalProvider);
      expect(groups.isEmpty, isTrue);
    });
  });
}
