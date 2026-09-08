import 'dart:typed_data';

/// Settings keys holding the on-device paths of the branding images.
const kLetterheadLogoPathKey = 'letterhead_logo_path';
const kLetterheadSignaturePathKey = 'letterhead_signature_path';

/// Clinic logo and doctor signature rendered onto a printed prescription.
///
/// [none] is what an unbranded or Free-tier practice prints: the PDF falls
/// back to the plain text letterhead it has always produced.
class LetterheadBranding {
  final Uint8List? logo;
  final Uint8List? signature;

  const LetterheadBranding({this.logo, this.signature});

  static const LetterheadBranding none = LetterheadBranding();

  bool get hasLogo => logo != null && logo!.isNotEmpty;
  bool get hasSignature => signature != null && signature!.isNotEmpty;
  bool get isEmpty => !hasLogo && !hasSignature;

  /// What should actually be printed, given whether the feature is unlocked.
  ///
  /// Branding is a Pro feature, so an expired subscription silently reverts
  /// to the plain letterhead rather than leaving a half-branded document or
  /// blocking the doctor from printing a prescription at all — a prescription
  /// is clinical output and must never be gated.
  static LetterheadBranding effective({
    required LetterheadBranding stored,
    required bool unlocked,
  }) => unlocked ? stored : LetterheadBranding.none;
}
