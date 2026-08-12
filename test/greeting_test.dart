import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/utils/formatters.dart';

void main() {
  group('Formatters.greeting', () {
    String at(int hour) => Formatters.greeting(DateTime(2026, 8, 12, hour));

    test('early hours read as night', () {
      expect(at(0), 'Good Night');
      expect(at(4), 'Good Night');
    });

    test('morning runs to noon', () {
      expect(at(5), 'Good Morning');
      expect(at(11), 'Good Morning');
    });

    test('afternoon runs to 5pm', () {
      expect(at(12), 'Good Afternoon');
      expect(at(16), 'Good Afternoon');
    });

    test('evening covers clinic hours', () {
      // The clinics open 6:30-9:30pm, so this is the greeting the doctor
      // sees most often.
      expect(at(17), 'Good Evening');
      expect(at(18), 'Good Evening');
      expect(at(20), 'Good Evening');
    });

    test('late night after 9pm', () {
      expect(at(21), 'Good Night');
      expect(at(23), 'Good Night');
    });

    test('never returns the old fixed placeholder', () {
      for (var h = 0; h < 24; h++) {
        expect(at(h), isNot('Good Day'));
      }
    });
  });

  group('Formatters.formatFullDate', () {
    test('includes day, month, year and weekday', () {
      final s = Formatters.formatFullDate(DateTime(2025, 5, 20));
      expect(s, contains('20'));
      expect(s, contains('May'));
      expect(s, contains('2025'));
      expect(s, contains('Tuesday'));
    });
  });
}
