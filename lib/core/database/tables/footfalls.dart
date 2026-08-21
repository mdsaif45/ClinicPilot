import 'package:drift/drift.dart';
import 'clinics.dart';
import 'patients.dart';

class Footfalls extends Table {
  TextColumn get id => text()();
  TextColumn get clinicId => text().references(Clinics, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get disease => text().nullable()();
  TextColumn get convertedPatientId => text().nullable().references(Patients, #id)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
