import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/id_generator.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/settings/providers/doctor_profile_provider.dart';
import 'demo_data/demo_disease_archetypes.dart';
import 'demo_data/demo_patient_roster.dart';
import 'demo_data/demo_crm_data.dart';

/// Ultra-realistic demo practice data generator for ClinicPilot.
/// Generates 125 unique patients, chronological visits from Dec 2025 to Sep 2026,
/// 2 physical evening clinics (7-10 PM on alternate days) + 1 online practice,
/// detailed homeopathic case histories, repertory complaints, prescriptions,
/// lab investigations, human-timed cash memos, and monthly itemized expenses.
class SampleDataSeeder {
  static DateTime _alignToClinicSchedule(
    DateTime targetDate,
    int clinicIndex,
    int patientIndex,
    int visitOffsetMinutes,
  ) {
    var day = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (clinicIndex == 0) {
      // Clinic 1: City Care (Mon=1, Wed=3, Fri=5)
      while (day.weekday != DateTime.monday &&
          day.weekday != DateTime.wednesday &&
          day.weekday != DateTime.friday) {
        day = day.add(const Duration(days: 1));
      }
      // Evening OPD: 7:00 PM to 10:00 PM (19:00 - 22:00)
      final hourSlots = [19, 19, 20, 20, 21, 21];
      final minuteSlots = [10, 35, 05, 40, 15, 45];
      final slotIdx = (patientIndex + visitOffsetMinutes) % hourSlots.length;
      return DateTime(
        day.year,
        day.month,
        day.day,
        hourSlots[slotIdx],
        minuteSlots[slotIdx] + (patientIndex % 10),
      );
    } else if (clinicIndex == 1) {
      // Clinic 2: Apex Health (Tue=2, Thu=4, Sat=6)
      while (day.weekday != DateTime.tuesday &&
          day.weekday != DateTime.thursday &&
          day.weekday != DateTime.saturday) {
        day = day.add(const Duration(days: 1));
      }
      // Evening OPD: 7:00 PM to 10:00 PM (19:00 - 22:00)
      final hourSlots = [19, 19, 20, 20, 21, 21];
      final minuteSlots = [15, 45, 10, 45, 20, 50];
      final slotIdx = (patientIndex + visitOffsetMinutes) % hourSlots.length;
      return DateTime(
        day.year,
        day.month,
        day.day,
        hourSlots[slotIdx],
        minuteSlots[slotIdx] + (patientIndex % 8),
      );
    } else {
      // Clinic 3: Online / Teleconsultation (Open All Days)
      // Mostly daytime (10 AM - 5 PM) with occasional urgent night consult (8:30 PM - 10 PM)
      final isNightSlot = (patientIndex % 6 == 0);
      if (isNightSlot) {
        return DateTime(
          day.year,
          day.month,
          day.day,
          20 + (patientIndex % 2),
          15 + (patientIndex % 35),
        );
      } else {
        final dayHours = [10, 11, 12, 14, 15, 16];
        final dayMinutes = [15, 40, 20, 10, 35, 45];
        final slotIdx = (patientIndex + visitOffsetMinutes) % dayHours.length;
        return DateTime(
          day.year,
          day.month,
          day.day,
          dayHours[slotIdx],
          dayMinutes[slotIdx] + (patientIndex % 12),
        );
      }
    }
  }

  static Future<void> seedRealisticData(dynamic ref) async {
    final AppDatabase db = ref is WidgetRef
        ? ref.read(databaseProvider)
        : (ref is ProviderContainer
            ? ref.read(databaseProvider)
            : (ref as dynamic).read(databaseProvider) as AppDatabase);

    // 0. Clean all existing practice data completely
    await db.clearAllPracticeData();

    final now = DateTime.now();

    // 1. Doctor Profile & Global Settings
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorNameKey,
            value: 'Dr. MD Zaid',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorFirstNameKey,
            value: 'MD',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorLastNameKey,
            value: 'Zaid',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorQualificationKey,
            value: 'BHMS, MD (Hom.)',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorRegNumberKey,
            value: 'WB-2018-98421',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorPhoneKey,
            value: '9830012345',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorEmailKey,
            value: 'dr.zaid@clinicpilot.com',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kOnboardingDoneKey,
            value: 'true',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal',
            value: '95000',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_new_patient_goal',
            value: '25',
            updatedAt: Value(now),
          ),
        );

    try {
      if (Hive.isBoxOpen('settings')) {
        final box = Hive.box('settings');
        box.put(kOnboardingDoneKey, true);
        box.put(kDoctorNameKey, 'Dr. MD Zaid');
        box.put(kDoctorFirstNameKey, 'MD');
        box.put(kDoctorLastNameKey, 'Zaid');
        box.put(kDoctorQualificationKey, 'BHMS, MD (Hom.)');
        box.put(kDoctorRegNumberKey, 'WB-2018-98421');
        box.put(kDoctorPhoneKey, '9830012345');
        box.put(kDoctorEmailKey, 'dr.zaid@clinicpilot.com');
      }
    } catch (_) {}

    // 2. Practice Clinics (2 Physical Evening Clinics + 1 Online Practice)
    const clinic1Id = 'clinic_city_care';
    const clinic2Id = 'clinic_apex_health';
    const clinicOnlineId = 'clinic_online';

    // Clinic 1: City Care Homeo Clinic (Mon, Wed, Fri 7-10 PM)
    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic1Id,
            name: 'City Care Homeo Clinic',
            address: const Value('14 Central Avenue, Market Complex'),
            phone: const Value('9830012345'),
            defaultConsultationFee: const Value(300.0),
            monthlyRent: const Value(6000.0),
            openDays: const Value('1,3,5'), // Mon, Wed, Fri
            colorHex: const Value('#0D9488'),
          ),
        );

    // Clinic 2: Apex Health Center (Tue, Thu, Sat 7-10 PM)
    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic2Id,
            name: 'Apex Health Center',
            address: const Value('82 Park Street, 2nd Floor'),
            phone: const Value('9830012346'),
            defaultConsultationFee: const Value(500.0),
            monthlyRent: const Value(8000.0),
            openDays: const Value('2,4,6'), // Tue, Thu, Sat
            colorHex: const Value('#2563EB'),
          ),
        );

    // Clinic 3: Online / Teleconsultation (Digital Practice)
    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinicOnlineId,
            name: 'Online / Teleconsultation',
            address: const Value('Digital / Remote Practice'),
            phone: const Value('9830012345'),
            defaultConsultationFee: const Value(350.0),
            monthlyRent: const Value(0.0),
            openDays: const Value('1,2,3,4,5,6,7'),
            colorHex: const Value('#7C3AED'),
          ),
        );

    // Clinic Revenue Targets
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic1Id',
            value: '45000',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic2Id',
            value: '35000',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinicOnlineId',
            value: '15000',
            updatedAt: Value(now),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'active_clinic_id',
            value: clinic1Id,
            updatedAt: Value(now),
          ),
        );

    // 3. Referral Partner CRM Contacts & Health Camps
    for (final r in DemoCrmData.referralContacts) {
      await db.into(db.referralContacts).insertOnConflictUpdate(
            ReferralContactsCompanion.insert(
              id: IdGenerator.generate(),
              name: r['name'] as String,
              contactPerson: Value(r['contactPerson'] as String?),
              category: Value(r['category'] as String),
              phone: Value(r['phone'] as String?),
              address: Value(r['address'] as String?),
              visitCount: Value(r['visitCount'] as int),
              referralCount: Value(r['referralCount'] as int),
              notes: Value(r['notes'] as String?),
              lastVisitedDate: Value(now.subtract(const Duration(days: 12))),
              createdAt: Value(DateTime(2025, 12, 1)),
              updatedAt: Value(now),
            ),
          );
    }

    for (final c in DemoCrmData.healthCamps) {
      final campDate = DateTime(2026, c['month'] as int, c['day'] as int, 9, 30);
      await db.into(db.camps).insertOnConflictUpdate(
            CampsCompanion.insert(
              id: IdGenerator.generate(),
              name: c['name'] as String,
              date: Value(campDate),
              location: Value(c['location'] as String?),
              cost: Value(c['cost'] as double),
              attendance: Value(c['attendance'] as int),
              clinicId: const Value(clinic1Id),
              notes: Value(c['notes'] as String?),
              createdAt: Value(campDate),
            ),
          );
    }

    // 4. Seeding 125 Patients, Cases, Encounters, Complaints, Prescriptions & Cash Memos
    final archetypes = DemoArchetypes.all;
    final patientEntries = DemoPatientRoster.entries;

    int memoCounter = 1;
    final clinicIds = [clinic1Id, clinic2Id, clinicOnlineId];

    for (int pIdx = 0; pIdx < patientEntries.length; pIdx++) {
      final p = patientEntries[pIdx];
      final archetype = archetypes[p.archetypeIndex % archetypes.length];
      final assignedClinicId = clinicIds[p.clinicIndex];
      final patientId = IdGenerator.generate();

      final serialNumberStr = (pIdx + 1).toString().padLeft(3, '0');
      final patientCodeStr = 'P-${p.registrationYear}-$serialNumberStr';

      // Initial Encounter Date aligned with clinic working hours
      final initialVisitDate = _alignToClinicSchedule(
        DateTime(p.registrationYear, p.registrationMonth, p.registrationDay),
        p.clinicIndex,
        pIdx,
        0,
      );

      // 4.1 Insert Patient Record
      await db.into(db.patients).insertOnConflictUpdate(
            PatientsCompanion.insert(
              id: patientId,
              name: p.name,
              phone: p.phone,
              email: Value(p.email.isEmpty ? null : p.email),
              age: p.age,
              gender: p.gender,
              primaryClinicId: Value(assignedClinicId),
              primaryDisease: Value(archetype.primaryDisease),
              area: Value(p.area),
              address: Value(p.address),
              occupation: Value(p.occupation),
              patientCode: Value(patientCodeStr),
              serialNo: Value(serialNumberStr),
              referralSource: Value(p.referralSource),
              createdAt: Value(initialVisitDate),
              updatedAt: Value(initialVisitDate),
            ),
          );

      // 4.2 Insert Patient Case Record (Comprehensive Totality)
      await db.into(db.patientCaseRecords).insertOnConflictUpdate(
            PatientCaseRecordsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: patientId,
              recordDate: Value(initialVisitDate),
              chiefComplaintsJson: Value(
                  '{"complaint":"${archetype.chiefComplaint}","sensation":"${archetype.sensation}","location":"${archetype.location}"}'),
              hpi: Value(
                  'Patient presents with ${archetype.chiefComplaint}. Onset: ${archetype.onset}. Aggravated by ${archetype.aggravatingFactors}. Ameliorated by ${archetype.amelioratingFactors}.'),
              pastHistoryJson: Value('{"past":"${archetype.pastHistory}"}'),
              familyHistoryJson: Value('{"family":"${archetype.familyHistory}"}'),
              physicalGeneralsJson: Value(
                  '{"thermal":"${archetype.thermal}","thirst":"${archetype.thirst}","appetite":"${archetype.appetite}","sleep":"${archetype.sleep}"}'),
              mentalGeneralsJson: Value('{"mental":"${archetype.mentalGenerals}"}'),
              miasmaticAnalysisJson: Value('{"miasm":"${archetype.miasm}"}'),
              outcome: const Value('Under Active Treatment'),
              createdAt: Value(initialVisitDate),
              updatedAt: Value(initialVisitDate),
            ),
          );

      // 4.3 Initial Encounter (Visit 1)
      final visit1Id = IdGenerator.generate();
      final hasFollowUps = p.followUpCount > 0;
      final nextFollowUpDate1 = hasFollowUps
          ? initialVisitDate.add(Duration(days: 21 + (pIdx % 7)))
          : null;

      await db.into(db.visits).insertOnConflictUpdate(
            VisitsCompanion.insert(
              id: visit1Id,
              patientId: patientId,
              clinicId: assignedClinicId,
              visitType: 'new',
              consultationType: Value(p.clinicIndex == 2 ? 'online' : 'clinic'),
              disease: archetype.primaryDisease,
              chiefComplaint: Value(archetype.chiefComplaint),
              referralSource: Value(p.referralSource),
              outcome: const Value('improved'),
              visitDate: initialVisitDate,
              nextFollowUpDate: Value(nextFollowUpDate1),
              notes: Value(
                  'Baseline homeopathic evaluation complete. Prescribed ${archetype.primaryRemedy} ${archetype.primaryPotency}. Advised dietary modifications.'),
              createdAt: Value(initialVisitDate),
            ),
          );

      // 4.4 Initial Complaint
      await db.into(db.complaints).insertOnConflictUpdate(
            ComplaintsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: patientId,
              visitId: Value(visit1Id),
              complaintIndex: const Value(1),
              complaintDate: Value(initialVisitDate),
              isBaseline: const Value(true),
              complaintName: archetype.chiefComplaint,
              location: Value(archetype.location),
              side: Value(archetype.side),
              onset: Value(archetype.onset),
              duration: Value(archetype.duration),
              sensation: Value(archetype.sensation),
              aggravatingFactors: Value(archetype.aggravatingFactors),
              amelioratingFactors: Value(archetype.amelioratingFactors),
              concomitants: Value(archetype.concomitants),
              causation: Value(archetype.causation),
              periodicity: Value(archetype.periodicity),
              severity: Value(archetype.initialSeverity),
              status: const Value('Active'),
              createdAt: Value(initialVisitDate),
              updatedAt: Value(initialVisitDate),
            ),
          );

      // 4.5 Initial Prescription
      await db.into(db.prescriptions).insertOnConflictUpdate(
            PrescriptionsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: patientId,
              visitId: Value(visit1Id),
              prescriptionDate: Value(initialVisitDate),
              isBaseline: const Value(true),
              remedyIndex: const Value(1),
              remedyName: archetype.primaryRemedy,
              potency: archetype.primaryPotency,
              doseCount: Value(archetype.doseCount),
              frequency: Value(archetype.frequency),
              vehicle: Value(archetype.vehicle),
              durationDays: const Value('21 days'),
              instructions: Value(archetype.instructions),
              dietaryAdvice: Value(archetype.dietaryAdvice),
              createdAt: Value(initialVisitDate),
              updatedAt: Value(initialVisitDate),
            ),
          );

      // 4.6 Initial Lab Investigation
      await db.into(db.investigations).insertOnConflictUpdate(
            InvestigationsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: patientId,
              visitId: Value(visit1Id),
              testDate: Value(initialVisitDate),
              isBaseline: const Value(true),
              testCategory: Value(archetype.testCategory),
              testName: archetype.testName,
              numericValue: Value(archetype.numericValue),
              stringValue: Value(archetype.stringValue),
              unit: Value(archetype.unit),
              refRangeMin: Value(archetype.refMin),
              refRangeMax: Value(archetype.refMax),
              flag: Value(archetype.flag),
              labName: Value(archetype.labName),
              notes: Value(archetype.testNotes),
              createdAt: Value(initialVisitDate),
              updatedAt: Value(initialVisitDate),
            ),
          );

      // 4.7 Cash Memo for Visit 1 (Human realistic timing: 12-25 mins after visit start)
      final memoTime1 = initialVisitDate.add(Duration(minutes: 12 + (pIdx % 15)));
      final consultFee1 = p.clinicIndex == 1
          ? 500.0
          : (p.clinicIndex == 2 ? 350.0 : 300.0);
      final medFee1 = archetype.medicineFee;
      final discount1 = (pIdx % 10 == 0) ? 50.0 : 0.0;
      final total1 = (consultFee1 + medFee1) - discount1;

      // ~90% fully paid, ~10% partial payment with pending balance
      final isPartial1 = (pIdx % 9 == 0);
      final paidAmount1 = isPartial1 ? (total1 - 200.0).clamp(100.0, total1) : total1;

      final paymentMethods = ['UPI', 'Cash', 'UPI', 'Google Pay', 'PhonePe', 'Card'];
      final payMethod1 = paymentMethods[pIdx % paymentMethods.length];

      final memoNum1 = 'CM-${initialVisitDate.year}-${memoCounter.toString().padLeft(5, '0')}';
      memoCounter++;

      await db.into(db.cashMemos).insertOnConflictUpdate(
            CashMemosCompanion.insert(
              id: IdGenerator.generate(),
              memoNumber: memoNum1,
              patientId: patientId,
              clinicId: Value(assignedClinicId),
              visitId: Value(visit1Id),
              consultationFee: Value(consultFee1),
              medicineFee: Value(medFee1),
              discount: Value(discount1),
              total: total1,
              paidAmount: Value(paidAmount1),
              paymentMethod: payMethod1,
              notes: Value(isPartial1 ? 'Partial payment received. Balance pending.' : 'Fully paid.'),
              memoDate: Value(memoTime1),
              createdAt: Value(memoTime1),
            ),
          );

      // 4.8 Multi-Encounter Follow-ups across Months
      DateTime previousVisitDate = initialVisitDate;
      for (int k = 1; k <= p.followUpCount; k++) {
        final targetFollowUpDate = previousVisitDate.add(Duration(days: 21 + (pIdx % 10)));
        if (targetFollowUpDate.isAfter(now)) {
          break; // Stop if projected beyond current live date
        }

        final followUpDate = _alignToClinicSchedule(
          targetFollowUpDate,
          p.clinicIndex,
          pIdx,
          k * 15,
        );
        previousVisitDate = followUpDate;

        final followUpVisitId = IdGenerator.generate();
        final isLastFollowUp = (k == p.followUpCount);
        final nextFollowUpDateK = isLastFollowUp
            ? followUpDate.add(Duration(days: 28 + (pIdx % 14)))
            : null;

        final followUpOutcome = k >= 2 ? 'recovered' : 'improved';

        await db.into(db.visits).insertOnConflictUpdate(
              VisitsCompanion.insert(
                id: followUpVisitId,
                patientId: patientId,
                clinicId: assignedClinicId,
                visitType: 'repeat',
                consultationType: Value(p.clinicIndex == 2 ? 'online' : 'clinic'),
                disease: archetype.primaryDisease,
                chiefComplaint: Value(archetype.chiefComplaint),
                referralSource: const Value(null), // Null on repeat visits
                outcome: Value(followUpOutcome),
                visitDate: followUpDate,
                nextFollowUpDate: Value(nextFollowUpDateK),
                notes: Value(
                    'Follow-up #$k. Patient reports marked symptomatic relief. Joint stiffness and acute bouts reduced. Continued ${archetype.followUpRemedy} ${archetype.followUpPotency}.'),
                createdAt: Value(followUpDate),
              ),
            );

        // Follow-up complaint with reduced severity
        final improvedSeverity = math.max(2, archetype.initialSeverity - (k * 2));
        await db.into(db.complaints).insertOnConflictUpdate(
              ComplaintsCompanion.insert(
                id: IdGenerator.generate(),
                patientId: patientId,
                visitId: Value(followUpVisitId),
                complaintIndex: const Value(1),
                complaintDate: Value(followUpDate),
                isBaseline: const Value(false),
                complaintName: archetype.chiefComplaint,
                location: Value(archetype.location),
                side: Value(archetype.side),
                onset: Value(archetype.onset),
                duration: Value(archetype.duration),
                sensation: Value('Slight residual tenderness on heavy exertion'),
                aggravatingFactors: Value(archetype.aggravatingFactors),
                amelioratingFactors: Value(archetype.amelioratingFactors),
                concomitants: const Value('Appetite and sleep improved'),
                severity: Value(improvedSeverity),
                status: Value(improvedSeverity <= 3 ? 'Improving' : 'Active'),
                createdAt: Value(followUpDate),
                updatedAt: Value(followUpDate),
              ),
            );

        // Follow-up prescription
        await db.into(db.prescriptions).insertOnConflictUpdate(
              PrescriptionsCompanion.insert(
                id: IdGenerator.generate(),
                patientId: patientId,
                visitId: Value(followUpVisitId),
                prescriptionDate: Value(followUpDate),
                isBaseline: const Value(false),
                remedyIndex: const Value(1),
                remedyName: archetype.followUpRemedy,
                potency: archetype.followUpPotency,
                doseCount: Value(archetype.doseCount),
                frequency: const Value('OD (Once daily in morning)'),
                vehicle: Value(archetype.vehicle),
                durationDays: const Value('30 days'),
                instructions: const Value('Dissolve under tongue. Report after 1 month.'),
                dietaryAdvice: Value(archetype.dietaryAdvice),
                createdAt: Value(followUpDate),
                updatedAt: Value(followUpDate),
              ),
            );

        // Follow-up Cash Memo (Follow-up fee + medicine refill)
        final memoTimeK = followUpDate.add(Duration(minutes: 10 + (pIdx % 12)));
        final consultFeeK = p.clinicIndex == 1 ? 400.0 : (p.clinicIndex == 2 ? 300.0 : 250.0);
        final medFeeK = archetype.medicineFee - 30.0;
        final totalK = consultFeeK + medFeeK;
        final memoNumK = 'CM-${followUpDate.year}-${memoCounter.toString().padLeft(5, '0')}';
        memoCounter++;

        final payMethodK = paymentMethods[(pIdx + k) % paymentMethods.length];

        await db.into(db.cashMemos).insertOnConflictUpdate(
              CashMemosCompanion.insert(
                id: IdGenerator.generate(),
                memoNumber: memoNumK,
                patientId: patientId,
                clinicId: Value(assignedClinicId),
                visitId: Value(followUpVisitId),
                consultationFee: Value(consultFeeK),
                medicineFee: Value(medFeeK),
                discount: const Value(0.0),
                total: totalK,
                paidAmount: Value(totalK),
                paymentMethod: payMethodK,
                notes: const Value('Follow-up consultation & medicine refill.'),
                memoDate: Value(memoTimeK),
                createdAt: Value(memoTimeK),
              ),
            );
      }
    }

    // 5. Practice Expenses across 10 Months (Dec 2025 – Sep 2026)
    final monthsTimeline = [
      (2025, 12),
      (2026, 1),
      (2026, 2),
      (2026, 3),
      (2026, 4),
      (2026, 5),
      (2026, 6),
      (2026, 7),
      (2026, 8),
      (2026, 9),
    ];

    for (final (yr, mo) in monthsTimeline) {
      final rentDate = DateTime(yr, mo, 1, 10, 0);
      final salDate = DateTime(yr, mo, 5, 11, 30);
      final internetDate = DateTime(yr, mo, 8, 14, 0);
      final elecDate = DateTime(yr, mo, 10, 15, 0);
      final medRestockDate = DateTime(yr, mo, 12, 16, 30);
      final maintDate = DateTime(yr, mo, 15, 12, 0);

      // ── Clinic 1 (City Care) Monthly Fixed & Variable Expenses ──
      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic1Id,
              category: 'Rent',
              subcategory: const Value('Commercial Space Rent'),
              amount: 6000.0,
              paymentMethod: const Value('Bank Transfer'),
              isRecurring: const Value(true),
              notes: const Value('Monthly clinic premises lease.'),
              date: rentDate,
              createdAt: Value(rentDate),
            ),
          );

      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic1Id,
              category: 'Staff Salary',
              subcategory: const Value('OPD Assistant & Receptionist'),
              amount: 5000.0,
              paymentMethod: const Value('Bank Transfer'),
              isRecurring: const Value(true),
              notes: const Value('Staff compensation.'),
              date: salDate,
              createdAt: Value(salDate),
            ),
          );

      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic1Id,
              category: 'Internet',
              subcategory: const Value('Airtel Xstream Fiber'),
              amount: 799.0,
              paymentMethod: const Value('UPI'),
              isRecurring: const Value(true),
              notes: const Value('High-speed broadband for patient records.'),
              date: internetDate,
              createdAt: Value(internetDate),
            ),
          );

      final elec1Amt = 1500.0 + ((mo * 110) % 700);
      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic1Id,
              category: 'Electricity',
              subcategory: const Value('CESC Commercial Bill'),
              amount: elec1Amt,
              paymentMethod: const Value('UPI'),
              isRecurring: const Value(true),
              notes: const Value('Monthly power and AC utilities.'),
              date: elecDate,
              createdAt: Value(elecDate),
            ),
          );

      final medRestock1Amt = 4800.0 + ((mo * 250) % 2200);
      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic1Id,
              category: 'Medicine Purchase',
              subcategory: const Value('SBL & Dr. Willmar Schwabe India'),
              amount: medRestock1Amt,
              paymentMethod: const Value('Bank Transfer'),
              isRecurring: const Value(false),
              notes: const Value('Bulk dilutions, mother tinctures, and sugar globules No. 30.'),
              date: medRestockDate,
              createdAt: Value(medRestockDate),
            ),
          );

      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic1Id,
              category: 'Miscellaneous',
              subcategory: const Value('Sanitization & Waste Disposal'),
              amount: 650.0,
              paymentMethod: const Value('Cash'),
              isRecurring: const Value(true),
              notes: const Value('Bio-medical waste handling and deep cleaning.'),
              date: maintDate,
              createdAt: Value(maintDate),
            ),
          );

      // ── Clinic 2 (Apex Health) Monthly Fixed & Variable Expenses ──
      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic2Id,
              category: 'Rent',
              subcategory: const Value('Park Street Polyclinic Chamber'),
              amount: 8000.0,
              paymentMethod: const Value('Bank Transfer'),
              isRecurring: const Value(true),
              notes: const Value('Monthly chamber lease.'),
              date: rentDate,
              createdAt: Value(rentDate),
            ),
          );

      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic2Id,
              category: 'Staff Salary',
              subcategory: const Value('Senior Clinic Attendant'),
              amount: 6500.0,
              paymentMethod: const Value('Bank Transfer'),
              isRecurring: const Value(true),
              notes: const Value('Monthly staff salary.'),
              date: salDate,
              createdAt: Value(salDate),
            ),
          );

      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic2Id,
              category: 'Internet',
              subcategory: const Value('Jio Fiber Gigabit'),
              amount: 999.0,
              paymentMethod: const Value('UPI'),
              isRecurring: const Value(true),
              notes: const Value('Clinic broadband connection.'),
              date: internetDate,
              createdAt: Value(internetDate),
            ),
          );

      final elec2Amt = 1950.0 + ((mo * 140) % 850);
      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic2Id,
              category: 'Electricity',
              subcategory: const Value('CESC Electricity'),
              amount: elec2Amt,
              paymentMethod: const Value('UPI'),
              isRecurring: const Value(true),
              notes: const Value('Chamber lighting and cooling.'),
              date: elecDate,
              createdAt: Value(elecDate),
            ),
          );

      final medRestock2Amt = 6200.0 + ((mo * 310) % 2800);
      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic2Id,
              category: 'Medicine Purchase',
              subcategory: const Value('Dr. Reckeweg (Germany) & Schwabe'),
              amount: medRestock2Amt,
              paymentMethod: const Value('Bank Transfer'),
              isRecurring: const Value(false),
              notes: const Value('Imported German drops, R-series formulations, and triturations.'),
              date: medRestockDate,
              createdAt: Value(medRestockDate),
            ),
          );

      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinic2Id,
              category: 'Miscellaneous',
              subcategory: const Value('Housekeeping & Maintenance'),
              amount: 750.0,
              paymentMethod: const Value('Cash'),
              isRecurring: const Value(true),
              notes: const Value('Housekeeping supplies and maintenance.'),
              date: maintDate,
              createdAt: Value(maintDate),
            ),
          );
    }

    // Stationery & Health Camp Expenses
    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: IdGenerator.generate(),
            clinicId: clinic1Id,
            category: 'Marketing',
            subcategory: const Value('Prescription Pads & Medicine Pouches Printing'),
            amount: 1400.0,
            paymentMethod: const Value('UPI'),
            isRecurring: const Value(false),
            notes: const Value('Custom printed envelopes and letterheads.'),
            date: DateTime(2026, 1, 15),
            createdAt: Value(DateTime(2026, 1, 15)),
          ),
        );

    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: IdGenerator.generate(),
            clinicId: clinic1Id,
            category: 'Camp',
            subcategory: const Value('Free Winter Joint & Arthritis Screening Camp'),
            amount: 2400.0,
            paymentMethod: const Value('Cash'),
            isRecurring: const Value(false),
            notes: const Value('Tent rental, community hall banner, and free uric acid test strips.'),
            date: DateTime(2026, 1, 18),
            createdAt: Value(DateTime(2026, 1, 18)),
          ),
        );

    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: IdGenerator.generate(),
            clinicId: clinic1Id,
            category: 'Camp',
            subcategory: const Value('Women & Child Spring Health Camp'),
            amount: 3100.0,
            paymentMethod: const Value('Cash'),
            isRecurring: const Value(false),
            notes: const Value('School ground logistics, Hb test strips, and complimentary pediatric tonics.'),
            date: DateTime(2026, 4, 12),
            createdAt: Value(DateTime(2026, 4, 12)),
          ),
        );

    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: IdGenerator.generate(),
            clinicId: clinic1Id,
            category: 'Camp',
            subcategory: const Value('Senior Citizens Lifestyle & Wellness Camp'),
            amount: 2800.0,
            paymentMethod: const Value('Cash'),
            isRecurring: const Value(false),
            notes: const Value('Senior citizen club logistics and complimentary mobility oils.'),
            date: DateTime(2026, 7, 19),
            createdAt: Value(DateTime(2026, 7, 19)),
          ),
        );

    // 6. Hourly Footfalls Logged during Clinic Operating Hours
    for (int pIdx = 0; pIdx < math.min(patientEntries.length, 60); pIdx++) {
      final p = patientEntries[pIdx];
      final footfallDate = DateTime(p.registrationYear, p.registrationMonth, p.registrationDay, 19, 15 + (pIdx % 35));
      await db.into(db.footfalls).insertOnConflictUpdate(
            FootfallsCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinicIds[p.clinicIndex],
              date: Value(footfallDate),
              name: p.name,
              phone: Value(p.phone),
              disease: Value(archetypes[p.archetypeIndex % archetypes.length].primaryDisease),
              notes: const Value('Walk-in registered and converted to regular patient.'),
              createdAt: Value(footfallDate),
            ),
          );
    }
  }
}
