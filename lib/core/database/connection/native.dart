import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../../services/database_encryption_service.dart';

QueryExecutor openConnection({DatabaseEncryptionService? encryptionService}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'clinic_pilot.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
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
