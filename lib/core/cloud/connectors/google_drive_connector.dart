import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../cloud_storage_connector.dart';

/// Callback invoked when OAuth tokens are refreshed or updated,
/// allowing the registry to persist them into secure storage.
typedef OnGoogleDriveTokensChanged =
    Future<void> Function({
      required String accessToken,
      String? refreshToken,
      DateTime? expiresAt,
      String? userEmail,
      String? userName,
    });

/// Cloud Storage Connector for Google Drive.
///
/// Implements "Zero-Knowledge / User-Owned Cloud Sync" by communicating
/// directly with Google Drive REST API v3 using the doctor's personal Google account.
///
/// Backups are uploaded directly into the isolated `appDataFolder` space
/// (`https://www.googleapis.com/auth/drive.appdata`), keeping them invisible to other
/// applications and avoiding clutter in the doctor's personal Drive root.
class GoogleDriveConnector implements CloudStorageConnector {
  final http.Client _client;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiresAt;
  String? _userEmail;
  String? _userName;
  OnGoogleDriveTokensChanged? onTokensChanged;

  /// Default client identifier for public mobile OAuth2 client.
  String? clientId;
  String? clientSecret;

  GoogleDriveConnector({
    http.Client? client,
    this.onTokensChanged,
    this.clientId,
    this.clientSecret,
  }) : _client = client ?? http.Client();

  @override
  String get id => 'google_drive';

  @override
  String get displayName => 'Google Drive';

  @override
  String get description =>
      'Zero-cost backup to your personal Google Drive (hidden app folder).';

  @override
  IconData get icon => Icons.add_to_drive_outlined;

  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  DateTime? get tokenExpiresAt => _tokenExpiresAt;

  bool get isTokenExpired {
    if (_tokenExpiresAt == null) return false;
    // Add 60s buffer for clock drift
    return DateTime.now().isAfter(
      _tokenExpiresAt!.subtract(const Duration(seconds: 60)),
    );
  }

  /// Ensures a valid access token is available, refreshing if necessary.
  Future<String> _ensureValidToken() async {
    if (_accessToken == null) {
      throw StateError(
        'Google Drive is not connected. Please authenticate first.',
      );
    }

    if (isTokenExpired && _refreshToken != null && _refreshToken!.isNotEmpty) {
      await refreshAccessToken();
    }

    return _accessToken!;
  }

  /// Refreshes the Google OAuth2 access token using the stored refresh token.
  Future<void> refreshAccessToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      throw StateError(
        'No refresh token available to renew Google Drive session.',
      );
    }

    final uri = Uri.parse('https://oauth2.googleapis.com/token');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId ?? 'clinicpilot-mobile',
        if (clientSecret != null && clientSecret!.isNotEmpty)
          'client_secret': clientSecret!,
        'refresh_token': _refreshToken!,
        'grant_type': 'refresh_token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _accessToken = data['access_token'] as String;
      final expiresIn = data['expires_in'] as int? ?? 3600;
      _tokenExpiresAt = DateTime.now().add(Duration(seconds: expiresIn));

      if (onTokensChanged != null) {
        await onTokensChanged!(
          accessToken: _accessToken!,
          refreshToken: _refreshToken,
          expiresAt: _tokenExpiresAt,
          userEmail: _userEmail,
          userName: _userName,
        );
      }
    } else {
      throw StateError(
        'Failed to refresh Google Drive token: ${response.body}',
      );
    }
  }

  @override
  Future<bool> isConnected() async {
    if (_accessToken == null) return false;
    try {
      final token = await _ensureValidToken();
      final uri = Uri.parse(
        'https://www.googleapis.com/drive/v3/about?fields=user',
      );
      final res = await _client
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> connect(Map<String, String> credentials) async {
    final token = credentials['accessToken'];
    final refresh = credentials['refreshToken'];
    final expiryStr = credentials['expiresAt'];
    final email = credentials['userEmail'];
    final name = credentials['userName'];

    if (token == null || token.trim().isEmpty) {
      throw ArgumentError('Access token is required to connect Google Drive.');
    }

    _accessToken = token.trim();
    _refreshToken = refresh?.trim();
    _userEmail = email?.trim();
    _userName = name?.trim();

    if (expiryStr != null && expiryStr.isNotEmpty) {
      _tokenExpiresAt = DateTime.tryParse(expiryStr);
    } else {
      _tokenExpiresAt = DateTime.now().add(const Duration(hours: 1));
    }

    // Fetch account info to verify and cache user identity
    try {
      final info = await getAccountInfo();
      _userName = info.accountName;
      _userEmail = info.email ?? _userEmail;
    } catch (_) {}

    if (onTokensChanged != null && _accessToken != null) {
      await onTokensChanged!(
        accessToken: _accessToken!,
        refreshToken: _refreshToken,
        expiresAt: _tokenExpiresAt,
        userEmail: _userEmail,
        userName: _userName,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiresAt = null;
    _userEmail = null;
    _userName = null;
  }

  @override
  Future<CloudAccountInfo> getAccountInfo() async {
    final token = await _ensureValidToken();
    final uri = Uri.parse(
      'https://www.googleapis.com/drive/v3/about?fields=user,storageQuota',
    );
    final response = await _client
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw StateError(
        'Failed to fetch Google Drive user details: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>? ?? {};
    final quota = data['storageQuota'] as Map<String, dynamic>? ?? {};

    final displayName = user['displayName'] as String? ?? 'Google User';
    final email = user['emailAddress'] as String?;
    final usedBytes = int.tryParse(quota['usage']?.toString() ?? '');
    final limitBytes = int.tryParse(quota['limit']?.toString() ?? '');

    _userName = displayName;
    _userEmail = email ?? _userEmail;

    return CloudAccountInfo(
      accountName: displayName,
      email: email,
      storageUsedBytes: usedBytes,
      storageTotalBytes: limitBytes,
    );
  }

  @override
  Future<CloudUploadResult> uploadBackup(
    Uint8List bytes,
    String filename, {
    Map<String, String>? metadata,
  }) async {
    final token = await _ensureValidToken();

    final uploadUri = Uri.parse(
      'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
    );

    final boundary =
        '----ClinicPilotBoundary${DateTime.now().millisecondsSinceEpoch}';

    // Metadata part
    final fileMetadata = {
      'name': filename,
      'parents': ['appDataFolder'],
      'description': 'ClinicPilot Encrypted Practice Backup',
      'appProperties': {
        'app': 'ClinicPilot',
        'type': 'encrypted_backup',
        'timestamp': DateTime.now().toIso8601String(),
        if (metadata != null)
          ...metadata.map((k, v) => MapEntry(k, v.toString())),
      },
    };

    final metadataJson = jsonEncode(fileMetadata);

    final bodyBytes = <int>[];
    // Part 1: Metadata
    bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
    bodyBytes.addAll(
      utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
    );
    bodyBytes.addAll(utf8.encode('$metadataJson\r\n'));

    // Part 2: Media
    bodyBytes.addAll(utf8.encode('--$boundary\r\n'));
    bodyBytes.addAll(
      utf8.encode('Content-Type: application/octet-stream\r\n\r\n'),
    );
    bodyBytes.addAll(bytes);
    bodyBytes.addAll(utf8.encode('\r\n--$boundary--\r\n'));

    final request = http.Request('POST', uploadUri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/related; boundary=$boundary';
    request.bodyBytes = Uint8List.fromList(bodyBytes);

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 45));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resData = jsonDecode(response.body) as Map<String, dynamic>;
      final fileId = resData['id'] as String?;
      return CloudUploadResult(
        success: true,
        fileId: fileId,
        fileName: filename,
        uploadedAt: DateTime.now(),
      );
    } else {
      throw StateError(
        'Google Drive upload failed (HTTP ${response.statusCode}): ${response.body}',
      );
    }
  }

  @override
  Future<List<RemoteBackupItem>> listBackups() async {
    final token = await _ensureValidToken();

    final queryUri = Uri.parse(
      'https://www.googleapis.com/drive/v3/files?'
      'spaces=appDataFolder&'
      'fields=files(id,name,size,modifiedTime,md5Checksum,appProperties)&'
      'orderBy=modifiedTime desc',
    );

    final response = await _client
        .get(queryUri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw StateError(
        'Failed to list backups from Google Drive (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>? ?? [];

    final results = <RemoteBackupItem>[];
    for (final f in files) {
      if (f is Map<String, dynamic>) {
        final id = f['id'] as String? ?? '';
        final name = f['name'] as String? ?? '';
        final size = int.tryParse(f['size']?.toString() ?? '0') ?? 0;
        final modTimeStr = f['modifiedTime'] as String?;
        final modTime =
            modTimeStr != null
                ? (DateTime.tryParse(modTimeStr) ?? DateTime.now())
                : DateTime.now();
        final md5 = f['md5Checksum'] as String?;
        final props = f['appProperties'] as Map<String, dynamic>? ?? {};

        // Only include .cpbak or ClinicPilot backup files
        if (name.endsWith('.cpbak') || props['app'] == 'ClinicPilot') {
          results.add(
            RemoteBackupItem(
              id: id,
              name: name,
              sizeBytes: size,
              modifiedAt: modTime,
              checksumSha256: md5,
              metadata: props,
            ),
          );
        }
      }
    }

    return results;
  }

  @override
  Future<Uint8List> downloadBackup(String backupId) async {
    final token = await _ensureValidToken();

    final uri = Uri.parse(
      'https://www.googleapis.com/drive/v3/files/$backupId?alt=media',
    );
    final response = await _client
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 45));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw StateError(
        'Failed to download backup from Google Drive (HTTP ${response.statusCode}): ${response.body}',
      );
    }
  }

  @override
  Future<bool> deleteBackup(String backupId) async {
    final token = await _ensureValidToken();

    final uri = Uri.parse(
      'https://www.googleapis.com/drive/v3/files/$backupId',
    );
    final response = await _client
        .delete(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));

    return response.statusCode == 204 || response.statusCode == 200;
  }
}
