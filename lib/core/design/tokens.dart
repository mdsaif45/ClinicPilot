import 'package:flutter/material.dart';

/// Design tokens — the single source of truth for spacing, shape and motion.
///
/// Nothing outside this file should contain a magic layout number.

abstract class Spacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}

/// Motion is deliberately restrained.
///
/// This app is used standing up, between patients. Animation that makes the
/// doctor wait is a defect, not polish — [slow] is a ceiling, not a default.
abstract class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 240);
  static const Curve curve = Curves.easeOutCubic;

  /// Number of leading list items that animate in. The rest render immediately
  /// so a long list never animates hundreds of times.
  static const int staggerLimit = 8;

  static const Duration staggerStep = Duration(milliseconds: 30);
}

/// Brand palette. Only [AppTheme] should read these directly — everything else
/// resolves colour from `Theme.of(context).colorScheme`.
abstract class BrandColors {
  static const Color emerald = Color(0xFF0F5132);
  static const Color teal = Color(0xFF198754);

  /// Money that represents a loss or an amount still owed.
  static const Color negativeLight = Color(0xFFB3261E);
  static const Color negativeDark = Color(0xFFF2B8B5);

  /// Money that represents profit or a settled amount.
  static const Color positiveLight = Color(0xFF1B5E20);
  static const Color positiveDark = Color(0xFF7FD68B);
}

/// Standard accounting colours for ledger receipts, vouchers and balance sheets.
abstract class FinanceColors {
  static const Color green = Color(0xFF2E7D32);
  static const Color greenLight = Color(0xFF81C784);
  static const Color greenBg = Color(0xFFE8F5E9);
  static const Color greenBorder = Color(0xFFC8E6C9);

  static const Color red = Color(0xFFD32F2F);
  static const Color redLight = Color(0xFFE57373);
  static const Color redBg = Color(0xFFFFEBEE);
  static const Color redBorder = Color(0xFFFFCDD2);
}

/// Semantic accents for data categories.
///
/// Charts and stat cards need several distinguishable colours, but they must
/// still follow the active palette — hardcoding Colors.red/blue/teal makes a
/// screen ignore the theme, which is how Monochrome ended up with teal icons.
///
/// These derive from the active ColorScheme so every palette keeps its own
/// character while remaining internally consistent.
abstract class SemanticColors {
  static Color income(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color expense(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color profit(BuildContext context, double value) =>
      value < 0 ? expense(context) : Theme.of(context).colorScheme.primary;

  static Color people(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  static Color muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Ordered palette for chart series, all drawn from the active scheme.
  static List<Color> chartSeries(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return [
      s.primary,
      s.tertiary,
      s.secondary,
      s.error,
      s.primaryContainer,
      s.tertiaryContainer,
    ];
  }
}

/// Standard icon for each payment method across the app.
abstract class PaymentIcons {
  static IconData forMethod(String method) => switch (method.toLowerCase()) {
        'cash' => Icons.payments_outlined,
        'upi' => Icons.qr_code_2,
        'card' => Icons.credit_card,
        _ => Icons.account_balance_outlined,
      };
}

