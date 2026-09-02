import 'package:drift/drift.dart';
import 'clinics.dart';
import 'patients.dart';

class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();

  // Revenue and patient-count attribution ALWAYS uses this column.
  TextColumn get clinicId => text().references(Clinics, #id)();

  // 'new' | 'repeat'
  //
  // COMPUTED AT INSERT TIME and STORED — do not derive it at query time.
  // Rule: 'new' if this patient has zero prior visits, else 'repeat'.
  TextColumn get visitType => text()();

  // 'clinic' | 'online' | 'camp'  — powers camp conversion tracking
  TextColumn get consultationType =>
      text().withDefault(const Constant('clinic'))();

  TextColumn get disease => text()(); // primary condition this visit
  TextColumn get chiefComplaint => text().nullable()();

  // Asked only on a NEW visit ("How did you hear about us?"). Null on repeats.
  TextColumn get referralSource => text().nullable()();

  // 'improved' | 'no_change' | 'worse' | 'recovered' | 'lost_followup' | null
  TextColumn get outcome => text().nullable()();

  DateTimeColumn get visitDate => dateTime()();
  DateTimeColumn get nextFollowUpDate =>
      dateTime().nullable()(); // powers overdue list

  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
