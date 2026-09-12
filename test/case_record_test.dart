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

    test(
      'serializes and deserializes PhysicalGenerals and MiasmaticAnalysis',
      () {
        const physical = PhysicalGenerals(
          thermal: 'Hot',
          sensitivityToTemperature: 'Cannot tolerate sun or warm rooms',
          thirst: 'Profuse, drinks large quantities',
          appetite: 'Good, cannot tolerate hunger',
          cravings: 'Sweets, fresh fish, tea',
          stool: 'Soft, offensive, twice daily with urgent waking',
          urine: 'Clear, profuse, nocturnal frequency',
          perspiration: 'Profuse, offensive on exertion',
          sleep: 'Disturbed due to flatulence',
        );

        final pJson = physical.toJson();
        final pParsed = PhysicalGenerals.fromJson(pJson);

        expect(pParsed.thermal, equals('Hot'));
        expect(
          pParsed.sensitivityToTemperature,
          contains('Cannot tolerate sun'),
        );
        expect(pParsed.cravings, contains('Sweets'));
        expect(
          pParsed.stool,
          equals('Soft, offensive, twice daily with urgent waking'),
        );
        expect(pParsed.urine, equals('Clear, profuse, nocturnal frequency'));

        const miasm = MiasmaticAnalysis(
          dominantMiasm: 'Sycotic',
          psoricFeatures: 'Burning eyes, itching',
          sycoticFeatures: 'Warts on tongue and forehead',
        );

        final mJson = miasm.toJson();
        final mParsed = MiasmaticAnalysis.fromJson(mJson);

        expect(mParsed.dominantMiasm, equals('Sycotic'));
        expect(mParsed.sycoticFeatures, contains('Warts'));
      },
    );

    test(
      'PhysicalGenerals synthesizes stool and urine from legacy granular fields when direct observation notes are empty',
      () {
        final legacyJson = {
          'thermal': 'Chilly',
          'stoolFrequency': 'Once daily in morning',
          'stoolConsistency': 'Hard, knotty, dry balls',
          'stoolColourOdour': 'Dark brown, foul odour',
          'stoolDifficultiesModalities':
              'Urging before stool, burning in rectum after',
          'urineFrequency': '4-5 times during day, once at night',
          'urineQuantity': 'Copious, 2 litres',
          'urineColourOdour': 'High-coloured, strong ammoniacal',
          'urinarySymptoms': 'Burning along urethra during micturition',
        };

        final parsed = PhysicalGenerals.fromJson(legacyJson);
        expect(
          parsed.stool,
          equals(
            'Once daily in morning, Hard, knotty, dry balls, Dark brown, foul odour, Urging before stool, burning in rectum after',
          ),
        );
        expect(
          parsed.urine,
          equals(
            '4-5 times during day, once at night, Copious, 2 litres, High-coloured, strong ammoniacal, Burning along urethra during micturition',
          ),
        );
      },
    );

    test(
      'MentalGenerals synthesizes generalMentalState from legacy subfields when generalMentalState is empty',
      () {
        final legacyJson = {
          'disposition': 'Gentle, yielding, easily weeping',
          'anxiety': 'Anxiety about health and future in the evening',
          'fears': 'Fear of dark and being alone',
          'anger': 'Quick-tempered but easily calmed',
          'consolationReaction': 'Consolation ameliorates symptoms',
        };

        final parsed = MentalGenerals.fromJson(legacyJson);
        expect(
          parsed.generalMentalState,
          contains('Disposition: Gentle, yielding, easily weeping'),
        );
        expect(
          parsed.generalMentalState,
          contains('Anxiety: Anxiety about health and future in the evening'),
        );
        expect(
          parsed.generalMentalState,
          contains('Fears: Fear of dark and being alone'),
        );
        expect(
          parsed.generalMentalState,
          contains('Anger & Temper: Quick-tempered but easily calmed'),
        );
        expect(
          parsed.generalMentalState,
          contains('Consolation Response: Consolation ameliorates symptoms'),
        );
      },
    );

    test('PastDiseaseEntry serializes and deserializes properly', () {
      const entry = PastDiseaseEntry(
        disease: 'Typhoid fever',
        years: '2018 (6 years ago)',
        treatment: 'Allopathic antibiotics',
        outcome: 'Full recovery, occasional fatigue',
      );
      final json = entry.toJson();
      final parsed = PastDiseaseEntry.fromJson(json);

      expect(parsed.disease, equals('Typhoid fever'));
      expect(parsed.years, equals('2018 (6 years ago)'));
      expect(parsed.treatment, equals('Allopathic antibiotics'));
      expect(parsed.outcome, equals('Full recovery, occasional fatigue'));
      expect(parsed.isNotEmpty, isTrue);
    });

    test(
      'PastHistoryDetails supports dynamic entries and backward-compatible migration',
      () {
        // 1. Modern entries serialization
        const modern = PastHistoryDetails(
          allergies: 'Penicillin allergy',
          entries: [
            PastDiseaseEntry(
              disease: 'Pneumonia',
              years: '2020',
              treatment: 'Hospital admission',
              outcome: 'Resolved',
            ),
            PastDiseaseEntry(
              disease: 'Appendectomy',
              years: '2015',
              treatment: 'Laparoscopic surgery',
              outcome: 'Complete recovery',
            ),
          ],
        );
        final json = modern.toJson();
        final parsed = PastHistoryDetails.fromJson(json);
        expect(parsed.allergies, equals('Penicillin allergy'));
        expect(parsed.entries.length, equals(2));
        expect(parsed.entries[0].disease, equals('Pneumonia'));
        expect(parsed.entries[1].treatment, equals('Laparoscopic surgery'));

        // 2. Legacy migration fallback
        final legacyJson = {
          'childhoodIllnesses': 'Chickenpox at age 7',
          'majorSurgeries': 'Tonsillectomy in 2012',
          'injuriesAccidents': 'Fractured right collarbone in 2016',
          'bloodTransfusions': 'None',
          'allergies': 'Dust allergy',
        };
        final migrated = PastHistoryDetails.fromJson(legacyJson);
        expect(migrated.allergies, equals('Dust allergy'));
        expect(migrated.entries.length, equals(3));
        expect(
          migrated.entries.any((e) => e.disease == 'Chickenpox at age 7'),
          isTrue,
        );
        expect(
          migrated.entries.any((e) => e.disease == 'Tonsillectomy in 2012'),
          isTrue,
        );
        expect(
          migrated.entries.any(
            (e) => e.disease == 'Fractured right collarbone in 2016',
          ),
          isTrue,
        );
      },
    );

    test(
      'FamilyHistoryDetails supports 3 lineages and legacy fallback synthesis',
      () {
        // 1. Modern 3-lineage serialization
        const modern = FamilyHistoryDetails(
          paternalHistory: 'Paternal grandfather had diabetes and hypertension',
          maternalHistory: 'Mother had hypothyroidism, grandmother had asthma',
          ownFamilyHistory: 'Brother has mild eczema',
        );
        final json = modern.toJson();
        final parsed = FamilyHistoryDetails.fromJson(json);
        expect(parsed.paternalHistory, contains('Paternal grandfather'));
        expect(parsed.maternalHistory, contains('Mother had hypothyroidism'));
        expect(parsed.ownFamilyHistory, contains('Brother has mild eczema'));

        // 2. Legacy fallback synthesis
        final legacyJson = {
          'father': 'Hypertension',
          'mother': 'Diabetes Mellitus',
          'siblings': 'Elder brother healthy',
          'paternalGrandparents': 'Heart disease',
          'maternalGrandparents': 'Bronchial asthma',
        };
        final fallback = FamilyHistoryDetails.fromJson(legacyJson);
        expect(fallback.paternalHistory, contains('Father: Hypertension'));
        expect(
          fallback.paternalHistory,
          contains('Paternal Grandparents: Heart disease'),
        );
        expect(fallback.maternalHistory, contains('Mother: Diabetes Mellitus'));
        expect(
          fallback.maternalHistory,
          contains('Maternal Grandparents: Bronchial asthma'),
        );
        expect(
          fallback.ownFamilyHistory,
          contains('Siblings: Elder brother healthy'),
        );
      },
    );

    test(
      'DevelopmentalHistoryDetails retains core fields and gracefully handles JSON',
      () {
        const dev = DevelopmentalHistoryDetails(
          maternalHealth: 'Good general health during pregnancy',
          pregnancyComplications: 'Mild nausea in first trimester',
          maternalMedications: 'Folic acid supplements',
          modeOfDelivery: 'Normal vaginal delivery',
          neonatalHistory: 'Cried immediately at birth',
          breastfeeding: 'Exclusive breastfeeding for 6 months',
          developmentalMilestones:
              'Walked at 11 months, spoke words at 12 months',
          childhoodDevelopment: 'Normal physical and cognitive growth',
          otherBirthDevelopmentalHistory:
              'Complete vaccination as per schedule',
        );
        final json = dev.toJson();
        final parsed = DevelopmentalHistoryDetails.fromJson(json);
        expect(
          parsed.maternalHealth,
          equals('Good general health during pregnancy'),
        );
        expect(parsed.modeOfDelivery, equals('Normal vaginal delivery'));
        expect(parsed.developmentalMilestones, contains('Walked at 11 months'));
        expect(
          parsed.otherBirthDevelopmentalHistory,
          contains('Complete vaccination'),
        );
      },
    );
  });

  group('MasterCaseTakingScreen Widget Tests', () {
    testWidgets(
      'renders all major clinical case taking sections in CREATE mode',
      (tester) async {
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
          overrides: [databaseProvider.overrideWithValue(db)],
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
      },
    );

    testWidgets('renders EDIT mode when existing case record is present', (
      tester,
    ) async {
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
          patientCaseRecordProvider(
            patient.id,
          ).overrideWith((ref) => Stream.value(existingRecord)),
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

    testWidgets(
      'shows confirmation dialog on back press when unsaved changes exist',
      (tester) async {
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
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Builder(
                  builder:
                      (context) => ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      MasterCaseTakingScreen(patient: patient),
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
      },
    );

    testWidgets(
      'Case Record Tab: empty state renders cleanly without meaningless summary',
      (tester) async {
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
            patientCaseRecordProvider(
              patient.id,
            ).overrideWith((ref) => Stream.value(null)),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(body: PatientProfileScreen(patient: patient)),
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
      },
    );

    testWidgets(
      'Case Record Tab: never renders raw JSON in Case Outcome or other fields',
      (tester) async {
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
          miasmaticAnalysis: const MiasmaticAnalysis(
            dominantMiasm: 'Tubercular',
          ),
          physicalGenerals: const PhysicalGenerals(thermal: 'Chilly'),
          caseTotality: const CaseTotality(
            finalRemedySelection: 'Tuberculinum',
            potency: '1M',
          ),
          outcomeDetails: const OutcomeDetails(
            finalStatus: 'Active Under Treatment',
            degreeOfImprovement: '50% improved',
            treatmentDuration: '3 months',
          ),
          // Simulate legacy or raw serialized JSON string in outcome
          outcome:
              '{"finalStatus":"Active Under Treatment","degreeOfImprovement":"50% improved","treatmentDuration":"3 months","reasonForDiscontinuation":"","lostToFollowUp":"","finalOutcomeNotes":""}',
        );

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            patientCaseRecordProvider(
              patient.id,
            ).overrideWith((ref) => Stream.value(recordWithJsonOutcome)),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(body: PatientProfileScreen(patient: patient)),
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
      },
    );

    testWidgets(
      'MasterCaseTakingScreen: Section 02, 05, 06, and 07 enhancements render properly',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 5000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final patient = Patient(
          id: 'p_test_enhancements',
          patientCode: 'P-2026-00006',
          name: 'Enhancement Test Patient',
          phone: '9876543215',
          age: 35,
          gender: 'Female',
          primaryClinicId: 'clinic_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          serialNo: '006',
          referralSource: 'Direct / Walk-in',
          reviewGiven: false,
        );

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
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

        // 1. Section 02 - Chief Complaints sequence
        expect(find.text('Chief Complaints (1)'), findsOneWidget);
        await tester.tap(find.text('Chief Complaints (1)'));
        await tester.pumpAndSettle();

        expect(find.text('Complaint'), findsOneWidget);
        expect(find.text('Onset'), findsOneWidget);
        expect(find.text('Duration'), findsOneWidget);
        expect(find.text('Causation / Origin'), findsOneWidget);
        expect(find.text('Severity'), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Radiation / Extension'), findsOneWidget);
        expect(find.text('Sensation / Character'), findsOneWidget);
        expect(find.text('Aggravation (< Modality)'), findsOneWidget);
        expect(find.text('Amelioration (> Modality)'), findsOneWidget);
        expect(find.text('Time Modality'), findsOneWidget);
        expect(find.text('Periodicity'), findsOneWidget);
        expect(find.text('Concomitants'), findsOneWidget);
        expect(find.text('Associated Symptoms'), findsOneWidget);

        // 2. Section 05 - Past Medical History structured table and dynamic add/remove
        expect(find.text('Past Medical History'), findsOneWidget);
        await tester.tap(find.text('Past Medical History'));
        await tester.pumpAndSettle();

        expect(find.text('Disease / Condition'), findsWidgets);
        expect(find.text('Years / Duration'), findsWidgets);
        expect(find.text('Treatment'), findsWidgets);
        expect(find.text('Outcome'), findsWidgets);
        expect(find.text('Add Past History Entry'), findsOneWidget);

        // Tap Add Past History Entry
        await tester.tap(find.text('Add Past History Entry'));
        await tester.pumpAndSettle();
        // Now there should be 2 rows of disease entries
        expect(find.byIcon(Icons.coronavirus_outlined), findsNWidgets(2));

        // Delete one entry
        final deleteButtons = find.byIcon(Icons.delete_outline);
        expect(deleteButtons, findsWidgets);
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.coronavirus_outlined), findsOneWidget);

        // 3. Section 06 - Family History 3 Lineages
        expect(find.text('Family History'), findsOneWidget);
        await tester.tap(find.text('Family History'));
        await tester.pumpAndSettle();

        expect(find.text('Paternal Family History'), findsOneWidget);
        expect(find.text('Maternal Family History'), findsOneWidget);
        expect(find.text('Own Family History'), findsOneWidget);

        // 4. Section 07 - Intrauterine & Developmental History
        expect(
          find.text('Intrauterine & Developmental History'),
          findsOneWidget,
        );
        await tester.tap(find.text('Intrauterine & Developmental History'));
        await tester.pumpAndSettle();

        expect(find.text('Maternal Health in Pregnancy'), findsOneWidget);
        expect(find.text('Pregnancy Complications'), findsOneWidget);
        expect(find.text('Maternal Medications'), findsOneWidget);
        expect(find.text('Mode of Delivery'), findsOneWidget);
        expect(find.text('Neonatal History / Cry'), findsOneWidget);
        expect(find.text('Breastfeeding History'), findsOneWidget);
        expect(
          find.text('Milestones (Teething, Walking, Talking)'),
          findsOneWidget,
        );
        expect(find.text('Childhood Development'), findsOneWidget);
        expect(find.text('Other Developmental Notes'), findsOneWidget);

        // Verify the 6 pruned fields are NOT present
        expect(find.text('Maternal Infections'), findsNothing);
        expect(find.text('Antenatal Care'), findsNothing);
        expect(find.text('Maternal Nutrition'), findsNothing);
        expect(find.text('Gestational Age / Term'), findsNothing);
        expect(find.text('Birth Order'), findsNothing);
        expect(find.text('Birth Weight'), findsNothing);
      },
    );

    testWidgets(
      'MasterCaseTakingScreen: Section 08 Physical Generals renders single Stool and Urine observation fields and prunes granular fields',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 5000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final patient = Patient(
          id: 'p_test_section_08',
          patientCode: 'P-2026-00008',
          name: 'Section 08 Test Patient',
          phone: '9876543218',
          age: 42,
          gender: 'Male',
          primaryClinicId: 'clinic_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          serialNo: '008',
          referralSource: 'Direct / Walk-in',
          reviewGiven: false,
        );

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
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

        // Switch to Generals stage tab
        expect(find.text('Generals'), findsOneWidget);
        await tester.tap(find.text('Generals'));
        await tester.pumpAndSettle();

        // Expand Section 08: Physical Generals
        expect(find.text('Physical Generals'), findsOneWidget);
        await tester.tap(find.text('Physical Generals'));
        await tester.pumpAndSettle();

        // Core and simplified fields are present
        expect(find.text('Thermal State'), findsOneWidget);
        expect(
          find.text('Temperature Sensitivities & Weather Notes'),
          findsOneWidget,
        );
        expect(find.text('Appetite'), findsOneWidget);
        expect(find.text('Thirst'), findsOneWidget);
        expect(find.text('Cravings, Desires & Aversions'), findsOneWidget);
        expect(find.text('Stool'), findsOneWidget);
        expect(find.text('Urine'), findsOneWidget);

        // Granular struck-through fields are pruned
        expect(find.text('Weather / Season Preference'), findsNothing);
        expect(find.text('Hunger & Fasting'), findsNothing);
        expect(find.text('Thirst Frequency'), findsNothing);
        expect(find.text('Thirst Timing'), findsNothing);
        expect(find.text('Food Aversions'), findsNothing);
        expect(find.text('Food Intolerances & Aggravations'), findsNothing);

        // Granular Stool & Urine subfields are pruned
        expect(find.text('Stool Frequency'), findsNothing);
        expect(find.text('Stool Consistency'), findsNothing);
        expect(find.text('Stool Colour / Odour'), findsNothing);
        expect(find.text('Stool Difficulties & Modalities'), findsNothing);
        expect(find.text('Urine Frequency'), findsNothing);
        expect(find.text('Urine Quantity'), findsNothing);
        expect(find.text('Urine Colour / Odour'), findsNothing);
        expect(find.text('Urinary Symptoms'), findsNothing);
      },
    );

    testWidgets(
      'MasterCaseTakingScreen: Section 09 Mental & Emotional Generals renders single observation field and prunes 26 granular fields',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 5000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final patient = Patient(
          id: 'p_test_section_09',
          patientCode: 'P-2026-00009',
          name: 'Section 09 Test Patient',
          phone: '9876543219',
          age: 38,
          gender: 'Female',
          primaryClinicId: 'clinic_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          serialNo: '009',
          referralSource: 'Direct / Walk-in',
          reviewGiven: false,
        );

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
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

        // Switch to Generals stage tab
        expect(find.text('Generals'), findsOneWidget);
        await tester.tap(find.text('Generals'));
        await tester.pumpAndSettle();

        // Expand Section 09: Mental & Emotional Generals
        expect(find.text('Mental & Emotional Generals'), findsOneWidget);
        await tester.tap(find.text('Mental & Emotional Generals'));
        await tester.pumpAndSettle();

        // Single comprehensive observation notes field is present
        expect(find.text('General Mental & Emotional State'), findsOneWidget);

        // 26 granular subfields are pruned from UI
        expect(find.text('Disposition / Nature'), findsNothing);
        expect(find.text('Irritability'), findsNothing);
        expect(find.text('Anger & Temper'), findsNothing);
        expect(find.text('Anxiety'), findsNothing);
        expect(find.text('Fears'), findsNothing);
        expect(find.text('Specific Fears & Phobias'), findsNothing);
        expect(find.text('Sadness & Grief'), findsNothing);
        expect(find.text('Depression'), findsNothing);
        expect(find.text('Jealousy & Envy'), findsNothing);
        expect(find.text('Suspicion'), findsNothing);
        expect(find.text('Company (Desire/Aversion)'), findsNothing);
        expect(find.text('Desire for Solitude'), findsNothing);
        expect(find.text('Consolation Response'), findsNothing);
        expect(find.text('Loquacity / Quietness'), findsNothing);
        expect(find.text('Confidence / Self-Esteem'), findsNothing);
        expect(find.text('Will & Determination'), findsNothing);
        expect(find.text('Indecision & Doubt'), findsNothing);
        expect(find.text('Memory & Recall'), findsNothing);
        expect(find.text('Concentration & Focus'), findsNothing);
        expect(find.text('Work / Study Response'), findsNothing);
        expect(find.text('Restlessness'), findsNothing);
        expect(find.text('Stress Handling'), findsNothing);
        expect(find.text('Reaction to Contradiction'), findsNothing);
        expect(find.text('Reaction to Reprimand'), findsNothing);
        expect(find.text('Obsessions / Compulsions'), findsNothing);
        expect(find.text('Other Characteristic Mentals'), findsNothing);
      },
    );

    test(
      'ClinicalAssessmentDetails.fromJson backward compatibility fallback',
      () {
        // 1. Only provisionalDiagnosis provided
        final cad1 = ClinicalAssessmentDetails.fromJson({
          'provisionalDiagnosis': 'Allergic Rhinitis',
        });
        expect(cad1.provisionalDiagnosis, 'Allergic Rhinitis');
        expect(cad1.finalWorkingDiagnosis, 'Allergic Rhinitis');

        // 2. Only finalWorkingDiagnosis provided
        final cad2 = ClinicalAssessmentDetails.fromJson({
          'finalWorkingDiagnosis': 'Bronchial Asthma',
        });
        expect(cad2.provisionalDiagnosis, 'Bronchial Asthma');
        expect(cad2.finalWorkingDiagnosis, 'Bronchial Asthma');

        // 3. Both provided with different values
        final cad3 = ClinicalAssessmentDetails.fromJson({
          'provisionalDiagnosis': 'Suspected Asthma',
          'finalWorkingDiagnosis': 'Confirmed Bronchial Asthma',
        });
        expect(cad3.provisionalDiagnosis, 'Suspected Asthma');
        expect(cad3.finalWorkingDiagnosis, 'Confirmed Bronchial Asthma');
      },
    );

    test(
      'FollowUpDetails.fromJson synthesizes legacy granular fields when generals is empty',
      () {
        final fu = FollowUpDetails.fromJson({
          'sleepChange': 'Improved, uninterrupted 7 hrs',
          'appetiteThirstChange': 'Appetite increased',
          'stoolUrineChange': 'Regular soft stool daily',
          'perspirationChange': 'Less sweating on palms',
          'energyChange': 'Significantly more active',
        });

        expect(
          fu.generalSymptomsChange,
          'Sleep: Improved, uninterrupted 7 hrs, Appetite/Thirst: Appetite increased, Bowels/Urine: Regular soft stool daily, Sweat: Less sweating on palms, Energy: Significantly more active',
        );
        expect(fu.sleepChange, 'Improved, uninterrupted 7 hrs');
        expect(fu.appetiteThirstChange, 'Appetite increased');
        expect(fu.stoolUrineChange, 'Regular soft stool daily');
        expect(fu.perspirationChange, 'Less sweating on palms');
        expect(fu.energyChange, 'Significantly more active');
      },
    );

    testWidgets(
      'Section 14: Clinical Assessment & Diagnosis renders consolidated diagnosis field and prunes redundant fields',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 5000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final patient = Patient(
          id: 'test_p14',
          patientCode: 'P-2026-00014',
          serialNo: '014',
          name: 'Diagnosis Test',
          phone: '9876543210',
          age: 38,
          gender: 'Female',
          primaryClinicId: 'clinic_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          referralSource: 'Direct / Walk-in',
          reviewGiven: false,
        );

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
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

        // Switch to Analysis stage tab
        expect(find.text('Analysis'), findsOneWidget);
        await tester.tap(find.text('Analysis'));
        await tester.pumpAndSettle();

        // Expand Section 14: Clinical Assessment & Diagnosis
        expect(find.text('Clinical Assessment & Diagnosis'), findsOneWidget);
        await tester.tap(find.text('Clinical Assessment & Diagnosis'));
        await tester.pumpAndSettle();

        // Consolidated field is present
        expect(find.text('Diagnosis / Provisional Diagnosis'), findsOneWidget);
        expect(find.text('Differential Diagnosis'), findsOneWidget);
        expect(find.text('Comorbidities'), findsOneWidget);
        expect(find.text('Clinical Remarks & Observations'), findsOneWidget);

        // Pruned fields are absent
        expect(find.text('Final Working Diagnosis'), findsNothing);
        expect(find.text('Red Flags & Referral Indications'), findsNothing);
      },
    );

    testWidgets(
      'Section 17: Follow-Up Details renders Generals/Mentals change and adverse symptoms, pruning redundant subfields',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 5000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);

        final patient = Patient(
          id: 'test_p17',
          patientCode: 'P-2026-00017',
          serialNo: '017',
          name: 'FollowUp Test',
          phone: '9876543210',
          age: 42,
          gender: 'Male',
          primaryClinicId: 'clinic_1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDeleted: false,
          referralSource: 'Direct / Walk-in',
          reviewGiven: false,
        );

        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
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

        // Switch to Prescription stage tab
        expect(find.text('Prescription'), findsOneWidget);
        await tester.tap(find.text('Prescription'));
        await tester.pumpAndSettle();

        // Expand Section 17: Follow-Up Details
        expect(find.text('Follow-Up Details'), findsOneWidget);
        await tester.tap(find.text('Follow-Up Details'));
        await tester.pumpAndSettle();

        // Retained fields are present
        expect(find.text('Generals Change'), findsOneWidget);
        expect(find.text('Mentals Change'), findsOneWidget);
        expect(find.text('Adverse / Unwanted Symptoms'), findsOneWidget);
        expect(find.text('Follow-Up Remedy'), findsOneWidget);

        // Pruned redundant subfields are absent
        expect(find.text('Sleep Change'), findsNothing);
        expect(find.text('Appetite & Thirst Change'), findsNothing);
        expect(find.text('Bowels & Urine Change'), findsNothing);
        expect(find.text('Perspiration Change'), findsNothing);
        expect(find.text('Energy Change'), findsNothing);
      },
    );
  });
}
