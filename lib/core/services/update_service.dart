import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class AppRelease {
  final String version;      // normalised, no leading 'v'  e.g. "0.3.0"
  final String tagName;      // raw tag                     e.g. "v0.3.0"
  final String notes;        // release body markdown
  final String? apkUrl;      // browser_download_url of the .apk asset
  final int apkSizeBytes;
  final DateTime publishedAt;

  const AppRelease({
    required this.version,
    required this.tagName,
    required this.notes,
    this.apkUrl,
    required this.apkSizeBytes,
    required this.publishedAt,
  });

  factory AppRelease.fromGitHubJson(Map<String, dynamic> json) {
    final rawTag = json['tag_name'] as String? ?? '';
    final version = rawTag.startsWith(RegExp(r'[vV]')) ? rawTag.substring(1) : rawTag;
    final notes = json['body'] as String? ?? '';
    final publishedAtStr = json['published_at'] as String?;
    final publishedAt = publishedAtStr != null
        ? (DateTime.tryParse(publishedAtStr) ?? DateTime.now())
        : DateTime.now();

    String? apkUrl;
    int apkSizeBytes = 0;

    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final name = asset['name'] as String? ?? '';
        if (name.toLowerCase().endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          apkSizeBytes = (asset['size'] as num?)?.toInt() ?? 0;
          break;
        }
      }
    }

    return AppRelease(
      version: version,
      tagName: rawTag,
      notes: notes,
      apkUrl: apkUrl,
      apkSizeBytes: apkSizeBytes,
      publishedAt: publishedAt,
    );
  }
}

class UpdateService {
  static const String _latestReleaseUrl =
      'https://api.github.com/repos/mdsaif45/ClinicPilot/releases/latest';

  final http.Client _client;
  final PackageInfo? _overridePackageInfo;

  UpdateService({
    http.Client? client,
    PackageInfo? overridePackageInfo,
  })  : _client = client ?? http.Client(),
        _overridePackageInfo = overridePackageInfo;

  /// Compares two version strings semantically.
  /// Returns 1 if a > b, -1 if a < b, 0 if a == b.
  /// Handles leading 'v', '+build' suffixes, and malformed strings safely.
  static int compareVersions(String a, String b) {
    final normA = _normalizeVersion(a);
    final normB = _normalizeVersion(b);

    final partsA = normA.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = normB.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = partsA.length > partsB.length ? partsA.length : partsB.length;

    for (int i = 0; i < maxLen; i++) {
      final valA = i < partsA.length ? partsA[i] : 0;
      final valB = i < partsB.length ? partsB[i] : 0;

      if (valA > valB) return 1;
      if (valA < valB) return -1;
    }

    return 0;
  }

  static String _normalizeVersion(String v) {
    var cleaned = v.trim();
    if (cleaned.startsWith(RegExp(r'[vV]'))) {
      cleaned = cleaned.substring(1);
    }
    // Remove build metadata e.g. "0.2.0+2" -> "0.2.0"
    if (cleaned.contains('+')) {
      cleaned = cleaned.split('+').first;
    }
    return cleaned;
  }

  /// Checks GitHub API for latest release. Returns [AppRelease] only if it is strictly
  /// newer than the running installed version.
  Future<AppRelease?> checkForUpdate() async {
    try {
      final response = await _client.get(
        Uri.parse(_latestReleaseUrl),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final release = AppRelease.fromGitHubJson(json);

      if (release.apkUrl == null || release.apkUrl!.isEmpty) {
        return null;
      }

      final currentVersion = _overridePackageInfo?.version ??
          (await PackageInfo.fromPlatform()).version;

      if (compareVersions(release.version, currentVersion) > 0) {
        return release;
      }

      return null;
    } catch (_) {
      // Network timeout, rate limiting, offline, or json error -> silently return null
      return null;
    }
  }

  /// Downloads the APK from release.apkUrl emitting progress (0.0 to 1.0) and returns local path.
  Stream<double> downloadApkStream(
    AppRelease release, {
    required Function(String filePath) onComplete,
    required Function(Object error) onError,
  }) async* {
    if (release.apkUrl == null) {
      onError('No download URL available for release.');
      return;
    }

    try {
      final request = http.Request('GET', Uri.parse(release.apkUrl!));
      final response = await _client.send(request).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        onError('Download failed with status code ${response.statusCode}');
        return;
      }

      final contentLength = response.contentLength ?? release.apkSizeBytes;
      final tempDir = await getTemporaryDirectory();
      final saveFile = File('${tempDir.path}/clinicpilot-update-${release.version}.apk');

      int downloaded = 0;
      final sink = saveFile.openWrite();

      await for (final chunk in response.stream) {
        downloaded += chunk.length;
        sink.add(chunk);
        if (contentLength > 0) {
          yield downloaded / contentLength;
        }
      }

      await sink.flush();
      await sink.close();

      onComplete(saveFile.path);
    } catch (e) {
      onError(e);
    }
  }

  /// Convenience method for downloading APK with progress callback.
  Future<String?> downloadApk(
    AppRelease release, {
    void Function(double progress)? onProgress,
  }) async {
    if (release.apkUrl == null) return null;

    try {
      final request = http.Request('GET', Uri.parse(release.apkUrl!));
      final response = await _client.send(request).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) return null;

      final contentLength = response.contentLength ?? release.apkSizeBytes;
      final tempDir = await getTemporaryDirectory();
      final saveFile = File('${tempDir.path}/clinicpilot-update-${release.version}.apk');

      int downloaded = 0;
      final sink = saveFile.openWrite();

      await for (final chunk in response.stream) {
        downloaded += chunk.length;
        sink.add(chunk);
        if (contentLength > 0 && onProgress != null) {
          onProgress(downloaded / contentLength);
        }
      }

      await sink.flush();
      await sink.close();

      return saveFile.path;
    } catch (_) {
      return null;
    }
  }

  /// Launches system package installer via open_filex.
  Future<OpenResult> installApk(String filePath) async {
    return await OpenFilex.open(filePath);
  }
}
