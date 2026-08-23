import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import '../../services/database_encryption_service.dart';

// Per sqlcipher_flutter_libs' own docs: this uses platform channels, which
// are unreliable off the main isolate, and must run before any isolate that
// touches sqlite3 is spawned - so it belongs at the top of openConnection,
// not inside isolateSetup.
Future<void> _applyAndroidCipherWorkaroundOnce() async {
  if (!Platform.isAndroid) return;
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
}

// overrideFor is plain Dart global state confined to one isolate. Both the
// main isolate (openConnection touches `sqlite3.tempDirectory` directly
// below) and the background isolate NativeDatabase.createInBackground spawns
// need it called independently - isolateSetup exists precisely to run this
// inside that second isolate.
void _overrideAndroidSqlite3Open() {
  if (!Platform.isAndroid) return;
  sqlite3_open.open.overrideFor(sqlite3_open.OperatingSystem.android, openCipherOnAndroid);
}

QueryExecutor openConnection({DatabaseEncryptionService? encryptionService}) {
  return LazyDatabase(() async {
    await _applyAndroidCipherWorkaroundOnce();
    _overrideAndroidSqlite3Open();

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'clinic_pilot.sqlite'));
    final cachebase = await getTemporaryDirectory();
    sqlite3.tempDirectory = cachebase.path;

    final service = encryptionService ?? DatabaseEncryptionService();
    String? key;
    try {
      key = await service.getOrCreateDatabaseKey();
    } catch (_) {
      // Secure storage fallback in non-supported environments
      key = null;
    }

    return NativeDatabase.createInBackground(
      file,
      isolateSetup: () async {
        _overrideAndroidSqlite3Open();
      },
      setup: (rawDb) {
        // Confirms the linked library is actually SQLCipher, not plain
        // sqlite3 - PRAGMA key silently no-ops on plain sqlite3, which would
        // otherwise leave the database unencrypted without any error.
        final cipherVersion = rawDb.select('PRAGMA cipher_version;');
        if (Platform.isAndroid && cipherVersion.isEmpty) {
          throw StateError(
            'SQLCipher native library is not loaded; refusing to open the '
            'database as it would not be encrypted.',
          );
        }

        if (key != null && key.isNotEmpty) {
          rawDb.execute("PRAGMA key = '$key';");
        }
      },
    );
  });
}
