import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/seed_clinics.dart';

/// A memo's reporting date must be the date the money moved, not the moment
/// the row happened to be written.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTestClinics(db);
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: 'p1',
            patientCode: const Value('P-2026-00001'),
            name: 'Backdated Patient',
            phone: '9800000001',
            age: 40,
            gender: 'Male',
            primaryClinicId: const Value('clinic_old'),
          ),
        );
  });

  tearDown(() async => db.close());

  Future<void> addMemo({
    required String id,
    required double total,
    required DateTime memoDate,
    required DateTime createdAt,
  }) {
    return db
        .into(db.cashMemos)
        .insert(
          CashMemosCompanion.insert(
            id: id,
            memoNumber: 'CM-2026-$id',
            patientId: 'p1',
            clinicId: const Value('clinic_old'),
            total: total,
            paymentMethod: 'Cash',
            memoDate: Value(memoDate),
            createdAt: Value(createdAt),
          ),
        );
  }

  test(
    'memo entered after midnight still reports in the month it was earned',
    () async {
      // Evening clinic on 31 March, written up at 00:20 on 1 April.
      await addMemo(
        id: 'm1',
        total: 900,
        memoDate: DateTime(2026, 3, 31, 20, 0),
        createdAt: DateTime(2026, 4, 1, 0, 20),
      );

      final march =
          await (db.select(db.cashMemos)..where(
            (t) =>
                t.memoDate.isBiggerOrEqual(Variable(DateTime(2026, 3, 1))) &
                t.memoDate.isSmallerThan(Variable(DateTime(2026, 4, 1))),
          )).get();

      expect(
        march.length,
        1,
        reason: 'the takings belong to March, when the patient paid',
      );
      expect(march.single.total, 900);

      final april =
          await (db.select(db.cashMemos)..where(
            (t) =>
                t.memoDate.isBiggerOrEqual(Variable(DateTime(2026, 4, 1))) &
                t.memoDate.isSmallerThan(Variable(DateTime(2026, 5, 1))),
          )).get();

      expect(
        april,
        isEmpty,
        reason: 'writing the row in April must not move the revenue there',
      );
    },
  );

  test(
    'memos list newest first by the date on the memo, not the entry time',
    () async {
      // Entered in the opposite order to the days they cover.
      await addMemo(
        id: 'm1',
        total: 100,
        memoDate: DateTime(2026, 3, 10),
        createdAt: DateTime(2026, 3, 12, 9, 0),
      );
      await addMemo(
        id: 'm2',
        total: 200,
        memoDate: DateTime(2026, 3, 11),
        createdAt: DateTime(2026, 3, 12, 8, 0),
      );

      final rows =
          await (db.select(db.cashMemos)
            ..orderBy([(t) => OrderingTerm.desc(t.memoDate)])).get();

      expect(rows.map((m) => m.id), [
        'm2',
        'm1',
      ], reason: 'a backdated memo sorts to its own day');
    },
  );

  test('an expense keeps the date it is given', () async {
    final receiptDate = DateTime(2026, 3, 2, 11, 0);
    await db
        .into(db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: 'e1',
            clinicId: 'clinic_old',
            category: 'Medicine Purchase',
            amount: 1500,
            date: receiptDate,
          ),
        );

    final row = await db.select(db.expenses).getSingle();
    expect(row.date, equals(receiptDate));
  });
}
