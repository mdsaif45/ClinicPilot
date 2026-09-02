import 'package:drift/drift.dart';
import 'patients.dart';
import 'visits.dart';

class Prescriptions extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get visitId => text().nullable().references(Visits, #id)();
  DateTimeColumn get prescriptionDate =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  BoolColumn get isBaseline =>
      boolean().nullable().withDefault(const Constant(true))();
  IntColumn get remedyIndex => integer().withDefault(const Constant(1))();
  TextColumn get remedyName => text()();
  TextColumn get potency => text()();
  TextColumn get doseCount => text().nullable()();
  TextColumn get frequency => text().nullable()();
  TextColumn get vehicle => text().nullable()();
  TextColumn get durationDays => text().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get dietaryAdvice => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
