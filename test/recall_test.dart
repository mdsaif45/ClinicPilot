import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/features/patients/providers/recall_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> addPatient(String id, String name) async {
    await db.into(db.patients).insert(PatientsCompanion.insert(
          id: id,
          patientCode: Value('P-$id'),
          name: name,
          phone: '9800000000',
          age: 30,
          gender: 'Female',
          primaryClinicId: const Value('clinic_old'),
        ));
  }

  Future<void> addVisit(
    String id,
    String patientId, {
    required DateTime visitDate,
    DateTime? followUp,
  }) async {
    await db.into(db.visits).insert(VisitsCompanion.insert(
          id: id,
          patientId: patientId,
          clinicId: 'clinic_old',
          visitType: 'new',
          disease: 'Migraine',
          visitDate: visitDate,
          nextFollowUpDate: Value(followUp),
        ));
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  final now = DateTime.now();

  test('a past follow-up date lands in overdue', () async {
    await addPatient('1', 'Overdue Person');
    await addVisit('v1', '1',
        visitDate: now.subtract(const Duration(days: 40)),
        followUp: now.subtract(const Duration(days: 10)));

    final lists = await container.read(recallListProvider.future);
    expect(lists.overdue.length, 1);
    expect(lists.overdue.first.daysOverdue, 10);
  });

  test('a follow-up within a week lands in due soon', () async {
    await addPatient('2', 'Soon Person');
    await addVisit('v2', '2',
        visitDate: now.subtract(const Duration(days: 5)),
        followUp: now.add(const Duration(days: 3)));

    final lists = await container.read(recallListProvider.future);
    expect(lists.dueSoon.length, 1);
    expect(lists.overdue, isEmpty);
  });

  test('a follow-up far in the future is not listed at all', () async {
    await addPatient('3', 'Distant Person');
    await addVisit('v3', '3',
        visitDate: now, followUp: now.add(const Duration(days: 60)));

    final lists = await container.read(recallListProvider.future);
    expect(lists.total, 0);
  });

  test('no follow-up and a long silence counts as lapsed', () async {
    await addPatient('4', 'Lapsed Person');
    await addVisit('v4', '4', visitDate: now.subtract(const Duration(days: 60)));

    final lists = await container.read(recallListProvider.future);
    expect(lists.lapsed.length, 1);
    expect(lists.lapsed.first.patient.name, 'Lapsed Person');
  });

  test('a recent visit without a follow-up is not chased', () async {
    await addPatient('5', 'Recent Person');
    await addVisit('v5', '5', visitDate: now.subtract(const Duration(days: 3)));

    final lists = await container.read(recallListProvider.future);
    expect(lists.total, 0);
  });

  test('a patient appears once, using their latest follow-up', () async {
    await addPatient('6', 'Repeat Person');
    await addVisit('v6a', '6',
        visitDate: now.subtract(const Duration(days: 60)),
        followUp: now.subtract(const Duration(days: 30)));
    await addVisit('v6b', '6',
        visitDate: now.subtract(const Duration(days: 20)),
        followUp: now.subtract(const Duration(days: 5)));

    final lists = await container.read(recallListProvider.future);
    expect(lists.overdue.length, 1);
    expect(lists.overdue.first.daysOverdue, 5);
  });

  test('the longest overdue patient is listed first', () async {
    await addPatient('7', 'Waiting Longer');
    await addVisit('v7', '7',
        visitDate: now.subtract(const Duration(days: 90)),
        followUp: now.subtract(const Duration(days: 40)));
    await addPatient('8', 'Waiting Less');
    await addVisit('v8', '8',
        visitDate: now.subtract(const Duration(days: 30)),
        followUp: now.subtract(const Duration(days: 2)));

    final lists = await container.read(recallListProvider.future);
    expect(lists.overdue.first.patient.name, 'Waiting Longer');
  });
}
