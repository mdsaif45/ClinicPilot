import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/services/contact_service.dart';

void main() {
  group('ContactService.normalisePhone', () {
    test('adds the country code to a 10 digit local number', () {
      expect(ContactService.normalisePhone('9800000001'), '919800000001');
    });

    test('strips spaces, dashes and brackets', () {
      expect(ContactService.normalisePhone('98000 00001'), '919800000001');
      expect(ContactService.normalisePhone('98000-00001'), '919800000001');
      expect(ContactService.normalisePhone('(98000) 00001'), '919800000001');
    });

    test('leaves an already prefixed number alone', () {
      expect(ContactService.normalisePhone('919800000001'), '919800000001');
      expect(ContactService.normalisePhone('+91 98000 00001'), '919800000001');
    });

    test('drops a leading zero', () {
      expect(ContactService.normalisePhone('09800000001'), '919800000001');
    });

    test('returns null for input with no digits', () {
      expect(ContactService.normalisePhone(''), isNull);
      expect(ContactService.normalisePhone('not a number'), isNull);
    });
  });

  group('message templates', () {
    test('follow-up names the patient and the clinic', () {
      final msg = ContactService.followUpMessage(
        patientName: 'Fatima',
        clinicName: 'Old Clinic',
      );
      expect(msg, contains('Fatima'));
      expect(msg, contains('Old Clinic'));
    });

    test('follow-up reads as a check-in, not a sales prompt', () {
      final msg = ContactService.followUpMessage(
        patientName: 'Fatima',
        clinicName: 'Old Clinic',
      );
      expect(msg.toLowerCase(), contains('how are you feeling'));
      expect(msg.toLowerCase(), isNot(contains('offer')));
      expect(msg.toLowerCase(), isNot(contains('discount')));
    });

    test('review request names the patient and the clinic', () {
      final msg = ContactService.reviewRequestMessage(
        patientName: 'Rahman',
        clinicName: 'New Clinic',
      );
      expect(msg, contains('Rahman'));
      expect(msg, contains('New Clinic'));
      expect(msg.toLowerCase(), contains('review'));
    });
  });
}
