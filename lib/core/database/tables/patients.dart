import 'package:drift/drift.dart';

class Patients extends Table {
  TextColumn get id => text()();

  // Human-readable sequential code shown in the UI: "P-2026-00042"
  TextColumn get patientCode => text().withDefault(const Constant(''))();

  // The number the doctor already writes in the physical register - typed by
  // hand at registration, not generated. Independent of patientCode, which
  // stays the app's own auto-generated id.
  //
  // Uniqueness (per clinic - two clinics can each have their own "1") is
  // enforced by an explicit CREATE UNIQUE INDEX in app_database.dart rather
  // than Table.uniqueKeys: SQLite refuses to DROP a column that a table-level
  // UNIQUE constraint references, which breaks the "simulate the pre-upgrade
  // shape" technique every migration test in this project relies on. An index
  // gives the same guarantee and can be dropped and rebuilt independently of
  // the column.
  TextColumn get serialNo => text().withDefault(const Constant(''))();

  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get whatsapp => text().nullable()();
  IntColumn  get age => integer()();
  TextColumn get gender => text()();               // Male | Female | Other
  TextColumn get area => text().nullable()();      // locality — hyperlocal marketing
  TextColumn get address => text().nullable()();
  TextColumn get occupation => text().nullable()();

  // Where this patient FIRST came. Analytics only.
  // NEVER use for revenue attribution — that always comes from visits.clinicId.
  TextColumn get primaryClinicId => text().withDefault(const Constant('clinic_old'))();

  // Denormalised copies of the FIRST visit, for list display without a join.
  // Source of truth is always the visits table.
  TextColumn get primaryDisease => text().nullable()();
  TextColumn get referralSource => text().nullable()();

  TextColumn get notes => text().nullable()();

  /// Google review tracking.
  ///
  /// The growth plan ranks Google reviews the single highest-impact local
  /// marketing channel, with a target of 100 in the first year. The app can
  /// only record that the ask happened and what the patient reported back — it
  /// cannot verify a review was actually published.
  DateTimeColumn get reviewAskedAt => dateTime().nullable()();
  BoolColumn get reviewGiven => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
