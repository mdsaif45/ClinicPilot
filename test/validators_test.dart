import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/utils/validators.dart';

void main() {
  group('Validators.age', () {
    test('accepts boundary and typical values', () {
      expect(Validators.age('0'), isNull);
      expect(Validators.age('45'), isNull);
      expect(Validators.age('120'), isNull);
    });

    test('rejects out-of-range values', () {
      expect(Validators.age('121'), isNotNull);
      expect(Validators.age('999'), isNotNull);
    });

    test('rejects non-numeric input', () {
      expect(Validators.age('abc'), isNotNull);
      expect(Validators.age('4a'), isNotNull);
    });

    test('rejects empty or null', () {
      expect(Validators.age(''), isNotNull);
      expect(Validators.age(null), isNotNull);
      expect(Validators.age('   '), isNotNull);
    });

    test('trims surrounding whitespace', () {
      expect(Validators.age(' 30 '), isNull);
    });

    test('message names the accepted range', () {
      expect(Validators.age('200'), contains('0-120'));
    });
  });
}
