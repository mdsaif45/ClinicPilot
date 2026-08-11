import 'package:flutter/material.dart';

import 'tokens.dart';

/// Colour palettes the user can choose between.
///
/// These are Material 3 *scheme variants*: each derives a full 26-role
/// ColorScheme from the same seed using a different algorithm, so switching
/// palette re-tints the whole app rather than swapping one accent colour.
///
/// Deliberately four rather than the full M3 set — seeded from a single brand
/// colour, most variants land within a few degrees of each other, so extra
/// entries would offer choice without visible difference.
enum AppPalette {
  /// Brand emerald. The identity the clinic already prints on its signboard.
  emerald,

  /// Almost greyscale with a faint brand tint. Calmest for long reading.
  neutral,

  /// High chroma. Strongest separation between profit/loss and chart series.
  vibrant,

  /// Pure greyscale. Maximum contrast, useful in bright evening clinic light.
  monochrome;

  String get label => switch (this) {
        AppPalette.emerald => 'Emerald',
        AppPalette.neutral => 'Neutral',
        AppPalette.vibrant => 'Vibrant',
        AppPalette.monochrome => 'Monochrome',
      };

  String get description => switch (this) {
        AppPalette.emerald => 'Clinic brand colour',
        AppPalette.neutral => 'Calm and muted',
        AppPalette.vibrant => 'Bold and high contrast',
        AppPalette.monochrome => 'Greyscale',
      };

  /// Colour shown in the palette picker swatch.
  Color get swatch => switch (this) {
        AppPalette.emerald => BrandColors.emerald,
        AppPalette.neutral => const Color(0xFF5F6B62),
        AppPalette.vibrant => const Color(0xFF00A86B),
        AppPalette.monochrome => const Color(0xFF3A3A3A),
      };

  DynamicSchemeVariant get variant => switch (this) {
        AppPalette.emerald => DynamicSchemeVariant.tonalSpot,
        AppPalette.neutral => DynamicSchemeVariant.neutral,
        AppPalette.vibrant => DynamicSchemeVariant.vibrant,
        AppPalette.monochrome => DynamicSchemeVariant.monochrome,
      };

  static AppPalette fromName(String? name) => AppPalette.values.firstWhere(
        (p) => p.name == name,
        orElse: () => AppPalette.emerald,
      );
}

/// Brightness options offered in Settings.
///
/// [black] is a true-black variant of dark mode. It is not a separate
/// ThemeMode — it is dark mode with pure black surfaces, which saves power on
/// OLED screens and reads better in a dim consulting room.
enum AppThemeMode {
  system,
  light,
  dark;

  String get label => switch (this) {
        AppThemeMode.system => 'Follow system',
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
      };

  ThemeMode get material => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };

  static AppThemeMode fromName(String? name) => AppThemeMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => AppThemeMode.system,
      );
}
