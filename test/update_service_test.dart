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
      expect(
        () => UpdateService.compareVersions('abc', '0.2.0'),
        returnsNormally,
      );
      expect(() => UpdateService.compareVersions('', '0.2.0'), returnsNormally);
      expect(
        () => UpdateService.compareVersions('1.x.0', '1.0.0'),
        returnsNormally,
      );
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
        return http.Response(
          validReleaseJson,
          200,
          headers: {'content-type': 'application/json'},
        );
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

    test('Split-per-abi release parses all three apk assets', () async {
      const splitReleaseJson = '''
      {
        "tag_name": "v0.8.0",
        "body": "Split per ABI",
        "published_at": "2026-08-20T12:00:00Z",
        "assets": [
          {
            "name": "ClinicPilot-v0.8.0-armeabi-v7a-release.apk",
            "browser_download_url": "https://example.com/armeabi-v7a.apk",
            "size": 12000000
          },
          {
            "name": "ClinicPilot-v0.8.0-arm64-v8a-release.apk",
            "browser_download_url": "https://example.com/arm64-v8a.apk",
            "size": 13000000
          },
          {
            "name": "ClinicPilot-v0.8.0-x86_64-release.apk",
            "browser_download_url": "https://example.com/x86_64.apk",
            "size": 14000000
          }
        ]
      }
      ''';

      final mockClient = MockClient((request) async {
        return http.Response(splitReleaseJson, 200);
      });

      final service = UpdateService(
        client: mockClient,
        overridePackageInfo: mockPackageInfo,
      );

      final release = await service.checkForUpdate();
      expect(release, isNotNull);
      expect(release!.apkAssets, hasLength(3));
      expect(
        release.apkAssets.map((a) => a.name),
        containsAll([
          'ClinicPilot-v0.8.0-armeabi-v7a-release.apk',
          'ClinicPilot-v0.8.0-arm64-v8a-release.apk',
          'ClinicPilot-v0.8.0-x86_64-release.apk',
        ]),
      );
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

  group('UpdateService.pickApkForAbis - split-per-abi asset selection', () {
    const armeabi = ApkAsset(
      name: 'ClinicPilot-v0.8.0-armeabi-v7a-release.apk',
      downloadUrl: 'https://example.com/armeabi-v7a.apk',
      sizeBytes: 12000000,
    );
    const arm64 = ApkAsset(
      name: 'ClinicPilot-v0.8.0-arm64-v8a-release.apk',
      downloadUrl: 'https://example.com/arm64-v8a.apk',
      sizeBytes: 13000000,
    );
    const x86_64 = ApkAsset(
      name: 'ClinicPilot-v0.8.0-x86_64-release.apk',
      downloadUrl: 'https://example.com/x86_64.apk',
      sizeBytes: 14000000,
    );
    final assets = [armeabi, arm64, x86_64];

    test('arm64 device picks the arm64-v8a asset', () {
      final picked = UpdateService.pickApkForAbis(assets, [
        'arm64-v8a',
        'armeabi-v7a',
      ]);
      expect(picked, same(arm64));
    });

    test('32-bit-only device picks the armeabi-v7a asset', () {
      final picked = UpdateService.pickApkForAbis(assets, [
        'armeabi-v7a',
        'armeabi',
      ]);
      expect(picked, same(armeabi));
    });

    test('x86_64 emulator picks the x86_64 asset', () {
      final picked = UpdateService.pickApkForAbis(assets, ['x86_64']);
      expect(picked, same(x86_64));
    });

    test('unknown ABI falls back to the first asset rather than nothing', () {
      final picked = UpdateService.pickApkForAbis(assets, ['riscv64']);
      expect(picked, same(armeabi));
    });

    test('empty ABI list falls back to the first asset', () {
      final picked = UpdateService.pickApkForAbis(assets, []);
      expect(picked, same(armeabi));
    });

    test('empty asset list returns null', () {
      final picked = UpdateService.pickApkForAbis([], ['arm64-v8a']);
      expect(picked, isNull);
    });

    test('pickApk resolves via the overridden ABI list end-to-end', () async {
      final service = UpdateService(overrideSupportedAbis: ['arm64-v8a']);
      final release = AppRelease(
        version: '0.8.0',
        tagName: 'v0.8.0',
        notes: '',
        apkAssets: assets,
        publishedAt: DateTime(2026, 8, 20),
      );

      final picked = await service.pickApk(release);
      expect(picked, same(arm64));
    });
  });
}
