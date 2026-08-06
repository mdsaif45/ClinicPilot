import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const _uuid = Uuid();

// Combined Cash Memo + Patient item model
class CashMemoWithPatient {
  final CashMemo memo;
  final Patient patient;

  CashMemoWithPatient({required this.memo, required this.patient});
}

// Stream provider for all Cash Memos joined with Patients
final cashMemosStreamProvider = StreamProvider.autoDispose<List<CashMemoWithPatient>>((ref) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.cashMemos).join([
    innerJoin(db.patients, db.patients.id.equalsExp(db.cashMemos.patientId)),
  ])..orderBy([OrderingTerm.desc(db.cashMemos.createdAt)]);

  return query.watch().map((rows) {
    return rows.map((row) {
      return CashMemoWithPatient(
        memo: row.readTable(db.cashMemos),
        patient: row.readTable(db.patients),
      );
    }).toList();
  });
});

// Notifier for adding Cash Memos
class CashMemoNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  CashMemoNotifier(this._db) : super(const AsyncValue.data(null));

  Future<CashMemo?> createCashMemo({
    required String patientId,
    required double consultationFee,
    required double medicineFee,
    required double otherFee,
    required double discount,
    required String paymentMethod,
  }) async {
    state = const AsyncValue.loading();
    try {
      final total = (consultationFee + medicineFee + otherFee) - discount;
      final count = await _db.customSelect('SELECT COUNT(*) AS c FROM cash_memos').getSingle();
      final memoNumIndex = (count.data['c'] as int? ?? 0) + 1;
      final memoNumber = "CM-${DateFormat('yyyy').format(DateTime.now())}-${memoNumIndex.toString().padLeft(5, '0')}";

      final id = _uuid.v4();
      final now = DateTime.now();

      final entry = CashMemosCompanion.insert(
        id: id,
        memoNumber: memoNumber,
        patientId: patientId,
        consultationFee: Value(consultationFee),
        medicineFee: Value(medicineFee),
        otherFee: Value(otherFee),
        discount: Value(discount),
        total: total,
        paymentMethod: paymentMethod,
        createdAt: Value(now),
      );

      await _db.into(_db.cashMemos).insert(entry);

      final created = CashMemo(
        id: id,
        memoNumber: memoNumber,
        patientId: patientId,
        consultationFee: consultationFee,
        medicineFee: medicineFee,
        otherFee: otherFee,
        discount: discount,
        total: total,
        paymentMethod: paymentMethod,
        createdAt: now,
      );

      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final cashMemoNotifierProvider = StateNotifierProvider.autoDispose<CashMemoNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return CashMemoNotifier(db);
});
