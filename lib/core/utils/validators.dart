/// Shared form validators.
///
/// Kept out of the widgets so they can be unit tested and reused by both the
/// add and edit dialogs.
class Validators {
  const Validators._();

  static const int maxAge = 120;

  /// Validates a typed age. Returns null when valid, otherwise a message.
  static String? age(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Enter age';

    final parsed = int.tryParse(raw);
    if (parsed == null) return 'Enter age 0-$maxAge';
    if (parsed < 0 || parsed > maxAge) return 'Enter age 0-$maxAge';

    return null;
  }
}
