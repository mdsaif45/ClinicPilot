import 'package:flutter/services.dart';

/// Centralized tactile haptics service for micro-interactions.
///
/// Designed to provide subtle, premium physical feedback standing up
/// between patients without overwhelming the user.
abstract class AppHaptics {
  /// Light tap for button clicks, chip selections, tab changes.
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium tap for primary actions (Save, Submit, Complete).
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Selection click for picker rolls, date changes, slider ticks.
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Success pattern on successful save / payment recorded.
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Error / warning pattern on invalid input or destructive deletion.
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
