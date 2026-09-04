import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Metadata for a backup stored on a remote cloud provider.
class RemoteBackupItem {
  final String id;
  final String name;
  final int sizeBytes;
  final DateTime modifiedAt;
  final String? checksumSha256;
  final Map<String, dynamic> metadata;

  const RemoteBackupItem({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.modifiedAt,
    this.checksumSha256,
    this.metadata = const {},
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// Cloud storage account details.
class CloudAccountInfo {
  final String accountName;
  final String? email;
  final int? storageUsedBytes;
  final int? storageTotalBytes;

  const CloudAccountInfo({
    required this.accountName,
    this.email,
    this.storageUsedBytes,
    this.storageTotalBytes,
  });

  double? get usageFraction {
    if (storageUsedBytes == null ||
        storageTotalBytes == null ||
        storageTotalBytes == 0) {
      return null;
    }
    return (storageUsedBytes! / storageTotalBytes!).clamp(0.0, 1.0);
  }
}

/// Result of uploading a backup to a cloud provider.
class CloudUploadResult {
  final bool success;
  final String? fileId;
  final String fileName;
  final DateTime uploadedAt;
  final String? errorMessage;

  const CloudUploadResult({
    required this.success,
    this.fileId,
    required this.fileName,
    required this.uploadedAt,
    this.errorMessage,
  });

  factory CloudUploadResult.failure(String fileName, String message) {
    return CloudUploadResult(
      success: false,
      fileName: fileName,
      uploadedAt: DateTime.now(),
      errorMessage: message,
    );
  }

  factory CloudUploadResult.success(String fileName, String fileId) {
    return CloudUploadResult(
      success: true,
      fileName: fileName,
      fileId: fileId,
      uploadedAt: DateTime.now(),
    );
  }
}

/// Abstract contract for a cloud storage provider connector.
abstract class CloudStorageConnector {
  String get id;
  String get displayName;
  String get description;
  IconData get icon;

  /// Whether this connector is configured and ready for file operations.
  Future<bool> isConnected();

  /// Validates and connects the connector with given credentials / configuration.
  Future<void> connect(Map<String, String> credentials);

  /// Disconnects and purges cached credentials.
  Future<void> disconnect();

  /// Retrieves account/storage quota information.
  Future<CloudAccountInfo?> getAccountInfo();

  /// Uploads a `.cpbak` archive to the cloud provider.
  Future<CloudUploadResult> uploadBackup(
    Uint8List bytes,
    String filename, {
    Map<String, String>? metadata,
  });

  /// Lists all `.cpbak` backups stored in this cloud provider's target folder.
  Future<List<RemoteBackupItem>> listBackups();

  /// Downloads a remote backup file by its unique identifier.
  Future<Uint8List> downloadBackup(String remoteId);

  /// Deletes a remote backup file.
  Future<bool> deleteBackup(String remoteId);
}
