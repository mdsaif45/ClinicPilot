import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/utils/formatters.dart';
import 'package:clinic_pilot/features/cashmemo/providers/cash_memo_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/complaint_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/investigation_provider.dart';
import 'package:clinic_pilot/features/clinical/providers/prescription_provider.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/patients/presentation/patient_profile_screen.dart';
import 'package:clinic_pilot/features/visits/providers/visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testPatient = Patient(
    id: 'p-1',
    patientCode: 'P-2026-00001',
    serialNo: '101',
    name: 'Saifuddin',
    phone: '9876543210',
    whatsapp: '9876543210',
    age: 28,
    gender: 'Male',
    area: 'Dhanbad',
    address: 'Near Station Road',
    occupation: 'Software Engineer',
    primaryClinicId: 'c-1',
    primaryDisease: 'Gastritis',
    referralSource: 'Direct Walk-in',
    notes: 'Mild acidity symptoms after meals',
    reviewGiven: false,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testClinic = Clinic(
    id: 'c-1',
    name: 'Main Clinic Dhanbad',
    address: 'Bank More',
    phone: '9876543210',
    monthlyRent: 15000,
    defaultConsultationFee: 300,
    openDays: 'Mon,Tue,Wed',
    colorHex: '#00796B',
    isActive: true,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  final testVisit = VisitWithDetails(
    visit: Visit(
      id: 'v-1',
      patientId: 'p-1',
      clinicId: 'c-1',
      visitType: 'new',
      consultationType: 'clinic',
      disease: 'Gastritis',
      chiefComplaint: 'Stomach burning after dinner',
      outcome: 'improved',
      nextFollowUpDate: DateTime.now().add(const Duration(days: 7)),
      visitDate: DateTime(2026, 8, 1),
      isDeleted: false,
      createdAt: DateTime(2026, 8, 1),
    ),
    patient: testPatient,
    clinic: testClinic,
  );

  final testMemo = CashMemoWithDetails(
    memo: CashMemo(
      id: 'm-1',
      memoNumber: 'MEMO-001',
      clinicId: 'c-1',
      patientId: 'p-1',
      consultationFee: 300,
      medicineFee: 200,
      otherFee: 0,
      discount: 0,
      total: 500,
      paidAmount: 400,
      paymentMethod: 'UPI',
      memoDate: DateTime(2026, 8, 1),
      isDeleted: false,
      createdAt: DateTime(2026, 8, 1),
    ),
    patient: testPatient,
    clinic: testClinic,
  );

  testWidgets('PatientProfileScreen renders header, metrics, and segmented tabs',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patientVisitsStreamProvider('p-1')
              .overrideWith((ref) => Stream.value([testVisit])),
          cashMemosStreamProvider
              .overrideWith((ref) => Stream.value([testMemo])),
          clinicsStreamProvider
              .overrideWith((ref) => Stream.value([testClinic])),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: PatientProfileScreen(patient: testPatient),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Header checks
    expect(find.text('Saifuddin'), findsWidgets);
    expect(find.text('P-2026-00001'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
    expect(find.text('Main Clinic Dhanbad'), findsWidgets);
    expect(find.text('Dhanbad'), findsWidgets);
    expect(find.text('Male, 28y'), findsOneWidget);

    // Metrics checks
    expect(find.text('Visits'), findsWidgets);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Lifetime'), findsOneWidget);
    expect(find.text('Avg bill'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    // ChipRow checks
    expect(find.text('Gastritis'), findsWidgets);
    expect(find.text('Direct Walk-in'), findsOneWidget);

    // Segmented tab default: Information
    expect(find.text('Information'), findsOneWidget);
    expect(find.text('Software Engineer'), findsOneWidget);
    expect(find.text('Near Station Road'), findsOneWidget);

    // Tap Complaints tab icon (healing_outlined)
    await tester.tap(find.byIcon(Icons.healing_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No complaints logged'), findsWidgets);

    // Tap Master Case Sheet tab icon (assignment_outlined)
    await tester.tap(find.byIcon(Icons.assignment_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Master Clinical Case Record'), findsWidgets);

    // Tap Prescriptions tab icon (medication_outlined)
    await tester.tap(find.byIcon(Icons.medication_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No prescriptions logged'), findsWidgets);

    // Tap Investigations tab icon (biotech_outlined)
    await tester.tap(find.byIcon(Icons.biotech_outlined));
    await tester.pumpAndSettle();
    expect(find.text('No lab tests recorded'), findsWidgets);

    // Tap Visits tab icon
    await tester.tap(find.byIcon(Icons.timeline));
    await tester.pumpAndSettle();
    expect(find.text('New Visit'), findsOneWidget);
    expect(find.text('Improved'), findsOneWidget);
    expect(find.text('Stomach burning after dinner'), findsOneWidget);

    // Tap Payments tab icon
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.text('MEMO-001'), findsOneWidget);
    expect(find.text('Pending ${Formatters.formatCurrency(100)}'), findsOneWidget);

    // Tap Follow-ups tab icon
    await tester.tap(find.byIcon(Icons.event_repeat_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming'), findsOneWidget);

    // Tap Insights tab icon
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Visit breakdown'), findsOneWidget);
    expect(find.text('Total visits'), findsOneWidget);
  });

  testWidgets('PatientProfileScreen renders populated clinical complaints, Rx, lab tests, and case sheet tabs without errors',
      (tester) async {
    final testComplaint1 = Complaint(
      id: 'c-1',
      patientId: 'p-1',
      complaintIndex: 1,
      complaintDate: DateTime(2026, 8, 1),
      isBaseline: true,
      complaintName: 'Acid Peptic Disease / GERD',
      location: 'Epigastrium',
      severity: 8,
      status: 'Active',
      isDeleted: false,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

    final testComplaint2 = Complaint(
      id: 'c-2',
      patientId: 'p-1',
      complaintIndex: 2,
      complaintDate: null, // Legacy row with null date to verify backward compatibility
      isBaseline: null, // Legacy row with null isBaseline
      complaintName: 'Recurrent Allergic Sinusitis',
      location: 'Nose & Forehead',
      severity: 5,
      status: 'Improving',
      isDeleted: false,
      createdAt: DateTime(2026, 8, 10),
      updatedAt: DateTime(2026, 8, 10),
    );

    final testRx = Prescription(
      id: 'rx-1',
      patientId: 'p-1',
      prescriptionDate: null, // Legacy row with null date
      isBaseline: null, // Legacy row with null isBaseline
      remedyIndex: 1,
      remedyName: 'Nux Vomica',
      potency: '200CH',
      doseCount: '4 Pills',
      frequency: 'Bedtime',
      isDeleted: false,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

    final testInv = Investigation(
      id: 'inv-1',
      patientId: 'p-1',
      testDate: null, // Legacy row with null date
      isBaseline: null, // Legacy row with null isBaseline
      testCategory: 'Blood / Biochemistry',
      testName: 'Serum Creatinine',
      numericValue: 1.1,
      unit: 'mg/dL',
      flag: 'Normal',
      isDeleted: false,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patientVisitsStreamProvider('p-1')
              .overrideWith((ref) => Stream.value([testVisit])),
          cashMemosStreamProvider
              .overrideWith((ref) => Stream.value([testMemo])),
          clinicsStreamProvider
              .overrideWith((ref) => Stream.value([testClinic])),
          patientComplaintsProvider('p-1')
              .overrideWith((ref) => Stream.value([testComplaint1, testComplaint2])),
          patientPrescriptionsProvider('p-1')
              .overrideWith((ref) => Stream.value([testRx])),
          patientInvestigationsProvider('p-1')
              .overrideWith((ref) => Stream.value([testInv])),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: PatientProfileScreen(patient: testPatient),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Switch to Complaints Tab
    await tester.tap(find.byIcon(Icons.healing_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Acid Peptic Disease / GERD'), findsOneWidget);
    expect(find.text('Recurrent Allergic Sinusitis'), findsOneWidget);

    // 2. Switch to Prescriptions Tab
    await tester.tap(find.byIcon(Icons.medication_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Nux Vomica'), findsOneWidget);
    expect(find.text('200CH'), findsOneWidget);

    // 3. Switch to Investigations Tab
    await tester.tap(find.byIcon(Icons.biotech_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Serum Creatinine'), findsWidgets);
    expect(find.text('NORMAL'), findsOneWidget);

    // 4. Switch to Case Sheet Tab
    await tester.tap(find.byIcon(Icons.assignment_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Master Clinical Case Record'), findsOneWidget);
  });

  testWidgets('PatientProfileScreen dynamically updates FAB per tab and opens ScheduleFollowUpDialog on Follow-ups tab',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          patientVisitsStreamProvider('p-1')
              .overrideWith((ref) => Stream.value([testVisit])),
          cashMemosStreamProvider
              .overrideWith((ref) => Stream.value([testMemo])),
          clinicsStreamProvider
              .overrideWith((ref) => Stream.value([testClinic])),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: PatientProfileScreen(patient: testPatient),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Default Tab (Information): FAB says Add Visit
    expect(find.text('Add Visit'), findsOneWidget);

    // Switch to Follow-ups tab
    await tester.tap(find.byIcon(Icons.event_repeat_outlined));
    await tester.pumpAndSettle();

    // FAB now dynamically switches to Schedule Follow-up
    expect(find.text('Schedule Follow-up'), findsOneWidget);

    // Tap Schedule Follow-up FAB
    await tester.tap(find.text('Schedule Follow-up'));
    await tester.pumpAndSettle();

    // Verify ScheduleFollowUpDialog is shown with Quick presets and Target Date field
    expect(find.text('Schedule Follow-up: Saifuddin'), findsOneWidget);
    expect(find.text('Quick Follow-up Interval'), findsOneWidget);
    expect(find.text('+7 Days (1 Wk)'), findsOneWidget);
    expect(find.text('+15 Days (2 Wks)'), findsOneWidget);
    expect(find.text('Target Follow-up Date *'), findsOneWidget);
    expect(find.text('Review Objective / Notes'), findsOneWidget);
    expect(find.text('Save Schedule'), findsOneWidget);
  });
}
