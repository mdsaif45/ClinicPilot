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
    // 7. Master Case Taking (19 Sections) for Patient 1 (Md. Saifuddin)
    final masterRecord = MasterCaseRecordData(
      id: uuid.v4(),
      patientId: p1Id,
      recordDate: now.subtract(const Duration(days: 14)),
      identification: const PatientIdentificationDetails(
        regNo: '001',
        firstVisitDate: '11 July 2024',
        patientName: 'Md. Saifuddin',
        age: '60 years',
        gender: 'Male',
        occupation: 'Tailor',
        address: 'Kolkata Central Practice',
        phone: '9876543210',
        maritalStatus: 'Married',
      ),
      chiefComplaints: const [
        ChiefComplaintDetail(
          complaint: 'Pain in right hip',
          location: 'Right hip',
          onset: '[Not dictated]',
          duration: '[Not dictated]',
          sensation: 'Pain',
          extensionRadiation: '[Not dictated]',
          modalitiesAgg: 'Gastric trouble at night; previously neck symptoms worse morning/cold air and joint pain worse walking/standing.',
          modalitiesAmel: '[Not dictated]',
          concomitants: 'Tingling; dry throat with occasional cough; burning eyes; excessive flatulence; abdominal rumbling.',
          causation: '[Not dictated]',
          periodicity: '[Not dictated]',
          time: '[Not dictated]',
          severity: 'Moderate',
          associatedSymptoms: 'Right-sided hip pain',
        ),
        ChiefComplaintDetail(
          complaint: 'Pain in knee, fingers and toes',
          location: 'Knee, fingers and toes',
          sensation: 'Pain',
          modalitiesAgg: 'Walking and standing',
          associatedSymptoms: 'Pain in fingers reported at follow-up',
        ),
        ChiefComplaintDetail(
          complaint: 'Neck pain with tingling and drawing sensation',
          location: 'Neck',
          sensation: 'Tingling; drawing sensation',
          modalitiesAgg: 'Morning; cold air',
        ),
      ],
      additionalComplaints: 'Tingling sensation all over body; pain in calf muscles; dry throat sometimes followed by cough; flat, wart-like eruption on tongue (palatine tonsil was doubted as dictated); round wart on forehead.',
      hpi: const HpiDetails(
        progression: 'Longstanding musculoskeletal complaints and gastric trouble. Previously treated with Thuja 30 followed by Rhus tox 30 without improvement; Kalmia prescribed on second visit without relief; Nux Vomica prescribed on third visit.',
        previousTreatment: 'Thuja -> Rhus tox -> Kalmia -> Nux Vomica',
        responseToTreatment: 'No improvement / no relief reported after Thuja/Arsenicum and Kalmia.',
        relevantPrecipitatingFactors: 'Cold air aggravates neck symptoms. Sedentary occupation as a tailor noted.',
      ),
      pastHistory: const PastHistoryDetails(
        chronicDiseases: 'Uncontrolled Type 2 Diabetes Mellitus',
        previousHomeopathicTreatment: 'Thuja, Arsenicum, Kalmia; Nux Vomica prescribed subsequently',
        otherPastHistory: 'History of rectal abscess; frequent gastric trouble.',
      ),
      familyHistory: const FamilyHistoryDetails(),
      developmentalHistory: const DevelopmentalHistoryDetails(),
      physicalGenerals: const PhysicalGenerals(
        thermal: 'Hot',
        hotChilly: 'Hot',
        weatherPreference: 'Prefers winter',
        thirst: 'Profuse; drinks a lot',
        appetite: 'Good',
        cravings: 'Sweet; tea; fruits; fresh fish; rice',
        stool: 'History of tight/hard stool',
        perspiration: 'Profuse; offensive',
        sleep: 'Sleep disturbed due to excessive gas',
        otherPhysicalGenerals: "Burning eyes; headache associated with [unclear: 'can't tolerate']",
      ),
      mentalGenerals: const MentalGenerals(
        anger: 'Anger',
        otherCharacteristicMentalSymptoms: 'No further mental symptoms dictated.',
      ),
      lifestyleHabits: const LifestyleHistoryDetails(
        mealPattern: 'Irregular meal habit',
        physicalActivity: 'Limited / sedentary work pattern noted; advised to increase physical activity.',
        occupationWorkPattern: 'Tailor; predominantly sedentary work',
      ),
      clinicalExam: const ClinicalExamVitals(
        entOralExamination: 'Tongue: flat, wart-like eruption; palatine tonsil was suspected/doubted as dictated. Throat dry, sometimes followed by cough. Round wart on forehead.',
      ),
      miasmaticAnalysis: const MiasmaticAnalysis(
        otherMiasmaticIndicators: 'Wart-like eruptions noted; no formal miasmatic interpretation dictated.',
      ),
      caseTotality: const CaseTotality(
        characteristicSymptoms: 'Neck pain with tingling/drawing aggravated morning and cold air; gastric flatulence with rumbling and fear of gas escaping; profuse offensive sweat; wart-like eruptions.',
        finalRemedySelection: 'Nux Vomica',
        potency: '30C',
        justification: 'Prescribed on third visit after continued gastric symptoms and advice to control blood sugar/increase physical activity.',
      ),
      baselinePrescription: const PrescriptionPlanDetails(
        remedyName: 'Nux Vomica',
        potency: '30C',
        dietRegimenAdvice: 'Control blood sugar; increase physical activity.',
        lifestyleAdvice: 'Increase physical activity; control blood sugar.',
        prescriptionNotes: 'Patient reported no improvement/no relief after earlier prescriptions.',
      ),
      investigations: const InvestigationsPlanDetails(),
      followUpNotes: 'Patient continued to report gastric trouble, excessive flatulence and abdominal rumbling; fear as if gas would escape from anus.',
      outcome: 'Under Active Treatment',
      documentation: const DocumentationDetails(
        dataSource: 'Original handwritten clinic register / dictated case record',
        originalRegisterReference: 'Registration No. 001',
        transcriptionNotes: 'Information arranged from dictated historical case data. Missing or unclear items are explicitly marked.',
        unclearInformation: "'Ambulation was on pressure' and 'blood vision' were unclear in dictation; not interpreted. 'Palatine tonsil' was recorded as dictated.",
      ),
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