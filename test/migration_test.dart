import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:clinic_pilot/core/database/app_database.dart';

void main() {
  group('Database Schema v1 to v2 Migration Tests', () {
    test('v1 -> v2 migration preserves all data and is idempotent', () async {
      // 1. Create a raw SQLite in-memory database
      final executor = NativeDatabase.memory();

      // 2. Build Schema v1 tables with ORIGINAL v1 column set
      await executor.ensureOpen(dummyUser);
      await executor.runCustom('''
        CREATE TABLE clinics (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT,
          created_at INTEGER
        );
      ''');
      await executor.runCustom('''
        CREATE TABLE patients (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          age INTEGER NOT NULL,
          gender TEXT NOT NULL,
          clinic_id TEXT NOT NULL,
          disease TEXT NOT NULL,
          referral_source TEXT,
          created_at INTEGER NOT NULL
        );
      ''');
      await executor.runCustom('''
        CREATE TABLE cash_memos (
          id TEXT NOT NULL PRIMARY KEY,
          memo_number TEXT NOT NULL,
          patient_id TEXT NOT NULL,
          consultation_fee REAL NOT NULL,
          medicine_fee REAL NOT NULL,
          other_fee REAL NOT NULL,
          discount REAL NOT NULL,
          total REAL NOT NULL,
          payment_method TEXT NOT NULL,
          created_at INTEGER NOT NULL
        );
      ''');
      await executor.runCustom('''
        CREATE TABLE expenses (
          id TEXT NOT NULL PRIMARY KEY,
          clinic_id TEXT NOT NULL,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          notes TEXT,
          date INTEGER NOT NULL
        );
      ''');

      final nowTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Insert 1 legacy clinic
      await executor.runInsert(
        'INSERT INTO clinics (id, name, address, created_at) VALUES (?, ?, ?, ?)',
        ['clinic_old', 'Old Clinic', 'Babu Bazar', nowTimestamp],
      );

      // Insert 3 legacy v1 patients
      await executor.runInsert(
        'INSERT INTO patients (id, name, phone, age, gender, clinic_id, disease, referral_source, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['pat-v1-001', 'Patient One', '9876543210', 45, 'Male', 'clinic_old', 'Chronic Asthma', 'Friend', nowTimestamp],
      );
      await executor.runInsert(
        'INSERT INTO patients (id, name, phone, age, gender, clinic_id, disease, referral_source, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['pat-v1-002', 'Patient Two', '9876543211', 32, 'Female', 'clinic_old', 'Migraine', 'Google', nowTimestamp],
      );
      await executor.runInsert(
        'INSERT INTO patients (id, name, phone, age, gender, clinic_id, disease, referral_source, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['pat-v1-003', 'Patient Three', '9876543212', 28, 'Male', 'clinic_old', 'Gastritis', 'Self', nowTimestamp],
      );

      // Insert 4 legacy v1 cash memos
      await executor.runInsert(
        'INSERT INTO cash_memos (id, memo_number, patient_id, consultation_fee, medicine_fee, other_fee, discount, total, payment_method, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['memo-v1-001', 'CM-OLD-001', 'pat-v1-001', 300.0, 200.0, 0.0, 0.0, 500.0, 'Cash', nowTimestamp],
      );
      await executor.runInsert(
        'INSERT INTO cash_memos (id, memo_number, patient_id, consultation_fee, medicine_fee, other_fee, discount, total, payment_method, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['memo-v1-002', 'CM-OLD-002', 'pat-v1-002', 400.0, 300.0, 0.0, 50.0, 650.0, 'UPI', nowTimestamp],
      );
      await executor.runInsert(
        'INSERT INTO cash_memos (id, memo_number, patient_id, consultation_fee, medicine_fee, other_fee, discount, total, payment_method, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['memo-v1-003', 'CM-OLD-003', 'pat-v1-003', 300.0, 150.0, 0.0, 0.0, 450.0, 'Cash', nowTimestamp],
      );
      await executor.runInsert(
        'INSERT INTO cash_memos (id, memo_number, patient_id, consultation_fee, medicine_fee, other_fee, discount, total, payment_method, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        ['memo-v1-004', 'CM-OLD-004', 'pat-v1-001', 300.0, 250.0, 0.0, 0.0, 550.0, 'UPI', nowTimestamp],
      );

      // Insert 2 legacy expenses
      await executor.runInsert(
        'INSERT INTO expenses (id, clinic_id, category, amount, notes, date) VALUES (?, ?, ?, ?, ?, ?)',
        ['exp-v1-001', 'clinic_old', 'Rent', 3000.0, 'Legacy rent', nowTimestamp],
      );
      await executor.runInsert(
        'INSERT INTO expenses (id, clinic_id, category, amount, notes, date) VALUES (?, ?, ?, ?, ?, ?)',
        ['exp-v1-002', 'clinic_old', 'Medicine', 1200.0, 'Stock purchase', nowTimestamp],
      );

      // 3. Open with AppDatabase and trigger migration onUpgrade
      final db = AppDatabase(executor);
      await db.migration.onUpgrade(db.createMigrator(), 1, 2);

      // 4. Assert Zero Row Loss & Data Integrity
      final patients = await db.select(db.patients).get();
      expect(patients.length, equals(3), reason: 'Zero row loss: 3 patients must remain');

      for (final p in patients) {
        expect(p.primaryClinicId, isNotEmpty, reason: 'Every patient must have primaryClinicId copied');
        expect(p.primaryDisease, isNotEmpty, reason: 'Every patient must have primaryDisease copied');
        expect(p.patientCode, startsWith('P-MIG-'), reason: 'Every patient must have a generated patientCode');
      }

      final p1 = patients.firstWhere((p) => p.id == 'pat-v1-001');
      expect(p1.primaryDisease, equals('Chronic Asthma'));
      expect(p1.primaryClinicId, equals('clinic_old'));

      final memos = await db.select(db.cashMemos).get();
      expect(memos.length, equals(4), reason: 'Zero row loss: 4 cash memos must remain');
      for (final m in memos) {
        expect(m.clinicId, equals('clinic_old'));
        expect(m.visitId, equals('mig-${m.patientId}'));
        expect(m.paidAmount, equals(m.total), reason: 'Historical memos backfilled as fully paid');
      }

      final visits = await db.select(db.visits).get();
      expect(visits.length, equals(3), reason: 'One visit backfilled per existing patient');
      for (final v in visits) {
        expect(v.visitType, equals('new'));
      }

      final expenses = await db.select(db.expenses).get();
      expect(expenses.length, equals(2), reason: 'Zero row loss: 2 expenses must remain');

      // 5. Assert Idempotency: Running migration a 2nd time must be a no-op without crashing
      await expectLater(
        db.migration.onUpgrade(db.createMigrator(), 1, 2),
        completes,
        reason: 'Running migration twice must be a no-op and not throw exceptions',
      );

      final patientsAfter2ndRun = await db.select(db.patients).get();
      expect(patientsAfter2ndRun.length, equals(3));

      final visitsAfter2ndRun = await db.select(db.visits).get();
      expect(visitsAfter2ndRun.length, equals(3));

      await db.close();
    });
  });
}

final dummyUser = _DummyQueryExecutorUser();

class _DummyQueryExecutorUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}

  Future<void> createSchema(QueryExecutor executor) async {}

  Future<void> updateSchema(QueryExecutor executor, int from, int to) async {}
}
