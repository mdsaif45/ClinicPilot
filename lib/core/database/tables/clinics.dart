import 'package:drift/drift.dart';

class Clinics extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();

  // Monthly fixed rent. Enables true profit-per-clinic without forcing the
  // doctor to key in a rent expense row every month.
  RealColumn get monthlyRent => real().withDefault(const Constant(0.0))();

  // Default consultation fee; pre-fills the cash memo form.
  RealColumn get defaultConsultationFee =>
      real().withDefault(const Constant(0.0))();

  // Which evenings this clinic opens: comma-separated ints, Mon=1..Sun=7.
  // e.g. "1,3,5". Needed for "average patients per CLINIC DAY".
  TextColumn get openDays =>
      text().withDefault(const Constant('1,2,3,4,5,6'))();

  // GSTIN printed on tax invoices. Null until the doctor registers, which is
  // also what decides whether cash memos show a tax breakdown at all — an
  // unregistered practice must not issue anything resembling a tax invoice.
  TextColumn get gstin => text().nullable()();

  // Fallback GST slab (percent) for dispensed items whose own rate is unset.
  // Nullable so existing rows and hand-built Clinic objects need no change;
  // callers treat null as the 12% default.
  RealColumn get defaultGstRate => real().nullable()();

  TextColumn get colorHex => text().withDefault(const Constant('#0F5132'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
