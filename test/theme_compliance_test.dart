import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the rule that made palettes look broken: a screen that names a
/// colour directly stops following the active theme, so switching to
/// Monochrome left teal icons behind.
void main() {
  test('no hardcoded colours outside the theme and design layers', () {
    final offenders = <String>[];

    final namedColour = RegExp(
      r'\bColors\.(red|blue|teal|green|orange|purple|amber|grey|white|black|'
      r'indigo|cyan|pink|lime|brown|deepOrange|redAccent|blueAccent|black87)\b',
    );
    final hexColour = RegExp(r'Color\(0x[Ff][Ff]');

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final path = entity.path.replaceAll(r'\', '/');
      // The theme and design layers define the palette, and a PDF renderer
      // draws to paper, not a screen - the active theme has no meaning
      // there, so its own fixed colours are correct rather than a bug.
      if (path.contains('core/theme/') ||
          path.contains('core/design/') ||
          path.contains('pdf_service') ||
          path.contains('pdf_export_service')) {
        continue;
      }

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (namedColour.hasMatch(line) || hexColour.hasMatch(line)) {
          offenders.add('$path:${i + 1}  ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Resolve colours from Theme.of(context).colorScheme instead:\n'
          '${offenders.join('\n')}',
    );
  });
}
