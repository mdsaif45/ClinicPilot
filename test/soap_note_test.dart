import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinical/models/soap_note_model.dart';
import 'package:clinic_pilot/features/clinical/presentation/soap_note_screen.dart';
import 'package:clinic_pilot/features/clinical/presentation/widgets/vital_signs_card.dart';
import 'package:clinic_pilot/features/clinical/providers/case_record_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VitalSigns Model Unit Tests', () {
    test('calculateBmi accurately computes BMI from weight and height', () {
      // 70kg, 175cm -> 70 / (1.75 * 1.75) = 22.86 -> 22.9
      final bmi = VitalSigns.calculateBmi('70', '175');
      expect(bmi, equals('22.9'));

      // 95kg, 170cm -> 95 / (1.7 * 1.7) = 32.87 -> 32.9
      final obeseBmi = VitalSigns.calculateBmi('95', '170');
      expect(obeseBmi, equals('32.9'));

      // Empty or invalid values return empty string
      expect(VitalSigns.calculateBmi('', '175'), isEmpty);
      expect(VitalSigns.calculateBmi('70', ''), isEmpty);
      expect(VitalSigns.calculateBmi('0', '175'), isEmpty);
      expect(VitalSigns.calculateBmi('70', '0'), isEmpty);
      expect(VitalSigns.calculateBmi('abc', 'xyz'), isEmpty);
    });

    test('getBmiCategory returns correct WHO classification', () {
      expect(VitalSigns.getBmiCategory('17.5'), equals('Underweight'));
      expect(VitalSigns.getBmiCategory('22.0'), equals('Normal weight'));
      expect(VitalSigns.getBmiCategory('27.4'), equals('Overweight'));
      expect(VitalSigns.getBmiCategory('33.1'), equals('Obese'));
      expect(VitalSigns.getBmiCategory(''), isEmpty);
      expect(VitalSigns.getBmiCategory('not-a-number'), isEmpty);
    });

    test('hasVitals accurately reflects whether any vital sign is present', () {
      const emptyVitals = VitalSigns();
      expect(emptyVitals.hasVitals, isFalse);
      expect(emptyVitals.summary, equals('No vitals recorded'));

      const vitalsWithBp = VitalSigns(bloodPressure: '120/80');
      expect(vitalsWithBp.hasVitals, isTrue);
      expect(vitalsWithBp.summary, contains('BP: 120/80'));

      const vitalsWithPulseAndWeight = VitalSigns(
        pulse: '76',
        weightKg: '68',
        bmi: '23.5',
      );
      expect(vitalsWithPulseAndWeight.hasVitals, isTrue);
      expect(vitalsWithPulseAndWeight.summary, contains('Pulse: 76 bpm'));
      expect(vitalsWithPulseAndWeight.summary, contains('Wt: 68 kg'));
      expect(vitalsWithPulseAndWeight.summary, contains('BMI: 23.5'));
    });

    test('toMap and fromMap preserves all vital signs', () {
      const original = VitalSigns(
        bloodPressure: '130/85',
        pulse: '82',
        temperature: '98.6',
        spo2: '99',
        respiratoryRate: '18',
        weightKg: '72',
        heightCm: '172',
        bmi: '24.3',
      );

      final map = original.toMap();
      final restored = VitalSigns.fromMap(map);

      expect(restored.bloodPressure, equals('130/85'));
      expect(restored.pulse, equals('82'));
      expect(restored.temperature, equals('98.6'));
      expect(restored.spo2, equals('99'));
      expect(restored.respiratoryRate, equals('18'));
      expect(restored.weightKg, equals('72'));
      expect(restored.heightCm, equals('172'));
      expect(restored.bmi, equals('24.3'));
    });
  });

  group('SoapNoteData Model & Conversion Tests', () {
    test('converts seamlessly to and from MasterCaseRecordData', () {
      final now = DateTime.now();
      final followUp = now.add(const Duration(days: 7));

      final soap = SoapNoteData(
        id: 'soap-101',
        patientId: 'patient-abc',
        recordDate: now,
        chiefComplaint: 'Acute headache and fever',
        symptomDuration: '3 days',
        hpi: 'High fever associated with frontal headache and body ache.',
        vitals: const VitalSigns(
          bloodPressure: '120/80',
          pulse: '88',
          temperature: '101.2',
          spo2: '98',
          respiratoryRate: '20',
          weightKg: '65',
          heightCm: '168',
          bmi: '23.0',
        ),
        physicalExamFindings:
            'Pharynx mildly congested. Chest clear bilaterally.',
        workingDiagnosis: 'Viral Upper Respiratory Infection',
        prescriptionNotes:
            'Paracetamol 650mg TDS x 3 days\nCetirizine 10mg OD HS x 5 days',
        investigationsOrdered: 'Complete Blood Count (CBC)',
        adviceLifestyle: 'Adequate hydration, warm fluids, light soft diet.',
        nextFollowUpDate: followUp,
      );

      // Convert to MasterCaseRecordData
      final master = soap.toMasterCaseRecord();

      expect(master.id, equals('soap-101'));
      expect(master.patientId, equals('patient-abc'));
      expect(master.chiefComplaints.length, equals(1));
      expect(
        master.chiefComplaints.first.complaint,
        equals('Acute headache and fever'),
      );
      expect(master.chiefComplaints.first.duration, equals('3 days'));
      expect(
        master.hpi.chronologicalDevelopment,
        contains('High fever associated with frontal headache'),
      );
      expect(master.clinicalExam.bloodPressure, equals('120/80'));
      expect(master.clinicalExam.pulse, equals('88'));
      expect(master.clinicalExam.temperature, equals('101.2'));
      expect(master.clinicalExam.bmi, equals('23.0'));
      expect(
        master.clinicalExam.otherExaminationFindings,
        contains('Pharynx mildly congested'),
      );
      expect(
        master.clinicalAssessment.finalWorkingDiagnosis,
        equals('Viral Upper Respiratory Infection'),
      );
      expect(
        master.baselinePrescription.prescriptionNotes,
        contains('Paracetamol 650mg'),
      );
      expect(
        master.investigations.investigationName,
        contains('Complete Blood Count'),
      );
      expect(master.followUpNotes, contains('Adequate hydration'));

      // Reconstruct back from MasterCaseRecordData
      final restored = SoapNoteData.fromMasterCaseRecord(master);

      expect(restored.id, equals('soap-101'));
      expect(restored.patientId, equals('patient-abc'));
      expect(restored.chiefComplaint, equals('Acute headache and fever'));
      expect(restored.symptomDuration, equals('3 days'));
      expect(restored.vitals.bloodPressure, equals('120/80'));
      expect(restored.vitals.pulse, equals('88'));
      expect(
        restored.workingDiagnosis,
        equals('Viral Upper Respiratory Infection'),
      );
      expect(restored.prescriptionNotes, contains('Paracetamol 650mg'));
    });
  });

  group('SOAP Widgets & UI Flow Tests', () {
    late AppDatabase db;
    late Patient patient;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      patient = Patient(
        id: 'patient-test-soap',
        patientCode: 'P-2026-00099',
        serialNo: 'GP-001',
        name: 'Rahul Sharma',
        phone: '9876543210',
        gender: 'Male',
        age: 32,
        primaryClinicId: 'clinic-1',
        reviewGiven: false,
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('VitalSignsCard renders fields and computes live BMI', (
      tester,
    ) async {
      final weightController = TextEditingController();
      final heightController = TextEditingController();
      final bpController = TextEditingController();
      final pulseController = TextEditingController();
      final tempController = TextEditingController();
      final spo2Controller = TextEditingController();
      final respRateController = TextEditingController();
      final sugarController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: VitalSignsCard(
                weightController: weightController,
                heightController: heightController,
                bpController: bpController,
                pulseController: pulseController,
                tempController: tempController,
                spo2Controller: spo2Controller,
                respRateController: respRateController,
                sugarController: sugarController,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vital Signs'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Height (cm)'), findsOneWidget);

      // Set weight and height to test live BMI update
      weightController.text = '72';
      heightController.text = '175';
      await tester.pump();

      // BMI should calculate to 23.5 and show Normal weight badge
      expect(find.textContaining('BMI: 23.5'), findsOneWidget);
      expect(find.textContaining('Normal weight'), findsOneWidget);
    });

    testWidgets('VitalSignsSummaryStrip displays vital sign chips cleanly', (
      tester,
    ) async {
      const vitals = VitalSigns(
        bloodPressure: '124/82',
        pulse: '74',
        temperature: '98.4',
        spo2: '99',
        weightKg: '70',
        bmi: '22.9',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: VitalSignsSummaryStrip(vitals: vitals)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('124/82 mmHg'), findsOneWidget);
      expect(find.text('74 bpm'), findsOneWidget);
      expect(find.text('98.4°F'), findsOneWidget);
      expect(find.text('99%'), findsOneWidget);
      expect(find.text('70 kg'), findsOneWidget);
      expect(find.text('22.9'), findsOneWidget);
    });

    testWidgets('SoapNoteScreen renders 4 SOAP tabs and navigates smoothly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientCaseRecordProvider(
              patient.id,
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: SoapNoteScreen(patient: patient),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title with patient name
      expect(find.text('SOAP Clinical Note'), findsOneWidget);
      expect(find.textContaining('Rahul Sharma'), findsOneWidget);

      // Verify tab labels
      expect(find.text('S - Subjective'), findsOneWidget);
      expect(find.text('O - Objective'), findsOneWidget);
      expect(find.text('A - Assess'), findsOneWidget);
      expect(find.text('P - Plan'), findsOneWidget);

      // S Tab is initially selected: verify quick complaint chips
      expect(find.text('Chief Complaint(s) *'), findsOneWidget);
      expect(find.text('Fever'), findsOneWidget);
      expect(find.text('Abdominal Pain'), findsOneWidget);
      expect(find.text('Headache'), findsOneWidget);

      // Tap quick complaint chip 'Fever'
      await tester.tap(find.text('Fever'));
      await tester.pump();
      expect(find.text('Fever'), findsWidgets);

      // Switch to O tab (Objective)
      await tester.tap(find.text('O - Objective'));
      await tester.pumpAndSettle();
      expect(find.text('Vital Signs'), findsOneWidget);
      expect(find.text('Physical & Systemic Examination'), findsOneWidget);

      // Switch to A tab (Assessment)
      await tester.tap(find.text('A - Assess'));
      await tester.pumpAndSettle();
      expect(find.text('Primary Working Diagnosis *'), findsOneWidget);
      expect(find.text('Clinical Assessment & Diagnosis'), findsOneWidget);
      expect(find.text('Essential Hypertension'), findsOneWidget);

      // Switch to P tab (Plan)
      await tester.tap(find.text('P - Plan'));
      await tester.pumpAndSettle();
      expect(find.text('Prescription & Medication Plan'), findsOneWidget);
      expect(
        find.text('Lab Investigations / Diagnostic Tests Ordered'),
        findsOneWidget,
      );
      expect(
        find.text('Dietary & Lifestyle Advice / Precautions'),
        findsOneWidget,
      );
      expect(find.text('Next Follow-up Date'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
