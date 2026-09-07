import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:clinic_pilot/core/cloud/cloud_storage_registry.dart';
import 'package:clinic_pilot/core/cloud/connectors/google_drive_connector.dart';

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
  group('GoogleDriveConnector Metadata and Basic Auth', () {
    test('connector exposes correct identifier and descriptive metadata', () {
      final connector = GoogleDriveConnector();
      expect(connector.id, equals('google_drive'));
      expect(connector.displayName, equals('Google Drive'));
      expect(connector.description, contains('app folder'));
    });

    test(
      'throws ArgumentError if connecting with empty access token',
      () async {
        final connector = GoogleDriveConnector();
        expect(
          () => connector.connect({'accessToken': ''}),
          throwsArgumentError,
        );
      },
    );

    test('isConnected returns false if not connected', () async {
      final connector = GoogleDriveConnector();
      expect(await connector.isConnected(), isFalse);
    });

    test('disconnect clears all session credentials', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'user': {
              'displayName': 'Dr. Fatima',
              'emailAddress': 'fatima@gmail.com',
            },
          }),
          200,
        );
      });

      final connector = GoogleDriveConnector(client: mockClient);
      await connector.connect({
        'accessToken': 'valid_token_123',
        'refreshToken': 'refresh_123',
        'userEmail': 'fatima@gmail.com',
        'userName': 'Dr. Fatima',
      });

      expect(connector.accessToken, equals('valid_token_123'));
      expect(connector.refreshToken, equals('refresh_123'));
      expect(connector.userEmail, equals('fatima@gmail.com'));

      await connector.disconnect();

      expect(connector.accessToken, isNull);
      expect(connector.refreshToken, isNull);
      expect(connector.userEmail, isNull);
      expect(connector.userName, isNull);
    });
  });

  group('GoogleDriveConnector REST Operations', () {
    test(
      'getAccountInfo parses user displayName, email, and storage quota',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, contains('/drive/v3/about'));
          expect(
            request.headers['Authorization'],
            equals('Bearer test_access_token'),
          );

          return http.Response(
            jsonEncode({
              'user': {
                'displayName': 'Dr. John Doe',
                'emailAddress': 'dr.john@example.com',
              },
              'storageQuota': {
                'limit': '16106127360', // ~15 GB
                'usage': '5368709120', // ~5 GB
              },
            }),
            200,
          );
        });

        final connector = GoogleDriveConnector(client: mockClient);
        await connector.connect({'accessToken': 'test_access_token'});

        final info = await connector.getAccountInfo();
        expect(info.accountName, equals('Dr. John Doe'));
        expect(info.email, equals('dr.john@example.com'));
        expect(info.storageUsedBytes, equals(5368709120));
        expect(info.storageTotalBytes, equals(16106127360));
        expect(info.usageFraction, closeTo(0.333, 0.01));
      },
    );

    test(
      'uploadBackup sends multipart payload into appDataFolder and returns success',
      () async {
        final backupData = Uint8List.fromList([10, 20, 30, 40, 50]);
        const fileName = 'ClinicPilot_Backup_20260907.cpbak';

        final mockClient = MockClient((request) async {
          expect(request.url.path, contains('/upload/drive/v3/files'));
          expect(
            request.url.queryParameters['uploadType'],
            equals('multipart'),
          );
          expect(
            request.headers['Authorization'],
            equals('Bearer test_upload_token'),
          );
          expect(
            request.headers['Content-Type'],
            contains('multipart/related'),
          );

          return http.Response(
            jsonEncode({'id': 'gdrive_file_id_9988', 'name': fileName}),
            200,
          );
        });

        final connector = GoogleDriveConnector(client: mockClient);
        await connector.connect({'accessToken': 'test_upload_token'});

        final result = await connector.uploadBackup(backupData, fileName);
        expect(result.success, isTrue);
        expect(result.fileId, equals('gdrive_file_id_9988'));
        expect(result.fileName, equals(fileName));
      },
    );

    test(
      'listBackups queries appDataFolder and filters ClinicPilot .cpbak archives',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.path, contains('/drive/v3/files'));
          expect(
            request.url.queryParameters['spaces'],
            equals('appDataFolder'),
          );

          return http.Response(
            jsonEncode({
              'files': [
                {
                  'id': 'file_1',
                  'name': 'ClinicPilot_Backup_20260907_120000.cpbak',
                  'size': '2048',
                  'modifiedTime': '2026-09-07T12:00:00Z',
                  'md5Checksum': 'abc123md5',
                  'appProperties': {'app': 'ClinicPilot'},
                },
                {
                  'id': 'file_2',
                  'name': 'other_random_file.json',
                  'size': '512',
                  'modifiedTime': '2026-09-06T10:00:00Z',
                },
              ],
            }),
            200,
          );
        });

        final connector = GoogleDriveConnector(client: mockClient);
        await connector.connect({'accessToken': 'test_token'});

        final list = await connector.listBackups();
        expect(list.length, equals(1));
        expect(list.first.id, equals('file_1'));
        expect(
          list.first.name,
          equals('ClinicPilot_Backup_20260907_120000.cpbak'),
        );
        expect(list.first.sizeBytes, equals(2048));
        expect(list.first.formattedSize, equals('2.0 KB'));
        expect(list.first.checksumSha256, equals('abc123md5'));
      },
    );

    test('downloadBackup fetches raw binary bytes with alt=media', () async {
      final rawBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/drive/v3/files/backup_file_42'));
        expect(request.url.queryParameters['alt'], equals('media'));

        return http.Response.bytes(rawBytes, 200);
      });

      final connector = GoogleDriveConnector(client: mockClient);
      await connector.connect({'accessToken': 'test_token'});

      final downloaded = await connector.downloadBackup('backup_file_42');
      expect(downloaded, equals(rawBytes));
    });

    test('deleteBackup sends DELETE request to file resource', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, equals('DELETE'));
        expect(request.url.path, contains('/drive/v3/files/backup_to_delete'));

        return http.Response('', 204);
      });

      final connector = GoogleDriveConnector(client: mockClient);
      await connector.connect({'accessToken': 'test_token'});

      final ok = await connector.deleteBackup('backup_to_delete');
      expect(ok, isTrue);
    });
  });

  group('GoogleDriveConnector Token Refresh & Registry Integration', () {
    test(
      'refreshAccessToken requests new token and invokes onTokensChanged callback',
      () async {
        int refreshCallCount = 0;
        String? persistedNewToken;

        final mockClient = MockClient((request) async {
          if (request.url.host == 'oauth2.googleapis.com' &&
              request.url.path == '/token') {
            refreshCallCount++;
            expect(request.bodyFields['grant_type'], equals('refresh_token'));
            expect(
              request.bodyFields['refresh_token'],
              equals('my_refresh_token'),
            );

            return http.Response(
              jsonEncode({
                'access_token': 'new_renewed_access_token',
                'expires_in': 3600,
              }),
              200,
            );
          }
          return http.Response('Not Found', 404);
        });

        final connector = GoogleDriveConnector(
          client: mockClient,
          onTokensChanged: ({
            required String accessToken,
            String? refreshToken,
            DateTime? expiresAt,
            String? userEmail,
            String? userName,
          }) async {
            persistedNewToken = accessToken;
          },
        );

        // Connect with valid token
        await connector.connect({
          'accessToken': 'initial_token',
          'refreshToken': 'my_refresh_token',
        });

        expect(connector.accessToken, equals('initial_token'));

        // Trigger manual refresh
        await connector.refreshAccessToken();

        expect(refreshCallCount, equals(1));
        expect(connector.accessToken, equals('new_renewed_access_token'));
        expect(persistedNewToken, equals('new_renewed_access_token'));
        expect(connector.isTokenExpired, isFalse);
      },
    );

    test(
      'automatically refreshes expired token during connect or backup upload',
      () async {
        int refreshCallCount = 0;
        int uploadCallCount = 0;

        final mockClient = MockClient((request) async {
          if (request.url.host == 'oauth2.googleapis.com' &&
              request.url.path == '/token') {
            refreshCallCount++;
            return http.Response(
              jsonEncode({
                'access_token': 'renewed_token_456',
                'expires_in': 3600,
              }),
              200,
            );
          }

          if (request.url.host == 'www.googleapis.com' &&
              request.url.path.contains('/files')) {
            uploadCallCount++;
            expect(
              request.headers['Authorization'],
              equals('Bearer renewed_token_456'),
            );
            return http.Response(
              jsonEncode({'id': 'file_456', 'name': 'auto_sync.cpbak'}),
              200,
            );
          }

          if (request.url.host == 'www.googleapis.com' &&
              request.url.path.contains('/about')) {
            return http.Response(
              jsonEncode({
                'user': {'displayName': 'Dr. Test'},
              }),
              200,
            );
          }

          return http.Response('Not Found', 404);
        });

        final connector = GoogleDriveConnector(client: mockClient);

        // Connect with expired token -> triggers auto-refresh during connect verification
        await connector.connect({
          'accessToken': 'old_expired_token',
          'refreshToken': 'valid_refresh_token',
          'expiresAt':
              DateTime.now()
                  .subtract(const Duration(minutes: 10))
                  .toIso8601String(),
        });

        expect(refreshCallCount, equals(1));
        expect(connector.accessToken, equals('renewed_token_456'));

        // Perform upload using refreshed token
        final result = await connector.uploadBackup(
          Uint8List.fromList([1, 2, 3]),
          'auto_sync.cpbak',
        );

        expect(result.success, isTrue);
        expect(uploadCallCount, equals(1));
      },
    );

    test(
      'CloudStorageRegistry configures, connects, and persists Google Drive credentials',
      () async {
        final fakeStorage = FakeSecureStorage();
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'user': {
                'displayName': 'Dr. Sharma',
                'emailAddress': 'sharma@clinic.in',
              },
            }),
            200,
          );
        });

        final gdriveConnector = GoogleDriveConnector(client: mockClient);
        final registry = CloudStorageRegistry(
          secureStorage: fakeStorage,
          initialConnectors: [gdriveConnector],
        );

        await registry.configureAndConnect('google_drive', {
          'accessToken': 'gd_token_abc',
          'refreshToken': 'gd_refresh_xyz',
          'userEmail': 'sharma@clinic.in',
          'userName': 'Dr. Sharma',
        });

        expect(registry.activeConnectorId, equals('google_drive'));
        expect(registry.activeConnector, isNotNull);

        // Verify persisted in secure storage
        expect(
          await fakeStorage.read(key: kCloudActiveProviderKey),
          equals('google_drive'),
        );
        expect(
          await fakeStorage.read(key: kCloudGoogleDriveAccessTokenKey),
          equals('gd_token_abc'),
        );
        expect(
          await fakeStorage.read(key: kCloudGoogleDriveRefreshTokenKey),
          equals('gd_refresh_xyz'),
        );
        expect(
          await fakeStorage.read(key: kCloudGoogleDriveEmailKey),
          equals('sharma@clinic.in'),
        );

        // Disconnect active
        await registry.disconnectActive();
        expect(registry.activeConnectorId, isNull);
        expect(registry.activeConnector, isNull);
        expect(await fakeStorage.read(key: kCloudActiveProviderKey), isNull);
        expect(
          await fakeStorage.read(key: kCloudGoogleDriveAccessTokenKey),
          isNull,
        );
      },
    );
  });
}
