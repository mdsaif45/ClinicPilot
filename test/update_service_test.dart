import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:clinic_pilot/core/services/update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpdateService - Version Comparison Unit Tests', () {
    test('0.3.0 > 0.2.0', () {
      expect(UpdateService.compareVersions('0.3.0', '0.2.0'), 1);
    });

    test('0.10.0 > 0.9.0 (numeric comparison vs string comparison)', () {
      expect(UpdateService.compareVersions('0.10.0', '0.9.0'), 1);
    });

    test('1.0.0 > 0.99.99', () {
      expect(UpdateService.compareVersions('1.0.0', '0.99.99'), 1);
    });

    test('0.2.0 == 0.2.0', () {
      expect(UpdateService.compareVersions('0.2.0', '0.2.0'), 0);
    });

    test('0.2.0 < 0.3.0 (installed build is newer)', () {
      expect(UpdateService.compareVersions('0.2.0', '0.3.0'), -1);
    });

    test('leading v stripped: v0.3.0 vs 0.3.0', () {
      expect(UpdateService.compareVersions('v0.3.0', '0.3.0'), 0);
      expect(UpdateService.compareVersions('0.3.0', 'v0.3.0'), 0);
      expect(UpdateService.compareVersions('V0.3.0', '0.2.0'), 1);
    });

    test('+build suffix ignored: 0.2.0+2 vs 0.2.0+5 -> equal', () {
      expect(UpdateService.compareVersions('0.2.0+2', '0.2.0+5'), 0);
      expect(UpdateService.compareVersions('0.3.0+1', '0.2.0+10'), 1);
    });

    test('malformed inputs handle gracefully without throwing', () {
      expect(() => UpdateService.compareVersions('abc', '0.2.0'), returnsNormally);
      expect(() => UpdateService.compareVersions('', '0.2.0'), returnsNormally);
      expect(() => UpdateService.compareVersions('1.x.0', '1.0.0'), returnsNormally);
      expect(UpdateService.compareVersions('abc', '0.0.0'), 0);
    });
  });

  group('UpdateService - Release Parsing & Network Failure Unit Tests', () {
    final mockPackageInfo = PackageInfo(
      appName: 'ClinicPilot',
      packageName: 'com.clinicpilot.clinic_pilot',
      version: '0.2.0',
      buildNumber: '2',
    );

    const validReleaseJson = '''
    {
      "tag_name": "v0.3.0",
      "body": "## What is new in v0.3.0\\n- In-app updates\\n- Release signing",
      "published_at": "2026-08-10T12:00:00Z",
      "assets": [
        {
          "name": "app-release.apk",
          "browser_download_url": "https://github.com/mdsaif45/ClinicPilot/releases/download/v0.3.0/app-release.apk",
          "size": 30517578
        }
      ]
    }
    ''';

    test('Valid GitHub JSON parses into AppRelease', () async {
      final mockClient = MockClient((request) async {
        return http.Response(validReleaseJson, 200, headers: {
          'content-type': 'application/json',
        });
      });

      final service = UpdateService(
        client: mockClient,
        overridePackageInfo: mockPackageInfo,
      );

      final release = await service.checkForUpdate();
      expect(release, isNotNull);
      expect(release!.version, '0.3.0');
      expect(release.tagName, 'v0.3.0');
      expect(release.apkUrl, contains('app-release.apk'));
      expect(release.apkSizeBytes, 30517578);
      expect(release.notes, contains('In-app updates'));
    });

    test('Release with no .apk asset -> returns null', () async {
      const jsonNoApk = '''
      {
        "tag_name": "v0.3.0",
        "body": "Release without APK",
        "published_at": "2026-08-10T12:00:00Z",
        "assets": [
          {
            "name": "source.zip",
            "browser_download_url": "https://example.com/source.zip",
            "size": 1000
          }
        ]
      }
      ''';

      final mockClient = MockClient((request) async {
        return http.Response(jsonNoApk, 200);
      });

      final service = UpdateService(
        client: mockClient,
        overridePackageInfo: mockPackageInfo,
      );

      final release = await service.checkForUpdate();
      expect(release, isNull);
    });

    test('HTTP 403 rate limit -> returns null, no throw', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"message": "API rate limit exceeded"}', 403);
      });

      final service = UpdateService(
        client: mockClient,
        overridePackageInfo: mockPackageInfo,
      );

      final release = await service.checkForUpdate();
      expect(release, isNull);
    });

    test('Malformed JSON -> returns null, no throw', () async {
      final mockClient = MockClient((request) async {
        return http.Response('THIS IS NOT JSON {{{', 200);
      });

      final service = UpdateService(
        client: mockClient,
        overridePackageInfo: mockPackageInfo,
      );

      final release = await service.checkForUpdate();
      expect(release, isNull);
    });

    test('Network exception / timeout -> returns null, no throw', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Network error / Aeroplane mode');
      });

      final service = UpdateService(
        client: mockClient,
        overridePackageInfo: mockPackageInfo,
      );

      final release = await service.checkForUpdate();
      expect(release, isNull);
    });

    test('Same or older version remote -> returns null', () async {
      const olderReleaseJson = '''
      {
        "tag_name": "v0.1.5",
        "body": "Old release",
        "published_at": "2026-01-01T12:00:00Z",
        "assets": [
          {
            "name": "app-release.apk",
            "browser_download_url": "https://example.com/app-release.apk",
            "size": 20000000
          }
        ]
      }
      ''';

      final mockClient = MockClient((request) async {
        return http.Response(olderReleaseJson, 200);
      });

      final service = UpdateService(
        client: mockClient,
        overridePackageInfo: mockPackageInfo,
      );

      final release = await service.checkForUpdate();
      expect(release, isNull);
    });
  });
}
