import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import '../../services/database_encryption_service.dart';

QueryExecutor openConnection({DatabaseEncryptionService? encryptionService}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'clinic_pilot.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      sqlite3_open.open.overrideFor(sqlite3_open.OperatingSystem.android, openCipherOnAndroid);
    }
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
      setup: (rawDb) {
        if (key != null && key.isNotEmpty) {
          rawDb.execute("PRAGMA key = '$key';");
        }
      },
    );
  });
}
