import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/app_palette.dart';
import '../design/tokens.dart';

/// Application theme for ClinicPilot.
///
/// This is the ONLY file allowed to name a colour literal. Every widget must
/// resolve colour through `Theme.of(context).colorScheme`, otherwise a screen
/// silently stops following the theme — which is exactly how the app bar ended
/// up rendering light-on-light.
class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => build(Brightness.light);
  static ThemeData get darkTheme => build(Brightness.dark);

  /// Builds a theme for a brightness, palette and optional true-black variant.
  ///
  /// [blackVariant] only applies to dark mode: it forces surfaces to pure black
  /// for OLED screens, which the standard dark scheme deliberately avoids.
  static ThemeData build(
    Brightness brightness, {
    AppPalette palette = AppPalette.emerald,
    bool blackVariant = false,
  }) {
    // Seed AND variant both come from the palette. Using one fixed seed for
    // every variant produces nine near-identical themes.
    var scheme = ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: brightness,
      dynamicSchemeVariant: palette.variant,
    );

    if (brightness == Brightness.light) {
      scheme = scheme.copyWith(
        surface: const Color(0xFFFFFFFF),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF8FAF9),
        surfaceContainer: const Color(0xFFF0F4F1),
        surfaceContainerHigh: const Color(0xFFE6EDE8),
        surfaceContainerHighest: const Color(0xFFDCE5DF),
      );
    } else if (brightness == Brightness.dark && blackVariant) {
      scheme = scheme.copyWith(
        surface: const Color(0xFF000000),
        surfaceContainerLowest: const Color(0xFF000000),
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF121212),
        surfaceContainerHigh: const Color(0xFF1A1A1A),
        surfaceContainerHighest: const Color(0xFF242424),
      );
    }

    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    final textTheme = _textTheme(base.textTheme, scheme);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        // Explicit pair. The bar sits on the surface, so anything drawn on it
        // must resolve against onSurface - a control that assumes onPrimary
        // renders white on white.
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: Radii.pillAll),
        backgroundColor: Colors.transparent,
        selectedColor: scheme.secondaryContainer,
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.xs,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: scheme.error),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        // AnimatedNavIcon draws its own filled pill, so the built-in indicator
        // would sit behind it as a second, differently-shaped highlight.
        indicatorColor: Colors.transparent,
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            // Selected must be clearly stronger than unselected, not a faint tint.
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: Radii.lgAll),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl,
            vertical: Spacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl,
            vertical: Spacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    final t = GoogleFonts.interTextTheme(base);
    return t.copyWith(
      displaySmall: t.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
      labelSmall: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
    );
  }

  /// Digits that occupy equal width, so money columns line up when stacked.
  static TextStyle tabularFigures(TextStyle? style) =>
      (style ?? const TextStyle())
          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Colour for a monetary value, by sign.
  static Color moneyColor(BuildContext context, double value) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    if (value < 0) {
      return isDark ? BrandColors.negativeDark : BrandColors.negativeLight;
    }
    return isDark ? BrandColors.positiveDark : BrandColors.positiveLight;
  }
}
