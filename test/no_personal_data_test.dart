import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ClinicPilot is a general-purpose app, not one practice's internal tool.
///
/// Sample names had been used as form placeholders and as a fallback clinic
/// name on the printed receipt, so a different doctor saw - and could print -
/// somebody else's details. This keeps them from coming back the next time a
/// realistic-looking example is wanted.
void main() {
  test('no real names, clinics or localities are baked into the app', () {
    final offenders = <String>[];

    final personal = RegExp(
      r"(Zaid|Khidderpore|Khidirpur|Babu\s*Bazar|Babubazar)",
      caseSensitive: false,
    );

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final path = entity.path.replaceAll(r'\', '/');
      // Generated code and explicit demo data seeder hold test/demo records.
      if (path.endsWith('.g.dart') || path.endsWith('sample_data_seeder.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (personal.hasMatch(lines[i])) {
          offenders.add('$path:${i + 1}  ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Use a neutral example, or leave the hint empty and let the '
          'label carry the meaning:\n${offenders.join('\n')}',
    );
  });
}
