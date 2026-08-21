import 'package:drift/drift.dart';
import 'clinics.dart';
import 'patients.dart';

class ReviewRequests extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get clinicId => text().nullable().references(Clinics, #id)();
  DateTimeColumn get requestedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get reviewedAt => dateTime().nullable()();
  IntColumn get rating => integer().nullable()(); // 1 to 5 stars
  TextColumn get platform => text().withDefault(const Constant('google'))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
