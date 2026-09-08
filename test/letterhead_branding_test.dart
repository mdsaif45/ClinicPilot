import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/prescription_pdf_service.dart';
import 'package:clinic_pilot/features/settings/providers/doctor_profile_provider.dart';
import 'package:clinic_pilot/features/settings/services/letterhead_branding.dart';

/// A minimal valid 1x1 PNG, enough for the PDF encoder to embed.
final _pngBytes = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('LetterheadBranding model', () {
    test('none carries no images', () {
      expect(LetterheadBranding.none.hasLogo, isFalse);
      expect(LetterheadBranding.none.hasSignature, isFalse);
      expect(LetterheadBranding.none.isEmpty, isTrue);
    });

    test('an empty byte list does not count as an image', () {
      final branding = LetterheadBranding(
        logo: Uint8List(0),
        signature: Uint8List(0),
      );
      expect(branding.hasLogo, isFalse);
      expect(branding.hasSignature, isFalse);
      expect(branding.isEmpty, isTrue);
    });

    test('logo and signature are independent', () {
      final logoOnly = LetterheadBranding(logo: _pngBytes);
      expect(logoOnly.hasLogo, isTrue);
      expect(logoOnly.hasSignature, isFalse);
      expect(logoOnly.isEmpty, isFalse);
    });
  });

  group('LetterheadBranding.effective — the Pro gate', () {
    final stored = LetterheadBranding(logo: _pngBytes, signature: _pngBytes);

    test('an unlocked practice prints its branding', () {
      final result = LetterheadBranding.effective(
        stored: stored,
        unlocked: true,
      );
      expect(result.hasLogo, isTrue);
      expect(result.hasSignature, isTrue);
    });

    test('a locked practice silently reverts to the plain letterhead', () {
      final result = LetterheadBranding.effective(
        stored: stored,
        unlocked: false,
      );
      // Uploads are kept on disk — only the printing is gated, so a lapsed
      // subscription does not strand the doctor's images.
      expect(result.isEmpty, isTrue);
      expect(stored.hasLogo, isTrue);
    });

    test('unlocking with nothing stored still prints plain', () {
      final result = LetterheadBranding.effective(
        stored: LetterheadBranding.none,
        unlocked: true,
      );
      expect(result.isEmpty, isTrue);
    });
  });

  group('PrescriptionPdfService with branding', () {
    Future<(Patient, Clinic)> seed() async {
      await db
          .into(db.clinics)
          .insert(ClinicsCompanion.insert(id: 'c1', name: 'Homeo Care'));
      await db
          .into(db.patients)
          .insert(
            PatientsCompanion.insert(
              id: 'p1',
              name: 'Rahul Sharma',
              phone: '9876543210',
              gender: 'Male',
              age: 34,
              primaryClinicId: const Value('c1'),
            ),
          );
      final clinic =
          await (db.select(db.clinics)
            ..where((t) => t.id.equals('c1'))).getSingle();
      final patient =
          await (db.select(db.patients)
            ..where((t) => t.id.equals('p1'))).getSingle();
      return (patient, clinic);
    }

    Future<void> seedPrescription() async {
      await db
          .into(db.prescriptions)
          .insert(
            PrescriptionsCompanion.insert(
              id: 'rx1',
              patientId: 'p1',
              remedyName: 'Arnica Montana',
              potency: '200C',
            ),
          );
    }

    test('renders without branding, as it always has', () async {
      final (patient, clinic) = await seed();
      await seedPrescription();
      final rx = await db.select(db.prescriptions).get();

      final bytes = await PrescriptionPdfService.generatePrescriptionPdf(
        patient: patient,
        clinic: clinic,
        doctorProfile: const DoctorProfile(name: 'Dr. Mehta'),
        prescriptions: rx,
      );

      expect(bytes, isNotEmpty);
    });

    test('renders with a logo and signature embedded', () async {
      final (patient, clinic) = await seed();
      await seedPrescription();
      final rx = await db.select(db.prescriptions).get();

      final plain = await PrescriptionPdfService.generatePrescriptionPdf(
        patient: patient,
        clinic: clinic,
        doctorProfile: const DoctorProfile(name: 'Dr. Mehta'),
        prescriptions: rx,
      );

      final branded = await PrescriptionPdfService.generatePrescriptionPdf(
        patient: patient,
        clinic: clinic,
        doctorProfile: const DoctorProfile(name: 'Dr. Mehta'),
        prescriptions: rx,
        branding: LetterheadBranding(logo: _pngBytes, signature: _pngBytes),
      );

      expect(branded, isNotEmpty);
      // The embedded images make the branded document larger; if they were
      // silently dropped the two would be the same size.
      expect(branded.length, greaterThan(plain.length));
    });

    test('a gated (empty) branding produces the plain document', () async {
      final (patient, clinic) = await seed();
      await seedPrescription();
      final rx = await db.select(db.prescriptions).get();

      final plain = await PrescriptionPdfService.generatePrescriptionPdf(
        patient: patient,
        clinic: clinic,
        doctorProfile: const DoctorProfile(name: 'Dr. Mehta'),
        prescriptions: rx,
      );
      final gated = await PrescriptionPdfService.generatePrescriptionPdf(
        patient: patient,
        clinic: clinic,
        doctorProfile: const DoctorProfile(name: 'Dr. Mehta'),
        prescriptions: rx,
        branding: LetterheadBranding.effective(
          stored: LetterheadBranding(logo: _pngBytes, signature: _pngBytes),
          unlocked: false,
        ),
      );

      // Same content, so the same size — the gate really did drop the images.
      expect(gated.length, equals(plain.length));
    });
  });
}
