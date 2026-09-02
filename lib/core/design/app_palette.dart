import 'package:flutter/material.dart';

import 'tokens.dart';

/// Colour palettes offered in Settings.
///
/// Each entry pairs a **seed colour** with a Material 3 **scheme variant**.
/// Both matter: the variant decides how chroma is distributed across the 26
/// colour roles, while the seed decides the hue. Varying only the variant from
/// a single seed produces nine near-identical themes, which is exactly the
/// mistake this enum previously made.
enum AppPalette {
  /// Clinic brand. The colour already on the signboard, so it stays default.
  emerald(
    label: 'Emerald',
    description: 'Clinic brand colour',
    seed: BrandColors.emerald,
    variant: DynamicSchemeVariant.tonalSpot,
  ),

  tonalSpot(
    label: 'TonalSpot',
    description: 'Balanced slate blue',
    seed: Color(0xFF4A5568),
    variant: DynamicSchemeVariant.tonalSpot,
  ),

  neutral(
    label: 'Neutral',
    description: 'Calm and muted',
    seed: Color(0xFF5F5F5F),
    variant: DynamicSchemeVariant.neutral,
  ),

  vibrant(
    label: 'Vibrant',
    description: 'Bold and saturated',
    seed: Color(0xFF3F4CD9),
    variant: DynamicSchemeVariant.vibrant,
  ),

  expressive(
    label: 'Expressive',
    description: 'Playful violet',
    seed: Color(0xFF6750A4),
    variant: DynamicSchemeVariant.expressive,
  ),

  rainbow(
    label: 'Rainbow',
    description: 'Bright blue violet',
    seed: Color(0xFF4F5BD5),
    variant: DynamicSchemeVariant.rainbow,
  ),

  fruitSalad(
    label: 'FruitSalad',
    description: 'Fresh cyan',
    seed: Color(0xFF00A5C4),
    variant: DynamicSchemeVariant.fruitSalad,
  ),

  monochrome(
    label: 'Monochrome',
    description: 'Greyscale',
    seed: Color(0xFF5C5C5C),
    variant: DynamicSchemeVariant.monochrome,
  ),

  fidelity(
    label: 'Fidelity',
    description: 'True to the source colour',
    seed: Color(0xFF4A52B8),
    variant: DynamicSchemeVariant.fidelity,
  ),

  content(
    label: 'Content',
    description: 'Indigo, content aware',
    seed: Color(0xFF5A5FCF),
    variant: DynamicSchemeVariant.content,
  );

  const AppPalette({
    required this.label,
    required this.description,
    required this.seed,
    required this.variant,
  });

  final String label;
  final String description;
  final Color seed;
  final DynamicSchemeVariant variant;

  /// Colour shown in the picker swatch.
  Color get swatch => seed;

  static AppPalette fromName(String? name) => AppPalette.values.firstWhere(
    (p) => p.name == name,
    orElse: () => AppPalette.emerald,
  );
}

/// Brightness options offered in Settings.
///
/// The true-black option is not a separate mode: it is dark mode with pure
/// black surfaces, which saves power on OLED screens and reads better in a dim
/// consulting room.
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
