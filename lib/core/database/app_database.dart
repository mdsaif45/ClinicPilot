import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables/clinics.dart';
import 'tables/patients.dart';
import 'tables/cash_memos.dart';
import 'tables/expenses.dart';

part 'app_database.g.dart';

// Type-safe SQLite database powered by Drift ORM
@DriftDatabase(tables: [Clinics, Patients, CashMemos, Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Seed default clinic for immediate usage
          await into(clinics).insert(
            ClinicsCompanion.insert(
              id: 'default_clinic',
              name: "Dr Zaid's Clinic",
              address: const Value('Main Branch'),
            ),
          );
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      return NativeDatabase.memory();
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'clinic_pilot.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final cachebase = await getTemporaryDirectory();
    sqlite3.tempDirectory = cachebase.path;
    return NativeDatabase.createInBackground(file);
  });
}
