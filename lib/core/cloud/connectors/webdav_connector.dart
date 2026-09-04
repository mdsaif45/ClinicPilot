import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../cloud_storage_connector.dart';

/// Connector that synchronizes backups directly to any WebDAV-compatible cloud service
/// (e.g. Nextcloud, OwnCloud, Box via dav.box.com, pCloud, or private NAS servers).
class WebDavConnector implements CloudStorageConnector {
  String? _serverUrl;
  String? _username;
  String? _password;
  final http.Client _client;

  WebDavConnector({http.Client? client}) : _client = client ?? http.Client();

  @override
  String get id => 'webdav';

  @override
  String get displayName => 'Nextcloud / WebDAV';

  @override
  String get description =>
      'Direct sync with Nextcloud, OwnCloud, Box, or any WebDAV cloud server.';

  @override
  IconData get icon => Icons.cloud_queue_outlined;

  String? get serverUrl => _serverUrl;
  String? get username => _username;

  String _authHeader() {
    final credentials = '$_username:$_password';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  String _normalizeUrl(String url) {
    var clean = url.trim();
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      clean = 'https://$clean';
    }
    if (!clean.endsWith('/')) {
      clean = '$clean/';
    }
    return clean;
  }

  @override
  Future<bool> isConnected() async {
    if (_serverUrl == null || _username == null || _password == null) {
      return false;
    }
    try {
      final uri = Uri.parse(_serverUrl!);
      final request = http.Request('PROPFIND', uri);
      request.headers['Authorization'] = _authHeader();
      request.headers['Depth'] = '0';

      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 10));
      return streamed.statusCode == 200 ||
          streamed.statusCode == 207 ||
          streamed.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> connect(Map<String, String> credentials) async {
    final url = credentials['serverUrl'];
    final user = credentials['username'];
    final pass = credentials['password'];

    if (url == null || url.trim().isEmpty) {
      throw ArgumentError('Server URL is required.');
    }
    if (user == null || user.trim().isEmpty) {
      throw ArgumentError('Username is required.');
    }
    if (pass == null || pass.trim().isEmpty) {
      throw ArgumentError('Password or App Token is required.');
    }

    _serverUrl = _normalizeUrl(url);
    _username = user.trim();
    _password = pass.trim();

    // Verify connection
    final uri = Uri.parse(_serverUrl!);
    final request = http.Request('PROPFIND', uri);
    request.headers['Authorization'] = _authHeader();
    request.headers['Depth'] = '0';

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 12));
    if (streamed.statusCode == 401 || streamed.statusCode == 403) {
      throw const WebDavAuthException('Invalid WebDAV username or password.');
    }
    if (streamed.statusCode >= 400) {
      throw WebDavServerException(
        'WebDAV server returned HTTP ${streamed.statusCode}',
      );
    }

    // Ensure remote ClinicPilot/Backups directory exists
    await _ensureRemoteDirectory();
  }

  Future<void> _ensureRemoteDirectory() async {
    if (_serverUrl == null) return;
    try {
      final backupsUri = Uri.parse('${_serverUrl!}ClinicPilot/');
      final req1 = http.Request('MKCOL', backupsUri);
      req1.headers['Authorization'] = _authHeader();
      await _client.send(req1);

      final dirUri = Uri.parse('${_serverUrl!}ClinicPilot/Backups/');
      final req2 = http.Request('MKCOL', dirUri);
      req2.headers['Authorization'] = _authHeader();
      await _client.send(req2);
    } catch (_) {
      // MKCOL returns 405 if directory already exists, which is expected.
    }
  }

  @override
  Future<void> disconnect() async {
    _serverUrl = null;
    _username = null;
    _password = null;
  }

  @override
  Future<CloudAccountInfo?> getAccountInfo() async {
    if (_serverUrl == null || _username == null) return null;
    final host = Uri.tryParse(_serverUrl!)?.host ?? _serverUrl!;
    return CloudAccountInfo(accountName: _username!, email: host);
  }

  @override
  Future<CloudUploadResult> uploadBackup(
    Uint8List bytes,
    String filename, {
    Map<String, String>? metadata,
  }) async {
    if (_serverUrl == null) {
      return CloudUploadResult.failure(
        filename,
        'WebDAV connector is not connected.',
      );
    }

    await _ensureRemoteDirectory();

    final targetUrl = '${_serverUrl!}ClinicPilot/Backups/$filename';
    try {
      final uri = Uri.parse(targetUrl);
      final response = await _client.put(
        uri,
        headers: {
          'Authorization': _authHeader(),
          'Content-Type': 'application/octet-stream',
        },
        body: bytes,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CloudUploadResult.success(filename, targetUrl);
      } else {
        return CloudUploadResult.failure(
          filename,
          'WebDAV upload failed with HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return CloudUploadResult.failure(filename, e.toString());
    }
  }

  @override
  Future<List<RemoteBackupItem>> listBackups() async {
    if (_serverUrl == null) return [];
    final targetUrl = '${_serverUrl!}ClinicPilot/Backups/';
    try {
      final uri = Uri.parse(targetUrl);
      final request = http.Request('PROPFIND', uri);
      request.headers['Authorization'] = _authHeader();
      request.headers['Depth'] = '1';

      final response = await _client.send(request);
      if (response.statusCode >= 400) return [];

      final body = await response.stream.bytesToString();
      return _parsePropfindXml(body, targetUrl);
    } catch (_) {
      return [];
    }
  }

  List<RemoteBackupItem> _parsePropfindXml(String xml, String baseUrl) {
    final items = <RemoteBackupItem>[];
    final responseRegex = RegExp(
      r'<(?:\w+:)?response[\s>](.*?)<\/(?:\w+:)?response>',
      dotAll: true,
    );
    final matches = responseRegex.allMatches(xml);

    for (final match in matches) {
      final block = match.group(1) ?? '';

      // Check if collection
      if (block.contains(
        RegExp(
          r'<(?:\w+:)?collection\s*\/>|<(?:\w+:)?resourcetype[^>]*>\s*<(?:\w+:)?collection',
        ),
      )) {
        continue; // Skip directories
      }

      final hrefMatch = RegExp(
        r'<(?:\w+:)?href>(.*?)<\/(?:\w+:)?href>',
      ).firstMatch(block);
      final lengthMatch = RegExp(
        r'<(?:\w+:)?getcontentlength>(\d+)<\/(?:\w+:)?getcontentlength>',
      ).firstMatch(block);
      final dateMatch = RegExp(
        r'<(?:\w+:)?getlastmodified>(.*?)<\/(?:\w+:)?getlastmodified>',
      ).firstMatch(block);

      if (hrefMatch == null) continue;
      final href = hrefMatch.group(1)!.trim();
      final name = Uri.decodeFull(
        href.split('/').where((s) => s.isNotEmpty).last,
      );

      if (!name.endsWith('.cpbak')) continue;

      final size =
          lengthMatch != null ? int.tryParse(lengthMatch.group(1)!) ?? 0 : 0;
      DateTime modified = DateTime.now();
      if (dateMatch != null) {
        try {
          modified = HttpDate.parse(dateMatch.group(1)!.trim());
        } catch (_) {
          try {
            modified = DateFormat(
              'EEE, dd MMM yyyy HH:mm:ss',
            ).parse(dateMatch.group(1)!.trim());
          } catch (_) {}
        }
      }

      // Resolve full download URL
      final fullDownloadUrl =
          href.startsWith('http')
              ? href
              : Uri.parse(baseUrl).resolve(href).toString();

      items.add(
        RemoteBackupItem(
          id: fullDownloadUrl,
          name: name,
          sizeBytes: size,
          modifiedAt: modified,
        ),
      );
    }

    items.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return items;
  }

  @override
  Future<Uint8List> downloadBackup(String remoteId) async {
    final uri = Uri.parse(remoteId);
    final response = await _client.get(
      uri,
      headers: {'Authorization': _authHeader()},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    } else {
      throw WebDavServerException(
        'Failed to download: HTTP ${response.statusCode}',
      );
    }
  }

  @override
  Future<bool> deleteBackup(String remoteId) async {
    try {
      final uri = Uri.parse(remoteId);
      final response = await _client.delete(
        uri,
        headers: {'Authorization': _authHeader()},
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

class WebDavAuthException implements Exception {
  final String message;
  const WebDavAuthException(this.message);

  @override
  String toString() => 'WebDavAuthException: $message';
}

class WebDavServerException implements Exception {
  final String message;
  const WebDavServerException(this.message);

  @override
  String toString() => 'WebDavServerException: $message';
}

/// Fallback RFC 1123 / 822 HTTP Date parser
class HttpDate {
  static final _httpDateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss');

  static DateTime parse(String dateStr) {
    final clean = dateStr.replaceAll(' GMT', '').replaceAll(' UTC', '').trim();
    return _httpDateFormat.parse(clean, true).toLocal();
  }
}
