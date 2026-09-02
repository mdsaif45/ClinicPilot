import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/features/cashmemo/providers/cash_memo_provider.dart';
import 'package:clinic_pilot/features/expenses/providers/expense_provider.dart';
import 'package:clinic_pilot/features/finances/presentation/monthly_statement_screen.dart';
import 'package:clinic_pilot/features/finances/presentation/sort_by_bottom_sheet.dart';
import 'package:clinic_pilot/features/finances/presentation/transaction_detail_screen.dart';
import 'package:clinic_pilot/features/finances/presentation/transaction_history_screen.dart';
import 'package:clinic_pilot/features/finances/providers/monthly_statement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clinic = Clinic(
    id: 'c1',
    name: 'City Care Clinic',
    address: 'Park Street',
    phone: '9800000000',
    monthlyRent: 5000,
    defaultConsultationFee: 300,
    openDays: '1,2,3,4,5,6',
    colorHex: '#0F5132',
    isActive: true,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  final patient = Patient(
    id: 'p1',
    patientCode: 'P-2026-00001',
    serialNo: '1',
    name: 'Kandukuri Khaja Bee',
    phone: '9811002200',
    whatsapp: null,
    age: 45,
    gender: 'Female',
    area: 'Central',
    address: null,
    occupation: null,
    primaryClinicId: 'c1',
    primaryDisease: 'Arthritis',
    referralSource: null,
    notes: null,
    reviewAskedAt: null,
    reviewGiven: false,
    isDeleted: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  Expense makeExpense(
    String id,
    String category,
    double amount,
    DateTime date,
  ) => Expense(
    id: id,
    clinicId: 'c1',
    category: category,
    subcategory: null,
    amount: amount,
    paymentMethod: 'UPI',
    isRecurring: false,
    notes: 'Vendor payment $id',
    date: date,
    isDeleted: false,
    createdAt: date,
  );

  CashMemo makeMemo(String id, double total, double paid, DateTime date) =>
      CashMemo(
        id: id,
        memoNumber: 'CM-$id',
        patientId: 'p1',
        clinicId: 'c1',
        visitId: null,
        consultationFee: total,
        medicineFee: 0,
        otherFee: 0,
        discount: 0,
        total: total,
        paidAmount: paid,
        paymentMethod: 'UPI',
        notes: null,
        isDeleted: false,
        memoDate: date,
        createdAt: date,
      );

  group('sortExpenses Unit Tests', () {
    final e1 = ExpenseWithClinic(
      expense: makeExpense('1', 'Rent', 8000, DateTime(2026, 7, 3)),
      clinic: clinic,
    );
    final e2 = ExpenseWithClinic(
      expense: makeExpense('2', 'Mutual Fund', 5000, DateTime(2026, 7, 4)),
      clinic: clinic,
    );
    final e3 = ExpenseWithClinic(
      expense: makeExpense('3', 'Airtel', 3599, DateTime(2026, 7, 17)),
      clinic: clinic,
    );
    final list = [e2, e1, e3];

    test('sorts by highestFirst', () {
      final sorted = sortExpenses(list, FinanceSortOption.highestFirst);
      expect(sorted.map((e) => e.expense.amount).toList(), [8000, 5000, 3599]);
    });

    test('sorts by lowestFirst', () {
      final sorted = sortExpenses(list, FinanceSortOption.lowestFirst);
      expect(sorted.map((e) => e.expense.amount).toList(), [3599, 5000, 8000]);
    });

    test('sorts by recents', () {
      final sorted = sortExpenses(list, FinanceSortOption.recents);
      expect(sorted.first.expense.id, '3'); // July 17
      expect(sorted.last.expense.id, '1'); // July 3
    });

    test('sorts by oldest', () {
      final sorted = sortExpenses(list, FinanceSortOption.oldest);
      expect(sorted.first.expense.id, '1'); // July 3
      expect(sorted.last.expense.id, '3'); // July 17
    });
  });

  group('sortCashMemos Unit Tests', () {
    final m1 = CashMemoWithDetails(
      memo: makeMemo('1', 500, 500, DateTime(2026, 7, 10)),
      patient: patient,
      clinic: clinic,
    );
    final m2 = CashMemoWithDetails(
      memo: makeMemo('2', 1000, 1000, DateTime(2026, 7, 20)),
      patient: patient,
      clinic: clinic,
    );
    final list = [m1, m2];

    test('sorts by highestFirst', () {
      final sorted = sortCashMemos(list, FinanceSortOption.highestFirst);
      expect(sorted.first.memo.paidAmount, 1000);
    });

    test('sorts by lowestFirst', () {
      final sorted = sortCashMemos(list, FinanceSortOption.lowestFirst);
      expect(sorted.first.memo.paidAmount, 500);
    });
  });

  group('SortByBottomSheet Widget Test', () {
    testWidgets('renders sort options and selection interaction', (
      tester,
    ) async {
      FinanceSortOption? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () async {
                      result = await showSortByBottomSheet(
                        context,
                        FinanceSortOption.highestFirst,
                      );
                    },
                    child: const Text('Open'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Sort by'), findsOneWidget);
      expect(find.text('Recents'), findsOneWidget);
      expect(find.text('Oldest'), findsOneWidget);
      expect(find.text('Highest first'), findsOneWidget);
      expect(find.text('Lowest first'), findsOneWidget);

      // Select 'Recents'
      await tester.tap(find.text('Recents'));
      await tester.pumpAndSettle();

      // Tap 'Done'
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(result, FinanceSortOption.recents);
    });
  });

  group('MonthlyStatementScreen Terminology Widget Test', () {
    testWidgets(
      'renders Expenses and Cash Memo labels instead of generic spent/received',
      (tester) async {
        final e1 = ExpenseWithClinic(
          expense: makeExpense('1', 'Rent', 8000, DateTime(2026, 7, 3)),
          clinic: clinic,
        );
        final m1 = CashMemoWithDetails(
          memo: makeMemo('1', 500, 500, DateTime(2026, 7, 10)),
          patient: patient,
          clinic: clinic,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              expensesStreamProvider.overrideWithValue(AsyncData([e1])),
              cashMemosStreamProvider.overrideWith((ref) => Stream.value([m1])),
            ],
            child: MaterialApp(
              home: MonthlyStatementScreen(initialMonth: DateTime(2026, 7, 1)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Expenses'), findsWidgets);
        expect(find.text('Cash Memo'), findsWidgets);
        expect(find.text('Spent'), findsNothing);
        expect(find.text('Received'), findsNothing);
      },
    );
  });

  group('TransactionHistoryScreen Widget Test', () {
    testWidgets(
      'renders clean titles, day-month dates, and navigates to TransactionDetailScreen',
      (tester) async {
        final e1 = ExpenseWithClinic(
          expense: makeExpense('1', 'Bakery', 65, DateTime(2026, 8, 30)),
          clinic: clinic,
        );
        final m1 = CashMemoWithDetails(
          memo: makeMemo('1', 500, 500, DateTime(2026, 8, 28)),
          patient: patient,
          clinic: clinic,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              expensesStreamProvider.overrideWithValue(AsyncData([e1])),
              cashMemosStreamProvider.overrideWith((ref) => Stream.value([m1])),
            ],
            child: const MaterialApp(home: TransactionHistoryScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('August 2026'), findsOneWidget);
        // Clean titles without repetitive prefix
        expect(find.text('Vendor payment 1'), findsOneWidget);
        expect(find.text('Kandukuri Khaja Bee'), findsOneWidget);
        // Clean dates without year
        expect(find.text('30 Aug'), findsOneWidget);
        expect(find.text('28 Aug'), findsOneWidget);
        // Amounts with minus (-) and plus (+)
        expect(find.text('- ₹ 65'), findsOneWidget);
        expect(find.text('+ ₹ 500'), findsOneWidget);

        // Tap on Cash Memo row -> Navigates to TransactionDetailScreen
        await tester.tap(find.text('Kandukuri Khaja Bee'));
        await tester.pumpAndSettle();

        expect(find.byType(TransactionDetailScreen), findsOneWidget);
        expect(find.text('Cash Memo Record'), findsOneWidget);
        expect(find.text('Voucher Specifications'), findsOneWidget);

        await tester.scrollUntilVisible(find.text('Share Record'), 200);
        expect(find.text('View Formal Receipt'), findsOneWidget);
        expect(find.text('Share Record'), findsOneWidget);
        expect(find.text('Edit Memo'), findsOneWidget);
      },
    );
  });
}
