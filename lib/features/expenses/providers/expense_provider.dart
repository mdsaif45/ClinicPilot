import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

const _uuid = Uuid();

// Stream of all expenses from SQLite DB
final expensesStreamProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.expenses)
        ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .watch();
});

// Category filter state provider
final selectedExpenseCategoryProvider = StateProvider.autoDispose<String>((ref) => 'All');

// Filtered expenses list provider
final filteredExpensesProvider = Provider.autoDispose<AsyncValue<List<Expense>>>((ref) {
  final expensesAsync = ref.watch(expensesStreamProvider);
  final category = ref.watch(selectedExpenseCategoryProvider);

  return expensesAsync.whenData((expenses) {
    if (category == 'All') return expenses;
    return expenses.where((e) => e.category == category).toList();
  });
});

// Expense Notifier
class ExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ExpenseNotifier(this._db) : super(const AsyncValue.data(null));

  Future<bool> addExpense({
    required String clinicId,
    required String category,
    required double amount,
    String? notes,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = _uuid.v4();
      await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: id,
              clinicId: clinicId,
              category: category,
              amount: amount,
              notes: Value(notes),
              date: date,
            ),
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final expenseNotifierProvider = StateNotifierProvider.autoDispose<ExpenseNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseNotifier(db);
});
