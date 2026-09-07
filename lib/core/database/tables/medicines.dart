import 'package:drift/drift.dart';
import 'clinics.dart';

class Medicines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category =>
      text()(); // Dilution, Mother Tincture, Biochemic, Tablets/Capsules, Ointment/Syrup, Consumables
  TextColumn get potency =>
      text().nullable()(); // 30C, 200C, 1M, Q, 6X, 500mg, etc.
  TextColumn get form =>
      text().nullable()(); // Globules, Liquid, Tablets, Cream, Drops, Powder
  RealColumn get currentStock => real().withDefault(const Constant(0.0))();
  TextColumn get unit =>
      text()(); // Bottles (30ml), Bottles (100ml), Vials, Strips, Packs, Drams, Tablets
  RealColumn get reorderLevel => real().withDefault(const Constant(3.0))();
  RealColumn get costPrice => real().nullable()();
  RealColumn get sellingPrice => real().nullable()();
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get clinicId => text().nullable().references(Clinics, #id)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
