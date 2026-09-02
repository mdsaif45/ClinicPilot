import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:drift/native.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/services/sample_data_seeder.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync('cp_seeder_test_');
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  test('SampleDataSeeder populates 125 patients and rich practice history across 10 months', () async {
    await SampleDataSeeder.seedRealisticData(container);

    // 1. Verify Clinics
    final allClinics = await db.select(db.clinics).get();
    expect(allClinics.length, 3);
    final clinicIds = allClinics.map((c) => c.id).toSet();
    expect(clinicIds, containsAll(['clinic_city_care', 'clinic_apex_health', 'clinic_online']));

    // 2. Verify Exact 125 Patients
    final allPatients = await db.select(db.patients).get();
    expect(allPatients.length, 125);

    // 3. Verify Case Records, Complaints, Prescriptions, Investigations
    final allCases = await db.select(db.patientCaseRecords).get();
    expect(allCases.length, 125);

    final allComplaints = await db.select(db.complaints).get();
    expect(allComplaints.length, greaterThanOrEqualTo(250));

    final allPrescriptions = await db.select(db.prescriptions).get();
    expect(allPrescriptions.length, greaterThanOrEqualTo(250));

    final allInvestigations = await db.select(db.investigations).get();
    expect(allInvestigations.length, 125);

    // 4. Verify Visits & Timeline Distribution (Dec 2025 - Sep 2026)
    final allVisits = await db.select(db.visits).get();
    expect(allVisits.length, greaterThanOrEqualTo(300));

    final visitYears = allVisits.map((v) => v.visitDate.year).toSet();
    expect(visitYears, containsAll([2025, 2026]));

    final visitMonths = allVisits.map((v) => v.visitDate.month).toSet();
    expect(visitMonths.length, greaterThanOrEqualTo(9)); // Spans all months

    // 5. Verify Operating Hours & Alternate Weekdays
    for (final v in allVisits) {
      if (v.clinicId == 'clinic_city_care') {
        expect([DateTime.monday, DateTime.wednesday, DateTime.friday], contains(v.visitDate.weekday));
        expect(v.visitDate.hour, inInclusiveRange(19, 21)); // 7 PM - 10 PM
      } else if (v.clinicId == 'clinic_apex_health') {
        expect([DateTime.tuesday, DateTime.thursday, DateTime.saturday], contains(v.visitDate.weekday));
        expect(v.visitDate.hour, inInclusiveRange(19, 21)); // 7 PM - 10 PM
      }
    }

    // 6. Verify Cash Memos & Itemized Breakdown
    final allMemos = await db.select(db.cashMemos).get();
    expect(allMemos.length, allVisits.length);

    final partialMemos = allMemos.where((m) => m.paidAmount < m.total).toList();
    expect(partialMemos.isNotEmpty, isTrue); // Some pending balances exist for realistic testing

    // 7. Verify Practice Expenses
    final allExpenses = await db.select(db.expenses).get();
    expect(allExpenses.length, greaterThanOrEqualTo(60));

    final rentExpenses = allExpenses.where((e) => e.category == 'Rent').toList();
    expect(rentExpenses.length, greaterThanOrEqualTo(20)); // 10 months * 2 physical clinics

    // 8. Verify Referral Contacts & Camps
    final allContacts = await db.select(db.referralContacts).get();
    expect(allContacts.length, 6);

    final allCamps = await db.select(db.camps).get();
    expect(allCamps.length, 3);
  });
}
