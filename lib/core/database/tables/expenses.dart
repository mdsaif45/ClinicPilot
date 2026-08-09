import 'package:drift/drift.dart';
import 'clinics.dart';

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get clinicId => text().references(Clinics, #id)();

  // Rent | Electricity | Staff Salary | Medicine Purchase | Furniture
  // | Marketing | Camp | Internet | Travel | Miscellaneous
  TextColumn get category => text()();

  // Free text, e.g. a camp name — lets the doctor total one camp's cost
  TextColumn get subcategory => text().nullable()();

  RealColumn get amount => real()();
  TextColumn get paymentMethod => text().withDefault(const Constant('Cash'))();

  // True for rent/electricity — separates fixed cost from variable spend
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
