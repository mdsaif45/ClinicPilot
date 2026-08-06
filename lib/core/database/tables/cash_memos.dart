import 'package:drift/drift.dart';
import 'patients.dart';

// Table for cash memo transactions
class CashMemos extends Table {
  TextColumn get id => text()();
  TextColumn get memoNumber => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  RealColumn get consultationFee => real().withDefault(const Constant(0.0))();
  RealColumn get medicineFee => real().withDefault(const Constant(0.0))();
  RealColumn get otherFee => real().withDefault(const Constant(0.0))();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text()(); // Cash, UPI, Card, Bank
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
