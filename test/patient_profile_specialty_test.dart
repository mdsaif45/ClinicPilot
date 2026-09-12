import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/providers/cash_memo_provider.dart';
import 'package:clinic_pilot/features/clinical/models/case_record_models.dart';
import 'package:clinic_pilot/features/clinical/providers/case_record_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/complaint_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/investigation_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/prescription_provider.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/patients/presentation/patient_profile_screen.dart';
import 'package:clinic_pilot/features/settings/providers/doctor_profile_provider.dart';
import 'package:clinic_pilot/features/visits/providers/visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testPatient = Patient(
    id: 'p-specialty-1',
    patientCode: 'P-2026-00099',
    serialNo: '99',
    name: 'Specialty Test Patient',
    phone: '9876543210',
    whatsapp: '9876543210',
    age: 35,
    gender: 'Female',
    area: 'Kolkata',
    address: 'Park Street',
    occupation: 'Teacher',
    primaryClinicId: 'c-1',
    primaryDisease: 'Migraine',
    referralSource: 'Direct Walk-in',
    reviewGiven: false,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testClinic = Clinic(
    id: 'c-1',
    name: 'City Clinic',
    address: 'Main St',
    phone: '9876543210',
    monthlyRent: 10000,
    defaultConsultationFee: 300,
    openDays: 'Mon,Wed,Fri',
    colorHex: '#00796B',
    isActive: true,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  final testCaseRecord = MasterCaseRecordData(
    patientId: 'p-specialty-1',
    recordDate: DateTime(2026, 9, 1),
    chiefComplaints: const [
      ChiefComplaintDetail(complaint: 'Chronic headache and migraine'),
    ],
    miasmaticAnalysis: const MiasmaticAnalysis(dominantMiasm: 'Psora'),
    physicalGenerals: const PhysicalGenerals(thermal: 'Chilly'),
    clinicalAssessment: const ClinicalAssessmentDetails(
      provisionalDiagnosis: 'Migraine without aura',
    ),
    outcomeDetails: const OutcomeDetails(finalStatus: 'Under Treatment'),
  );

  Widget createWidget({
    required ClinicalSpecialty specialty,
    MasterCaseRecordData? record,
  }) {
    final profile = DoctorProfile(
      name: 'Dr. Test Doctor',
      specialty: specialty,
      qualification:
          specialty == ClinicalSpecialty.homeopathy
              ? 'BHMS, MD (Hom.)'
              : (specialty == ClinicalSpecialty.dental ? 'BDS' : 'MBBS'),
    );

    return ProviderScope(
      overrides: [
        doctorProfileStreamProvider.overrideWith(
          (ref) => Stream.value(profile),
        ),
        patientCaseRecordProvider(
          testPatient.id,
        ).overrideWith((ref) => Stream.value(record)),
        patientVisitsStreamProvider(
          testPatient.id,
        ).overrideWith((ref) => Stream.value([])),
        cashMemosStreamProvider.overrideWith((ref) => Stream.value([])),
        clinicsStreamProvider.overrideWith((ref) => Stream.value([testClinic])),
        patientComplaintsProvider(
          testPatient.id,
        ).overrideWith((ref) => Stream.value([])),
        patientPrescriptionsProvider(
          testPatient.id,
        ).overrideWith((ref) => Stream.value([])),
        patientInvestigationsProvider(
          testPatient.id,
        ).overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: PatientProfileScreen(patient: testPatient),
      ),
    );
  }

  group('Specialty-Tailored Case Record Tab & Navigation', () {
    testWidgets(
      'Homeopathy doctor: Case Record empty state prioritizes Case Taking and prunes Dental',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createWidget(specialty: ClinicalSpecialty.homeopathy, record: null),
        );
        await tester.pumpAndSettle();

        // Switch to Case Record tab (index 5)
        await tester.tap(find.byIcon(Icons.assignment_outlined));
        await tester.pumpAndSettle();

        // Verifications
        expect(find.text('Start Clinical Case Taking'), findsOneWidget);
        expect(find.text('Quick SOAP Note & Vitals'), findsOneWidget);
        expect(find.text('Dental Odontogram & Chart'), findsNothing);

        // FAB label
        expect(find.text('Case Taking'), findsOneWidget);
      },
    );

    testWidgets(
      'Homeopathy doctor: Case Record populated state shows Case Sheet & SOAP and prunes Dental',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createWidget(
            specialty: ClinicalSpecialty.homeopathy,
            record: testCaseRecord,
          ),
        );
        await tester.pumpAndSettle();

        // Switch to Case Record tab
        await tester.tap(find.byIcon(Icons.assignment_outlined));
        await tester.pumpAndSettle();

        // Verifications
        expect(find.text('View Full Case Sheet'), findsOneWidget);
        expect(find.text('SOAP Note'), findsOneWidget);
        expect(find.text('Dental'), findsNothing);
      },
    );

    testWidgets(
      'Dental doctor: Case Record empty state prioritizes Dental and prunes Case Taking',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createWidget(specialty: ClinicalSpecialty.dental, record: null),
        );
        await tester.pumpAndSettle();

        // Switch to Case Record tab
        await tester.tap(find.byIcon(Icons.assignment_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Dental Odontogram & Chart'), findsOneWidget);
        expect(find.text('Quick SOAP Note & Vitals'), findsOneWidget);
        expect(find.text('Start Clinical Case Taking'), findsNothing);

        // FAB label
        expect(find.text('Dental Chart'), findsOneWidget);
      },
    );

    testWidgets(
      'Dental doctor: Case Record populated state shows Dental Chart & SOAP and prunes Full Case Sheet',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createWidget(
            specialty: ClinicalSpecialty.dental,
            record: testCaseRecord,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.assignment_outlined));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(FilledButton, 'Dental Chart'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(FloatingActionButton, 'Dental Chart'),
          findsOneWidget,
        );
        expect(find.text('SOAP Note'), findsOneWidget);
        expect(find.text('View Full Case Sheet'), findsNothing);
      },
    );

    testWidgets(
      'General Practice doctor: Case Record empty state prioritizes SOAP Note and prunes Dental',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createWidget(
            specialty: ClinicalSpecialty.generalPractice,
            record: null,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.assignment_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Quick SOAP Note & Vitals'), findsOneWidget);
        expect(find.text('Start Clinical Case Taking'), findsOneWidget);
        expect(find.text('Dental Odontogram & Chart'), findsNothing);

        // FAB label
        expect(find.text('Clinical Note'), findsOneWidget);
      },
    );

    testWidgets('Multi-Specialty doctor: Case Record shows all 3 options', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createWidget(
          specialty: ClinicalSpecialty.multiSpecialty,
          record: testCaseRecord,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.assignment_outlined));
      await tester.pumpAndSettle();

      expect(find.text('SOAP Note'), findsOneWidget);
      expect(find.text('Dental'), findsOneWidget);
      expect(find.text('View Full Case Sheet'), findsOneWidget);
    });
  });
}
