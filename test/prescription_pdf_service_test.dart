import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/prescription_pdf_service.dart';
import 'package:clinic_pilot/features/settings/providers/doctor_profile_provider.dart';

void main() {
  group('PrescriptionPdfService Tests', () {
    final testClinic = Clinic(
      id: 'clinic-1',
      name: 'Sunrise Homoeopathic Clinic',
      address: 'Shop 12, Health Plaza, Mumbai',
      phone: '+91 9876543210',
      monthlyRent: 15000,
      defaultConsultationFee: 500,
      openDays: '1,2,3,4,5,6',
      colorHex: '#0F5132',
      isActive: true,
      isDeleted: false,
      createdAt: DateTime(2026, 1, 1),
    );

    final testDoctor = DoctorProfile(
      firstName: 'Anjali',
      lastName: 'Deshmukh',
      name: 'Dr. Anjali Deshmukh',
      qualification: 'B.H.M.S., M.D. (Hom.)',
      regNumber: 'HOM-MH-2018-9942',
      phone: '+91 9820012345',
      email: 'dr.anjali@clinicpilot.com',
    );

    final testPatient = Patient(
      id: 'pat-1',
      patientCode: 'P-2026-00104',
      serialNo: '104',
      name: 'Rohan Mehra',
      phone: '+91 9811122233',
      age: 32,
      gender: 'Male',
      primaryClinicId: 'clinic-1',
      primaryDisease: 'Chronic Sinusitis & Rhinitis',
      reviewGiven: false,
      isDeleted: false,
      createdAt: DateTime(2026, 2, 1),
      updatedAt: DateTime(2026, 2, 1),
    );

    final testPrescriptions = [
      Prescription(
        id: 'rx-1',
        patientId: 'pat-1',
        visitId: 'vis-1',
        prescriptionDate: DateTime(2026, 9, 4),
        isBaseline: true,
        remedyIndex: 1,
        remedyName: 'Arsenicum Album',
        potency: '200 CH',
        doseCount: '4 pills',
        frequency: 'TDS (3 times a day)',
        vehicle: 'Globules No. 30',
        durationDays: '7 days',
        instructions: 'Take 15 mins before meals on a clean tongue',
        dietaryAdvice: 'Avoid raw onion, garlic, and strong coffee',
        isDeleted: false,
        createdAt: DateTime(2026, 9, 4),
        updatedAt: DateTime(2026, 9, 4),
      ),
      Prescription(
        id: 'rx-2',
        patientId: 'pat-1',
        visitId: 'vis-1',
        prescriptionDate: DateTime(2026, 9, 4),
        isBaseline: true,
        remedyIndex: 2,
        remedyName: 'Natrum Muriaticum',
        potency: '30C',
        doseCount: '4 pills',
        frequency: 'BD (Twice a day)',
        vehicle: 'Globules No. 30',
        durationDays: '14 days',
        instructions: 'Night dose before sleep',
        dietaryAdvice: null,
        isDeleted: false,
        createdAt: DateTime(2026, 9, 4),
        updatedAt: DateTime(2026, 9, 4),
      ),
    ];

    final testComplaints = [
      Complaint(
        id: 'cmp-1',
        patientId: 'pat-1',
        visitId: 'vis-1',
        complaintIndex: 1,
        complaintDate: DateTime(2026, 9, 4),
        isBaseline: true,
        complaintName: 'Sneezing fits in morning with thin watery discharge',
        location: 'Nose / Sinuses',
        side: 'Bilateral',
        onset: 'Gradual',
        duration: '3 weeks',
        sensation: 'Burning in nostrils',
        extension: null,
        aggravatingFactors: 'Cold draft, early morning',
        amelioratingFactors: 'Warm room, hot tea',
        concomitants: 'Dull forehead headache',
        causation: null,
        periodicity: 'Daily mornings',
        severity: 8,
        status: 'Active',
        beforeImages: null,
        afterImages: null,
        notes: null,
        isDeleted: false,
        createdAt: DateTime(2026, 9, 4),
        updatedAt: DateTime(2026, 9, 4),
      ),
    ];

    test(
      'generates valid PDF prescription with all clinical details',
      () async {
        final pdfBytes = await PrescriptionPdfService.generatePrescriptionPdf(
          patient: testPatient,
          clinic: testClinic,
          doctorProfile: testDoctor,
          prescriptions: testPrescriptions,
          complaints: testComplaints,
          diagnosis: 'Allergic Rhinitis with Frontal Sinusitis',
          nextFollowUpDate: DateTime(2026, 9, 18),
        );

        expect(pdfBytes, isNotNull);
        expect(pdfBytes.isNotEmpty, isTrue);
        // PDF documents start with '%PDF-' magic bytes
        expect(pdfBytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
      },
    );

    test(
      'generates valid PDF prescription with minimal details (empty complaints/advice)',
      () async {
        final minimalDoctor = DoctorProfile(
          firstName: 'Doctor',
          name: 'Dr. Doctor',
        );

        final pdfBytes = await PrescriptionPdfService.generatePrescriptionPdf(
          patient: testPatient,
          clinic: testClinic,
          doctorProfile: minimalDoctor,
          prescriptions: testPrescriptions,
        );

        expect(pdfBytes, isNotNull);
        expect(pdfBytes.isNotEmpty, isTrue);
        expect(pdfBytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
      },
    );

    test(
      'generates valid PDF prescription with zero prescriptions (advice only)',
      () async {
        final pdfBytes = await PrescriptionPdfService.generatePrescriptionPdf(
          patient: testPatient,
          clinic: testClinic,
          doctorProfile: testDoctor,
          prescriptions: const [],
          additionalAdvice: 'Rest and steam inhalation twice daily.',
        );

        expect(pdfBytes, isNotNull);
        expect(pdfBytes.isNotEmpty, isTrue);
        expect(pdfBytes.sublist(0, 5), equals([0x25, 0x50, 0x44, 0x46, 0x2D]));
      },
    );
  });
}
