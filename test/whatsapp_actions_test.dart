import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/contact_service.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/whatsapp_template_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactService WhatsApp Templates & Normalization', () {
    test('normalises standard 10-digit Indian phone numbers', () {
      expect(
        ContactService.normalisePhone('9876543210'),
        equals('919876543210'),
      );
      expect(
        ContactService.normalisePhone('+91 98765 43210'),
        equals('919876543210'),
      );
      expect(
        ContactService.normalisePhone('09876543210'),
        equals('919876543210'),
      );
    });

    test('generates follow-up reminder message', () {
      final msg = ContactService.followUpMessage(
        patientName: 'Rahim',
        clinicName: 'Hope Clinic',
      );
      expect(msg, contains('Rahim'));
      expect(msg, contains('Hope Clinic'));
      expect(msg, contains('Following up on your treatment'));
    });

    test('generates health tip message', () {
      final msg = ContactService.healthTipMessage(
        patientName: 'Amina',
        clinicName: 'Health Point',
      );
      expect(msg, contains('Amina'));
      expect(msg, contains('Health Point'));
      expect(msg, contains('clean tongue'));
    });

    test('generates camp invite message', () {
      final msg = ContactService.campInviteMessage(
        patientName: 'Zaid',
        clinicName: 'Healing Touch',
      );
      expect(msg, contains('Zaid'));
      expect(msg, contains('Healing Touch'));
      expect(msg, contains('camp'));
    });

    test('generates review request message', () {
      final msg = ContactService.reviewRequestMessage(
        patientName: 'Fatima',
        clinicName: 'Cure Clinic',
        reviewUrl: 'https://g.page/r/test',
      );
      expect(msg, contains('Fatima'));
      expect(msg, contains('Cure Clinic'));
      expect(msg, contains('https://g.page/r/test'));
    });
  });

  group('WhatsAppTemplatePickerSheet Widget Test', () {
    final testPatient = Patient(
      id: 'pat-1',
      patientCode: 'P-2026-00001',
      serialNo: '101',
      primaryClinicId: 'clinic-1',
      name: 'John Doe',
      phone: '9876543210',
      whatsapp: '9876543210',
      age: 30,
      gender: 'Male',
      primaryDisease: 'Migraine',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      reviewGiven: false,
    );

    testWidgets('renders templates and allows switching selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: WhatsAppTemplatePickerSheet(
              patient: testPatient,
              clinicName: 'Wellness Clinic',
            ),
          ),
        ),
      );

      expect(find.text('Message John Doe'), findsOneWidget);
      expect(find.text('Follow-up Check-in'), findsOneWidget);
      expect(find.text('Health & Dosage Tip'), findsOneWidget);
      expect(find.text('Free Camp / Clinic Invite'), findsOneWidget);
      expect(find.text('Open WhatsApp'), findsOneWidget);

      // Select second template (Health & Dosage Tip)
      await tester.tap(find.text('Health & Dosage Tip'));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
