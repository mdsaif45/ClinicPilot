import 'package:flutter/material.dart';

/// Design tokens — the single source of truth for spacing, shape and motion.
///
/// Nothing outside this file should contain a magic layout number.

abstract class Spacing {
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
