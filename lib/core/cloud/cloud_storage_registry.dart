import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/backup_container_service.dart';
import 'cloud_storage_connector.dart';
import 'connectors/folder_sync_connector.dart';
import 'connectors/webdav_connector.dart';

const kCloudActiveProviderKey = 'cloud_active_provider_id';
const kCloudWebDavUrlKey = 'cloud_webdav_url';
const kCloudWebDavUserKey = 'cloud_webdav_username';
const kCloudWebDavPassKey = 'cloud_webdav_password';
const kCloudFolderSyncPathKey = 'cloud_folder_sync_path';
const kCloudLastBackupTimeKey = 'cloud_last_backup_time';
const kCloudLastBackupFileKey = 'cloud_last_backup_file';

/// Central registry managing cloud storage connectors, persistent credentials,
/// and automated upload/download flows.
class CloudStorageRegistry {
  final FlutterSecureStorage _secureStorage;
  final Map<String, CloudStorageConnector> _connectors = {};
  String? _activeConnectorId;

  CloudStorageRegistry({
    FlutterSecureStorage? secureStorage,
    List<CloudStorageConnector>? initialConnectors,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    if (initialConnectors != null) {
      for (final c in initialConnectors) {
        _connectors[c.id] = c;
      }
    } else {
      registerConnector(FolderSyncConnector());
      registerConnector(WebDavConnector());
    }
  }

  void registerConnector(CloudStorageConnector connector) {
    _connectors[connector.id] = connector;
  }

  List<CloudStorageConnector> get availableConnectors =>
      _connectors.values.toList();

  CloudStorageConnector? get activeConnector =>
      _activeConnectorId != null ? _connectors[_activeConnectorId] : null;

  String? get activeConnectorId => _activeConnectorId;

  /// Loads saved connector configuration and initializes the active connector.
  Future<void> initialize() async {
    _activeConnectorId = await _secureStorage.read(
      key: kCloudActiveProviderKey,
    );

    // Initialize FolderSync connector if path is saved
    final folderPath = await _secureStorage.read(key: kCloudFolderSyncPathKey);
    if (folderPath != null && folderPath.isNotEmpty) {
      final folderConnector = _connectors['folder_sync'];
      if (folderConnector != null) {
        try {
          await folderConnector.connect({'path': folderPath});
        } catch (_) {}
      }
    }

    // Initialize WebDav connector if credentials are saved
    final webdavUrl = await _secureStorage.read(key: kCloudWebDavUrlKey);
    final webdavUser = await _secureStorage.read(key: kCloudWebDavUserKey);
    final webdavPass = await _secureStorage.read(key: kCloudWebDavPassKey);

    if (webdavUrl != null && webdavUser != null && webdavPass != null) {
      final webdavConnector = _connectors['webdav'];
      if (webdavConnector != null) {
        try {
          await webdavConnector.connect({
            'serverUrl': webdavUrl,
            'username': webdavUser,
            'password': webdavPass,
          });
        } catch (_) {}
      }
    }
  }

  /// Configures and connects a specific connector, persisting its credentials.
  Future<void> configureAndConnect(
    String connectorId,
    Map<String, String> credentials,
  ) async {
    final connector = _connectors[connectorId];
    if (connector == null) {
      throw ArgumentError('Unknown connector ID: $connectorId');
    }

    await connector.connect(credentials);
    _activeConnectorId = connectorId;
    await _secureStorage.write(
      key: kCloudActiveProviderKey,
      value: connectorId,
    );

    if (connectorId == 'folder_sync') {
      await _secureStorage.write(
        key: kCloudFolderSyncPathKey,
        value: credentials['path'] ?? '',
      );
    } else if (connectorId == 'webdav') {
      await _secureStorage.write(
        key: kCloudWebDavUrlKey,
        value: credentials['serverUrl'] ?? '',
      );
      await _secureStorage.write(
        key: kCloudWebDavUserKey,
        value: credentials['username'] ?? '',
      );
      await _secureStorage.write(
        key: kCloudWebDavPassKey,
        value: credentials['password'] ?? '',
      );
    }
  }

  /// Disconnects the active connector and removes its saved credentials.
  Future<void> disconnectActive() async {
    final active = activeConnector;
    if (active != null) {
      await active.disconnect();
    }
    if (_activeConnectorId == 'folder_sync') {
      await _secureStorage.delete(key: kCloudFolderSyncPathKey);
    } else if (_activeConnectorId == 'webdav') {
      await _secureStorage.delete(key: kCloudWebDavUrlKey);
      await _secureStorage.delete(key: kCloudWebDavUserKey);
      await _secureStorage.delete(key: kCloudWebDavPassKey);
    }
    _activeConnectorId = null;
    await _secureStorage.delete(key: kCloudActiveProviderKey);
  }

  /// Creates a full `.cpbak` practice backup and uploads it to the active cloud provider.
  Future<CloudUploadResult> createAndUploadBackup(AppDatabase db) async {
    final connector = activeConnector;
    if (connector == null) {
      return CloudUploadResult.failure(
        '',
        'No active cloud storage provider configured.',
      );
    }

    final isConnected = await connector.isConnected();
    if (!isConnected) {
      return CloudUploadResult.failure(
        '',
        'Cloud provider "${connector.displayName}" is not connected.',
      );
    }

    try {
      final bytes = await BackupContainerService(db).buildBackupBytes();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'ClinicPilot_Backup_$dateStr.cpbak';

      final result = await connector.uploadBackup(
        Uint8List.fromList(bytes),
        filename,
      );
      if (result.success) {
        await _secureStorage.write(
          key: kCloudLastBackupTimeKey,
          value: DateTime.now().toIso8601String(),
        );
        await _secureStorage.write(
          key: kCloudLastBackupFileKey,
          value: filename,
        );
      }
      return result;
    } catch (e) {
      return CloudUploadResult.failure('', e.toString());
    }
  }

  /// Gets the last backup timestamp if recorded.
  Future<DateTime?> getLastBackupTime() async {
    final raw = await _secureStorage.read(key: kCloudLastBackupTimeKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Downloads and restores a remote backup archive into the active database.
  Future<RestoreResult> downloadAndRestoreBackup(
    String remoteId,
    AppDatabase db,
  ) async {
    final connector = activeConnector;
    if (connector == null) {
      throw StateError('No active cloud storage provider configured.');
    }

    final bytes = await connector.downloadBackup(remoteId);
    final service = BackupContainerService(db);
    return service.restoreFromBackupBytes(bytes);
  }
}

// ----------------- RIVERPOD PROVIDERS -----------------

final cloudStorageRegistryProvider = Provider<CloudStorageRegistry>((ref) {
  final registry = CloudStorageRegistry();
  return registry;
});

final cloudRegistryInitProvider = FutureProvider<CloudStorageRegistry>((
  ref,
) async {
  final registry = ref.watch(cloudStorageRegistryProvider);
  await registry.initialize();
  return registry;
});

final activeCloudConnectorProvider = Provider<CloudStorageConnector?>((ref) {
  ref.watch(cloudRegistryInitProvider);
  final registry = ref.watch(cloudStorageRegistryProvider);
  return registry.activeConnector;
});

final cloudConnectionStatusProvider = FutureProvider<bool>((ref) async {
  final connector = ref.watch(activeCloudConnectorProvider);
  if (connector == null) return false;
  return connector.isConnected();
});

final remoteBackupsProvider = FutureProvider<List<RemoteBackupItem>>((
  ref,
) async {
  final connector = ref.watch(activeCloudConnectorProvider);
  if (connector == null) return [];
  final isConnected = await connector.isConnected();
  if (!isConnected) return [];
  return connector.listBackups();
});
