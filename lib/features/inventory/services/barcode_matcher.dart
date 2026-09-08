import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';

/// Whether this build can open a camera scanner.
///
/// `mobile_scanner` ships implementations for Android, iOS, macOS and web
/// only. ClinicPilot also targets Windows, where a front-desk PC has no
/// usable camera anyway, so every scan entry point checks this first and
/// falls back to typing the code by hand rather than throwing at runtime.
bool get isBarcodeScanningSupported {
  if (kIsWeb) return true;
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

/// Result of looking a scanned code up against inventory.
enum BarcodeLookupStatus {
  /// Exactly one stocked item carries this barcode.
  matched,

  /// No stocked item carries it — likely a pack that was never catalogued.
  unknown,

  /// More than one item claims the same barcode, so the clinician picks.
  ambiguous,
}

/// A scanned code resolved against clinic inventory.
class BarcodeLookup {
  final String code;
  final BarcodeLookupStatus status;

  /// Every stocked item carrying [code]. Empty when unknown, one entry when
  /// matched, more than one when ambiguous.
  final List<Medicine> matches;

  const BarcodeLookup({
    required this.code,
    required this.status,
    required this.matches,
  });

  /// The single item to select, or null when the scan needs a human decision.
  Medicine? get single =>
      status == BarcodeLookupStatus.matched ? matches.first : null;
}

/// Pure barcode normalisation and inventory lookup.
///
/// Free of Flutter widgets and Riverpod so the matching rules — which decide
/// what a scan at the counter actually dispenses — are directly unit testable
/// without a camera.
class BarcodeMatcher {
  const BarcodeMatcher._();

  /// Strips everything a scanner may add around the digits.
  ///
  /// Hardware wedge scanners commonly append a carriage return, and some
  /// emit the code with spaces or hyphens grouped as printed on the pack.
  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

  /// Validates an EAN-13 / GS1 check digit.
  ///
  /// Guards against a partial or misread scan being saved onto an item,
  /// where it would silently dispense the wrong remedy later. Codes that are
  /// not 13 digits are accepted as-is: clinics also use shorter EAN-8 packs
  /// and their own internal labels, which carry no GS1 check digit.
  static bool isValidEan13(String code) {
    if (code.length != 13) return false;
    if (!RegExp(r'^\d{13}$').hasMatch(code)) return false;

    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = code.codeUnitAt(i) - 0x30;
      sum += (i.isEven) ? digit : digit * 3;
    }
    final check = (10 - (sum % 10)) % 10;
    return check == (code.codeUnitAt(12) - 0x30);
  }

  /// Resolves a scanned [rawCode] against [inventory].
  static BarcodeLookup lookup({
    required String rawCode,
    required List<Medicine> inventory,
  }) {
    final code = normalize(rawCode);
    if (code.isEmpty) {
      return BarcodeLookup(
        code: code,
        status: BarcodeLookupStatus.unknown,
        matches: const [],
      );
    }

    final matches =
        inventory.where((m) => !m.isDeleted).where((m) {
          final stored = m.barcode;
          if (stored == null || stored.trim().isEmpty) return false;
          return normalize(stored) == code;
        }).toList();

    if (matches.isEmpty) {
      return BarcodeLookup(
        code: code,
        status: BarcodeLookupStatus.unknown,
        matches: const [],
      );
    }

    return BarcodeLookup(
      code: code,
      status:
          matches.length == 1
              ? BarcodeLookupStatus.matched
              : BarcodeLookupStatus.ambiguous,
      matches: matches,
    );
  }
}
