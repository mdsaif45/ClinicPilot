import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';


class CashMemoWithDetails {
  final CashMemo memo;
  final Patient patient;
  final Clinic clinic;
  final Visit? visit;

  const CashMemoWithDetails({
    required this.memo,
    required this.patient,
    required this.clinic,
    this.visit,
  });

  double get pendingAmount => memo.total - memo.paidAmount;
  bool get isFullyPaid => pendingAmount <= 0;
}

final cashMemosStreamProvider = StreamProvider<List<CashMemoWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.cashMemos).join([
    innerJoin(db.patients, db.patients.id.equalsExp(db.cashMemos.patientId)),
    innerJoin(db.clinics, db.clinics.id.equalsExp(db.cashMemos.clinicId)),
    leftOuterJoin(db.visits, db.visits.id.equalsExp(db.cashMemos.visitId)),
  ])
    ..where(db.cashMemos.isDeleted.equals(false))
    ..orderBy([OrderingTerm.desc(db.cashMemos.memoDate)]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return CashMemoWithDetails(
        memo: row.readTable(db.cashMemos),
        patient: row.readTable(db.patients),
        clinic: row.readTable(db.clinics),
        visit: row.readTableOrNull(db.visits),
      );
    }).toList();
  });
});

class CashMemoNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  CashMemoNotifier(this._db) : super(const AsyncData(null));

  Future<CashMemo> createCashMemo({
    required String patientId,
    required String clinicId,
    String? visitId,
    required double consultationFee,
    required double medicineFee,
    required double otherFee,
    required double discount,
    required double paidAmount,
    required String paymentMethod,
    String? notes,
    DateTime? memoDate,
  }) async {
    state = const AsyncLoading();

    final total = (consultationFee + medicineFee + otherFee) - discount;

    final date = memoDate ?? DateTime.now();

    // Generate memo number CM-YYYY-NNNNN using count + 1. The year is the
    // memo's own, so a backdated entry is not numbered into the wrong year.
    final year = date.year;
    final allMemos = await (_db.select(_db.cashMemos)).get();
    final nextNum = (allMemos.length + 1).toString().padLeft(5, '0');
    final memoNumber = 'CM-$year-$nextNum';

    final memoId = IdGenerator.generate();
    final companion = CashMemosCompanion.insert(
      id: memoId,
      memoNumber: memoNumber,
      patientId: patientId,
      clinicId: Value(clinicId),
      visitId: Value(visitId),
      consultationFee: Value(consultationFee),
      medicineFee: Value(medicineFee),
      otherFee: Value(otherFee),
      discount: Value(discount),
      total: total,
      paidAmount: Value(paidAmount),
      paymentMethod: paymentMethod,
      notes: Value(notes),
      memoDate: Value(date),
      createdAt: Value(DateTime.now()),
    );

    await _db.into(_db.cashMemos).insert(companion);

    state = const AsyncData(null);
    return await (_db.select(_db.cashMemos)
          ..where((tbl) => tbl.id.equals(memoId)))
        .getSingle();
  }

  Future<void> updateCashMemo({
    required String id,
    required double consultationFee,
    required double medicineFee,
    required double otherFee,
    required double discount,
    required double paidAmount,
    required String paymentMethod,
    String? notes,
    DateTime? memoDate,
  }) async {
    state = const AsyncLoading();
    final total = (consultationFee + medicineFee + otherFee) - discount;
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.cashMemos)..where((tbl) => tbl.id.equals(id))).write(
        CashMemosCompanion(
          consultationFee: Value(consultationFee),
          medicineFee: Value(medicineFee),
          otherFee: Value(otherFee),
          discount: Value(discount),
          total: Value(total),
          paidAmount: Value(paidAmount),
          paymentMethod: Value(paymentMethod),
          notes: Value(notes),
          // Absent means "leave as it is" - a caller that does not offer a
          // date field must not blank the one already stored.
          memoDate: memoDate == null ? const Value.absent() : Value(memoDate),
        ),
      );
    });
  }

  Future<void> archiveCashMemo(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.cashMemos)..where((tbl) => tbl.id.equals(id)))
          .write(const CashMemosCompanion(isDeleted: Value(true)));
    });
  }
}

final cashMemoNotifierProvider =
    StateNotifierProvider<CashMemoNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return CashMemoNotifier(db);
});
