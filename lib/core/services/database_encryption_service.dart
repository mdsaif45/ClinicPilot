import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseEncryptionService {
  static const keyStorageKey = 'clinicpilot_db_encryption_key';
  final FlutterSecureStorage _storage;

  DatabaseEncryptionService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String> getOrCreateDatabaseKey() async {
    final existing = await _storage.read(key: keyStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    final newKey = base64Url.encode(bytes);

    await _storage.write(key: keyStorageKey, value: newKey);
    return newKey;
  }

  Future<bool> hasEncryptionKey() async {
    final key = await _storage.read(key: keyStorageKey);
    return key != null && key.isNotEmpty;
  }

  Future<void> clearEncryptionKey() async {
    await _storage.delete(key: keyStorageKey);
  }
}
