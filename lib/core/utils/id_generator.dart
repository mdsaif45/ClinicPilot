import 'package:uuid/uuid.dart';

/// Centralized identifier generator for internal surrogate keys (ULID/UUID).
/// Produces clean, non-hyphenated 32-character lowercase hex strings.
class IdGenerator {
  const IdGenerator._();

  static const _uuid = Uuid();

  /// Generates a standard 32-character lowercase hex string without hyphens.
  static String generate() {
    return _uuid.v4().replaceAll('-', '').toLowerCase();
  }
}
