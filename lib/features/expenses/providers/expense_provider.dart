import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';


final expenseCategoryFilterProvider = StateProvider<String?>((ref) => null);

class ExpenseWithClinic {
  final Expense expense;
  final Clinic clinic;

  const ExpenseWithClinic({
    required this.expense,
    required this.clinic,
  });
}

final expensesStreamProvider = StreamProvider<List<ExpenseWithClinic>>((ref) {
  final db = ref.watch(databaseProvider);
  final categoryFilter = ref.watch(expenseCategoryFilterProvider);

  var query = db.select(db.expenses).join([
    innerJoin(db.clinics, db.clinics.id.equalsExp(db.expenses.clinicId)),
  ])..where(db.expenses.isDeleted.equals(false));

  if (categoryFilter != null && categoryFilter.isNotEmpty) {
    query = query..where(db.expenses.category.equals(categoryFilter));
  }

  return (query..orderBy([OrderingTerm.desc(db.expenses.date)]))
      .watch()
      .map((rows) {
    return rows.map((row) {
      return ExpenseWithClinic(
        expense: row.readTable(db.expenses),
        clinic: row.readTable(db.clinics),
      );
    }).toList();
  });
});

class ExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ExpenseNotifier(this._db) : super(const AsyncData(null));

  Future<void> addExpense({
    required String clinicId,
    required String category,
    String? subcategory,
    required double amount,
    String paymentMethod = 'Cash',
    bool isRecurring = false,
    String? notes,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.into(_db.expenses).insert(
            ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: clinicId,
              category: category,
              subcategory: Value(subcategory),
              amount: amount,
              paymentMethod: Value(paymentMethod),
              isRecurring: Value(isRecurring),
              notes: Value(notes),
              date: date,
            ),
          );
    });
  }

  Future<void> updateExpense({
    required String id,
    required String category,
    String? subcategory,
    required double amount,
    String paymentMethod = 'Cash',
    bool isRecurring = false,
    String? notes,
    required DateTime date,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.expenses)..where((tbl) => tbl.id.equals(id))).write(
        ExpensesCompanion(
          category: Value(category),
          subcategory: Value(subcategory),
          amount: Value(amount),
          paymentMethod: Value(paymentMethod),
          isRecurring: Value(isRecurring),
          notes: Value(notes),
          date: Value(date),
        ),
      );
    });
  }

  Future<void> archiveExpense(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await (_db.update(_db.expenses)..where((tbl) => tbl.id.equals(id)))
          .write(const ExpensesCompanion(isDeleted: Value(true)));
    });
  }
}

final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseNotifier(db);
});
