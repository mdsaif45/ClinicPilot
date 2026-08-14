import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

/// Result of an export attempt.
class ExportResult {
  final bool success;
  final String message;
  final String? path;
  final int rowCount;

  const ExportResult({
    required this.success,
    required this.message,
    this.path,
    this.rowCount = 0,
  });
}

/// Builds CSV backups of the clinic database.
///
/// The doctor is told to export before the one-time uninstall that release
/// signing forces, so this has to produce a real, complete file — a stub that
/// merely reports success would destroy patient data at exactly the moment the
/// backup is relied on.
class ExportService {
  final AppDatabase _db;

  const ExportService(this._db);

  /// Escapes a single CSV field.
  ///
  /// Clinic data routinely contains commas (addresses) and apostrophes
  /// (names), and notes can contain newlines, so quoting is not optional.
  static String _cell(Object? value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<Object?> cells) => cells.map(_cell).join(',');

  static String _date(DateTime? d) => d == null ? '' : d.toIso8601String();

  /// Produces the full backup as a single CSV document.
  ///
  /// Sections are separated by a blank line and a header row, so one file
  /// carries every table while staying readable in a spreadsheet.
  Future<String> buildCsv() async {
    final buffer = StringBuffer();

    final clinics = await (_db.select(_db.clinics)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    buffer.writeln('# CLINICS');
    buffer.writeln(_row(
        ['id', 'name', 'address', 'phone', 'monthly_rent', 'open_days']));
    for (final c in clinics) {
      buffer.writeln(_row(
          [c.id, c.name, c.address, c.phone, c.monthlyRent, c.openDays]));
    }

    final patients = await (_db.select(_db.patients)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    buffer
      ..writeln()
      ..writeln('# PATIENTS')
      ..writeln(_row([
        'patient_code', 'name', 'phone', 'whatsapp', 'age', 'gender',
        'area', 'address', 'occupation', 'primary_clinic_id',
        'primary_disease', 'referral_source', 'notes', 'created_at',
      ]));
    for (final p in patients) {
      buffer.writeln(_row([
        p.patientCode, p.name, p.phone, p.whatsapp, p.age, p.gender,
        p.area, p.address, p.occupation, p.primaryClinicId,
        p.primaryDisease, p.referralSource, p.notes, _date(p.createdAt),
      ]));
    }

    final visits = await (_db.select(_db.visits)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    buffer
      ..writeln()
      ..writeln('# VISITS')
      ..writeln(_row([
        'id', 'patient_id', 'clinic_id', 'visit_type', 'consultation_type',
        'disease', 'chief_complaint', 'referral_source', 'outcome',
        'visit_date', 'next_follow_up', 'notes',
      ]));
    for (final v in visits) {
      buffer.writeln(_row([
        v.id, v.patientId, v.clinicId, v.visitType, v.consultationType,
        v.disease, v.chiefComplaint, v.referralSource, v.outcome,
        _date(v.visitDate), _date(v.nextFollowUpDate), v.notes,
      ]));
    }

    final memos = await (_db.select(_db.cashMemos)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    buffer
      ..writeln()
      ..writeln('# CASH MEMOS')
      ..writeln(_row([
        'memo_number', 'patient_id', 'clinic_id', 'visit_id',
        'consultation_fee', 'medicine_fee', 'other_fee', 'discount',
        'total', 'paid_amount', 'payment_method', 'notes', 'created_at',
      ]));
    for (final m in memos) {
      buffer.writeln(_row([
        m.memoNumber, m.patientId, m.clinicId, m.visitId,
        m.consultationFee, m.medicineFee, m.otherFee, m.discount,
        m.total, m.paidAmount, m.paymentMethod, m.notes, _date(m.memoDate),
      ]));
    }

    final expenses = await (_db.select(_db.expenses)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    buffer
      ..writeln()
      ..writeln('# EXPENSES')
      ..writeln(_row([
        'id', 'clinic_id', 'category', 'subcategory', 'amount',
        'payment_method', 'is_recurring', 'notes', 'date',
      ]));
    for (final e in expenses) {
      buffer.writeln(_row([
        e.id, e.clinicId, e.category, e.subcategory, e.amount,
        e.paymentMethod, e.isRecurring, e.notes, _date(e.date),
      ]));
    }

    return buffer.toString();
  }

  /// Total rows the backup will contain, used to report what was written.
  Future<int> countRows() async {
    final counts = await Future.wait([
      _db.patients.count(where: (t) => t.isDeleted.equals(false)).getSingle(),
      _db.visits.count(where: (t) => t.isDeleted.equals(false)).getSingle(),
      _db.cashMemos.count(where: (t) => t.isDeleted.equals(false)).getSingle(),
      _db.expenses.count(where: (t) => t.isDeleted.equals(false)).getSingle(),
    ]);
    return counts.fold<int>(0, (a, b) => a + b);
  }

  /// Suggested filename, stamped so successive backups do not overwrite.
  static String suggestedFileName(DateTime now) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'clinicpilot-backup-'
        '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}.csv';
  }

  static List<int> encode(String csv) => utf8.encode(csv);
}
