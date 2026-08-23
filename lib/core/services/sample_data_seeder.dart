import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/id_generator.dart';
import '../../features/clinical/models/case_record_models.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/settings/providers/doctor_profile_provider.dart';

class SampleDataSeeder {
  static Future<void> seedRealisticData(dynamic ref) async {
    final AppDatabase db = ref is WidgetRef
        ? ref.read(databaseProvider)
        : (ref is ProviderContainer
            ? ref.read(databaseProvider)
            : (ref as dynamic).read(databaseProvider) as AppDatabase);

    // 0. Clean all existing data completely
    await db.clearAllPracticeData();

    // 1. Doctor Profile & Onboarding Settings
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorNameKey,
            value: 'Dr. MD Zaid',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorFirstNameKey,
            value: 'MD',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorLastNameKey,
            value: 'Zaid',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorQualificationKey,
            value: 'BHMS, MD (Hom.)',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorRegNumberKey,
            value: 'WB-2018-98421',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorPhoneKey,
            value: '9830012345',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorEmailKey,
            value: 'dr.zaid@clinicpilot.com',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kOnboardingDoneKey,
            value: 'true',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal',
            value: '75000',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_new_patient_goal',
            value: '25',
            updatedAt: Value(DateTime.now()),
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

    // 2. 3 Clinics
    final clinic1Id = IdGenerator.generate();
    final clinic2Id = IdGenerator.generate();
    final clinic3Id = IdGenerator.generate();

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic1Id,
            name: 'City Care Homeo Clinic',
            address: const Value('14 Central Avenue, Market Complex'),
            phone: const Value('9830012345'),
            defaultConsultationFee: const Value(300.0),
            monthlyRent: const Value(5000.0),
            openDays: const Value('1,2,3,4,5,6'),
          ),
        );

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic2Id,
            name: 'Apex Health Center',
            address: const Value('82 Park Street, 2nd Floor'),
            phone: const Value('9830012346'),
            defaultConsultationFee: const Value(500.0),
            monthlyRent: const Value(8000.0),
            openDays: const Value('1,3,5'),
          ),
        );

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic3Id,
            name: 'Healing Touch Homoeo Care',
            address: const Value('5 Lake Road, Opposite Metro Gate 2'),
            phone: const Value('9830012347'),
            defaultConsultationFee: const Value(400.0),
            monthlyRent: const Value(6000.0),
            openDays: const Value('2,4,6'),
          ),
        );

    // Save clinic targets
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic1Id',
            value: '35000',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic2Id',
            value: '25000',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal_$clinic3Id',
            value: '20000',
            updatedAt: Value(DateTime.now()),
          ),
        );

    // 3. 10 Patients
    final now = DateTime.now();

    final patientsData = [
      {
        'id': IdGenerator.generate(),
        'name': 'Tariq Mahmood',
        'phone': '9830112233',
        'age': 52,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Joint Pain / Osteoarthritis',
        'area': 'Central Avenue',
        'address': '14/2 Park Street',
        'occupation': 'Accountant',
        'code': 'P-2026-00001',
        'serial': '001',
        'marital': 'Married',
        'dob': '19740512',
        'firstVisit': '20260710',
        'remedy': 'Rhus Toxicodendron',
        'potency': '200C',
        'testName': 'Serum Uric Acid & Knee X-Ray',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Nusrat Jahan',
        'phone': '9830223344',
        'age': 36,
        'gender': 'Female',
        'clinicId': clinic1Id,
        'disease': 'Migraine / Chronic Headache',
        'area': 'Salt Lake',
        'address': 'Sector 1, Block B',
        'occupation': 'Teacher',
        'code': 'P-2026-00002',
        'serial': '002',
        'marital': 'Married',
        'dob': '19900824',
        'firstVisit': '20260714',
        'remedy': 'Natrum Muriaticum',
        'potency': '200C',
        'testName': 'Brain MRI & Vision Test',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Ayaan Ali',
        'phone': '9830334455',
        'age': 8,
        'gender': 'Male',
        'clinicId': clinic2Id,
        'disease': 'Allergic Rhinitis / Dust Allergy',
        'area': 'Park Circus',
        'address': '12 Orient Row',
        'occupation': 'Student',
        'code': 'P-2026-00003',
        'serial': '001',
        'marital': 'Single',
        'dob': '20180315',
        'firstVisit': '20260718',
        'remedy': 'Arsenicum Album',
        'potency': '30C',
        'testName': 'Absolute Eosinophil Count (AEC)',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Farhana Begum',
        'phone': '9830445566',
        'age': 45,
        'gender': 'Female',
        'clinicId': clinic2Id,
        'disease': 'PCOD / Hormonal Imbalance',
        'area': 'Ballygunge',
        'address': '45/A Circular Rd',
        'occupation': 'Homemaker',
        'code': 'P-2026-00004',
        'serial': '002',
        'marital': 'Married',
        'dob': '19811105',
        'firstVisit': '20260722',
        'remedy': 'Pulsatilla Nigricans',
        'potency': '200C',
        'testName': 'Pelvic USG & Hormone Profile',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Rashid Khan',
        'phone': '9830556677',
        'age': 61,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Hypertension & Insomnia',
        'area': 'Ripon Street',
        'address': '7 Ripon Lane',
        'occupation': 'Businessman',
        'code': 'P-2026-00005',
        'serial': '003',
        'marital': 'Married',
        'dob': '19650919',
        'firstVisit': '20260726',
        'remedy': 'Nux Vomica',
        'potency': '200C',
        'testName': 'Lipid Profile & Resting ECG',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Sana Fatima',
        'phone': '9830667788',
        'age': 29,
        'gender': 'Female',
        'clinicId': clinic3Id,
        'disease': 'Eczema / Chronic Dermatitis',
        'area': 'Lake Town',
        'address': 'Block A, Flat 4',
        'occupation': 'Architect',
        'code': 'P-2026-00006',
        'serial': '001',
        'marital': 'Single',
        'dob': '19970210',
        'firstVisit': '20260729',
        'remedy': 'Graphites',
        'potency': '30C',
        'testName': 'Skin Allergy Panel IgE',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Imran Shaikh',
        'phone': '9830778899',
        'age': 34,
        'gender': 'Male',
        'clinicId': clinic3Id,
        'disease': 'Gastritis & Acid Reflux / GERD',
        'area': 'New Town',
        'address': 'Action Area 1',
        'occupation': 'Software Engineer',
        'code': 'P-2026-00007',
        'serial': '002',
        'marital': 'Married',
        'dob': '19920618',
        'firstVisit': '20260802',
        'remedy': 'Lycopodium Clavatum',
        'potency': '200C',
        'testName': 'Upper GI Endoscopy Report',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Yasmin Akhtar',
        'phone': '9830889900',
        'age': 49,
        'gender': 'Female',
        'clinicId': clinic2Id,
        'disease': 'Hypothyroidism & Weight Gain',
        'area': 'Alipore',
        'address': '22 Judges Court Rd',
        'occupation': 'Bank Manager',
        'code': 'P-2026-00008',
        'serial': '003',
        'marital': 'Married',
        'dob': '19771230',
        'firstVisit': '20260806',
        'remedy': 'Thyroidinum',
        'potency': '3X',
        'testName': 'Thyroid Profile (T3, T4, TSH)',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Zubair Ahmed',
        'phone': '9830990011',
        'age': 23,
        'gender': 'Male',
        'clinicId': clinic1Id,
        'disease': 'Acne Vulgaris & Hair Fall',
        'area': 'Entally',
        'address': '18 CIT Road',
        'occupation': 'College Student',
        'code': 'P-2026-00009',
        'serial': '004',
        'marital': 'Single',
        'dob': '20030408',
        'firstVisit': '20260810',
        'remedy': 'Berberis Aquifolium',
        'potency': 'Q (Mother Tincture)',
        'testName': 'Serum Ferritin & Vitamin D3',
      },
      {
        'id': IdGenerator.generate(),
        'name': 'Meherun Nisa',
        'phone': '9831001122',
        'age': 68,
        'gender': 'Female',
        'clinicId': clinic3Id,
        'disease': 'Bronchial Asthma & Cough',
        'area': 'Kasba',
        'address': '88 Bosepukur Rd',
        'occupation': 'Retired Professor',
        'code': 'P-2026-00010',
        'serial': '003',
        'marital': 'Widowed',
        'dob': '19580125',
        'firstVisit': '20260814',
        'remedy': 'Blatta Orientalis',
        'potency': 'Q (Mother Tincture)',
        'testName': 'Spirometry Pulmonary Function Test',
      },
    ];

    // Insert Patients and their full Case Taking records
    for (final p in patientsData) {
      final pId = p['id'] as String;
      final clinicId = p['clinicId'] as String;
      final disease = p['disease'] as String;
      final name = p['name'] as String;
      final phone = p['phone'] as String;
      final age = p['age'] as int;
      final gender = p['gender'] as String;
      final area = p['area'] as String;
      final address = p['address'] as String;
      final occupation = p['occupation'] as String;
      final code = p['code'] as String;
      final serial = p['serial'] as String;
      final marital = p['marital'] as String;
      final dob = p['dob'] as String;
      final firstVisit = p['firstVisit'] as String;
      final remedy = p['remedy'] as String;
      final potency = p['potency'] as String;
      final testName = p['testName'] as String;

      await db.into(db.patients).insertOnConflictUpdate(
            PatientsCompanion.insert(
              id: pId,
              patientCode: Value(code),
              serialNo: Value(serial),
              name: name,
              phone: phone,
              age: age,
              gender: gender,
              primaryClinicId: Value(clinicId),
              primaryDisease: Value(disease),
              area: Value(area),
              address: Value(address),
              occupation: Value(occupation),
              createdAt: Value(now.subtract(const Duration(days: 40))),
            ),
          );

      // Full Master Case Record
      final caseRecord = MasterCaseRecordData(
        patientId: pId,
        recordDate: now.subtract(const Duration(days: 35)),
        identification: PatientIdentificationDetails(
          regNo: code,
          firstVisitDate: firstVisit,
          patientName: name,
          age: age.toString(),
          gender: gender,
          dob: dob,
          occupation: occupation,
          address: address,
          phone: phone,
          maritalStatus: marital,
        ),
        chiefComplaints: [
          ChiefComplaintDetail(
            complaint: disease,
            location: area,
            onset: 'Gradual onset over last 6 months',
            duration: '6 months',
            sensation: 'Severe aching and discomfort',
            extensionRadiation: 'Radiating during physical exertion',
            modalitiesAgg: 'Cold weather, evening exertion, fatigue',
            modalitiesAmel: 'Warm application, adequate rest',
            concomitants: 'General fatigue, disturbed sleep',
            causation: 'Occupational stress and postural strain',
            severity: 'Moderate',
            associatedSymptoms: 'Loss of stamina, mild stiffness',
          ),
        ],
        hpi: const HpiDetails(
          chronologicalDevelopment: 'Gradual onset progressing steadily with seasonal variation.',
          firstOccurrence: 'Started around 6 months ago.',
          progression: 'Slowly progressive without homeopathic intervention.',
          previousEpisodes: 'Recurrent seasonal flare-ups.',
          previousTreatment: 'Allopathic pain relievers providing temporary relief.',
          responseToTreatment: 'Partial and transient improvement.',
          relevantPrecipitatingFactors: 'Climate change, emotional and physical strain.',
          otherRelevantHistory: 'Sedentary habits and irregular work routine.',
        ),
        physicalGenerals: const PhysicalGenerals(
          hotChilly: 'Chilly',
          appetite: 'Moderate, desires warm home cooked meals',
          thirst: 'Moderate, 2 litres per day, prefers warm water',
          cravings: 'Warm savoury food, occasional sweets',
          aversions: 'Oily and spicy junk food',
          sleepQuantity: '6 to 7 hours, light sleep with early morning waking',
          perspiration: 'Moderate, mostly on forehead and neck',
          energyVitality: 'Moderate energy levels, fatigue after long work hours',
        ),
        mentalGenerals: const MentalGenerals(
          generalMentalState: 'Calm, cooperative, conscientious about health',
          disposition: 'Pleasant and hardworking',
          anxiety: 'Occasional health anxiety regarding chronic condition',
          irritability: 'Mild when overtired',
          responseToStress: 'Copes by listening to classical music and resting',
        ),
        clinicalExam: const ClinicalExamVitals(
          generalAppearance: 'Well nourished, alert, cooperative',
          pulse: '74 bpm',
          bloodPressure: '124/82 mmHg',
          temperature: '98.4 F',
          respiratoryRate: '16/min',
          spo2: '99%',
          weightKg: '68 kg',
          heightCm: '168 cm',
          bmi: '24.1',
        ),
        miasmaticAnalysis: const MiasmaticAnalysis(
          dominantMiasm: 'Psora',
          secondaryMixedMiasm: 'Sycotic',
          psoricFeatures: 'Hypersensitivity to cold, skin dryness, seasonal aggravation',
          sycoticFeatures: 'Sluggish recovery, localized stiffness',
        ),
        caseTotality: CaseTotality(
          totalityOfSymptoms: 'Totality of characteristic mental and physical general symptoms',
          characteristicSymptoms: 'Thermal modality chilly, worse cold and damp, better warmth',
          generals: 'Chilly thermal, moderate thirst, fatigue on exertion',
          finalRemedySelection: '$remedy $potency selected based on constitutional totality',
        ),
        clinicalAssessment: ClinicalAssessmentDetails(
          provisionalDiagnosis: disease,
          finalWorkingDiagnosis: disease,
          clinicalRemarks: 'Constitutional homoeopathic treatment initiated with lifestyle guidance',
        ),
        baselinePrescription: PrescriptionPlanDetails(
          prescriptionDate: firstVisit,
          remedyName: remedy,
          potency: potency,
          dose: '4 pills',
          repetitionFrequency: 'Twice daily before meals',
          route: 'Oral',
          pharmaceuticalForm: 'Globules / Sugar Pellets',
          quantityDispensed: '1 dram vial',
          dietRegimenAdvice: 'Avoid raw onions, strong coffee, and excessive spices during remedy action',
          lifestyleAdvice: 'Daily 30 min morning walk and 8 hours restful sleep',
        ),
        investigations: InvestigationsPlanDetails(
          investigationDate: firstVisit,
          investigationName: testName,
          resultValue: 'Within clinically acceptable limits',
          normalAbnormal: 'Normal',
          reportSummary: 'Diagnostic report reviewed and noted in chart.',
        ),
        followUpDetails: FollowUpDetails(
          followUpDate: firstVisit,
          nextFollowUp: '20260905',
          overallResponse: 'Treatment ongoing',
        ),
        outcome: 'Active Under Treatment',
      );

      await db.into(db.patientCaseRecords).insertOnConflictUpdate(
            PatientCaseRecordsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              recordDate: Value(now.subtract(const Duration(days: 35))),
              chiefComplaintsJson: Value(caseRecord.chiefComplaintsJson),
              hpi: Value(caseRecord.hpiJson),
              pastHistoryJson: Value(caseRecord.pastHistoryJson),
              familyHistoryJson: Value(caseRecord.familyHistoryJson),
              developmentalHistoryJson: Value(caseRecord.developmentalHistoryJson),
              physicalGeneralsJson: Value(caseRecord.physicalGeneralsJson),
              mentalGeneralsJson: Value(caseRecord.mentalGeneralsJson),
              lifestyleJson: Value(caseRecord.lifestyleJson),
              clinicalExamJson: Value(caseRecord.clinicalExamJson),
              miasmaticAnalysisJson: Value(caseRecord.miasmaticAnalysisJson),
              caseTotalityJson: Value(caseRecord.caseTotalityJson),
              baselinePrescriptionJson: Value(caseRecord.baselinePrescriptionJson),
              investigationsJson: Value(caseRecord.investigationsJson),
              followUpNotes: const Value('Initial comprehensive homeopathic case taking completed.'),
              outcome: const Value('Active Under Treatment'),
              createdAt: Value(now.subtract(const Duration(days: 35))),
            ),
          );

      // Structured complaint
      await db.into(db.complaints).insertOnConflictUpdate(
            ComplaintsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              complaintName: disease,
              location: Value(area),
              severity: const Value(6),
              status: const Value('Active'),
              createdAt: Value(now.subtract(const Duration(days: 35))),
            ),
          );

      // Structured prescription
      await db.into(db.prescriptions).insertOnConflictUpdate(
            PrescriptionsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              prescriptionDate: Value(now.subtract(const Duration(days: 35))),
              remedyName: remedy,
              potency: potency,
              doseCount: const Value('4 globules'),
              frequency: const Value('BD (Twice daily)'),
              instructions: const Value('Take on empty stomach 15 mins before meals'),
              dietaryAdvice: const Value('Avoid raw onion, garlic, and strong camphor'),
              createdAt: Value(now.subtract(const Duration(days: 35))),
            ),
          );

      // Structured investigation
      await db.into(db.investigations).insertOnConflictUpdate(
            InvestigationsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: pId,
              testDate: Value(now.subtract(const Duration(days: 35))),
              testName: testName,
              flag: const Value('Normal'),
              notes: const Value('Baseline clinical report verified by Dr. MD Zaid'),
              createdAt: Value(now.subtract(const Duration(days: 35))),
            ),
          );
    }

    // 4. 15 Visits (10 New Initial Visits + 5 Follow-Up Visits)
    final visits = <String, String>{}; // key: visitKey, val: visitId

    // 10 New Visits
    for (int i = 0; i < 10; i++) {
      final p = patientsData[i];
      final vId = IdGenerator.generate();
      visits['new_$i'] = vId;
      await db.into(db.visits).insertOnConflictUpdate(
            VisitsCompanion.insert(
              id: vId,
              patientId: p['id'] as String,
              clinicId: p['clinicId'] as String,
              visitType: 'new',
              disease: p['disease'] as String,
              chiefComplaint: Value(p['disease'] as String),
              visitDate: now.subtract(Duration(days: 30 - i * 2)),
              consultationType: const Value('clinic'),
              outcome: const Value('improved'),
              nextFollowUpDate: Value(now.add(Duration(days: 7 + i * 2))),
            ),
          );
    }

    // 5 Follow-Up Visits for Repeat Patients (P0, P1, P3, P5, P6)
    final followUpIndices = [0, 1, 3, 5, 6];
    final followUpOutcomes = ['improved', 'recovered', 'improved', 'improved', 'no_change'];
    for (int j = 0; j < followUpIndices.length; j++) {
      final pIndex = followUpIndices[j];
      final p = patientsData[pIndex];
      final vId = IdGenerator.generate();
      visits['followup_$j'] = vId;
      await db.into(db.visits).insertOnConflictUpdate(
            VisitsCompanion.insert(
              id: vId,
              patientId: p['id'] as String,
              clinicId: p['clinicId'] as String,
              visitType: 'followup',
              disease: p['disease'] as String,
              chiefComplaint: Value('Follow-up review for ${p['disease']}'),
              visitDate: now.subtract(Duration(days: 10 - j * 2)),
              consultationType: const Value('clinic'),
              outcome: Value(followUpOutcomes[j]),
              nextFollowUpDate: Value(now.add(Duration(days: 14 + j * 3))),
            ),
          );
    }

    // 5. 15 Cash Memos (Linked to visits & patients, with repeats and realistic payments)
    final memoConfigs = [
      // 10 Initial Visits Memos
      {'pIdx': 0, 'vKey': 'new_0', 'cId': clinic1Id, 'fee': 300.0, 'med': 200.0, 'disc': 0.0, 'paid': 500.0, 'method': 'UPI', 'daysAgo': 30},
      {'pIdx': 1, 'vKey': 'new_1', 'cId': clinic1Id, 'fee': 300.0, 'med': 150.0, 'disc': 0.0, 'paid': 450.0, 'method': 'Cash', 'daysAgo': 28},
      {'pIdx': 2, 'vKey': 'new_2', 'cId': clinic2Id, 'fee': 500.0, 'med': 200.0, 'disc': 50.0, 'paid': 650.0, 'method': 'UPI', 'daysAgo': 26},
      {'pIdx': 3, 'vKey': 'new_3', 'cId': clinic2Id, 'fee': 500.0, 'med': 250.0, 'disc': 0.0, 'paid': 500.0, 'method': 'Cash', 'daysAgo': 24}, // 250 pending due
      {'pIdx': 4, 'vKey': 'new_4', 'cId': clinic1Id, 'fee': 300.0, 'med': 300.0, 'disc': 0.0, 'paid': 600.0, 'method': 'Card', 'daysAgo': 22},
      {'pIdx': 5, 'vKey': 'new_5', 'cId': clinic3Id, 'fee': 400.0, 'med': 200.0, 'disc': 0.0, 'paid': 600.0, 'method': 'UPI', 'daysAgo': 20},
      {'pIdx': 6, 'vKey': 'new_6', 'cId': clinic3Id, 'fee': 400.0, 'med': 150.0, 'disc': 0.0, 'paid': 550.0, 'method': 'Cash', 'daysAgo': 18},
      {'pIdx': 7, 'vKey': 'new_7', 'cId': clinic2Id, 'fee': 500.0, 'med': 300.0, 'disc': 0.0, 'paid': 800.0, 'method': 'UPI', 'daysAgo': 16},
      {'pIdx': 8, 'vKey': 'new_8', 'cId': clinic1Id, 'fee': 300.0, 'med': 200.0, 'disc': 0.0, 'paid': 500.0, 'method': 'UPI', 'daysAgo': 14},
      {'pIdx': 9, 'vKey': 'new_9', 'cId': clinic3Id, 'fee': 400.0, 'med': 250.0, 'disc': 50.0, 'paid': 400.0, 'method': 'Cash', 'daysAgo': 12}, // 200 pending due
      // 5 Follow-Up Memos (Repeats)
      {'pIdx': 0, 'vKey': 'followup_0', 'cId': clinic1Id, 'fee': 200.0, 'med': 200.0, 'disc': 0.0, 'paid': 400.0, 'method': 'UPI', 'daysAgo': 10},
      {'pIdx': 1, 'vKey': 'followup_1', 'cId': clinic1Id, 'fee': 200.0, 'med': 150.0, 'disc': 0.0, 'paid': 350.0, 'method': 'Cash', 'daysAgo': 8},
      {'pIdx': 3, 'vKey': 'followup_2', 'cId': clinic2Id, 'fee': 300.0, 'med': 200.0, 'disc': 0.0, 'paid': 500.0, 'method': 'UPI', 'daysAgo': 6},
      {'pIdx': 5, 'vKey': 'followup_3', 'cId': clinic3Id, 'fee': 250.0, 'med': 200.0, 'disc': 0.0, 'paid': 450.0, 'method': 'Cash', 'daysAgo': 4},
      {'pIdx': 6, 'vKey': 'followup_4', 'cId': clinic3Id, 'fee': 250.0, 'med': 150.0, 'disc': 0.0, 'paid': 400.0, 'method': 'UPI', 'daysAgo': 2},
    ];

    for (int m = 0; m < memoConfigs.length; m++) {
      final cfg = memoConfigs[m];
      final pIdx = cfg['pIdx'] as int;
      final vKey = cfg['vKey'] as String;
      final cId = cfg['cId'] as String;
      final fee = cfg['fee'] as double;
      final med = cfg['med'] as double;
      final disc = cfg['disc'] as double;
      final total = (fee + med) - disc;
      final paid = cfg['paid'] as double;
      final method = cfg['method'] as String;
      final daysAgo = cfg['daysAgo'] as int;
      final memoNum = 'CM-2026-${(m + 1).toString().padLeft(5, '0')}';

      await db.into(db.cashMemos).insertOnConflictUpdate(
            CashMemosCompanion.insert(
              id: IdGenerator.generate(),
              memoNumber: memoNum,
              patientId: patientsData[pIdx]['id'] as String,
              clinicId: Value(cId),
              visitId: Value(visits[vKey]),
              consultationFee: Value(fee),
              medicineFee: Value(med),
              discount: Value(disc),
              total: total,
              paidAmount: Value(paid),
              paymentMethod: method,
              createdAt: Value(now.subtract(Duration(days: daysAgo))),
            ),
          );
    }

    // 6. 20 Footfalls (10 Converted to Patients + 10 Walk-in Inquiries)
    final footfallData = [
      // 10 Converted
      {'name': 'Tariq Mahmood', 'phone': '9830112233', 'cId': clinic1Id, 'pId': patientsData[0]['id'] as String, 'disease': 'Joint Pain', 'daysAgo': 32},
      {'name': 'Nusrat Jahan', 'phone': '9830223344', 'cId': clinic1Id, 'pId': patientsData[1]['id'] as String, 'disease': 'Migraine', 'daysAgo': 30},
      {'name': 'Ayaan Ali', 'phone': '9830334455', 'cId': clinic2Id, 'pId': patientsData[2]['id'] as String, 'disease': 'Allergic Rhinitis', 'daysAgo': 28},
      {'name': 'Farhana Begum', 'phone': '9830445566', 'cId': clinic2Id, 'pId': patientsData[3]['id'] as String, 'disease': 'PCOD', 'daysAgo': 26},
      {'name': 'Rashid Khan', 'phone': '9830556677', 'cId': clinic1Id, 'pId': patientsData[4]['id'] as String, 'disease': 'Hypertension', 'daysAgo': 24},
      {'name': 'Sana Fatima', 'phone': '9830667788', 'cId': clinic3Id, 'pId': patientsData[5]['id'] as String, 'disease': 'Eczema', 'daysAgo': 22},
      {'name': 'Imran Shaikh', 'phone': '9830778899', 'cId': clinic3Id, 'pId': patientsData[6]['id'] as String, 'disease': 'Gastritis', 'daysAgo': 20},
      {'name': 'Yasmin Akhtar', 'phone': '9830889900', 'cId': clinic2Id, 'pId': patientsData[7]['id'] as String, 'disease': 'Hypothyroidism', 'daysAgo': 18},
      {'name': 'Zubair Ahmed', 'phone': '9830990011', 'cId': clinic1Id, 'pId': patientsData[8]['id'] as String, 'disease': 'Acne & Hair Fall', 'daysAgo': 16},
      {'name': 'Meherun Nisa', 'phone': '9831001122', 'cId': clinic3Id, 'pId': patientsData[9]['id'] as String, 'disease': 'Bronchial Asthma', 'daysAgo': 15},
      // 10 Inquiries / Walk-ins
      {'name': 'Shahid Iqbal', 'phone': '9831112233', 'cId': clinic1Id, 'pId': null, 'disease': 'Sciatica & Backache', 'daysAgo': 14},
      {'name': 'Rehana Parveen', 'phone': '9831223344', 'cId': clinic1Id, 'pId': null, 'disease': 'Cervical Spondylosis', 'daysAgo': 13},
      {'name': 'Tanveer Alam', 'phone': '9831334455', 'cId': clinic2Id, 'pId': null, 'disease': 'Kidney Stone & Burning Urination', 'daysAgo': 11},
      {'name': 'Shabnam Bano', 'phone': '9831445566', 'cId': clinic2Id, 'pId': null, 'disease': 'Thyroid & Hair Thinning', 'daysAgo': 10},
      {'name': 'Arif Hossain', 'phone': '9831556677', 'cId': clinic1Id, 'pId': null, 'disease': 'Chronic Sinusitis & Headache', 'daysAgo': 9},
      {'name': 'Nilofar Yasmin', 'phone': '9831667788', 'cId': clinic3Id, 'pId': null, 'disease': 'Urticaria & Skin Itching', 'daysAgo': 7},
      {'name': 'Mohammad Danish', 'phone': '9831778899', 'cId': clinic3Id, 'pId': null, 'disease': 'Fatty Liver & Indigestion', 'daysAgo': 6},
      {'name': 'Sultana Begum', 'phone': '9831889900', 'cId': clinic2Id, 'pId': null, 'disease': 'Rheumatoid Arthritis', 'daysAgo': 4},
      {'name': 'Wasim Akram', 'phone': '9831990011', 'cId': clinic1Id, 'pId': null, 'disease': 'Piles & Fissure Discomfort', 'daysAgo': 3},
      {'name': 'Zeenat Aman', 'phone': '9832001122', 'cId': clinic3Id, 'pId': null, 'disease': 'Anxiety & Palpitations', 'daysAgo': 1},
    ];

    for (final f in footfallData) {
      await db.into(db.footfalls).insertOnConflictUpdate(
            FootfallsCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: f['cId'] as String,
              name: f['name'] as String,
              phone: Value(f['phone'] as String?),
              disease: Value(f['disease'] as String?),
              convertedPatientId: Value(f['pId'] as String?),
              notes: Value(f['pId'] != null ? 'Registered as patient with full case taking' : 'Enquiry for homoeopathic consultation'),
              date: Value(now.subtract(Duration(days: f['daysAgo'] as int))),
              createdAt: Value(now.subtract(Duration(days: f['daysAgo'] as int))),
            ),
          );
    }

    // 7. 20 Expenses Across ALL Categories
    final expensesList = [
      {'cId': clinic1Id, 'cat': 'Medicine', 'sub': 'Stock Purchase', 'amt': 4800.0, 'method': 'UPI', 'rec': false, 'notes': 'Homeopathic Dilutions (SBL/Schwabe) 30C & 200C batch', 'daysAgo': 28},
      {'cId': clinic2Id, 'cat': 'Medicine', 'sub': 'Biochemics Order', 'amt': 3500.0, 'method': 'UPI', 'rec': false, 'notes': 'Biochemic 12 Tissue Salts 6X & Mother Tinctures Q', 'daysAgo': 25},
      {'cId': clinic3Id, 'cat': 'Medicine', 'sub': 'Dispensary Supplies', 'amt': 2200.0, 'method': 'Cash', 'rec': false, 'notes': 'Pharmaceutical sugar globules #40 & dropper vials', 'daysAgo': 20},
      {'cId': clinic1Id, 'cat': 'Packaging', 'sub': 'Envelopes & Labels', 'amt': 1200.0, 'method': 'Cash', 'rec': false, 'notes': 'Custom printed clinic medicine paper envelopes & labels', 'daysAgo': 22},
      {'cId': clinic2Id, 'cat': 'Packaging', 'sub': 'Boxes & Pouches', 'amt': 1600.0, 'method': 'UPI', 'rec': false, 'notes': 'Corrugated courier packing boxes & ziplock pouches', 'daysAgo': 17},
      {'cId': clinic1Id, 'cat': 'Staff Salary', 'sub': 'Assistant Salary', 'amt': 6000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'Monthly salary for clinic assistant / receptionist', 'daysAgo': 27},
      {'cId': clinic2Id, 'cat': 'Staff Salary', 'sub': 'Dispensary Helper', 'amt': 7000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'Monthly dispensary assistant salary', 'daysAgo': 27},
      {'cId': clinic3Id, 'cat': 'Staff Salary', 'sub': 'Part-time Assistant', 'amt': 4500.0, 'method': 'Cash', 'rec': true, 'notes': 'Part-time compounder wages', 'daysAgo': 27},
      {'cId': clinic1Id, 'cat': 'Rent', 'sub': 'Monthly Rent', 'amt': 5000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'City Care Clinic commercial space rent', 'daysAgo': 29},
      {'cId': clinic2Id, 'cat': 'Rent', 'sub': 'Monthly Rent', 'amt': 8000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'Apex Health Center 2nd floor rent', 'daysAgo': 29},
      {'cId': clinic3Id, 'cat': 'Rent', 'sub': 'Monthly Rent', 'amt': 6000.0, 'method': 'Bank Transfer', 'rec': true, 'notes': 'Healing Touch Lake Road clinic space rent', 'daysAgo': 29},
      {'cId': clinic1Id, 'cat': 'Camp', 'sub': 'Community Health Camp', 'amt': 2800.0, 'method': 'UPI', 'rec': false, 'notes': 'Free Arthritis & Joint Health Camp banner, tent & logistics', 'daysAgo': 14},
      {'cId': clinic3Id, 'cat': 'Camp', 'sub': 'School Allergy Camp', 'amt': 1900.0, 'method': 'Cash', 'rec': false, 'notes': 'School Children Immunity & Allergy Awareness Camp kits', 'daysAgo': 8},
      {'cId': clinic1Id, 'cat': 'Marketing', 'sub': 'Local Pamphlets', 'amt': 1500.0, 'method': 'UPI', 'rec': false, 'notes': 'Clinic health awareness leaflets distribution in Park Street area', 'daysAgo': 21},
      {'cId': clinic2Id, 'cat': 'Marketing', 'sub': 'Online Promotion', 'amt': 2000.0, 'method': 'Card', 'rec': false, 'notes': 'Google Business Profile & Social Media practice promotion', 'daysAgo': 15},
      {'cId': clinic1Id, 'cat': 'Equipment', 'sub': 'Diagnostic Tools', 'amt': 3200.0, 'method': 'Card', 'rec': false, 'notes': 'Digital Blood Pressure Monitor & Pulse Oximeter', 'daysAgo': 23},
      {'cId': clinic2Id, 'cat': 'Equipment', 'sub': 'Clinical Examination', 'amt': 1800.0, 'method': 'UPI', 'rec': false, 'notes': 'Littmann-style stethoscope & diagnostic ENT pen torch', 'daysAgo': 19},
      {'cId': clinic1Id, 'cat': 'Utilities', 'sub': 'Electricity & Water', 'amt': 2400.0, 'method': 'UPI', 'rec': true, 'notes': 'Monthly electricity bill & water supply charges', 'daysAgo': 26},
      {'cId': clinic2Id, 'cat': 'Maintenance', 'sub': 'AC & Clinic Care', 'amt': 1500.0, 'method': 'Cash', 'rec': false, 'notes': 'Air conditioner deep servicing and clinic sanitization', 'daysAgo': 12},
      {'cId': clinic3Id, 'cat': 'Miscellaneous', 'sub': 'Broadband & Refreshments', 'amt': 1100.0, 'method': 'UPI', 'rec': true, 'notes': 'High-speed Wi-Fi broadband & doctor/patient refreshments', 'daysAgo': 10},
    ];

    for (final exp in expensesList) {
      await db.into(db.expenses).insertOnConflictUpdate(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: exp['cId'] as String,
              category: exp['cat'] as String,
              subcategory: Value(exp['sub'] as String?),
              amount: exp['amt'] as double,
              paymentMethod: Value(exp['method'] as String),
              isRecurring: Value(exp['rec'] as bool),
              notes: Value(exp['notes'] as String?),
              date: now.subtract(Duration(days: exp['daysAgo'] as int)),
              createdAt: Value(now.subtract(Duration(days: exp['daysAgo'] as int))),
            ),
          );
    }
  }
}
