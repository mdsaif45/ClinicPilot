import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/utils/formatters.dart';

void main() {
  group('Formatters Unit Tests', () {
    test('Currency formatter formats INR correctly', () {
      final formatted = Formatters.formatCurrency(5000);
      expect(formatted, contains('₹'));
      expect(formatted, contains('5,000'));
    });

    test('Date formatter formats date accurately', () {
      final date = DateTime(2026, 5, 20);
      final formatted = Formatters.formatDate(date);
      expect(formatted, equals('20 May 2026'));
    });

    test('MonthYear formatter formats month accurately', () {
      final date = DateTime(2026, 5, 20);
      final formatted = Formatters.formatMonthYear(date);
      expect(formatted, equals('May 2026'));
    });
  });
}
