import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/providers/security_provider.dart';
import 'package:clinic_pilot/core/services/security_service.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/new_cash_memo_dialog.dart';
import 'package:clinic_pilot/features/clinical/models/case_record_models.dart';
import 'package:clinic_pilot/features/clinical/models/investigation_templates.dart';
import 'package:clinic_pilot/features/clinical/providers/case_record_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/complaint_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/investigation_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/prescription_provider.dart';
import 'package:clinic_pilot/features/growth/providers/referral_crm_provider.dart';
import 'package:clinic_pilot/features/patients/presentation/add_patient_dialog.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTestSecurityService extends SecurityService {
  final Map<String, String> _mem = {};

  @override
  Future<bool> isAppLockEnabled() async => _mem['clinicpilot_lock_enabled'] == 'true';
  @override
  Future<bool> isBiometricsEnabled() async => _mem['clinicpilot_biometrics_enabled'] == 'true';
  @override
  Future<int> getAutoLockMinutes() async => int.tryParse(_mem['clinicpilot_auto_lock_minutes'] ?? '5') ?? 5;
  @override
  Future<void> setPin(String pin, {bool enableBiometrics = false, int autoLockMinutes = 5}) async {
    _mem['clinicpilot_pin_hash'] = 'hash_$pin';
    _mem['clinicpilot_pin_salt'] = 'salt_123';
    _mem['clinicpilot_lock_enabled'] = 'true';
    _mem['clinicpilot_biometrics_enabled'] = enableBiometrics ? 'true' : 'false';
    _mem['clinicpilot_auto_lock_minutes'] = autoLockMinutes.toString();
  }
  @override
  Future<bool> verifyPin(String pin) async => _mem['clinicpilot_pin_hash'] == 'hash_$pin';
  @override
  Future<void> disableAppLock() async => _mem.clear();
  @override
  Future<bool> isBiometricsSupported() async => true;
  @override
  Future<bool> authenticateWithBiometrics({String reason = 'Unlock ClinicPilot'}) async => true;
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Real-World Practice End-to-End Regression Tests', () {
    testWidgets('Practice Setup -> Patient Registration with Single Clinic Auto-select', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Seed 1 Clinic
      await db.into(db.clinics).insert(
        ClinicsCompanion.insert(
          id: 'clinic_main_01',
          name: 'City Care Homeopathy',
          address: const drift.Value('Main Market, City Center'),
          defaultConsultationFee: const drift.Value(300.0),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: AddPatientDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Clinic is automatically preselected to the single existing clinic
      expect(find.text('City Care Homeopathy'), findsOneWidget);

      final fields = find.byType(TextFormField);
      // Serial No
      await tester.enterText(fields.at(0), '001');
      // Full Name
      await tester.enterText(fields.at(1), 'Patient One');
      // Phone Number
      await tester.enterText(fields.at(2), '9876543210');
      // Age
      await tester.enterText(fields.at(4), '60');
      // Locality
      await tester.enterText(fields.at(5), 'Central Park');
      // Disease
      await tester.enterText(fields.at(6), 'Joint Pain');

      // Submit
      await tester.tap(find.text('Register & Create Visit'));
      await tester.pumpAndSettle();

      final patients = await db.select(db.patients).get();
      expect(patients.length, equals(1));
      expect(patients.first.name, equals('Patient One'));
      expect(patients.first.serialNo, equals('001'));
      expect(patients.first.primaryClinicId, equals('clinic_main_01'));
    });

    testWidgets('Cash Memo: Full Payment vs Partial Payment with Pending Balance auto-calculation', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await db.into(db.clinics).insert(
        ClinicsCompanion.insert(
          id: 'clinic_main_01',
          name: 'City Care Homeopathy',
          defaultConsultationFee: const drift.Value(300.0),
        ),
      );

      final pCompanion = PatientsCompanion.insert(
        id: 'patient_01',
        name: 'Patient One',
        phone: '9876543210',
        age: 60,
        gender: 'Male',
        patientCode: const drift.Value('P-2026-00001'),
        primaryClinicId: const drift.Value('clinic_main_01'),
      );
      await db.into(db.patients).insert(pCompanion);
      final patient = await (db.select(db.patients)..where((t) => t.id.equals('patient_01'))).getSingle();

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: NewCashMemoDialog(initialPatient: patient),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check auto-synced Paid Amount matches Consultation Fee 300
      expect(find.text('Total Payable:'), findsOneWidget);
      expect(find.textContaining('300'), findsWidgets);

      final fields = find.byType(TextFormField);
      // Index 1: Medicine Fee -> 200
      await tester.enterText(fields.at(1), '200');
      await tester.pumpAndSettle();

      expect(find.textContaining('500'), findsWidgets);

      // Index 4: Paid Amount -> 300
      await tester.enterText(fields.at(4), '300');
      await tester.pumpAndSettle();

      expect(find.textContaining('Note: Rs 200 will be recorded as Pending Due balance'), findsOneWidget);

      // Save Cash Memo
      await tester.tap(find.text('Save & Issue Memo'));
      await tester.pumpAndSettle();

      final memos = await db.select(db.cashMemos).get();
      expect(memos.length, equals(1));
      expect(memos.first.total, equals(500.0));
      expect(memos.first.paidAmount, equals(300.0));
      expect(memos.first.total - memos.first.paidAmount, equals(200.0));
    });

    test('Full Clinical Case Workflow: Master Record + Relational Complaints + Prescriptions + Labs + Referral CRM', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // 1. Create Patient
      await db.into(db.clinics).insert(
        ClinicsCompanion.insert(
          id: 'clinic_01',
          name: 'Homeopathy Center',
          defaultConsultationFee: const drift.Value(300.0),
        ),
      );
      await db.into(db.patients).insert(
        PatientsCompanion.insert(
          id: 'p_saif',
          name: 'Saifuddin Patient',
          phone: '9876543210',
          age: 60,
          gender: 'Male',
          patientCode: const drift.Value('P-2026-00001'),
          primaryClinicId: const drift.Value('clinic_01'),
          occupation: const drift.Value('Tailor'),
        ),
      );

      // 2. Master Case Record (16-Section)
      final caseNotifier = container.read(caseRecordNotifierProvider.notifier);
      final masterRecord = MasterCaseRecordData(
        patientId: 'p_saif',
        recordDate: DateTime.now(),
        chiefComplaints: const [
          ChiefComplaintDetail(
            complaint: 'Hip & Knee Joint Pain',
            location: 'Right Hip & Knee',
            sensation: 'Drawing, tingling pain',
            modalitiesAgg: '< walking, standing, morning cold air',
            modalitiesAmel: '> pressure, rest',
            severity: 'Severe',
          ),
        ],
        hpi: const HpiDetails(progression: 'Pain began 2 years ago, gradually worsening. Known Type 2 Diabetes.'),
        pastHistory: const PastHistoryDetails(surgeries: 'Rectal abscess surgically drained 5 years ago.'),
        familyHistory: const FamilyHistoryDetails(father: 'Father had Diabetes and Hypertension.'),
        physicalGenerals: const PhysicalGenerals(
          thermal: 'Hot',
          weatherPreference: 'Winter',
          thirst: 'Profuse thirst, drinks large quantities',
          appetite: 'Good appetite, irritable when hungry',
          cravings: 'Sweets, tea, fruits, fresh fish',
          aversions: 'Milk',
          perspiration: 'Profuse and offensive',
          sleep: 'Disturbed by flatulence',
        ),
        mentalGenerals: const MentalGenerals(
          disposition: 'Industrious, anxious about health',
          anger: 'Easily angered, irritable with gastric trouble',
          fears: 'Fear of incurable disease',
          desireForAttentionConsolation: 'Aggravated by consolation',
        ),
        clinicalExam: const ClinicalExamVitals(
          bloodPressure: '130/85',
          pulse: '76',
          weightKg: '72',
          entOralExamination: 'Flat wart-like eruption on tongue margin',
          otherExaminationFindings: 'Right hip joint tenderness on extension',
        ),
        miasmaticAnalysis: const MiasmaticAnalysis(
          psoricFeatures: 'Intense itching, functional digestive disorders',
          sycoticFeatures: 'Warts on forehead and tongue, joint stiffness < cold air',
          dominantMiasm: 'Sycotic',
        ),
        caseTotality: const CaseTotality(
          characteristicSymptoms: 'Right-sided joint stiffness, warts, hot patient, profuse sweat',
          rubricsSelected: 'Extremities; pain; hip; right • Generals; thermal; hot',
          finalRemedySelection: 'Thuja Occidentalis',
          potency: '200C',
        ),
        baselinePrescription: const PrescriptionPlanDetails(
          remedyName: 'Thuja Occidentalis',
          potency: '200C',
          pharmaceuticalForm: 'Globules',
          dose: '4 pills',
          repetitionFrequency: 'OD',
          
        ),
        outcome: 'Under Active Treatment',
      );

      await caseNotifier.saveCaseRecord(masterRecord);
      final savedCase = await container.read(patientCaseRecordProvider('p_saif').future);
      expect(savedCase, isNotNull);
      expect(savedCase!.miasmaticAnalysis.dominantMiasm, equals('Sycotic'));
      expect(savedCase.physicalGenerals.thermal, equals('Hot'));

      // 3. Multi-Complaint Log
      final complaintNotifier = container.read(complaintNotifierProvider.notifier);
      await complaintNotifier.addComplaint(
        patientId: 'p_saif',
        complaintName: 'Right Hip & Knee Pain',
        location: 'Right Hip',
        sensation: 'Drawing, stiffness',
        aggravatingFactors: '< walking, cold air',
        amelioratingFactors: '> rest, warmth',
        severity: 8,
        status: 'Active',
      );
      final complaints = await db.select(db.complaints).get();
      expect(complaints.length, equals(1));
      expect(complaints.first.severity, equals(8));

      // 4. Prescription Log (Multi-remedy)
      final rxNotifier = container.read(prescriptionNotifierProvider.notifier);
      await rxNotifier.addPrescription(
        patientId: 'p_saif',
        remedyName: 'Thuja Occidentalis',
        potency: '200C',
        vehicle: 'Globules',
        doseCount: '4 pills',
        frequency: 'OD (Once Daily)',
        durationDays: '3 days',
        dietaryAdvice: 'Avoid raw onion, garlic, camphor',
      );
      final prescriptions = await db.select(db.prescriptions).get();
      expect(prescriptions.length, equals(1));
      expect(prescriptions.first.remedyName, equals('Thuja Occidentalis'));

      // 5. Investigation Log (Auto-flagging)
      final flagFbs = computeLabFlag(160.0, 70.0, 100.0);
      expect(flagFbs, equals('High'));

      final invNotifier = container.read(investigationNotifierProvider.notifier);
      await invNotifier.addInvestigation(
        patientId: 'p_saif',
        testCategory: 'Diabetes',
        testName: 'Fasting Blood Sugar (FBS)',
        numericValue: 160.0,
        unit: 'mg/dL',
        refRangeMin: 70.0,
        refRangeMax: 100.0,
        flag: flagFbs,
        labName: 'City Diagnostic Center',
      );
      final investigations = await db.select(db.investigations).get();
      expect(investigations.length, equals(1));
      expect(investigations.first.flag, equals('High'));

      // 6. Referral Partner CRM
      final crmNotifier = container.read(referralCrmNotifierProvider.notifier);
      final partnerId = await crmNotifier.addContact(
        name: 'City Pathology & Pharmacy',
        category: 'Diagnostic Lab',
        phone: '9876500000',
        contactPerson: 'Dr. Pathak',
      );
      await crmNotifier.logOutreachVisit(partnerId);
      await crmNotifier.incrementReferralCount(partnerId);

      final partners = await db.select(db.referralContacts).get();
      expect(partners.length, equals(1));
      expect(partners.first.visitCount, equals(1));
      expect(partners.first.referralCount, equals(1));
    });

    test('Security App Lock & Inactivity auto-lock unit test', () async {
      final service = FakeTestSecurityService();
      final notifier = AppLockNotifier(service);

      // Set up PIN
      await notifier.setupPin('1234', enableBiometrics: true, autoLockMinutes: 5);
      expect(notifier.state.isEnabled, isTrue);
      expect(notifier.state.isLocked, isFalse);

      // Inactivity timeout simulation
      notifier.onAppPaused();
      notifier.state = notifier.state.copyWith(
        lastBackgroundTime: DateTime.now().subtract(const Duration(minutes: 6)),
      );
      notifier.onAppResumed();
      expect(notifier.state.isLocked, isTrue);

      // Unlock
      final unlocked = await notifier.verifyAndUnlock('1234');
      expect(unlocked, isTrue);
      expect(notifier.state.isLocked, isFalse);
    });
  });
}