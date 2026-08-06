import 'package:drift/drift.dart';
import 'clinics.dart';

// Table for clinic expense entries
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get clinicId => text().references(Clinics, #id)();
  TextColumn get category => text()(); // Rent, Electricity, Medicine Purchase, Marketing, Camp, Other
  RealColumn get amount => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
