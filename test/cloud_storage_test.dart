import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/cloud/cloud_storage_registry.dart';
import 'package:clinic_pilot/core/cloud/connectors/folder_sync_connector.dart';
import 'package:clinic_pilot/core/cloud/connectors/webdav_connector.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  group('FolderSyncConnector Tests', () {
    late Directory tempDir;
    late FolderSyncConnector connector;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'clinicpilot_cloud_test_',
      );
      connector = FolderSyncConnector(initialPath: tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('initializes and verifies connected status', () async {
      final isConnected = await connector.isConnected();
      expect(isConnected, isTrue);
      expect(connector.displayName, contains('Synced Folder'));
      expect(connector.targetPath, equals(tempDir.path));

      final account = await connector.getAccountInfo();
      expect(account?.email, equals(tempDir.path));
    });

    test('uploads, lists, downloads, and deletes .cpbak file', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final uploadResult = await connector.uploadBackup(
        dummyBytes,
        'ClinicPilot_Backup_Test.cpbak',
      );

      expect(uploadResult.success, isTrue);
      expect(uploadResult.fileName, equals('ClinicPilot_Backup_Test.cpbak'));

      // List backups
      final backups = await connector.listBackups();
      expect(backups.length, equals(1));
      expect(backups.first.name, equals('ClinicPilot_Backup_Test.cpbak'));
      expect(backups.first.sizeBytes, equals(5));
      expect(backups.first.formattedSize, equals('5 B'));

      // Download backup
      final downloaded = await connector.downloadBackup(backups.first.id);
      expect(downloaded, equals(dummyBytes));

      // Delete backup
      final deleted = await connector.deleteBackup(backups.first.id);
      expect(deleted, isTrue);

      final backupsAfter = await connector.listBackups();
      expect(backupsAfter.isEmpty, isTrue);
    });

    test('throws ArgumentError when connecting with empty path', () async {
      expect(() => connector.connect({'path': ''}), throwsArgumentError);
    });
  });

  group('WebDavConnector Tests', () {
    test('validates required credentials on connect', () async {
      final connector = WebDavConnector();

      expect(() => connector.connect({'serverUrl': ''}), throwsArgumentError);
      expect(
        () => connector.connect({
          'serverUrl': 'https://cloud.test',
          'username': '',
        }),
        throwsArgumentError,
      );
    });

    test('identifies metadata correctly', () {
      final connector = WebDavConnector();
      expect(connector.id, equals('webdav'));
      expect(connector.displayName, contains('WebDAV'));
    });
  });

  group('CloudStorageRegistry Tests', () {
    late FakeSecureStorage fakeStorage;
    late Directory tempDir;

    setUp(() async {
      fakeStorage = FakeSecureStorage();
      tempDir = await Directory.systemTemp.createTemp('clinicpilot_reg_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('registers connectors and identifies active connector', () {
      final folderConnector = FolderSyncConnector();
      final webdavConnector = WebDavConnector();
      final registry = CloudStorageRegistry(
        secureStorage: fakeStorage,
        initialConnectors: [folderConnector, webdavConnector],
      );

      expect(registry.availableConnectors.length, equals(2));
      expect(registry.activeConnector, isNull);
    });

    test('configures and persists active connector', () async {
      final folderConnector = FolderSyncConnector();
      final registry = CloudStorageRegistry(
        secureStorage: fakeStorage,
        initialConnectors: [folderConnector],
      );

      await registry.configureAndConnect('folder_sync', {'path': tempDir.path});

      expect(registry.activeConnectorId, equals('folder_sync'));
      expect(registry.activeConnector, isNotNull);

      // Verify persisted in storage
      expect(
        await fakeStorage.read(key: kCloudActiveProviderKey),
        equals('folder_sync'),
      );
      expect(
        await fakeStorage.read(key: kCloudFolderSyncPathKey),
        equals(tempDir.path),
      );

      // Disconnect
      await registry.disconnectActive();
      expect(registry.activeConnectorId, isNull);
      expect(registry.activeConnector, isNull);
      expect(await fakeStorage.read(key: kCloudActiveProviderKey), isNull);
    });

    test('initializes from saved storage credentials', () async {
      await fakeStorage.write(
        key: kCloudActiveProviderKey,
        value: 'folder_sync',
      );
      await fakeStorage.write(
        key: kCloudFolderSyncPathKey,
        value: tempDir.path,
      );

      final folderConnector = FolderSyncConnector();
      final registry = CloudStorageRegistry(
        secureStorage: fakeStorage,
        initialConnectors: [folderConnector],
      );

      await registry.initialize();

      expect(registry.activeConnectorId, equals('folder_sync'));
      expect(await registry.activeConnector?.isConnected(), isTrue);
    });
  });
}
