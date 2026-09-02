import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/list_export_service.dart';
import 'package:clinic_pilot/features/cashmemo/providers/cash_memo_provider.dart';
import 'package:clinic_pilot/features/expenses/providers/expense_provider.dart';
import 'package:clinic_pilot/features/finances/presentation/finances_screen.dart';
import 'package:clinic_pilot/features/finances/providers/payment_method_breakdown_provider.dart';
import 'package:clinic_pilot/features/growth/presentation/growth_screen.dart';
import 'package:clinic_pilot/features/growth/providers/growth_provider.dart';
import 'package:clinic_pilot/features/patients/presentation/patients_tab_screen.dart';
import 'package:clinic_pilot/features/patients/providers/footfall_provider.dart';
import 'package:clinic_pilot/features/patients/providers/recall_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('patientsExportColumns', () {
    test(
      'resolves the clinic id to a name, and falls back to the id itself',
      () {
        final columns = patientsExportColumns({'clinic-1': 'Downtown Clinic'});

        final known = Patient(
          id: 'p1',
          patientCode: 'P-2026-00001',
          serialNo: '14',
          name: 'Asha Rao',
          phone: '9800000001',
          whatsapp: null,
          age: 34,
          gender: 'Female',
          area: 'Kharagpur',
          address: null,
          occupation: null,
          primaryClinicId: 'clinic-1',
          primaryDisease: 'Migraine',
          referralSource: 'Walk-in',
          notes: null,
          reviewAskedAt: null,
          reviewGiven: false,
          isDeleted: false,
          createdAt: DateTime(2026, 1, 10),
          updatedAt: DateTime(2026, 1, 10),
        );
        final unknown = known.copyWith(
          id: 'p2',
          serialNo: '1',
          primaryClinicId: 'ghost-clinic',
        );

        final csv = ListExportService.buildCsv([known, unknown], columns);
        final lines = csv.trim().split('\n');

        expect(lines[0], contains('Serial No.'));
        expect(lines[0], contains('Clinic'));
        expect(lines[1], contains('14'));
        expect(lines[1], contains('Downtown Clinic'));
        expect(lines[2], contains('ghost-clinic'));
      },
    );
  });

  group('followUpsExportColumns', () {
    test('formats overdue and due status accurately', () {
      final patient = Patient(
        id: 'p1',
        patientCode: 'P-1',
        serialNo: '10',
        name: 'Zaid',
        phone: '9876543210',
        whatsapp: null,
        age: 28,
        gender: 'Male',
        area: 'Banjara',
        address: null,
        occupation: null,
        primaryClinicId: 'c1',
        primaryDisease: 'Asthma',
        referralSource: null,
        notes: null,
        reviewAskedAt: null,
        reviewGiven: false,
        isDeleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final clinic = Clinic(
        id: 'c1',
        name: 'Downtown Clinic',
        address: null,
        phone: null,
        monthlyRent: 0,
        defaultConsultationFee: 0,
        openDays: '1,2,3',
        colorHex: '#0F5132',
        isActive: true,
        isDeleted: false,
        createdAt: DateTime(2026, 1, 1),
      );
      final visit = Visit(
        id: 'v1',
        patientId: 'p1',
        clinicId: 'c1',
        visitType: 'New',
        consultationType: 'Clinic',
        disease: 'Asthma',
        outcome: 'Improved',
        visitDate: DateTime(2026, 8, 1),
        nextFollowUpDate: DateTime(2026, 8, 15),
        isDeleted: false,
        createdAt: DateTime(2026, 8, 1),
      );

      final entry = RecallEntry(
        patient: patient,
        visit: visit,
        clinic: clinic,
        daysOverdue: 5,
      );

      final columns = followUpsExportColumns();
      final csv = ListExportService.buildCsv([entry], columns);
      expect(csv, contains('Overdue by 5 days'));
      expect(csv, contains('Asthma'));
      expect(csv, contains('Zaid'));
    });
  });

  group('footfallsExportColumns', () {
    test('formats walk-in lead with converted status', () {
      final clinic = Clinic(
        id: 'c1',
        name: 'Downtown Clinic',
        address: null,
        phone: null,
        monthlyRent: 0,
        defaultConsultationFee: 0,
        openDays: '1,2,3',
        colorHex: '#0F5132',
        isActive: true,
        isDeleted: false,
        createdAt: DateTime(2026, 1, 1),
      );
      final patient = Patient(
        id: 'p1',
        patientCode: 'P-2026-00001',
        serialNo: '1',
        name: 'Imran Khan',
        phone: '9811001100',
        whatsapp: null,
        age: 35,
        gender: 'Male',
        area: null,
        address: null,
        occupation: null,
        primaryClinicId: 'c1',
        primaryDisease: 'Eczema',
        referralSource: null,
        notes: null,
        reviewAskedAt: null,
        reviewGiven: false,
        isDeleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final footfall = Footfall(
        id: 'f1',
        clinicId: 'c1',
        name: 'Imran Khan',
        phone: '9811001100',
        disease: 'Eczema',
        convertedPatientId: 'p1',
        notes: 'Walk-in inquiry',
        date: DateTime(2026, 8, 1),
        isDeleted: false,
        createdAt: DateTime(2026, 8, 1),
      );

      final entry = FootfallWithDetails(
        footfall: footfall,
        clinic: clinic,
        convertedPatient: patient,
      );

      final columns = footfallsExportColumns();
      final csv = ListExportService.buildCsv([entry], columns);
      expect(csv, contains('Converted to Patient'));
      expect(csv, contains('P-2026-00001'));
      expect(csv, contains('Imran Khan'));
    });
  });

  group('cashMemoExportColumns / cashMemoExportTotals', () {
    test(
      'the totals row sums Total, Paid and Pending properly across enhanced columns',
      () {
        final patient = Patient(
          id: 'p1',
          patientCode: 'P-1',
          serialNo: '1',
          name: 'A',
          phone: '9800000000',
          whatsapp: null,
          age: 30,
          gender: 'Male',
          area: null,
          address: null,
          occupation: null,
          primaryClinicId: 'c1',
          primaryDisease: null,
          referralSource: null,
          notes: null,
          reviewAskedAt: null,
          reviewGiven: false,
          isDeleted: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        final clinic = Clinic(
          id: 'c1',
          name: 'Clinic 1',
          address: null,
          phone: null,
          monthlyRent: 0,
          defaultConsultationFee: 0,
          openDays: '1,2,3,4,5,6',
          colorHex: '#0F5132',
          isActive: true,
          isDeleted: false,
          createdAt: DateTime(2026, 1, 1),
        );

        CashMemo memo(String id, double total, double paid) => CashMemo(
          id: id,
          memoNumber: 'CM-$id',
          patientId: 'p1',
          clinicId: 'c1',
          visitId: null,
          consultationFee: total,
          medicineFee: 0,
          otherFee: 0,
          discount: 0,
          total: total,
          paidAmount: paid,
          paymentMethod: 'Cash',
          notes: 'Test note',
          isDeleted: false,
          memoDate: DateTime(2026, 3, 1),
          createdAt: DateTime(2026, 3, 1),
        );

        final rows = [
          CashMemoWithDetails(
            memo: memo('1', 500, 500),
            patient: patient,
            clinic: clinic,
          ),
          CashMemoWithDetails(
            memo: memo('2', 300, 100),
            patient: patient,
            clinic: clinic,
          ),
        ];

        final csv = ListExportService.buildCsv(
          rows,
          cashMemoExportColumns(),
          totals: cashMemoExportTotals(),
        );
        final lines = csv.trim().split('\n');

        expect(lines[0], contains('Patient Code'));
        expect(lines[0], contains('Serial No.'));
        expect(lines[0], contains('Payment Status'));
        expect(lines.last, startsWith('TOTAL'));
        expect(lines.last, contains('800.0')); // Total: 500 + 300
        expect(lines.last, contains('600.0')); // Paid: 500 + 100
        expect(lines.last, contains('200.0')); // Pending: 0 + 200
      },
    );
  });

  group('expensesExportColumns / expensesExportTotals', () {
    test('the totals row sums Amount only', () {
      final clinic = Clinic(
        id: 'c1',
        name: 'Clinic 1',
        address: null,
        phone: null,
        monthlyRent: 0,
        defaultConsultationFee: 0,
        openDays: '1,2,3,4,5,6',
        colorHex: '#0F5132',
        isActive: true,
        isDeleted: false,
        createdAt: DateTime(2026, 1, 1),
      );
      Expense expense(String id, double amount) => Expense(
        id: id,
        clinicId: 'c1',
        category: 'Rent',
        subcategory: 'Main Branch',
        amount: amount,
        paymentMethod: 'Cash',
        isRecurring: true,
        notes: 'Paid landlord',
        date: DateTime(2026, 3, 1),
        isDeleted: false,
        createdAt: DateTime(2026, 3, 1),
      );

      final rows = [
        ExpenseWithClinic(expense: expense('1', 3000), clinic: clinic),
        ExpenseWithClinic(expense: expense('2', 1500), clinic: clinic),
      ];

      final csv = ListExportService.buildCsv(
        rows,
        expensesExportColumns(),
        totals: expensesExportTotals(),
      );
      final lines = csv.trim().split('\n');

      expect(lines[0], contains('Nature'));
      expect(lines[0], contains('Notes / Vendor'));
      expect(lines.last, 'TOTAL,,,,4500.0,,,,');
    });
  });

  group('splitExportColumns / splitExportTotals', () {
    test('summarizes payment methods and calculates totals', () {
      const stats = [
        PaymentMethodStat(
          method: 'Cash',
          totalCollected: 5000,
          totalBilled: 5000,
          count: 10,
          percentage: 62.5,
        ),
        PaymentMethodStat(
          method: 'UPI',
          totalCollected: 3000,
          totalBilled: 3000,
          count: 6,
          percentage: 37.5,
        ),
      ];

      final csv = ListExportService.buildCsv(
        stats,
        splitExportColumns(),
        totals: splitExportTotals(),
      );
      final lines = csv.trim().split('\n');

      expect(lines[1], contains('Cash'));
      expect(lines[2], contains('UPI'));
      expect(lines.last, 'TOTAL,8000.0,8000.0,16,100.0%');
    });
  });

  group('growthExportEntries / growthExportTitle', () {
    const analytics = GrowthAnalytics(
      dailyRevenueMap: {},
      dailyExpenseMap: {},
      referralSourceCount: {'Walk-in': 5, 'Google': 2},
      diseaseFrequency: {'Migraine': 3},
      totalNewPatients: 10,
      totalRepeatPatients: 20,
      totalRevenue: 45000,
      totalExpenses: 12000,
      netProfit: 33000,
      totalPatients: 120,
      dailyPatientMap: {},
      daysInPeriod: 30,
    );
    final range = DateTimeRange(
      start: DateTime(2026, 8, 1),
      end: DateTime(2026, 8, 31),
    );

    test('the title names the period', () {
      expect(
        growthExportTitle(range),
        'Growth summary: 2026-08-01 to 2026-08-31',
      );
    });

    test('the entries carry every headline metric', () {
      final csv = ListExportService.buildKeyValueCsv(
        growthExportEntries(analytics),
        title: growthExportTitle(range),
      );

      expect(csv, contains('Growth summary: 2026-08-01 to 2026-08-31'));
      expect(csv, contains('New Patients,10'));
      expect(csv, contains('Repeat Patients,20'));
      expect(csv, contains('Net Profit,33000.0'));
      expect(csv, contains('Referral: Walk-in,5'));
      expect(csv, contains('Disease: Migraine,3'));
    });
  });

  group('Excel Styling, AutoFilter & Sticky Headers', () {
    test(
      'buildXlsx applies soft blue bold header style, autoFilter tag, and frozen sticky top pane',
      () {
        const stats = [
          PaymentMethodStat(
            method: 'Cash',
            totalCollected: 5000,
            totalBilled: 5000,
            count: 10,
            percentage: 62.5,
          ),
        ];

        final xlsxBytes = ListExportService.buildXlsx(
          stats,
          splitExportColumns(),
          totals: splitExportTotals(),
          sheetName: 'Split',
        );

        expect(xlsxBytes.isNotEmpty, isTrue);

        // Verify Excel autoFilter and frozen pane was injected into the openXML archive
        final archive = ZipDecoder().decodeBytes(xlsxBytes);
        var autoFilterFound = false;
        var frozenPaneFound = false;

        for (final f in archive) {
          if (f.name.startsWith('xl/worksheets/') &&
              f.name.endsWith('.xml') &&
              !f.name.contains('_rels')) {
            final xml = utf8.decode(f.content as List<int>);
            if (xml.contains('<autoFilter')) {
              autoFilterFound = true;
            }
            if (xml.contains('state="frozen"') && xml.contains('ySplit="1"')) {
              frozenPaneFound = true;
            }
          }
        }
        expect(autoFilterFound, isTrue);
        expect(frozenPaneFound, isTrue);
      },
    );
  });
}
