import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clinic_pilot/core/design/app_palette.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';

void main() {
  // GoogleFonts would otherwise attempt a network fetch during tests.
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppPalette', () {
    test('every palette has a distinct seed colour', () {
      // Regression guard: an earlier version used one fixed seed for every
      // variant, so all palettes rendered as shades of the same green.
      final seeds = AppPalette.values.map((p) => p.seed).toSet();
      expect(seeds.length, AppPalette.values.length);
    });

    test('all nine reference palettes plus the brand default exist', () {
      expect(AppPalette.values.length, 10);
    });

    test('fromName round-trips and falls back to emerald', () {
      for (final p in AppPalette.values) {
        expect(AppPalette.fromName(p.name), p);
      }
      expect(AppPalette.fromName('nonsense'), AppPalette.emerald);
      expect(AppPalette.fromName(null), AppPalette.emerald);
    });
  });

  group('AppThemeMode', () {
    test('maps to the matching ThemeMode', () {
      expect(AppThemeMode.system.material, ThemeMode.system);
      expect(AppThemeMode.light.material, ThemeMode.light);
      expect(AppThemeMode.dark.material, ThemeMode.dark);
    });

    test('fromName falls back to system', () {
      expect(AppThemeMode.fromName('nope'), AppThemeMode.system);
      expect(AppThemeMode.fromName('dark'), AppThemeMode.dark);
    });
  });

  group('AppTheme.build', () {
    testWidgets('brightness is honoured', (tester) async {
      expect(AppTheme.build(Brightness.light).colorScheme.brightness,
          Brightness.light);
      expect(AppTheme.build(Brightness.dark).colorScheme.brightness,
          Brightness.dark);
    });

    testWidgets('every palette yields a visually distinct primary',
        (tester) async {
      // Not just "two differ" - all of them must, otherwise the picker offers
      // choices the user cannot tell apart.
      final primaries = <Color>{};
      for (final p in AppPalette.values) {
        primaries.add(AppTheme.build(Brightness.light, palette: p)
            .colorScheme
            .primary);
      }
      expect(primaries.length, AppPalette.values.length);
    });

    testWidgets('black variant forces pure black surfaces in dark mode', (tester) async {
      final black = AppTheme.build(
        Brightness.dark,
        blackVariant: true,
      );
      expect(black.colorScheme.surface, const Color(0xFF000000));
      expect(black.scaffoldBackgroundColor, const Color(0xFF000000));
    });

    testWidgets('black variant does not affect light mode', (tester) async {
      final light = AppTheme.build(Brightness.light, blackVariant: true);
      expect(light.colorScheme.surface, isNot(const Color(0xFF000000)));
    });

    testWidgets('app bar background and foreground always match', (tester) async {
      // The pair must stay consistent, whichever surface the bar sits on -
      // a mismatch is what made the bar render light-on-light.
      for (final b in Brightness.values) {
        for (final p in AppPalette.values) {
          final t = AppTheme.build(b, palette: p);
          expect(t.appBarTheme.backgroundColor, t.colorScheme.surface);
          expect(t.appBarTheme.foregroundColor, t.colorScheme.onSurface);
        }
      }
    });
  });
}
