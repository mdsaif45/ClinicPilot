import 'dart:convert';

import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../models/case_record_models.dart';

final patientComplaintsProvider =
    StreamProvider.family<List<Complaint>, String>((ref, patientId) {
  final db = ref.watch(databaseProvider);

  final query = db.select(db.complaints)
    ..where((t) => t.patientId.equals(patientId) & t.isDeleted.equals(false))
    ..orderBy([
      (t) => OrderingTerm.asc(t.complaintIndex),
      (t) => OrderingTerm.asc(t.createdAt),
    ]);

  return query.watch();
});

class ComplaintNotifier extends StateNotifier<AsyncValue<void>> {
  final AppDatabase _db;

  ComplaintNotifier(this._db) : super(const AsyncData(null));

  String _formatSeverityToString(int sev) {
    if (sev <= 3) return 'Mild';
    if (sev <= 6) return 'Moderate';
    if (sev <= 9) return 'Severe';
    return 'Intolerable';
  }

  static List<String> parseImages(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  static String? serializeImages(List<String> images) {
    final clean = images.where((i) => i.trim().isNotEmpty).toList();
    return clean.isEmpty ? null : jsonEncode(clean);
  }

  Future<void> _syncWithCaseRecord(String patientId) async {
    // Only baseline complaints sync into the initial Master Case Taking record
    final activeBaselineComplaints = await (_db.select(_db.complaints)
          ..where((t) =>
              t.patientId.equals(patientId) &
              t.isDeleted.equals(false) &
              t.isBaseline.equals(true))
          ..orderBy([
            (t) => OrderingTerm.asc(t.complaintIndex),
            (t) => OrderingTerm.asc(t.complaintDate),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();

    final chiefList = activeBaselineComplaints.map((c) => ChiefComplaintDetail(
          complaint: c.complaintName,
          location: c.location ?? '',
          onset: c.onset ?? '',
          duration: c.duration ?? '',
          sensation: c.sensation ?? '',
          extensionRadiation: c.extension ?? '',
          modalitiesAgg: c.aggravatingFactors ?? '',
          modalitiesAmel: c.amelioratingFactors ?? '',
          concomitants: c.concomitants ?? '',
          causation: c.causation ?? '',
          periodicity: c.periodicity ?? '',
          severity: _formatSeverityToString(c.severity),
          associatedSymptoms: c.notes ?? '',
        )).toList();

    final jsonStr = jsonEncode(chiefList.map((e) => e.toJson()).toList());

    final existingCase = await (_db.select(_db.patientCaseRecords)
          ..where((t) => t.patientId.equals(patientId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(1))
        .getSingleOrNull();

    if (existingCase != null) {
      await (_db.update(_db.patientCaseRecords)
            ..where((t) => t.id.equals(existingCase.id)))
          .write(
        PatientCaseRecordsCompanion(
          chiefComplaintsJson: Value(jsonStr),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<String> addComplaint({
    required String patientId,
    String? visitId,
    DateTime? complaintDate,
    bool isBaseline = true,
    int complaintIndex = 1,
    required String complaintName,
    String? location,
    String? side,
    String? onset,
    String? duration,
    String? sensation,
    String? extension,
    String? aggravatingFactors,
    String? amelioratingFactors,
    String? concomitants,
    String? causation,
    String? periodicity,
    int severity = 5,
    String status = 'Active',
    List<String> beforeImages = const [],
    List<String> afterImages = const [],
    String? notes,
  }) async {
    state = const AsyncLoading();
    final id = IdGenerator.generate();
    final now = DateTime.now();

    final companion = ComplaintsCompanion.insert(
      id: id,
      patientId: patientId,
      visitId: Value(visitId),
      complaintDate: Value(complaintDate ?? now),
      isBaseline: Value(isBaseline),
      complaintIndex: Value(complaintIndex),
      complaintName: complaintName.trim(),
      location: Value(location?.trim()),
      side: Value(side),
      onset: Value(onset?.trim()),
      duration: Value(duration?.trim()),
      sensation: Value(sensation?.trim()),
      extension: Value(extension?.trim()),
      aggravatingFactors: Value(aggravatingFactors?.trim()),
      amelioratingFactors: Value(amelioratingFactors?.trim()),
      concomitants: Value(concomitants?.trim()),
      causation: Value(causation?.trim()),
      periodicity: Value(periodicity?.trim()),
      severity: Value(severity),
      status: Value(status),
      beforeImages: Value(serializeImages(beforeImages)),
      afterImages: Value(serializeImages(afterImages)),
      notes: Value(notes?.trim()),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    state = await AsyncValue.guard(() async {
      await _db.into(_db.complaints).insert(companion);
      if (isBaseline) {
        await _syncWithCaseRecord(patientId);
      }
    });

    return id;
  }

  Future<void> updateComplaint({
    required String id,
    required String complaintName,
    DateTime? complaintDate,
    bool? isBaseline,
    int complaintIndex = 1,
    String? location,
    String? side,
    String? onset,
    String? duration,
    String? sensation,
    String? extension,
    String? aggravatingFactors,
    String? amelioratingFactors,
    String? concomitants,
    String? causation,
    String? periodicity,
    int severity = 5,
    String status = 'Active',
    List<String>? beforeImages,
    List<String>? afterImages,
    String? notes,
  }) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing = await (_db.select(_db.complaints)..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.complaints)..where((t) => t.id.equals(id))).write(
        ComplaintsCompanion(
          complaintName: Value(complaintName.trim()),
          complaintDate: complaintDate != null ? Value(complaintDate) : const Value.absent(),
          isBaseline: isBaseline != null ? Value(isBaseline) : const Value.absent(),
          complaintIndex: Value(complaintIndex),
          location: Value(location?.trim()),
          side: Value(side),
          onset: Value(onset?.trim()),
          duration: Value(duration?.trim()),
          sensation: Value(sensation?.trim()),
          extension: Value(extension?.trim()),
          aggravatingFactors: Value(aggravatingFactors?.trim()),
          amelioratingFactors: Value(amelioratingFactors?.trim()),
          concomitants: Value(concomitants?.trim()),
          causation: Value(causation?.trim()),
          periodicity: Value(periodicity?.trim()),
          severity: Value(severity),
          status: Value(status),
          beforeImages: beforeImages != null ? Value(serializeImages(beforeImages)) : const Value.absent(),
          afterImages: afterImages != null ? Value(serializeImages(afterImages)) : const Value.absent(),
          notes: Value(notes?.trim()),
          updatedAt: Value(now),
        ),
      );
      if (existing != null && ((existing.isBaseline ?? true) || (isBaseline ?? false))) {
        await _syncWithCaseRecord(existing.patientId);
      }
    });
  }

  Future<void> updateStatus(String id, String status) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing = await (_db.select(_db.complaints)..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.complaints)..where((t) => t.id.equals(id))).write(
        ComplaintsCompanion(
          status: Value(status),
          updatedAt: Value(now),
        ),
      );
      if (existing != null) {
        await _syncWithCaseRecord(existing.patientId);
      }
    });
  }

  Future<void> deleteComplaint(String id) async {
    state = const AsyncLoading();
    final now = DateTime.now();

    state = await AsyncValue.guard(() async {
      final existing = await (_db.select(_db.complaints)..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.complaints)..where((t) => t.id.equals(id))).write(
        ComplaintsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      if (existing != null) {
        await _syncWithCaseRecord(existing.patientId);
      }
    });
  }
}

final complaintNotifierProvider =
    StateNotifierProvider<ComplaintNotifier, AsyncValue<void>>((ref) {
  final db = ref.watch(databaseProvider);
  return ComplaintNotifier(db);
});
