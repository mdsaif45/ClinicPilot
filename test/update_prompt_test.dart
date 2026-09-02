import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:drift/native.dart';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/services/update_service.dart';
import 'package:clinic_pilot/features/settings/providers/release_provider.dart';
import 'package:clinic_pilot/features/settings/providers/update_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('update prompt notifies on launch and on next session after Later', () async {
    final db = AppDatabase(NativeDatabase.memory());

    const v088Json = '''
    {
      "tag_name": "v0.8.8",
      "name": "ClinicPilot v0.8.8",
      "body": "Release notes for 0.8.8",
      "published_at": "2026-09-02T10:30:00Z",
      "assets": [
        {
          "name": "ClinicPilot-v0.8.8-arm64-v8a-release.apk",
          "browser_download_url": "https://github.com/mdsaif45/ClinicPilot/releases/download/v0.8.8/ClinicPilot-v0.8.8-arm64-v8a-release.apk",
          "size": 50000000
        }
      ]
    }
    ''';

    final mockClient = MockClient((request) async {
      return http.Response(v088Json, 200, headers: {'content-type': 'application/json'});
    });

    final mockService = UpdateService(
      client: mockClient,
      overridePackageInfo: PackageInfo(
        appName: 'ClinicPilot',
        packageName: 'com.clinicpilot.clinic_pilot',
        version: '0.8.7',
        buildNumber: '9',
      ),
    );

    // Session 1:
    final container1 = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        updateServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container1.dispose);

    await container1.read(updatePromptProvider.notifier).evaluate();
    expect(container1.read(updatePromptProvider)?.version, '0.8.8');

    // User taps "Later" -> dismisses for this session:
    container1.read(updatePromptProvider.notifier).dismiss();
    expect(container1.read(updatePromptProvider), isNull);

    // Session 2 (user restarts/reopens app):
    final container2 = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        updateServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container2.dispose);

    // On reopen, evaluate() should notify again!
    await container2.read(updatePromptProvider.notifier).evaluate();
    expect(container2.read(updatePromptProvider)?.version, '0.8.8');
  });
}
