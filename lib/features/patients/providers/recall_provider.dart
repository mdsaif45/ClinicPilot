import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

class RecallEntry {
  final Patient patient;
  final Visit visit;
  final Clinic clinic;

  /// Days past the scheduled follow-up. Negative means still upcoming.
  final int daysOverdue;

  const RecallEntry({
    required this.patient,
    required this.visit,
    required this.clinic,
    required this.daysOverdue,
  });

  bool get isOverdue => daysOverdue > 0;
  bool get isDueToday => daysOverdue == 0;
}

class RecallLists {
  final List<RecallEntry> overdue;
  final List<RecallEntry> dueSoon;
  final List<RecallEntry> upcoming;

  /// Patients with no follow-up scheduled who have not been seen for a while.
  /// They never appear in a date-driven list, yet they are the ones quietly
  /// lapsing.
  final List<RecallEntry> lapsed;

  const RecallLists({
    required this.overdue,
    required this.dueSoon,
    this.upcoming = const [],
    required this.lapsed,
  });

  int get total => overdue.length + dueSoon.length + upcoming.length + lapsed.length;
}

/// How long without a visit before a patient counts as lapsed.
///
/// The growth plan suggests contacting patients absent 6–8 weeks; 45 days sits
/// inside that window.
const _lapsedAfterDays = 45;

/// Patients worth contacting, across every clinic.
///
/// The per-patient profile can only answer "is this person overdue" once the
/// doctor already suspects it. This inverts that: a patient who came twice and
/// stopped is warmer than any stranger a leaflet reaches, and this is the list
/// that surfaces them without being asked.
final recallListProvider = StreamProvider<RecallLists>((ref) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.visits).join([
    innerJoin(db.patients, db.patients.id.equalsExp(db.visits.patientId)),
    innerJoin(db.clinics, db.clinics.id.equalsExp(db.visits.clinicId)),
  ])
    ..where(db.visits.isDeleted.equals(false) &
        db.patients.isDeleted.equals(false));

  return query.watch().map((rows) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Latest visit per patient, plus the furthest follow-up they carry.
    final lastVisit = <String, Visit>{};
    final followUp = <String, Visit>{};
    final patients = <String, Patient>{};
    final clinics = <String, Clinic>{};

    for (final row in rows) {
      final v = row.readTable(db.visits);
      final p = row.readTable(db.patients);
      final c = row.readTable(db.clinics);

      patients[v.patientId] = p;
      clinics[v.patientId] = c;

      final prev = lastVisit[v.patientId];
      if (prev == null || v.visitDate.isAfter(prev.visitDate)) {
        lastVisit[v.patientId] = v;
      }

      if (v.nextFollowUpDate != null) {
        final f = followUp[v.patientId];
        if (f == null ||
            v.nextFollowUpDate!.isAfter(f.nextFollowUpDate!)) {
          followUp[v.patientId] = v;
        }
      }
    }

    final overdue = <RecallEntry>[];
    final dueSoon = <RecallEntry>[];
    final upcoming = <RecallEntry>[];
    final lapsed = <RecallEntry>[];

    for (final patientId in patients.keys) {
      final p = patients[patientId]!;
      final c = clinics[patientId]!;
      final scheduled = followUp[patientId];

      if (scheduled != null) {
        final due = DateTime(
          scheduled.nextFollowUpDate!.year,
          scheduled.nextFollowUpDate!.month,
          scheduled.nextFollowUpDate!.day,
        );
        final days = today.difference(due).inDays;
        final entry = RecallEntry(
          patient: p,
          visit: scheduled,
          clinic: c,
          daysOverdue: days,
        );

        if (days >= 0) {
          overdue.add(entry);
        } else if (days >= -7) {
          // Due in the coming 7 days
          dueSoon.add(entry);
        } else if (days >= -30) {
          // Scheduled within the coming 30 days
          upcoming.add(entry);
        }
        continue;
      }

      // No follow-up scheduled: lapsed if the last visit is old enough.
      final last = lastVisit[patientId];
      if (last == null) continue;
      final sinceLast = today
          .difference(DateTime(
              last.visitDate.year, last.visitDate.month, last.visitDate.day))
          .inDays;
      if (sinceLast >= _lapsedAfterDays) {
        lapsed.add(RecallEntry(
          patient: p,
          visit: last,
          clinic: c,
          daysOverdue: sinceLast,
        ));
      }
    }

    // Longest waiting first — those are the ones closest to being lost.
    overdue.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
    dueSoon.sort((a, b) => a.daysOverdue.compareTo(b.daysOverdue));
    upcoming.sort((a, b) => a.daysOverdue.compareTo(b.daysOverdue));
    lapsed.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));

    return RecallLists(overdue: overdue, dueSoon: dueSoon, upcoming: upcoming, lapsed: lapsed);
  });
});
