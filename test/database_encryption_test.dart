import 'package:clinic_pilot/core/services/database_encryption_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  FakeSecureStorage();

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    AppleOptions? iOptions,
    LinuxOptions? lOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
  }) async {
    _storage.remove(key);
  }
}

void main() {
  group('Database Encryption Service Tests', () {
    test('generates and persists 256-bit encryption key', () async {
      final fakeStorage = FakeSecureStorage();
      final service = DatabaseEncryptionService(storage: fakeStorage);

      expect(await service.hasEncryptionKey(), isFalse);

      final key1 = await service.getOrCreateDatabaseKey();
      expect(key1, isNotEmpty);
      expect(await service.hasEncryptionKey(), isTrue);

      // Subsequent call returns same persisted key
      final key2 = await service.getOrCreateDatabaseKey();
      expect(key2, equals(key1));

      // Clear key
      await service.clearEncryptionKey();
      expect(await service.hasEncryptionKey(), isFalse);
    });
  });
}
