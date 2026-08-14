import 'package:drift/drift.dart';
import 'patients.dart';
import 'clinics.dart';
import 'visits.dart';

class CashMemos extends Table {
  TextColumn get id => text()();
  TextColumn get memoNumber => text()();               // "CM-2026-00001"

  TextColumn get patientId => text().references(Patients, #id)();

  // NEW — without this, revenue-per-clinic is impossible.
  TextColumn get clinicId => text().withDefault(const Constant('clinic_old')).references(Clinics, #id)();

  // NEW — ties money to the specific encounter.
  TextColumn get visitId => text().nullable().references(Visits, #id)();

  RealColumn get consultationFee => real().withDefault(const Constant(0.0))();
  RealColumn get medicineFee => real().withDefault(const Constant(0.0))();
  RealColumn get otherFee => real().withDefault(const Constant(0.0))();
  RealColumn get discount => real().withDefault(const Constant(0.0))();

  RealColumn get total => real()();                    // (consult+med+other) - discount

  // Partial payment support. Set to `total` for a fully-paid memo;
  // pending = total - paidAmount.
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();

  TextColumn get paymentMethod => text()();            // Cash | UPI | Card | Bank Transfer
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // When the money actually moved. Every revenue report reads this.
  //
  // Separate from createdAt because the two only agree when a memo is entered
  // the moment it is paid. Memos written up after evening clinic - or the next
  // morning - would otherwise book revenue to the wrong day, and around
  // midnight on the 1st, the wrong month.
  DateTimeColumn get memoDate => dateTime().withDefault(currentDateAndTime)();

  // When the row was written. Audit trail, not a reporting date.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
