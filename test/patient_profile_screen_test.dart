import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/utils/formatters.dart';
import 'package:clinic_pilot/features/cashmemo/providers/cash_memo_provider.dart';
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
      nextFollowUpDate: DateTime(2026, 9, 1),
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
}
