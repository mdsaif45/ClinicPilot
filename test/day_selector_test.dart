import 'package:clinic_pilot/core/widgets/day_selector_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DaySelectorField stored format', () {
    test('parses the stored comma list', () {
      expect(DaySelectorField.parse('1,3,5'), {1, 3, 5});
    });

    test('tolerates spacing and ignores junk', () {
      // The value used to be typed by hand, so old rows may hold anything.
      expect(DaySelectorField.parse(' 2 , 4 ,x, 9 , 6 '), {2, 4, 6},
          reason: 'out-of-range and unparsable entries are dropped');
    });

    test('formats ascending regardless of tap order', () {
      expect(DaySelectorField.format({5, 1, 3}), '1,3,5');
    });

    test('round-trips', () {
      const raw = '2,4,6';
      expect(DaySelectorField.format(DaySelectorField.parse(raw)), raw);
    });

    test('describes days by name', () {
      expect(DaySelectorField.describe('1,3,5'), 'Mon, Wed, Fri');
      expect(DaySelectorField.describe('1,2,3,4,5,6,7'), 'Every day');
      expect(DaySelectorField.describe(''), 'Not set');
    });

    test('1 is Monday, matching DateTime.weekday', () {
      // clinic_comparison_provider counts open days with
      // openDaysList.contains(day.weekday), so the mapping must agree.
      final monday = DateTime(2026, 3, 2);
      expect(monday.weekday, 1);
      expect(DaySelectorField.describe('${monday.weekday}'), 'Mon');
    });
  });
}
