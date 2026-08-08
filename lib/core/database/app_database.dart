import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

import 'tables/clinics.dart';
import 'tables/patients.dart';
import 'tables/cash_memos.dart';
import 'tables/expenses.dart';

part 'app_database.g.dart';

// Type-safe database powered by Drift ORM (Mobile, Desktop, and Web ready)
@DriftDatabase(tables: [Clinics, Patients, CashMemos, Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.openConnection());

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
