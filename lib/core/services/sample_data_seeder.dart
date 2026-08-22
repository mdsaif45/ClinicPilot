import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../features/clinical/models/case_record_models.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';

class SampleDataSeeder {
  static Future<void> seedRealisticData(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    const uuid = Uuid();

    // 1. Settings & Onboarding
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: kDoctorNameKey,
            value: 'Dr. Md. Saifuddin',
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
            value: '50000',
            updatedAt: Value(DateTime.now()),
          ),
        );
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_new_patient_goal',
            value: '15',
            updatedAt: Value(DateTime.now()),
          ),
        );

    try {
      if (Hive.isBoxOpen('settings')) {
        Hive.box('settings').put(kOnboardingDoneKey, true);
        Hive.box('settings').put(kDoctorNameKey, 'Dr. Md. Saifuddin');
      }
    } catch (_) {}

    // 2. Clinics
    const clinic1Id = 'clinic_main';
    const clinic2Id = 'clinic_branch';

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic1Id,
            name: 'City Care Homeopathy',
            address: const Value('Main Market, City Center'),
            defaultConsultationFee: const Value(300.0),
            monthlyRent: const Value(5000.0),
            openDays: const Value('1,2,3,4,5,6'),
          ),
        );

    await db.into(db.clinics).insertOnConflictUpdate(
          ClinicsCompanion.insert(
            id: clinic2Id,
            name: 'Metro Health Clinic',
            address: const Value('Park Street, Metro Hub'),
            defaultConsultationFee: const Value(400.0),
            monthlyRent: const Value(8000.0),
            openDays: const Value('2,4,6'),
          ),
        );

    // 3. Patients
    final now = DateTime.now();

    // Patient 1: Md. Saifuddin
    const p1Id = 'patient_001';
    await db.into(db.patients).insertOnConflictUpdate(
          PatientsCompanion.insert(
            id: p1Id,
            patientCode: const Value('P-2026-00001'),
            serialNo: const Value('001'),
            name: 'Md. Saifuddin',
            phone: '9876543210',
            age: 60,
            gender: 'Male',
            primaryClinicId: const Value(clinic1Id),
            primaryDisease: const Value('Joint Pain / Osteoarthritis'),
            area: const Value('Central Park'),
            address: const Value('12/A Baker Street'),
            occupation: const Value('Tailor'),
            createdAt: Value(now.subtract(const Duration(days: 45))),
          ),
        );

    // Patient 2: Zahida Parveen
    const p2Id = 'patient_002';
    await db.into(db.patients).insertOnConflictUpdate(
          PatientsCompanion.insert(
            id: p2Id,
            patientCode: const Value('P-2026-00002'),
            serialNo: const Value('002'),
            name: 'Zahida Parveen',
            phone: '9876543211',
            age: 42,
            gender: 'Female',
            primaryClinicId: const Value(clinic1Id),
            primaryDisease: const Value('Migraine / Chronic Headache'),
            area: const Value('Green View'),
            occupation: const Value('Homemaker'),
            createdAt: Value(now.subtract(const Duration(days: 20))),
          ),
        );

    // Patient 3: Habibul Rahman
    const p3Id = 'patient_003';
    await db.into(db.patients).insertOnConflictUpdate(
          PatientsCompanion.insert(
            id: p3Id,
            patientCode: const Value('P-2026-00003'),
            serialNo: const Value('003'),
            name: 'Habibul Rahman',
            phone: '9876543212',
            age: 28,
            gender: 'Male',
            primaryClinicId: const Value(clinic2Id),
            primaryDisease: const Value('Allergic Rhinitis / Sneezing'),
            area: const Value('Metro Complex'),
            occupation: const Value('Software Engineer'),
            createdAt: Value(now.subtract(const Duration(days: 5))),
          ),
        );

    // 4. Visits
    const v1Id = 'visit_001';
    await db.into(db.visits).insertOnConflictUpdate(
          VisitsCompanion.insert(
            id: v1Id,
            patientId: p1Id,
            clinicId: clinic1Id,
            visitType: 'new',
            disease: 'Joint Pain / Osteoarthritis',
            chiefComplaint: const Value('Hip & Knee Joint Pain'),
            visitDate: now.subtract(const Duration(days: 14)),
            nextFollowUpDate: Value(now.add(const Duration(days: 7))),
          ),
        );

    const v2Id = 'visit_002';
    await db.into(db.visits).insertOnConflictUpdate(
          VisitsCompanion.insert(
            id: v2Id,
            patientId: p2Id,
            clinicId: clinic1Id,
            visitType: 'new',
            disease: 'Migraine / Chronic Headache',
            chiefComplaint: const Value('Chronic Migraine & Acidity'),
            visitDate: now.subtract(const Duration(days: 10)),
            nextFollowUpDate: Value(now.add(const Duration(days: 5))),
          ),
        );

    // 5. Cash Memos (Full & Partial Payments)
    await db.into(db.cashMemos).insertOnConflictUpdate(
          CashMemosCompanion.insert(
            id: 'memo_001',
            memoNumber: 'CM-2026-00001',
            patientId: p1Id,
            clinicId: const Value(clinic1Id),
            visitId: const Value(v1Id),
            consultationFee: const Value(300.0),
            medicineFee: const Value(200.0),
            otherFee: const Value(0.0),
            discount: const Value(0.0),
            total: 500.0,
            paidAmount: const Value(300.0), // Rs 200 Partial due
            paymentMethod: 'Cash',
            createdAt: Value(now.subtract(const Duration(days: 14))),
          ),
        );

    await db.into(db.cashMemos).insertOnConflictUpdate(
          CashMemosCompanion.insert(
            id: 'memo_002',
            memoNumber: 'CM-2026-00002',
            patientId: p2Id,
            clinicId: const Value(clinic1Id),
            visitId: const Value(v2Id),
            consultationFee: const Value(300.0),
            medicineFee: const Value(100.0),
            discount: const Value(0.0),
            total: 400.0,
            paidAmount: const Value(400.0), // Full payment
            paymentMethod: 'UPI',
            createdAt: Value(now.subtract(const Duration(days: 10))),
          ),
        );

    await db.into(db.cashMemos).insertOnConflictUpdate(
          CashMemosCompanion.insert(
            id: 'memo_003',
            memoNumber: 'CM-2026-00003',
            patientId: p3Id,
            clinicId: const Value(clinic2Id),
            consultationFee: const Value(400.0),
            medicineFee: const Value(150.0),
            discount: const Value(50.0),
            total: 500.0,
            paidAmount: const Value(500.0),
            paymentMethod: 'UPI',
            createdAt: Value(now.subtract(const Duration(days: 2))),
          ),
        );

    // 6. Expenses across categories
    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: uuid.v4(),
            clinicId: clinic1Id,
            category: 'Medicine Purchase',
            amount: 4500.0,
            paymentMethod: const Value('UPI'),
            date: now.subtract(const Duration(days: 12)),
            notes: const Value('Batch 2026/05 Homeopathic Dilutions'),
          ),
        );

    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: uuid.v4(),
            clinicId: clinic1Id,
            category: 'Packaging & Dispensing',
            amount: 850.0,
            paymentMethod: const Value('Cash'),
            date: now.subtract(const Duration(days: 8)),
            notes: const Value('Glass phials & sugar globules'),
          ),
        );

    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: uuid.v4(),
            clinicId: clinic1Id,
            category: 'Staff Salary',
            amount: 6000.0,
            paymentMethod: const Value('Bank Transfer'),
            date: now.subtract(const Duration(days: 5)),
            isRecurring: const Value(true),
          ),
        );

    await db.into(db.expenses).insertOnConflictUpdate(
          ExpensesCompanion.insert(
            id: uuid.v4(),
            clinicId: clinic1Id,
            category: 'Electricity',
            amount: 1250.0,
            paymentMethod: const Value('UPI'),
            date: now.subtract(const Duration(days: 3)),
          ),
        );

    // 7. Master Case Taking (16 Sections) for Patient 1
    final masterRecord = MasterCaseRecordData(
      id: uuid.v4(),
      patientId: p1Id,
      recordDate: now.subtract(const Duration(days: 14)),
      identification: const PatientIdentificationDetails(
        regNo: '001',
        firstVisitDate: '11 July 2024',
        patientName: 'Md. Saifuddin',
        age: '60',
        gender: 'Male',
        occupation: 'Tailor',
        address: '12/A Baker Street, Central Park',
        phone: '9876543210',
        maritalStatus: 'Married',
      ),
      chiefComplaints: const [
        ChiefComplaintDetail(
          complaint: 'Right Hip & Knee Joint Pain with stiffness',
          location: 'Right Hip extending down to Knee',
          sensation: 'Drawing, tearing and stiffness',
          modalitiesAgg: '< walking, standing, cold damp morning air',
          modalitiesAmel: '> continuous motion, warm application, rest',
          concomitants: 'Flatulence and fullness after eating',
          duration: '2 Years',
          causation: 'Worse winter season',
          severity: 'Severe',
        ),
      ],
      hpi: const HpiDetails(
        progression: 'Pain began gradually 2 years ago. Worsens during winter and damp weather. Known Type 2 Diabetes for 6 years.',
        firstOccurrence: '2 years ago',
        previousTreatments: 'Thuja, Arsenicum, Kalmia without adequate relief',
        precipitatingFactors: 'Sedentary occupation as tailor, irregular meals',
      ),
      pastHistory: const PastHistoryDetails(
        childhoodIllnesses: 'Measles in childhood',
        chronicDiseases: 'Type 2 Diabetes Mellitus (6 years)',
        surgeries: 'Surgically drained ischiorectal abscess 5 years ago',
        injuriesTrauma: 'No major skeletal fractures',
        allergies: 'None reported',
        previousTreatments: 'Homeopathic and allopathic medications',
      ),
      familyHistory: const FamilyHistoryDetails(
        father: 'Type 2 Diabetes & Hypertension',
        mother: 'Osteoarthritis',
        siblingsChildren: '2 sons, 1 daughter healthy',
        hereditaryDiseases: 'Diabetes Mellitus, Joint disorders',
        psychiatricHistory: 'No familial psychiatric disorders',
      ),
      developmentalHistory: const DevelopmentalHistoryDetails(
        maternalHealth: 'Normal pregnancy and gestation',
        deliveryComplications: 'Normal full-term delivery at home',
        milestonesDentition: 'Normal developmental milestones',
        vaccinationNeonatal: 'Childhood vaccinations completed',
      ),
      physicalGenerals: const PhysicalGenerals(
        thermal: 'Hot',
        weatherPreference: 'Dislikes cold damp weather, prefers dry winter',
        thirst: 'Thirsty for large quantities of normal water',
        appetite: 'Good, irritable if meals are delayed',
        cravings: 'Sweets, warm tea, fresh fish, sour fruits, rice',
        aversions: 'Boiled milk, fatty greasy mutton',
        intolerances: 'Cabbage and onions cause bloating',
        stool: 'Regular but sluggish, tight stool, prone to hemorrhoids',
        urine: 'Normal color, increased nocturnal frequency',
        perspiration: 'Profuse and offensive, especially on forehead',
        sleep: 'Restless due to flatulence and joint ache',
        dreams: 'Dreams of falling, daily tailoring work routines',
        energyFatigue: 'Fatigued in late afternoon',
        skinHairNails: 'Warts on forehead and right tongue margin',
      ),
      mentalGenerals: const MentalGenerals(
        disposition: 'Industrious, punctual, anxious about health recovery',
        irritabilityAnger: 'Quick tempered with gastric discomfort, but cools down rapidly',
        anxietyFears: 'Fear of incurable disease and financial security',
        sadnessGrief: 'Broods over physical ailments',
        companySolitude: 'Prefers quiet solitude when in pain',
        consolationReaction: 'Aggravated by unwanted consolation',
        memoryConcentration: 'Good memory, sharp focus',
        stressResponse: 'Manifests in gastrointestinal bloating and headache',
      ),
      lifestyleHabits: const LifestyleHistoryDetails(
        dietaryHabits: 'Non-veg (fish/rice preferred), irregular meal timings',
        habitsAddictions: 'Non-smoker, drinks 3 cups of tea daily',
        physicalActivity: 'Sedentary work at tailoring table for 8-10 hours',
        occupationalHazards: 'Prolonged sitting posture',
        socialStressors: 'Workload and health worries',
      ),
      clinicalExam: const ClinicalExamVitals(
        generalAppearance: 'Well-built, sitting posture with hip discomfort',
        pallorIcterus: 'No pallor, no icterus, no clubbing, no oedema',
        bp: '130/85 mmHg',
        pulse: '76 bpm',
        respiratoryRate: '18 /min',
        temperature: '98.4 F',
        spo2: '98%',
        weightKg: '72',
        heightCm: '168',
        bmi: '25.5',
        tongueExam: 'Flat wart-like growth on right margin of tongue',
        systemicFindings: 'Right hip joint tenderness on extension. Crepitus in right knee.',
      ),
      miasmaticAnalysis: const MiasmaticAnalysis(
        psoricFeatures: 'Functional dyspepsia, intense itching at times',
        sycoticFeatures: 'Warts on forehead & tongue margin, joint stiffness < cold damp weather',
        syphiliticFeatures: 'Past history of ischiorectal abscess',
        tubercularFeatures: 'None prominent',
        cancerinicFeatures: 'None prominent',
        characteristicSymptoms: 'Overgrowths, sycotic joint stiffness, gastric flatulence',
        dominantMiasm: 'Sycosis',
      ),
      caseTotality: const CaseTotality(
        characteristicSymptoms: 'Right-sided joint stiffness, warts on skin/tongue, hot patient, profuse offensive sweat',
        rubricsSelected: 'Extremities; pain; hip; right • Generals; thermal; hot • Skin; warts; pedunculated',
        repertorialResult: 'Thuja (18/7), Rhus Tox (14/5), Lycopodium (13/5)',
        differentialRemedies: 'Rhus Tox, Lycopodium, Medorrhinum',
        selectedRemedy: 'Thuja Occidentalis',
        potency: '200C',
        justification: 'Matches sycotic miasm, prominent warts, right-sided joint involvement, and thermal modality.',
      ),
      baselinePrescription: const PrescriptionPlanDetails(
        remedyName: 'Thuja Occidentalis',
        potency: '200C',
        dosageForm: 'Globules No. 30',
        doseCount: '4 pills',
        frequency: 'OD',
        duration: '3 Days',
        instructions: 'Morning on clean empty tongue for 3 consecutive days',
        dietaryAdvice: 'Avoid raw onion, raw garlic, strong spices and cold refrigerated water',
        referralAdvice: 'Advised strict glycemic monitoring and dietary control',
      ),
      investigations: const InvestigationsPlanDetails(
        testsAdvised: 'FBS, PPBS, HbA1c, Serum Uric Acid, X-Ray Right Hip & Knee',
        resultsInterpretation: 'FBS: 160 mg/dL (High), HbA1c: 7.8% (High) - Type 2 Diabetes uncontrolled',
      ),
      followUpNotes: 'Advised follow-up in 14 days. Limit dietary sugar and avoid cold refrigerated drinks.',
      outcome: 'Under Active Treatment',
    );

    await db.into(db.patientCaseRecords).insertOnConflictUpdate(
          PatientCaseRecordsCompanion.insert(
            id: masterRecord.id!,
            patientId: p1Id,
            recordDate: Value(masterRecord.recordDate),
            chiefComplaintsJson: Value(masterRecord.chiefComplaintsJson),
            hpi: Value(masterRecord.hpiJson),
            pastHistoryJson: Value(masterRecord.pastHistoryJson),
            familyHistoryJson: Value(masterRecord.familyHistoryJson),
            developmentalHistoryJson: Value(masterRecord.developmentalHistoryJson),
            physicalGeneralsJson: Value(masterRecord.physicalGeneralsJson),
            mentalGeneralsJson: Value(masterRecord.mentalGeneralsJson),
            lifestyleJson: Value(masterRecord.lifestyleJson),
            clinicalExamJson: Value(masterRecord.clinicalExamJson),
            miasmaticAnalysisJson: Value(masterRecord.miasmaticAnalysisJson),
            caseTotalityJson: Value(masterRecord.caseTotalityJson),
            baselinePrescriptionJson: Value(masterRecord.baselinePrescriptionJson),
            investigationsJson: Value(masterRecord.investigationsJson),
            followUpNotes: Value(masterRecord.followUpNotes),
            outcome: Value(masterRecord.outcome),
          ),
        );

    // 8. Relational Complaints
    await db.into(db.complaints).insertOnConflictUpdate(
          ComplaintsCompanion.insert(
            id: uuid.v4(),
            patientId: p1Id,
            visitId: const Value(v1Id),
            complaintIndex: const Value(1),
            complaintName: 'Right Hip & Knee Joint Pain',
            location: const Value('Right Hip and Knee'),
            side: const Value('Right'),
            onset: const Value('Gradual'),
            duration: const Value('2 Years'),
            sensation: const Value('Drawing, tearing pain with morning stiffness'),
            aggravatingFactors: const Value('< cold air, early morning, first movement'),
            amelioratingFactors: const Value('> continued gentle motion, warmth'),
            severity: const Value(8),
            status: const Value('Active'),
          ),
        );

    // 9. Relational Prescriptions
    await db.into(db.prescriptions).insertOnConflictUpdate(
          PrescriptionsCompanion.insert(
            id: uuid.v4(),
            patientId: p1Id,
            visitId: const Value(v1Id),
            remedyIndex: const Value(1),
            remedyName: 'Thuja Occidentalis',
            potency: '200C',
            vehicle: const Value('Globules No. 30'),
            doseCount: const Value('4 pills'),
            frequency: const Value('OD (Once Daily)'),
            durationDays: const Value('3 Days'),
            instructions: const Value('Morning on clean empty tongue'),
            dietaryAdvice: const Value('Avoid raw garlic, raw onion, and strong perfumes'),
          ),
        );

    await db.into(db.prescriptions).insertOnConflictUpdate(
          PrescriptionsCompanion.insert(
            id: uuid.v4(),
            patientId: p1Id,
            visitId: const Value(v1Id),
            remedyIndex: const Value(2),
            remedyName: 'Nux Vomica',
            potency: '30C',
            vehicle: const Value('Globules No. 30'),
            doseCount: const Value('4 pills'),
            frequency: const Value('HS (At Bedtime)'),
            durationDays: const Value('7 Days'),
            instructions: const Value('Night before sleep for dyspepsia'),
          ),
        );

    // 10. Lab Investigations (Auto-flagged)
    await db.into(db.investigations).insertOnConflictUpdate(
          InvestigationsCompanion.insert(
            id: uuid.v4(),
            patientId: p1Id,
            testCategory: const Value('Diabetes / Glycemia'),
            testName: 'Fasting Blood Sugar (FBS)',
            numericValue: const Value(160.0),
            unit: const Value('mg/dL'),
            refRangeMin: const Value(70.0),
            refRangeMax: const Value(100.0),
            flag: const Value('High'),
            labName: const Value('City Diagnostic Center'),
            testDate: Value(now.subtract(const Duration(days: 13))),
          ),
        );

    await db.into(db.investigations).insertOnConflictUpdate(
          InvestigationsCompanion.insert(
            id: uuid.v4(),
            patientId: p1Id,
            testCategory: const Value('Diabetes / Glycemia'),
            testName: 'HbA1c (Glycated Hemoglobin)',
            numericValue: const Value(7.8),
            unit: const Value('%'),
            refRangeMin: const Value(4.0),
            refRangeMax: const Value(5.6),
            flag: const Value('High'),
            labName: const Value('City Diagnostic Center'),
            testDate: Value(now.subtract(const Duration(days: 13))),
          ),
        );

    // 11. Referral Contacts CRM
    await db.into(db.referralContacts).insertOnConflictUpdate(
          ReferralContactsCompanion.insert(
            id: uuid.v4(),
            name: 'City Diagnostic Center',
            category: const Value('Diagnostic Lab'),
            contactPerson: const Value('Dr. R. K. Pathak'),
            phone: const Value('9830012345'),
            address: const Value('City Center Main Road'),
            lastVisitedDate: Value(now.subtract(const Duration(days: 6))),
            visitCount: const Value(4),
            referralCount: const Value(6),
            notes: const Value('Specializes in diabetic panels and lipid profiles'),
          ),
        );

    await db.into(db.referralContacts).insertOnConflictUpdate(
          ReferralContactsCompanion.insert(
            id: uuid.v4(),
            name: 'Care Pharmacy & Surgical',
            category: const Value('Pharmacy'),
            contactPerson: const Value('Sunil Kumar'),
            phone: const Value('9830054321'),
            address: const Value('Opposite District Hospital'),
            lastVisitedDate: Value(now.subtract(const Duration(days: 3))),
            visitCount: const Value(2),
            referralCount: const Value(8),
            notes: const Value('Stocks homeopathic dispensing supplies and remedies'),
          ),
        );
  }
}