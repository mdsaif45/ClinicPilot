import 'package:drift/drift.dart';
import 'clinics.dart';

class Camps extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get location => text().nullable()();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  IntColumn get attendance => integer().withDefault(const Constant(0))();
  TextColumn get clinicId => text().nullable().references(Clinics, #id)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
