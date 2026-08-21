import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/providers/cash_memo_provider.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/finances/presentation/payment_method_breakdown_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Payment Method Breakdown Logic & Provider Tests', () {
    final patient = Patient(
      id: 'p1',
      patientCode: 'P-2026-00001',
      serialNo: '1',
      primaryClinicId: 'c1',
      name: 'Test Patient',
      phone: '9876543210',
      age: 25,
      gender: 'Male',
      primaryDisease: 'Fever',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      reviewGiven: false,
    );

    final clinic = Clinic(
      id: 'c1',
      name: 'Main Clinic',
      address: 'Test Address',
      phone: '9876543210',
      monthlyRent: 10000,
      defaultConsultationFee: 300,
      openDays: '1,3,5',
      colorHex: '#0F5132',
      isActive: true,
      isDeleted: false,
      createdAt: DateTime.now(),
    );

    final testMemos = [
      CashMemoWithDetails(
        memo: CashMemo(
          id: 'm1',
          memoNumber: 'CM-2026-00001',
          patientId: 'p1',
          clinicId: 'c1',
          consultationFee: 500,
          medicineFee: 500,
          otherFee: 0,
          discount: 0,
          total: 1000,
          paidAmount: 1000,
          paymentMethod: 'Cash',
          memoDate: DateTime.now(),
          createdAt: DateTime.now(),
          isDeleted: false,
        ),
        patient: patient,
        clinic: clinic,
      ),
      CashMemoWithDetails(
        memo: CashMemo(
          id: 'm2',
          memoNumber: 'CM-2026-00002',
          patientId: 'p1',
          clinicId: 'c1',
          consultationFee: 1000,
          medicineFee: 1000,
          otherFee: 0,
          discount: 0,
          total: 2000,
          paidAmount: 1500,
          paymentMethod: 'UPI',
          memoDate: DateTime.now(),
          createdAt: DateTime.now(),
          isDeleted: false,
        ),
        patient: patient,
        clinic: clinic,
      ),
      CashMemoWithDetails(
        memo: CashMemo(
          id: 'm3',
          memoNumber: 'CM-2026-00003',
          patientId: 'p1',
          clinicId: 'c1',
          consultationFee: 300,
          medicineFee: 200,
          otherFee: 0,
          discount: 0,
          total: 500,
          paidAmount: 500,
          paymentMethod: 'UPI',
          memoDate: DateTime.now(),
          createdAt: DateTime.now(),
          isDeleted: false,
        ),
        patient: patient,
        clinic: clinic,
      ),
    ];

    testWidgets('calculates and renders payment breakdown properly',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cashMemosStreamProvider.overrideWith(
              (ref) => Stream.value(testMemos),
            ),
            activeClinicProvider.overrideWithValue(null),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PaymentMethodBreakdownScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Total collected: 1000 (Cash) + 1500 (UPI) + 500 (UPI) = 3000
      expect(find.text('₹ 3,000'), findsOneWidget);
      // Total pending: 500
      expect(find.text('₹ 500'), findsOneWidget);
      // UPI and Cash labels
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('2 transactions'), findsOneWidget);
      expect(find.text('1 transaction'), findsOneWidget);
    });
  });
}
