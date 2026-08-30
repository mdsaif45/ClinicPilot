import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinical/models/case_record_models.dart';
import 'package:clinic_pilot/features/clinical/presentation/master_case_taking_screen.dart';
import 'package:clinic_pilot/features/clinical/providers/case_record_provider.dart';
import 'package:clinic_pilot/features/patients/presentation/patient_profile_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MasterCaseRecordData & Clinical Models Unit Tests', () {
    test('serializes and deserializes ChiefComplaintDetail properly', () {
      const complaint = ChiefComplaintDetail(
        complaint: 'Right Knee Joint Pain',
        location: 'Right knee joint extending to calf',
        sensation: 'Drawing, stitching pain',
        modalitiesAgg: 'Cold air, morning, walking',
        modalitiesAmel: 'Warm application, rest',
        concomitants: 'Gastric flatulence',
        duration: '6 months',
        severity: 'Severe',
      );

      final json = complaint.toJson();
      final parsed = ChiefComplaintDetail.fromJson(json);

      expect(parsed.complaint, equals('Right Knee Joint Pain'));
      expect(parsed.location, equals('Right knee joint extending to calf'));
      expect(parsed.modalitiesAgg, equals('Cold air, morning, walking'));
      expect(parsed.severity, equals('Severe'));
    });

    test('serializes and deserializes PhysicalGenerals and MiasmaticAnalysis', () {
      const physical = PhysicalGenerals(
        thermal: 'Hot',
        thirst: 'Profuse, drinks large quantities',
        appetite: 'Good, cannot tolerate hunger',
        cravings: 'Sweets, fresh fish, tea',
        perspiration: 'Profuse, offensive on exertion',
        sleep: 'Disturbed due to flatulence',
      );

      final pJson = physical.toJson();
      final pParsed = PhysicalGenerals.fromJson(pJson);

      expect(pParsed.thermal, equals('Hot'));
      expect(pParsed.cravings, contains('Sweets'));

      const miasm = MiasmaticAnalysis(
        dominantMiasm: 'Sycotic',
        psoricFeatures: 'Burning eyes, itching',
        sycoticFeatures: 'Warts on tongue and forehead',
      );

      final mJson = miasm.toJson();
      final mParsed = MiasmaticAnalysis.fromJson(mJson);

      expect(mParsed.dominantMiasm, equals('Sycotic'));
      expect(mParsed.sycoticFeatures, contains('Warts'));
    });
  });

  group('MasterCaseTakingScreen Widget Tests', () {
    testWidgets('renders all major clinical case taking sections in CREATE mode', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final patient = Patient(
        id: 'p_test_1',
        patientCode: 'P-2026-00001',
        name: 'Demo Patient',
        phone: '9876543210',
        age: 45,
        gender: 'Male',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '001',
        referralSource: 'Direct / Walk-in',
        reviewGiven: false,
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
            home: MasterCaseTakingScreen(patient: patient),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Case Taking'), findsOneWidget);
      expect(find.text('Patient Identification'), findsOneWidget);
      expect(find.text('Save Case'), findsOneWidget);

      // Verify all 4 stage tabs are rendered
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Generals'), findsOneWidget);
      expect(find.text('Analysis'), findsOneWidget);
      expect(find.text('Prescription'), findsOneWidget);

      // Tap Generals stage tab
      await tester.tap(find.text('Generals'));
      await tester.pumpAndSettle();
      expect(find.text('Physical Generals'), findsOneWidget);
      expect(find.text('Mental & Emotional Generals'), findsOneWidget);

      // Tap Analysis stage tab
      await tester.tap(find.text('Analysis'));
      await tester.pumpAndSettle();
      expect(find.text('Miasmatic Analysis'), findsOneWidget);
    });

    testWidgets('renders EDIT mode when existing case record is present', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final patient = Patient(
        id: 'p_test_2',
        patientCode: 'P-2026-00002',
        name: 'Jane Doe',
        phone: '9876543211',
        age: 32,
        gender: 'Female',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '002',
        referralSource: 'Direct / Walk-in',
        reviewGiven: false,
      );

      final existingRecord = MasterCaseRecordData(
        patientId: patient.id,
        recordDate: DateTime.now(),
        identification: PatientIdentificationDetails(
          patientName: 'Jane Doe',
          age: '32',
          gender: 'Female',
        ),
        miasmaticAnalysis: const MiasmaticAnalysis(dominantMiasm: 'Psora'),
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          patientCaseRecordProvider(patient.id).overrideWith((ref) => Stream.value(existingRecord)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: MasterCaseTakingScreen(patient: patient),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edit Case'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog on back press when unsaved changes exist', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final patient = Patient(
        id: 'p_test_3',
        patientCode: 'P-2026-00003',
        name: 'Bob Smith',
        phone: '9876543212',
        age: 50,
        gender: 'Male',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '003',
        referralSource: 'Direct / Walk-in',
        reviewGiven: false,
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
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MasterCaseTakingScreen(patient: patient),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Case Taking'), findsOneWidget);

      // Modify a text field to make it dirty
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, 'Modified Name');
      await tester.pumpAndSettle();

      // Tap the AppBar back button
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Unsaved Changes'), findsOneWidget);
      expect(find.text('Keep Editing'), findsOneWidget);
      expect(find.text('Discard Changes'), findsOneWidget);

      // Tap Keep Editing
      await tester.tap(find.text('Keep Editing'));
      await tester.pumpAndSettle();

      // Should still be on Case Taking screen
      expect(find.text('Case Taking'), findsOneWidget);

      // Tap Back again and Discard Changes
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard Changes'));
      await tester.pumpAndSettle();

      // Screen should have popped back to home
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Case Taking'), findsNothing);
    });

    testWidgets('Case Record Tab: empty state renders cleanly without meaningless summary', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final patient = Patient(
        id: 'p_test_empty',
        patientCode: 'P-2026-00004',
        name: 'Empty Case Patient',
        phone: '9876543213',
        age: 28,
        gender: 'Female',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '004',
        referralSource: 'Direct / Walk-in',
        reviewGiven: false,
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          patientCaseRecordProvider(patient.id).overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: PatientProfileScreen(patient: patient),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Case Record tab
      final caseRecordTab = find.byTooltip('Case Record');
      expect(caseRecordTab, findsOneWidget);
      await tester.tap(caseRecordTab);
      await tester.pumpAndSettle();

      // Should show empty state message and Start button
      expect(find.text('Master Clinical Case Record'), findsOneWidget);
      expect(find.text('No case taking form recorded yet'), findsOneWidget);
      expect(find.text('Start Clinical Case Taking'), findsOneWidget);

      // Should NOT show any clinical summary rows
      expect(find.text('Dominant Miasm'), findsNothing);
      expect(find.text('Thermal State'), findsNothing);
      expect(find.text('Case Outcome'), findsNothing);
    });

    testWidgets('Case Record Tab: never renders raw JSON in Case Outcome or other fields', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final patient = Patient(
        id: 'p_test_json_check',
        patientCode: 'P-2026-00005',
        name: 'JSON Check Patient',
        phone: '9876543214',
        age: 40,
        gender: 'Male',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '005',
        referralSource: 'Direct / Walk-in',
        reviewGiven: false,
      );

      // Even if outcome contains serialized JSON
      final recordWithJsonOutcome = MasterCaseRecordData(
        patientId: patient.id,
        recordDate: DateTime(2026, 7, 23),
        chiefComplaints: const [
          ChiefComplaintDetail(complaint: 'Chronic Bronchitis'),
        ],
        clinicalAssessment: const ClinicalAssessmentDetails(
          finalWorkingDiagnosis: 'Chronic Bronchial Asthma',
        ),
        miasmaticAnalysis: const MiasmaticAnalysis(dominantMiasm: 'Tubercular'),
        physicalGenerals: const PhysicalGenerals(thermal: 'Chilly'),
        caseTotality: const CaseTotality(finalRemedySelection: 'Tuberculinum', potency: '1M'),
        outcomeDetails: const OutcomeDetails(
          finalStatus: 'Active Under Treatment',
          degreeOfImprovement: '50% improved',
          treatmentDuration: '3 months',
        ),
        // Simulate legacy or raw serialized JSON string in outcome
        outcome: '{"finalStatus":"Active Under Treatment","degreeOfImprovement":"50% improved","treatmentDuration":"3 months","reasonForDiscontinuation":"","lostToFollowUp":"","finalOutcomeNotes":""}',
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          patientCaseRecordProvider(patient.id).overrideWith((ref) => Stream.value(recordWithJsonOutcome)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: PatientProfileScreen(patient: patient),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Case Record tab
      await tester.tap(find.byTooltip('Case Record'));
      await tester.pumpAndSettle();

      // Verify human-readable summary fields
      expect(find.text('Chronic Bronchitis'), findsOneWidget);
      expect(find.text('Chronic Bronchial Asthma'), findsOneWidget);
      expect(find.text('Tubercular'), findsOneWidget);
      expect(find.text('Chilly'), findsOneWidget);
      expect(find.text('Tuberculinum 1M'), findsOneWidget);
      expect(find.text('Active Under Treatment'), findsOneWidget);
      expect(find.text('50% improved'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('View Full Case Sheet'), findsOneWidget);
      expect(find.text('Case Taking'), findsOneWidget);

      // Verify NO raw JSON or brackets are visible in the UI
      expect(find.textContaining('{"finalStatus"'), findsNothing);
      expect(find.textContaining('"degreeOfImprovement"'), findsNothing);
      expect(find.textContaining('""}'), findsNothing);
    });
  });
}
