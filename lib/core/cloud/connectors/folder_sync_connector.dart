import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../cloud_storage_connector.dart';

/// Connector that syncs practice backups to a local directory synchronized
/// with cloud storage services (Google Drive sync, OneDrive, Dropbox, or Nextcloud client).
class FolderSyncConnector implements CloudStorageConnector {
  String? _targetPath;

  FolderSyncConnector({String? initialPath}) : _targetPath = initialPath;

  @override
  String get id => 'folder_sync';

  @override
  String get displayName => 'Cloud Synced Folder';

  @override
  String get description =>
      'Syncs directly to your Google Drive, OneDrive, or Dropbox folder on this device.';

  @override
  IconData get icon => Icons.folder_shared_outlined;

  String? get targetPath => _targetPath;

  @override
  Future<bool> isConnected() async {
    if (_targetPath == null || _targetPath!.trim().isEmpty) return false;
    final dir = Directory(_targetPath!);
    return dir.exists();
  }

  @override
  Future<void> connect(Map<String, String> credentials) async {
    final path = credentials['path'];
    if (path == null || path.trim().isEmpty) {
      throw ArgumentError('Directory path is required.');
    }
    final dir = Directory(path.trim());
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _targetPath = dir.path;
  }

  @override
  Future<void> disconnect() async {
    _targetPath = null;
  }

  @override
  Future<CloudAccountInfo?> getAccountInfo() async {
    if (_targetPath == null) return null;
    return CloudAccountInfo(
      accountName: 'Local Cloud Folder',
      email: _targetPath,
    );
  }

  @override
  Future<CloudUploadResult> uploadBackup(
    Uint8List bytes,
    String filename, {
    Map<String, String>? metadata,
  }) async {
    if (_targetPath == null) {
      return CloudUploadResult.failure(
        filename,
        'No synced directory configured.',
      );
    }
    try {
      final dir = Directory(_targetPath!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes, flush: true);

      return CloudUploadResult.success(filename, file.path);
    } catch (e) {
      return CloudUploadResult.failure(filename, e.toString());
    }
  }

  @override
  Future<List<RemoteBackupItem>> listBackups() async {
    if (_targetPath == null) return [];
    final dir = Directory(_targetPath!);
    if (!await dir.exists()) return [];

    final list = <RemoteBackupItem>[];
    final entities = await dir.list().toList();

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.cpbak')) {
        final stat = await entity.stat();
        final name = p.basename(entity.path);

        list.add(
          RemoteBackupItem(
            id: entity.path,
            name: name,
            sizeBytes: stat.size,
            modifiedAt: stat.modified,
          ),
        );
      }
    }

    list.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return list;
  }

  @override
  Future<Uint8List> downloadBackup(String remoteId) async {
    final file = File(remoteId);
    if (!await file.exists()) {
      throw FileNotFoundException('Backup file not found at $remoteId');
    }
    return file.readAsBytes();
  }

  @override
  Future<bool> deleteBackup(String remoteId) async {
    try {
      final file = File(remoteId);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

class FileNotFoundException implements Exception {
  final String message;
  const FileNotFoundException(this.message);

  @override
  String toString() => 'FileNotFoundException: $message';
}
