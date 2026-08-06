import 'package:drift/drift.dart';
import 'clinics.dart';

// Table for patient registration details
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  TextColumn get clinicId => text().references(Clinics, #id)();
  TextColumn get disease => text()();
  TextColumn get referralSource => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
