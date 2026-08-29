import 'package:drift/drift.dart';
import 'patients.dart';
import 'visits.dart';

class Complaints extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get visitId => text().nullable().references(Visits, #id)();
  IntColumn get complaintIndex => integer().withDefault(const Constant(1))();
  DateTimeColumn get complaintDate => dateTime().nullable().withDefault(currentDateAndTime)();
  BoolColumn get isBaseline => boolean().nullable().withDefault(const Constant(true))();
  TextColumn get complaintName => text()();
  TextColumn get location => text().nullable()();
  TextColumn get side => text().nullable()(); // Left, Right, Bilateral, Central, Not specified
  TextColumn get onset => text().nullable()(); // Sudden, Gradual, etc.
  TextColumn get duration => text().nullable()();
  TextColumn get sensation => text().nullable()();
  TextColumn get extension => text().nullable()();
  TextColumn get aggravatingFactors => text().nullable()();
  TextColumn get amelioratingFactors => text().nullable()();
  TextColumn get concomitants => text().nullable()();
  TextColumn get causation => text().nullable()();
  TextColumn get periodicity => text().nullable()();
  IntColumn get severity => integer().withDefault(const Constant(5))(); // 1 to 10 scale
  TextColumn get status => text().withDefault(const Constant('Active'))(); // Active, Improving, Resolved, Recurrent
  TextColumn get beforeImages => text().nullable()(); // JSON list of image paths
  TextColumn get afterImages => text().nullable()(); // JSON list of image paths
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
