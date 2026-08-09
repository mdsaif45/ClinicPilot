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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
