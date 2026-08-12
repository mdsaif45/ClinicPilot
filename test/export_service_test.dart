import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_clinics.dart';
import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/export_service.dart';

void main() {
  late AppDatabase db;
  late ExportService service;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTestClinics(db);
    service = ExportService(db);
  });

  tearDown(() async => db.close());

  Future<void> addPatient(String id, String name,
      {String? notes, bool deleted = false}) async {
    await db.into(db.patients).insert(PatientsCompanion.insert(
          id: id,
          patientCode: Value('P-$id'),
          name: name,
          phone: '9800000000',
          age: 30,
          gender: 'Female',
          primaryClinicId: const Value('clinic_old'),
          notes: Value(notes),
          isDeleted: Value(deleted),
        ));
  }

  test('suggested filename is timestamped and ends in .csv', () {
    final name = ExportService.suggestedFileName(DateTime(2026, 8, 12, 9, 5));
    expect(name, 'clinicpilot-backup-20260812-0905.csv');
  });

  test('exports seeded clinics', () async {
    final csv = await service.buildCsv();
    expect(csv, contains('# CLINICS'));
    expect(csv, contains('# PATIENTS'));
    expect(csv, contains('# VISITS'));
    expect(csv, contains('# CASH MEMOS'));
    expect(csv, contains('# EXPENSES'));
  });

  test('patient rows appear in the export', () async {
    await addPatient('1', 'Fatima Begum');
    final csv = await service.buildCsv();
    expect(csv, contains('Fatima Begum'));
    expect(csv, contains('P-1'));
  });

  test('commas in data are quoted, not left to split the row', () async {
    await addPatient('2', 'Rahman, Ali');
    final csv = await service.buildCsv();
    expect(csv, contains('"Rahman, Ali"'));
  });

  test('embedded quotes are doubled', () async {
    await addPatient('3', 'A "Nick" B');
    final csv = await service.buildCsv();
    expect(csv, contains('"A ""Nick"" B"'));
  });

  test('newlines inside notes are quoted', () async {
    await addPatient('4', 'Line Break', notes: 'first\nsecond');
    final csv = await service.buildCsv();
    expect(csv, contains('"first\nsecond"'));
  });

  test('soft-deleted patients are excluded from the backup', () async {
    await addPatient('5', 'Gone Person', deleted: true);
    final csv = await service.buildCsv();
    expect(csv, isNot(contains('Gone Person')));
  });

  test('countRows counts only live records', () async {
    expect(await service.countRows(), 0);
    await addPatient('6', 'Counted');
    await addPatient('7', 'Not counted', deleted: true);
    expect(await service.countRows(), 1);
  });

  test('encode produces valid UTF-8 bytes', () {
    final bytes = ExportService.encode('naam, ₹500');
    expect(bytes, isNotEmpty);
  });
}
