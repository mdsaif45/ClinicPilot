import 'package:drift/drift.dart';
import 'patients.dart';
import 'visits.dart';

class Investigations extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get visitId => text().nullable().references(Visits, #id)();
  DateTimeColumn get testDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get testCategory => text().withDefault(const Constant('Blood / Biochemistry'))();
  TextColumn get testName => text()();
  RealColumn get numericValue => real().nullable()();
  TextColumn get stringValue => text().nullable()();
  TextColumn get unit => text().nullable()();
  RealColumn get refRangeMin => real().nullable()();
  RealColumn get refRangeMax => real().nullable()();
  TextColumn get flag => text().withDefault(const Constant('Normal'))(); // High, Low, Normal, Borderline, Abnormal
  TextColumn get labName => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
