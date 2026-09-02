import 'package:drift/drift.dart';

class ReferralContacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get category =>
      text().withDefault(
        const Constant('Pharmacy'),
      )(); // Pharmacy, Diagnostic Lab, Physiotherapy, Dentist, Gym / Fitness, Specialist Doctor, Other
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get lastVisitedDate => dateTime().nullable()();
  IntColumn get visitCount => integer().withDefault(const Constant(0))();
  IntColumn get referralCount => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
