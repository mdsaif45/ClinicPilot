import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp or the dialer for a patient.
///
/// Deliberately a deep link rather than an API integration: it needs no
/// account, no approval and no cost, and it leaves the doctor to press send.
/// Automating clinical outreach would be a consent question, not a UX one.
class ContactService {
  const ContactService._();

  /// Normalises an Indian phone number to the international form WhatsApp
  /// expects. Numbers are entered locally as 10 digits.
  static String? normalisePhone(String raw, {String countryCode = '91'}) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;

    if (digits.length == 10) return '$countryCode$digits';
    if (digits.length == 12 && digits.startsWith(countryCode)) return digits;
    if (digits.length == 11 && digits.startsWith('0')) {
      return '$countryCode${digits.substring(1)}';
    }
    // Anything else is passed through; an unusual number is better handed to
    // WhatsApp than silently dropped.
    return digits;
  }

  /// Suggested follow-up message. Kept short, and phrased as a check-in rather
  /// than a sales prompt.
  static String followUpMessage({
    required String patientName,
    required String clinicName,
  }) {
    return 'Hello $patientName, this is $clinicName. '
        'It has been a while since your last visit. '
        'How are you feeling? If you need a follow-up, we are happy to help.';
  }

  static String reviewRequestMessage({
    required String patientName,
    required String clinicName,
  }) {
    return 'Hello $patientName, thank you for visiting $clinicName. '
        'If the treatment helped, would you mind leaving a short Google '
        'review? It helps other patients find us.';
  }

  static Future<bool> openWhatsApp({
    required String phone,
    String? message,
  }) async {
    final number = normalisePhone(phone);
    if (number == null) return false;

    final uri = Uri.parse(
      'https://wa.me/$number'
      '${message == null ? '' : '?text=${Uri.encodeComponent(message)}'}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> call(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return false;
    return launchUrl(Uri.parse('tel:$digits'));
  }
}
