import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/patient_export_service.dart';
import 'package:clinic_pilot/features/clinical/models/case_record_models.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('PatientExportService Unit & Integration Tests', () {
    test('fetchPatientExportRows aggregates full clinical and financial data per patient', () async {
      final now = DateTime(2026, 8, 15, 10, 30);

      await db.into(db.clinics).insert(
            Clinic(
              id: 'c1',
              name: 'Downtown Homeo Clinic',
              monthlyRent: 12000,
              defaultConsultationFee: 500,
              openDays: 'Mon,Tue,Wed',
              colorHex: '#1976D2',
              isActive: true,
              isDeleted: false,
              createdAt: now,
            ),
          );

      await db.into(db.patients).insert(
            Patient(
              id: 'p1',
              serialNo: '101',
              patientCode: 'P-2026-00101',
              name: 'Fatima Al-Zahra',
              phone: '9849012345',
              whatsapp: '9849012345',
              email: 'fatima@example.com',
              age: 27,
              gender: 'Female',
              occupation: 'Architect',
              area: 'Banjara Hills',
              address: 'Villa 12, Road 10',
              primaryClinicId: 'c1',
              primaryDisease: 'Psoriasis',
              referralSource: 'Instagram',
              reviewAskedAt: now,
              reviewGiven: true,
              notes: 'Severe flare-ups during winter',
              isDeleted: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.complaints).insert(
            Complaint(
              id: 'comp1',
              patientId: 'p1',
              complaintIndex: 1,
              complaintName: 'Skin Scaling & Itching',
              severity: 8,
              status: 'Active',
              isDeleted: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.prescriptions).insert(
            Prescription(
              id: 'rx1',
              patientId: 'p1',
              remedyIndex: 1,
              remedyName: 'Arsenicum Album',
              potency: '200C',
              vehicle: 'Pills',
              doseCount: '4 pills',
              frequency: 'OD',
              durationDays: '15',
              isDeleted: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.investigations).insert(
            Investigation(
              id: 'inv1',
              patientId: 'p1',
              testName: 'IgE Level',
              testCategory: 'Immunology',
              numericValue: 350.0,
              unit: 'kU/L',
              flag: 'High',
              testDate: now,
              isDeleted: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.visits).insert(
            Visit(
              id: 'v1',
              patientId: 'p1',
              clinicId: 'c1',
              visitDate: now,
              disease: 'Psoriasis',
              visitType: 'New',
              consultationType: 'Clinic',
              outcome: 'Improved',
              nextFollowUpDate: now.add(const Duration(days: 14)),
              isDeleted: false,
              createdAt: now,
            ),
          );

      await db.into(db.cashMemos).insert(
            CashMemo(
              id: 'm1',
              memoNumber: 'CM-001',
              patientId: 'p1',
              clinicId: 'c1',
              consultationFee: 500,
              medicineFee: 300,
              otherFee: 0,
              discount: 50,
              total: 750,
              paidAmount: 700,
              paymentMethod: 'UPI',
              memoDate: now,
              isDeleted: false,
              createdAt: now,
            ),
          );

      final exportRows = await PatientExportService.fetchPatientExportRows(db);
      expect(exportRows.length, equals(1));

      final row = exportRows.first;
      expect(row.patient.name, equals('Fatima Al-Zahra'));
      expect(row.clinicName, equals('Downtown Homeo Clinic'));
      expect(row.totalVisits, equals(1));
      expect(row.lastVisitOutcome, equals('Improved'));
      expect(row.activeComplaints, contains('Skin Scaling & Itching (Severity 8/10)'));
      expect(row.lastPrescription, contains('Arsenicum Album 200C (OD)'));
      expect(row.totalInvestigations, equals(1));
      expect(row.totalBilled, equals(750.0));
      expect(row.totalPaid, equals(700.0));
      expect(row.outstandingBalance, equals(50.0));
      expect(row.preferredPaymentMode, equals('UPI'));
    });

    test('buildMultiSheetPatientXlsx produces valid workbook with 9 populated sheets and clinical summaries', () async {
      final now = DateTime(2026, 8, 20);

      await db.into(db.clinics).insert(
            Clinic(
              id: 'c1',
              name: 'Downtown Clinic',
              monthlyRent: 10000,
              defaultConsultationFee: 400,
              openDays: 'Mon,Tue',
              colorHex: '#1976D2',
              isActive: true,
              isDeleted: false,
              createdAt: now,
            ),
          );

      await db.into(db.patients).insert(
            Patient(
              id: 'p1',
              serialNo: '1',
              patientCode: 'P-2026-00001',
              name: 'Dr. Sameer Verma',
              phone: '9811012345',
              age: 50,
              gender: 'Male',
              primaryClinicId: 'c1',
              reviewGiven: false,
              isDeleted: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final caseRecord = MasterCaseRecordData(
        patientId: 'p1',
        recordDate: now,
        chiefComplaints: const [
          ChiefComplaintDetail(
            complaint: 'Chronic Migraine',
            location: 'Right Forehead',
            onset: 'Gradual',
            modalitiesAgg: 'Sun, Noise',
            modalitiesAmel: 'Dark quiet room',
            severity: 'Severe',
          ),
        ],
        hpi: const HpiDetails(chronologicalDevelopment: 'Started 2 years ago after high job stress.'),
        pastHistory: const PastHistoryDetails(majorIllnesses: 'Typhoid (2020)', surgeries: 'None'),
        familyHistory: const FamilyHistoryDetails(father: 'Type 2 Diabetes', mother: 'Hypertension'),
        physicalGenerals: const PhysicalGenerals(
          thermal: 'Chilly',
          thirst: 'Small quantities often',
          appetite: 'Low',
          cravings: 'Sweets, Warm milk',
          aversions: 'Meat',
        ),
        mentalGenerals: const MentalGenerals(
          disposition: 'Anxious, Fastidious',
          fears: 'Heights, Darkness',
        ),
        miasmaticAnalysis: const MiasmaticAnalysis(
          dominantMiasm: 'Psora',
          psoricFeatures: '70% itchy skin',
        ),
        baselinePrescription: const PrescriptionPlanDetails(
          remedyName: 'Lycopodium Clavatum',
          potency: '200C',
          dose: '4 pills',
          repetitionFrequency: 'TDS',
        ),
      );

      await db.into(db.patientCaseRecords).insert(
            PatientCaseRecord(
              id: 'case1',
              patientId: 'p1',
              recordDate: now,
              chiefComplaintsJson: caseRecord.chiefComplaintsJson,
              hpi: caseRecord.hpiPackedJson,
              pastHistoryJson: caseRecord.pastHistoryJson,
              familyHistoryJson: caseRecord.familyHistoryJson,
              physicalGeneralsJson: caseRecord.physicalGeneralsJson,
              mentalGeneralsJson: caseRecord.mentalGeneralsJson,
              miasmaticAnalysisJson: caseRecord.miasmaticAnalysisJson,
              baselinePrescriptionJson: caseRecord.baselinePrescriptionJson,
              isDeleted: false,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final xlsxBytes = await PatientExportService.buildMultiSheetPatientXlsx(db);
      expect(xlsxBytes.isNotEmpty, isTrue);

      final decoded = xlsx.Excel.decodeBytes(xlsxBytes);
      expect(decoded.tables.containsKey('Patients Master'), isTrue);
      expect(decoded.tables.containsKey('Visits History'), isTrue);
      expect(decoded.tables.containsKey('Clinical Complaints'), isTrue);
      expect(decoded.tables.containsKey('Prescriptions History'), isTrue);
      expect(decoded.tables.containsKey('Lab Investigations'), isTrue);
      expect(decoded.tables.containsKey('Billing & Cash Memos'), isTrue);
      expect(decoded.tables.containsKey('Follow-Up Schedule'), isTrue);
      expect(decoded.tables.containsKey('Master Case Records'), isTrue);
      expect(decoded.tables.containsKey('Physical & Mental Generals'), isTrue);
      expect(decoded.tables.containsKey('Walk-in Leads & Footfalls'), isTrue);
    });
  });
}
