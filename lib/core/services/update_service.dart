import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

/// One .apk asset attached to a release - a split-per-abi build attaches
/// three (arm64-v8a, armeabi-v7a, x86_64), named
/// ClinicPilot-{tag}-{arch}-release.apk.
class ApkAsset {
  final String name;
  final String downloadUrl;
  final int sizeBytes;

  const ApkAsset({
    required this.name,
    required this.downloadUrl,
    required this.sizeBytes,
  });
}

class AppRelease {
  final String version;      // normalised, no leading 'v'  e.g. "0.3.0"
  final String tagName;      // raw tag                     e.g. "v0.3.0"
  final String notes;        // release body markdown
  final DateTime publishedAt;

  /// Every .apk asset on the release, unfiltered. Picking the one that
  /// matches this device happens separately (see [UpdateService._pickApk]) -
  /// a release can be parsed and cached without knowing what phone will read
  /// it back.
  final List<ApkAsset> apkAssets;

  /// The payload this was parsed from, so a release can be cached and rebuilt
  /// without a second network call.
  final Map<String, dynamic> rawJson;

  const AppRelease({
    required this.version,
    required this.tagName,
    required this.notes,
    required this.apkAssets,
    required this.publishedAt,
    this.rawJson = const {},
  });

  /// The single asset a pre-split-per-abi caller (or a test) expects - the
  /// first apk attached, or null if none. Prefer [UpdateService]'s ABI-aware
  /// selection for an actual download.
  ApkAsset? get firstApk => apkAssets.isEmpty ? null : apkAssets.first;

  String? get apkUrl => firstApk?.downloadUrl;
  int get apkSizeBytes => firstApk?.sizeBytes ?? 0;

  factory AppRelease.fromGitHubJson(Map<String, dynamic> json) {
    final rawTag = json['tag_name'] as String? ?? '';
    final version = rawTag.startsWith(RegExp(r'[vV]')) ? rawTag.substring(1) : rawTag;
    final notes = json['body'] as String? ?? '';
    final publishedAtStr = json['published_at'] as String?;
    final publishedAt = publishedAtStr != null
        ? (DateTime.tryParse(publishedAtStr) ?? DateTime.now())
        : DateTime.now();

    final apkAssets = <ApkAsset>[];
    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final name = asset['name'] as String? ?? '';
        if (name.toLowerCase().endsWith('.apk')) {
          final url = asset['browser_download_url'] as String?;
          if (url != null) {
            apkAssets.add(ApkAsset(
              name: name,
              downloadUrl: url,
              sizeBytes: (asset['size'] as num?)?.toInt() ?? 0,
            ));
          }
        }
      }
    }

    return AppRelease(
      version: version,
      tagName: rawTag,
      notes: notes,
      apkAssets: apkAssets,
      rawJson: json,
      publishedAt: publishedAt,
    );
  }
}

class UpdateService {
  static const String _latestReleaseUrl =
      'https://api.github.com/repos/mdsaif45/ClinicPilot/releases/latest';

  final http.Client _client;
  final PackageInfo? _overridePackageInfo;
  final List<String>? _overrideSupportedAbis;

  UpdateService({
    http.Client? client,
    PackageInfo? overridePackageInfo,
    List<String>? overrideSupportedAbis,
  })  : _client = client ?? http.Client(),
        _overridePackageInfo = overridePackageInfo,
        _overrideSupportedAbis = overrideSupportedAbis;

  /// The running device's ABIs, most-preferred first (e.g.
  /// ['arm64-v8a', 'armeabi-v7a', 'armeabi']) - what a split-per-abi release
  /// asset is matched against. Empty (never null) off Android, so asset
  /// selection falls back to "just pick one" rather than throwing.
  Future<List<String>> _supportedAbis() async {
    if (_overrideSupportedAbis != null) return _overrideSupportedAbis;
    if (!Platform.isAndroid) return const [];
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.supportedAbis;
    } catch (_) {
      return const [];
    }
  }

  /// Picks the asset matching this device out of every apk a release
  /// attaches. A split-per-abi release names each
  /// ClinicPilot-{tag}-{arch}-release.apk; the {arch} segment is matched
  /// against the device's own supported-ABI list, most-preferred ABI first,
  /// so a v7 device on an arm64 phone loses to the 64-bit build it actually
  /// prefers.
  ///
  /// Falls back to the first attached apk when nothing matches - an older
  /// release built as one universal APK, or a device whose ABI list could
  /// not be read - so an update is still offered rather than silently
  /// disappearing.
  static ApkAsset? pickApkForAbis(
    List<ApkAsset> assets,
    List<String> supportedAbis,
  ) {
    if (assets.isEmpty) return null;
    for (final abi in supportedAbis) {
      for (final asset in assets) {
        if (asset.name.toLowerCase().contains(abi.toLowerCase())) {
          return asset;
        }
      }
    }
    return assets.first;
  }

  /// The asset this device should download from [release] - resolves the
  /// device's real ABI list and matches it against every apk the release
  /// attaches.
  Future<ApkAsset?> pickApk(AppRelease release) async {
    final abis = await _supportedAbis();
    return pickApkForAbis(release.apkAssets, abis);
  }

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

  /// Fetches the latest published release, whatever its version.
  ///
  /// [checkForUpdate] deliberately returns null when the app is current, which
  /// is right for an update prompt but useless for a release-notes screen -
  /// that needs the notes for the version already installed.
  Future<AppRelease?> fetchLatestRelease() async {
    try {
      final response = await _client.get(
        Uri.parse(_latestReleaseUrl),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      return AppRelease.fromGitHubJson(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
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

  /// Downloads the apk asset matching this device's ABI, emitting progress
  /// (0.0 to 1.0), and returns the local path.
  Stream<double> downloadApkStream(
    AppRelease release, {
    required Function(String filePath) onComplete,
    required Function(Object error) onError,
  }) async* {
    final asset = await pickApk(release);
    if (asset == null) {
      onError('No download URL available for release.');
      return;
    }

    try {
      final request = http.Request('GET', Uri.parse(asset.downloadUrl));
      final response = await _client.send(request).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        onError('Download failed with status code ${response.statusCode}');
        return;
      }

      final contentLength = response.contentLength ?? asset.sizeBytes;
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

  /// Convenience method for downloading the ABI-matched APK with a progress callback.
  Future<String?> downloadApk(
    AppRelease release, {
    void Function(double progress)? onProgress,
  }) async {
    final asset = await pickApk(release);
    if (asset == null) return null;

    try {
      final request = http.Request('GET', Uri.parse(asset.downloadUrl));
      final response = await _client.send(request).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) return null;

      final contentLength = response.contentLength ?? asset.sizeBytes;
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
