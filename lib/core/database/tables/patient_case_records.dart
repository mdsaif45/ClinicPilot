import 'package:drift/drift.dart';
import 'patients.dart';

class PatientCaseRecords extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  DateTimeColumn get recordDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get chiefComplaintsJson => text().nullable()();
  TextColumn get hpi => text().nullable()();
  TextColumn get pastHistoryJson => text().nullable()();
  TextColumn get familyHistoryJson => text().nullable()();
  TextColumn get developmentalHistoryJson => text().nullable()();
  TextColumn get physicalGeneralsJson => text().nullable()();
  TextColumn get mentalGeneralsJson => text().nullable()();
  TextColumn get lifestyleJson => text().nullable()();
  TextColumn get clinicalExamJson => text().nullable()();
  TextColumn get miasmaticAnalysisJson => text().nullable()();
  TextColumn get caseTotalityJson => text().nullable()();
  TextColumn get baselinePrescriptionJson => text().nullable()();
  TextColumn get investigationsJson => text().nullable()();
  TextColumn get followUpNotes => text().nullable()();
  TextColumn get outcome => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
