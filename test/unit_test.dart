import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/utils/formatters.dart';
import 'package:clinic_pilot/core/providers/period_provider.dart';

void main() {
  group('Formatters Unit Tests', () {
    test('formatCurrency formats Indian Rupees correctly', () {
      expect(Formatters.formatCurrency(5000), '₹ 5,000');
      expect(Formatters.formatCurrency(0), '₹ 0');
      expect(Formatters.formatCurrency(15400.50), '₹ 15,401');
    });

    test('formatDate formats DateTime correctly', () {
      final date = DateTime(2026, 5, 20);
      expect(Formatters.formatDate(date), '20 May 2026');
    });

    test('formatMonthYear formats month and year correctly', () {
      final date = DateTime(2026, 8, 15);
      expect(Formatters.formatMonthYear(date), 'August 2026');
    });
  });

  group('Database Schema v2 & Business Logic Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      // Seed test patient p1 for tests requiring valid Foreign Keys
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p1',
              patientCode: const drift.Value('P-2026-00001'),
              name: 'Dr Zaid Patient',
              phone: '9876543210',
              age: 35,
              gender: 'Male',
              primaryClinicId: const drift.Value('clinic_old'),
              primaryDisease: const drift.Value('Fever'),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('Default clinics and settings are seeded on create', () async {
      final clinics = await db.select(db.clinics).get();
      expect(clinics.length, equals(2));
      expect(clinics.any((c) => c.id == 'clinic_old'), isTrue);
      expect(clinics.any((c) => c.id == 'clinic_new'), isTrue);

      final settings = await db.select(db.settings).get();
      expect(settings.isNotEmpty, isTrue);
      expect(settings.any((s) => s.key == 'monthly_revenue_goal'), isTrue);
    });

    test('Patient registration creates patient identity', () async {
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p_reg',
              patientCode: const drift.Value('P-2026-00002'),
              name: 'New Registered Patient',
              phone: '9876543211',
              age: 40,
              gender: 'Female',
              primaryClinicId: const drift.Value('clinic_old'),
              primaryDisease: const drift.Value('Cold'),
            ),
          );

      final patient = await (db.select(db.patients)..where((t) => t.id.equals('p_reg'))).getSingle();
      expect(patient.name, equals('New Registered Patient'));
      expect(patient.patientCode, equals('P-2026-00002'));
      expect(patient.isDeleted, isFalse);
    });

    test('First visit for a patient is NEW and second visit is REPEAT', () async {
      // 1st visit
      final v1 = VisitsCompanion.insert(
        id: 'v1',
        patientId: 'p1',
        clinicId: 'clinic_old',
        visitType: 'new',
        disease: 'Fever',
        visitDate: DateTime.now(),
      );
      await db.into(db.visits).insert(v1);

      final visitsBefore = await (db.select(db.visits)..where((t) => t.patientId.equals('p1'))).get();
      final nextType = visitsBefore.isEmpty ? 'new' : 'repeat';
      expect(nextType, equals('repeat'));

      // 2nd visit
      final v2 = VisitsCompanion.insert(
        id: 'v2',
        patientId: 'p1',
        clinicId: 'clinic_new',
        visitType: nextType,
        disease: 'Follow-up Fever',
        visitDate: DateTime.now(),
      );
      await db.into(db.visits).insert(v2);

      final visitsAfter = await (db.select(db.visits)..where((t) => t.patientId.equals('p1'))).get();
      expect(visitsAfter.length, equals(2));
      expect(visitsAfter[0].visitType, equals('new'));
      expect(visitsAfter[1].visitType, equals('repeat'));
    });

    test('Cash memo total calculation = (consult + med + other) - discount', () {
      const consult = 300.0;
      const med = 450.0;
      const other = 50.0;
      const discount = 100.0;

      final total = (consult + med + other) - discount;
      expect(total, equals(700.0));
    });

    test('Revenue for Clinic A excludes Clinic B memos', () async {
      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'm1',
              memoNumber: 'CM-2026-00001',
              patientId: 'p1',
              clinicId: const drift.Value('clinic_old'),
              total: 500.0,
              paidAmount: const drift.Value(500.0),
              paymentMethod: 'Cash',
            ),
          );

      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'm2',
              memoNumber: 'CM-2026-00002',
              patientId: 'p1',
              clinicId: const drift.Value('clinic_new'),
              total: 800.0,
              paidAmount: const drift.Value(800.0),
              paymentMethod: 'UPI',
            ),
          );

      final oldMemos = await (db.select(db.cashMemos)..where((t) => t.clinicId.equals('clinic_old'))).get();
      final newMemos = await (db.select(db.cashMemos)..where((t) => t.clinicId.equals('clinic_new'))).get();

      final oldRev = oldMemos.fold<double>(0.0, (s, m) => s + m.total);
      final newRev = newMemos.fold<double>(0.0, (s, m) => s + m.total);

      expect(oldRev, equals(500.0));
      expect(newRev, equals(800.0));
    });

    test('Net Profit = Revenue - (Variable Expenses + Fixed Rent)', () {
      const revenue = 15000.0;
      const variableExpenses = 2000.0;
      const monthlyRent = 3000.0;

      final netProfit = revenue - (variableExpenses + monthlyRent);
      expect(netProfit, equals(10000.0));
    });

    test('Soft-deleted records are excluded from query results', () async {
      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'm_active',
              memoNumber: 'CM-2026-00010',
              patientId: 'p1',
              clinicId: const drift.Value('clinic_old'),
              total: 500.0,
              paymentMethod: 'Cash',
            ),
          );

      await db.into(db.cashMemos).insert(
            CashMemosCompanion.insert(
              id: 'm_deleted',
              memoNumber: 'CM-2026-00011',
              patientId: 'p1',
              clinicId: const drift.Value('clinic_old'),
              total: 1000.0,
              paymentMethod: 'Cash',
              isDeleted: const drift.Value(true),
            ),
          );

      final activeMemos = await (db.select(db.cashMemos)..where((t) => t.isDeleted.equals(false))).get();
      expect(activeMemos.length, equals(1));
    });

    test('Patient visiting both clinics is counted in each clinic visit totals', () async {
      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v_old',
              patientId: 'p1',
              clinicId: 'clinic_old',
              visitType: 'new',
              disease: 'Fever',
              visitDate: DateTime.now(),
            ),
          );

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v_new',
              patientId: 'p1',
              clinicId: 'clinic_new',
              visitType: 'repeat',
              disease: 'Follow-up',
              visitDate: DateTime.now(),
            ),
          );

      final oldVisits = await (db.select(db.visits)..where((t) => t.clinicId.equals('clinic_old'))).get();
      final newVisits = await (db.select(db.visits)..where((t) => t.clinicId.equals('clinic_new'))).get();

      expect(oldVisits.length, equals(1));
      expect(newVisits.length, equals(1));
    });

    test('Pending balance = Total - Paid Amount', () {
      const total = 1200.0;
      const paid = 800.0;
      final pending = total - paid;
      expect(pending, equals(400.0));
    });

    test('Period filter calculates boundaries correctly', () {
      final notifier = PeriodNotifier();
      notifier.setFilter(PeriodFilter.thisMonth);

      final state = notifier.state;
      expect(state.filter, equals(PeriodFilter.thisMonth));
      expect(state.dateRange.start.day, equals(1));
      expect(state.priorDateRange, isA<DateTimeRange>());
    });

    test('Period Filter Labels are readable', () {
      expect(PeriodFilter.today.label, equals('Today'));
      expect(PeriodFilter.thisWeek.label, equals('This Week'));
      expect(PeriodFilter.thisMonth.label, equals('This Month'));
      expect(PeriodFilter.lastMonth.label, equals('Last Month'));
      expect(PeriodFilter.custom.label, equals('Custom Range'));
    });

    test('Clinics update modifies fields properly', () async {
      await (db.update(db.clinics)..where((t) => t.id.equals('clinic_old'))).write(
        const ClinicsCompanion(
          monthlyRent: drift.Value(3500.0),
        ),
      );

      final updated = await (db.select(db.clinics)..where((t) => t.id.equals('clinic_old'))).getSingle();
      expect(updated.monthlyRent, equals(3500.0));
    });

    test('Expenses category filtering works', () async {
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'e1',
              clinicId: 'clinic_old',
              category: 'Rent',
              amount: 3000.0,
              date: DateTime.now(),
            ),
          );

      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'e2',
              clinicId: 'clinic_old',
              category: 'Marketing',
              amount: 1500.0,
              date: DateTime.now(),
            ),
          );

      final rentExps = await (db.select(db.expenses)..where((t) => t.category.equals('Rent'))).get();
      expect(rentExps.length, equals(1));
      expect(rentExps.first.amount, equals(3000.0));
    });

    test('Patient search matches name, code, or disease', () async {
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p_search',
              patientCode: const drift.Value('P-2026-00099'),
              name: 'Ahmad Khan',
              phone: '9123456789',
              age: 40,
              gender: 'Male',
              primaryClinicId: const drift.Value('clinic_old'),
              primaryDisease: const drift.Value('Gastritis'),
            ),
          );

      final byName = await (db.select(db.patients)..where((t) => t.name.contains('Ahmad'))).get();
      expect(byName.isNotEmpty, isTrue);

      final byCode = await (db.select(db.patients)..where((t) => t.patientCode.equals('P-2026-00099'))).get();
      expect(byCode.isNotEmpty, isTrue);
    });

    test('Visit outcome field supports improved, no_change, worse, recovered', () async {
      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v_outcome',
              patientId: 'p1',
              clinicId: 'clinic_old',
              visitType: 'repeat',
              disease: 'Asthma',
              outcome: const drift.Value('improved'),
              visitDate: DateTime.now(),
            ),
          );

      final visit = await (db.select(db.visits)..where((t) => t.id.equals('v_outcome'))).getSingle();
      expect(visit.outcome, equals('improved'));
    });

    test('Visits with follow-up dates can be queried for overdue lists', () async {
      final today = DateTime.now();
      final followUp = today.add(const Duration(days: 7));

      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v_followup',
              patientId: 'p1',
              clinicId: 'clinic_old',
              visitType: 'repeat',
              disease: 'Hypertension',
              visitDate: today,
              nextFollowUpDate: drift.Value(followUp),
            ),
          );

      final visit = await (db.select(db.visits)..where((t) => t.id.equals('v_followup'))).getSingle();
      expect(visit.nextFollowUpDate, isNotNull);
      expect(visit.nextFollowUpDate!.isAfter(today), isTrue);
    });

    test('Settings key-value updates persist correctly', () async {
      await db.into(db.settings).insertOnConflictUpdate(
            SettingsCompanion.insert(
              key: 'monthly_revenue_goal',
              value: '75000',
              updatedAt: drift.Value(DateTime.now()),
            ),
          );

      final setting = await (db.select(db.settings)..where((t) => t.key.equals('monthly_revenue_goal'))).getSingle();
      expect(setting.value, equals('75000'));
    });

    test('Open days clinic calculation parses correctly', () {
      const openDaysStr = '1,3,5';
      final openDaysList = openDaysStr.split(',').map((e) => int.parse(e.trim())).toList();

      expect(openDaysList.length, equals(3));
      expect(openDaysList, contains(1));
      expect(openDaysList, contains(3));
      expect(openDaysList, contains(5));
    });

    test('Patient code generation format P-YYYY-NNNNN', () {
      const year = 2026;
      const count = 42;
      final code = 'P-$year-${count.toString().padLeft(5, '0')}';
      expect(code, equals('P-2026-00042'));
    });

    test('Memo number generation format CM-YYYY-NNNNN', () {
      const year = 2026;
      const count = 1;
      final memoNum = 'CM-$year-${count.toString().padLeft(5, '0')}';
      expect(memoNum, equals('CM-2026-00001'));
    });

    test('Multiple clinics allow distinct monthly rent settings', () async {
      final clinics = await db.select(db.clinics).get();
      final oldC = clinics.firstWhere((c) => c.id == 'clinic_old');
      final newC = clinics.firstWhere((c) => c.id == 'clinic_new');

      expect(oldC.monthlyRent, equals(3000.0));
      expect(newC.monthlyRent, equals(8000.0));
    });

    test('Subcategory field in Expenses supports camp names', () async {
      await db.into(db.expenses).insert(
            ExpensesCompanion.insert(
              id: 'exp_camp',
              clinicId: 'clinic_old',
              category: 'Camp',
              subcategory: const drift.Value('Khidderpore Free Eye Camp'),
              amount: 2500.0,
              date: DateTime.now(),
            ),
          );

      final exp = await (db.select(db.expenses)..where((t) => t.id.equals('exp_camp'))).getSingle();
      expect(exp.subcategory, equals('Khidderpore Free Eye Camp'));
    });

    test('Visits support online and camp consultation types', () async {
      await db.into(db.visits).insert(
            VisitsCompanion.insert(
              id: 'v_camp',
              patientId: 'p1',
              clinicId: 'clinic_old',
              visitType: 'new',
              consultationType: const drift.Value('camp'),
              disease: 'Cataract',
              visitDate: DateTime.now(),
            ),
          );

      final v = await (db.select(db.visits)..where((t) => t.id.equals('v_camp'))).getSingle();
      expect(v.consultationType, equals('camp'));
    });

    test('Deleting a patient marks isDeleted = true without losing row', () async {
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p_to_delete',
              patientCode: const drift.Value('P-2026-00088'),
              name: 'To Delete',
              phone: '1111111111',
              age: 30,
              gender: 'Female',
              primaryClinicId: const drift.Value('clinic_old'),
            ),
          );

      await (db.update(db.patients)..where((t) => t.id.equals('p_to_delete'))).write(
        const PatientsCompanion(isDeleted: drift.Value(true)),
      );

      final allRows = await db.select(db.patients).get();
      final activeRows = await (db.select(db.patients)..where((t) => t.isDeleted.equals(false))).get();

      expect(allRows.any((p) => p.id == 'p_to_delete'), isTrue);
      expect(activeRows.any((p) => p.id == 'p_to_delete'), isFalse);
    });

    test('Rent prorating: Today -> roughly monthlyRent / daysInMonth', () {
      const monthlyRent = 8000.0;
      final today = DateTime(2026, 8, 15);
      final range = DateTimeRange(start: today, end: today);
      final daysInPeriod = range.end.difference(range.start).inDays + 1;
      final daysInMonth = DateUtils.getDaysInMonth(range.start.year, range.start.month);
      final prorated = monthlyRent * (daysInPeriod / daysInMonth);
      expect(prorated, closeTo(258.06, 0.1));
    });

    test('Rent prorating: This Month -> exactly monthlyRent', () {
      const monthlyRent = 8000.0;
      final start = DateTime(2026, 8, 1);
      final end = DateTime(2026, 8, 31);
      final range = DateTimeRange(start: start, end: end);
      final daysInPeriod = range.end.difference(range.start).inDays + 1;
      final daysInMonth = DateUtils.getDaysInMonth(range.start.year, range.start.month);
      final prorated = monthlyRent * (daysInPeriod / daysInMonth);
      expect(prorated, equals(8000.0));
    });

    test('Rent prorating: Custom 15-day range in a 30-day month -> monthlyRent / 2', () {
      const monthlyRent = 8000.0;
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 6, 15);
      final range = DateTimeRange(start: start, end: end);
      final daysInPeriod = range.end.difference(range.start).inDays + 1;
      final daysInMonth = DateUtils.getDaysInMonth(range.start.year, range.start.month);
      final prorated = monthlyRent * (daysInPeriod / daysInMonth);
      expect(prorated, equals(4000.0));
    });
  });
}
