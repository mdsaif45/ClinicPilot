import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/clinical/models/case_record_models.dart';
import 'package:clinic_pilot/features/clinical/presentation/clinical_case_sheet_screen.dart';
import 'package:clinic_pilot/features/clinical/providers/case_record_provider.dart';

void main() {
  final testPatient = Patient(
    id: 'p_test_101',
    patientCode: 'P-2026-00019',
    serialNo: 'ONL-00001',
    name: 'Pooja Sharma',
    phone: '9876543210',
    email: 'pooja.sharma@patna.org',
    age: 28,
    gender: 'Female',
    area: 'Patna, Bihar',
    primaryClinicId: 'clinic_online',
    reviewGiven: false,
    isDeleted: false,
    createdAt: DateTime(2026, 8, 2),
    updatedAt: DateTime(2026, 8, 2),
  );

  final testCaseRecord = MasterCaseRecordData(
    id: 'cr_test_101',
    patientId: 'p_test_101',
    recordDate: DateTime(2026, 8, 2),
    chiefComplaints: const [
      ChiefComplaintDetail(
        complaint: 'Alopecia Areata & Hair Thinning',
        location: 'Patna, Bihar',
        sensation: 'Patchy loss of scalp hair with tingling',
        modalitiesAgg: 'Aggravated by stress and post-wash',
        modalitiesAmel: 'Relieved by oil massage',
        concomitants: 'Restlessness and sleep disruption',
        duration: '8 months',
        severity: 'Moderate',
      ),
    ],
    hpi: const HpiDetails(
      chronologicalDevelopment:
          'Gradual patchy hair thinning noted 8 months ago',
      progression: 'Progressively worse with seasonal transitions',
      previousTreatment: 'Allopathic minoxidil gave temporary palliation',
    ),
    pastHistory: const PastHistoryDetails(
      allergies: 'Hypersensitive to chemical hair dyes',
      childhoodIllnesses: 'Recurrent measles',
    ),
    familyHistory: const FamilyHistoryDetails(
      father: 'Hypertension',
      mother: 'Early hair thinning and thyroid disorder',
    ),
    physicalGenerals: const PhysicalGenerals(
      thermal: 'Chilly',
      appetite: 'Normal, desires warm cooked foods',
      thirst: 'Moderate, 2.5 litres per day',
      sleep: 'Disturbed past 2 AM',
      dreams: 'Occupational stress dreams',
    ),
    mentalGenerals: const MentalGenerals(
      generalMentalState: 'Meticulous, conscientious, anxious about recovery',
      fears: 'Fear of sudden loss and high places',
    ),
    lifestyleHabits: const LifestyleHistoryDetails(
      diet: 'Mixed non-vegetarian, regular meal timings',
      physicalActivity: 'Sedentary work desk with 30 min evening walk',
    ),
    clinicalExam: const ClinicalExamVitals(
      pulse: '74 bpm',
      bloodPressure: '124/82 mmHg',
      temperature: '98.4 F',
      respiratoryRate: '16/min',
      spo2: '99%',
      weightKg: '68 kg',
      heightCm: '168 cm',
      bmi: '24.1',
      generalAppearance: 'Well nourished, alert, cooperative',
    ),
    miasmaticAnalysis: const MiasmaticAnalysis(
      dominantMiasm: 'Psora',
      secondaryMixedMiasm: 'Sycotic',
    ),
    caseTotality: const CaseTotality(
      totalityOfSymptoms:
          'Totality of characteristic mental and physical general symptoms',
      characteristicSymptoms:
          'Thermal modality chilly, worse cold and damp, better warmth',
      generals: 'Chilly thermal, moderate thirst, fatigue on exertion',
      finalRemedySelection: 'Phosphorus',
      potency: '200C',
    ),
    clinicalAssessment: const ClinicalAssessmentDetails(
      provisionalDiagnosis: 'Alopecia Areata & Hair Thinning',
      finalWorkingDiagnosis: 'Alopecia Areata & Hair Thinning',
      clinicalRemarks: 'Constitutional homoeopathic treatment initiated',
    ),
    baselinePrescription: const PrescriptionPlanDetails(
      remedyName: 'Phosphorus',
      potency: '200C',
      dose: '4 pills',
      repetitionFrequency: 'Twice daily before meals',
      pharmaceuticalForm: 'Globules / Sugar Pellets',
      dietRegimenAdvice: 'Avoid raw onions, strong coffee, and camphor',
    ),
    investigations: const InvestigationsPlanDetails(
      investigationName: 'Serum Ferritin & Scalp Trichoscopy',
      reportSummary: 'Within clinically acceptable limits',
      normalAbnormal: 'Normal',
    ),
    followUpDetails: const FollowUpDetails(
      overallResponse: 'Treatment ongoing',
    ),
    outcome: 'Active Under Treatment',
  );

  Widget createWidgetUnderTest({MasterCaseRecordData? record}) {
    return ProviderScope(
      overrides: [
        patientCaseRecordProvider(
          testPatient.id,
        ).overrideWith((ref) => Stream.value(record)),
        clinicsStreamProvider.overrideWith(
          (ref) => Stream.value([
            Clinic(
              id: 'clinic_online',
              name: 'Online / Teleconsultation',
              address: 'Digital / Remote Practice',
              phone: '9830012345',
              defaultConsultationFee: 350.0,
              monthlyRent: 0.0,
              openDays: '1,2,3,4,5,6,7',
              colorHex: '#7C3AED',
              isActive: true,
              isDeleted: false,
              createdAt: DateTime(2026, 1, 1),
            ),
          ]),
        ),
      ],
      child: MaterialApp(home: ClinicalCaseSheetScreen(patient: testPatient)),
    );
  }

  group('ClinicalCaseSheetScreen Tests', () {
    testWidgets('renders patient header and clinical highlights', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(record: testCaseRecord));
      await tester.pumpAndSettle();

      expect(find.text('Clinical Case Sheet'), findsOneWidget);
      expect(find.text('Pooja Sharma'), findsOneWidget);
      expect(find.text('P-2026-00019'), findsOneWidget);
      expect(find.text('28y, Female'), findsOneWidget);

      // Hero Badges
      expect(find.text('Miasm: Psora'), findsOneWidget);
      expect(find.text('Thermal: Chilly'), findsOneWidget);
      expect(find.text('Remedy: Phosphorus 200C'), findsWidgets);
    });

    testWidgets(
      'renders structured clinical sections in readable format with section chips',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest(record: testCaseRecord));
        await tester.pumpAndSettle();

        // Top section quick-jump chips are available
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Complaints'), findsWidgets);
        expect(find.text('HPI'), findsOneWidget);

        // No editable form fields in clinical body
        expect(find.byType(TextFormField), findsNothing);

        // Structured Sections
        expect(find.text('Chief Complaints'), findsOneWidget);
        expect(find.text('Alopecia Areata & Hair Thinning'), findsWidgets);
        expect(
          find.text('Patchy loss of scalp hair with tingling'),
          findsOneWidget,
        );

        expect(find.text('History of Present Illness (HPI)'), findsOneWidget);
        expect(
          find.text('Gradual patchy hair thinning noted 8 months ago'),
          findsOneWidget,
        );

        expect(find.text('Past Medical History & Allergies'), findsOneWidget);
        expect(
          find.text('Hypersensitive to chemical hair dyes'),
          findsOneWidget,
        );

        expect(find.text('Physical Generals & Modalities'), findsOneWidget);
        expect(find.text('Disturbed past 2 AM'), findsOneWidget);

        expect(find.text('Baseline Prescription Plan'), findsOneWidget);
        expect(
          find.text('Avoid raw onions, strong coffee, and camphor'),
          findsOneWidget,
        );

        expect(
          find.text('Diagnostic Investigations & Lab Tests'),
          findsOneWidget,
        );
        expect(find.text('Serum Ferritin & Scalp Trichoscopy'), findsOneWidget);

        // Edit button exists
        expect(find.text('Edit Master Case Record'), findsOneWidget);
      },
    );

    testWidgets('quick-jump chip filters matching clinical section', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest(record: testCaseRecord));
      await tester.pumpAndSettle();

      // Tap "Past History" chip
      await tester.tap(find.text('Past History'));
      await tester.pumpAndSettle();

      // Past History section is visible
      expect(find.text('Past Medical History & Allergies'), findsOneWidget);
      expect(find.text('Hypersensitive to chemical hair dyes'), findsOneWidget);

      // Other unrelated sections are filtered out
      expect(find.text('Baseline Prescription Plan'), findsNothing);
    });

    testWidgets('displays empty state when no case record exists', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(record: null));
      await tester.pumpAndSettle();

      expect(find.text('No Case Record Found'), findsOneWidget);
      expect(find.text('Start Clinical Case Taking'), findsOneWidget);
    });

    test(
      'ChiefComplaintDetail model serializes and parses correctly for sync',
      () {
        const detail = ChiefComplaintDetail(
          complaint: 'Chronic Migraine',
          location: 'Right temporal',
          onset: 'Sudden',
          duration: '3 years',
          sensation: 'Throbbing, pulsating',
          extensionRadiation: 'Radiates to right eye',
          modalitiesAgg: 'Sun exposure, noise',
          modalitiesAmel: 'Dark quiet room, hard pressure',
          concomitants: 'Nausea, photophobia',
          causation: 'Mental strain',
          periodicity: 'Weekly on Sundays',
          severity: 'Severe',
          associatedSymptoms: 'Dizziness with aura',
        );

        final json = detail.toJson();
        expect(json['complaint'], 'Chronic Migraine');
        expect(json['severity'], 'Severe');

        final parsed = ChiefComplaintDetail.fromJson(json);
        expect(parsed.complaint, 'Chronic Migraine');
        expect(parsed.modalitiesAgg, 'Sun exposure, noise');
        expect(parsed.modalitiesAmel, 'Dark quiet room, hard pressure');
      },
    );

    testWidgets(
      'renders structured Past Medical History table, 3-lineage Family History, and Developmental section',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final testRecordWithEnhancements = MasterCaseRecordData(
          id: 'cr_test_enhancements',
          patientId: testPatient.id,
          recordDate: DateTime(2026, 8, 10),
          chiefComplaints: const [
            ChiefComplaintDetail(
              complaint: 'Chronic Eczema',
              onset: 'Gradual after change of residence',
              duration: '1.5 years',
              causation: 'Hard water exposure and mental stress',
              severity: 'Moderate',
              location: 'Flexor surfaces of elbows and knees',
              extensionRadiation: 'Spreading to wrists',
              sensation: 'Intense itching, dry cracked skin',
              modalitiesAgg: 'Night, winter, hot showers',
              modalitiesAmel: 'Coconut oil application, open air',
              concomitants: 'Restlessness at night, anxiety',
              associatedSymptoms: 'Dry scalp with dandruff',
            ),
          ],
          pastHistory: const PastHistoryDetails(
            allergies: 'Severe allergy to sulfa drugs',
            entries: [
              PastDiseaseEntry(
                disease: 'Bronchial Asthma',
                years: '2015 - 2018',
                treatment: 'Inhalers (Salbutamol)',
                outcome: 'Quiescent since 2019',
              ),
              PastDiseaseEntry(
                disease: 'Acute Appendicitis',
                years: '2021',
                treatment: 'Appendectomy',
                outcome: 'Fully recovered without complications',
              ),
            ],
          ),
          familyHistory: const FamilyHistoryDetails(
            paternalHistory:
                'Father: Type 2 Diabetes, Paternal Uncle: Hypertension',
            maternalHistory:
                'Mother: Bronchial Asthma, Maternal Grandfather: Stroke',
            ownFamilyHistory:
                'Elder sister has allergic rhinitis, younger brother healthy',
          ),
          developmentalHistory: const DevelopmentalHistoryDetails(
            maternalHealth: 'Normal uneventful pregnancy',
            pregnancyComplications: 'None reported',
            maternalMedications: 'Prenatal iron and calcium',
            modeOfDelivery: 'Full term normal vaginal delivery',
            neonatalHistory: 'Normal birth cry, no jaundice',
            breastfeeding: 'Exclusively breastfed for 6 months',
            developmentalMilestones: 'All motor milestones reached on time',
            childhoodDevelopment: 'Active child, average milestones',
            otherBirthDevelopmentalHistory:
                'Up to date with primary immunization schedule',
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(record: testRecordWithEnhancements),
        );
        await tester.pumpAndSettle();

        // 1. Chief Complaints order
        expect(find.text('Chronic Eczema'), findsWidgets);
        expect(
          find.textContaining('Gradual after change of residence'),
          findsOneWidget,
        );
        expect(
          find.text('Hard water exposure and mental stress'),
          findsOneWidget,
        );
        expect(
          find.text('Flexor surfaces of elbows and knees'),
          findsOneWidget,
        );
        expect(find.text('Intense itching, dry cracked skin'), findsOneWidget);

        // 2. Structured Past Medical History table
        expect(find.text('Past Medical History & Allergies'), findsOneWidget);
        expect(find.text('Severe allergy to sulfa drugs'), findsOneWidget);
        expect(find.text('Disease'), findsWidgets);
        expect(find.text('Bronchial Asthma'), findsOneWidget);
        expect(find.text('2015 - 2018'), findsOneWidget);
        expect(find.text('Inhalers (Salbutamol)'), findsOneWidget);
        expect(find.text('Quiescent since 2019'), findsOneWidget);
        expect(find.text('Acute Appendicitis'), findsOneWidget);

        // 3. Family History 3 Lineages
        expect(find.text('Family Medical History'), findsOneWidget);
        expect(
          find.text('Paternal Lineage (Father & Grandparents)'),
          findsOneWidget,
        );
        expect(
          find.text('Father: Type 2 Diabetes, Paternal Uncle: Hypertension'),
          findsOneWidget,
        );
        expect(
          find.text('Maternal Lineage (Mother & Grandparents)'),
          findsOneWidget,
        );
        expect(
          find.text('Mother: Bronchial Asthma, Maternal Grandfather: Stroke'),
          findsOneWidget,
        );
        expect(
          find.text('Own Family (Siblings, Spouse, Children)'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Elder sister has allergic rhinitis, younger brother healthy',
          ),
          findsOneWidget,
        );

        // 4. Developmental History Section
        expect(find.text('Intrauterine & Developmental History'), findsOneWidget);
        expect(find.text('Normal uneventful pregnancy'), findsOneWidget);
        expect(find.text('Full term normal vaginal delivery'), findsOneWidget);
        expect(
          find.text('All motor milestones reached on time'),
          findsOneWidget,
        );
        expect(
          find.text('Up to date with primary immunization schedule'),
          findsOneWidget,
        );
      },
    );
  });
}
