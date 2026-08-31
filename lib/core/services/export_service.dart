import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:excel/excel.dart' as xlsx;

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

/// Builds Excel (XLSX) and CSV backups of the clinic database.
class ExportService {
  final AppDatabase _db;

  const ExportService(this._db);

  /// Escapes a single CSV field.
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

  static xlsx.CellValue? _cellValue(Object? value) {
    return switch (value) {
      null => null,
      int v => xlsx.IntCellValue(v),
      double v => xlsx.DoubleCellValue(v),
      DateTime v => xlsx.DateTimeCellValue.fromDateTime(v),
      bool v => xlsx.BoolCellValue(v),
      _ => xlsx.TextCellValue(value.toString()),
    };
  }

  static void _styleHeaderRow(xlsx.Sheet sheet, int colCount) {
    for (var col = 0; col < colCount; col++) {
      final cell = sheet.cell(xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = xlsx.CellStyle(
        backgroundColorHex: xlsx.ExcelColor.fromHexString('#1976D2'),
        fontColorHex: xlsx.ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        fontFamily: xlsx.getFontFamily(xlsx.FontFamily.Calibri),
      );
    }
  }

  /// Builds a complete Excel workbook with dedicated sheets for each data domain.
  Future<List<int>> buildXlsx() async {
    final excel = xlsx.Excel.createExcel();
    excel.rename('Sheet1', 'Clinics');

    // Preload clinics and patients maps for human-readable cross-referencing
    final allClinics = await (_db.select(_db.clinics)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final clinicNameById = {for (final c in allClinics) c.id: c.name};

    final allPatients = await (_db.select(_db.patients)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final patientNameById = {for (final p in allPatients) p.id: p.name};
    final patientCodeById = {for (final p in allPatients) p.id: p.patientCode};

    // 1. Clinics Sheet
    final clinicsSheet = excel['Clinics'];
    final clinicHeaders = ['Clinic ID', 'Clinic Name', 'Address', 'Phone', 'Monthly Rent', 'Open Days'];
    clinicsSheet.appendRow(clinicHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(clinicsSheet, clinicHeaders.length);

    for (final c in allClinics) {
      clinicsSheet.appendRow([
        _cellValue(c.id),
        _cellValue(c.name),
        _cellValue(c.address ?? ''),
        _cellValue(c.phone ?? ''),
        _cellValue(c.monthlyRent),
        _cellValue(c.openDays),
      ]);
    }

    // 2. Patients Sheet
    final patientsSheet = excel['Patients'];
    final patientHeaders = [
      'Patient ID', 'Patient Code', 'Serial No.', 'Name', 'Phone', 'WhatsApp', 'Age', 'Gender',
      'Area', 'Address', 'Occupation', 'Clinic Name',
      'Primary Disease', 'Referral Source', 'Notes', 'Created At',
    ];
    patientsSheet.appendRow(patientHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(patientsSheet, patientHeaders.length);

    for (final p in allPatients) {
      final clinicName = clinicNameById[p.primaryClinicId] ?? p.primaryClinicId;
      patientsSheet.appendRow([
        _cellValue(p.id),
        _cellValue(p.patientCode),
        _cellValue(p.serialNo),
        _cellValue(p.name),
        _cellValue(p.phone),
        _cellValue(p.whatsapp ?? ''),
        _cellValue(p.age),
        _cellValue(p.gender),
        _cellValue(p.area ?? ''),
        _cellValue(p.address ?? ''),
        _cellValue(p.occupation ?? ''),
        _cellValue(clinicName),
        _cellValue(p.primaryDisease ?? ''),
        _cellValue(p.referralSource ?? ''),
        _cellValue(p.notes ?? ''),
        _cellValue(p.createdAt),
      ]);
    }

    // 3. Visits Sheet
    final visitsSheet = excel['Visits'];
    final visitHeaders = [
      'Visit ID', 'Patient Code', 'Patient Name', 'Clinic', 'Visit Type', 'Consultation Type',
      'Disease', 'Chief Complaint', 'Referral Source', 'Outcome',
      'Visit Date', 'Next Follow-up', 'Notes',
    ];
    visitsSheet.appendRow(visitHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(visitsSheet, visitHeaders.length);

    final visits = await (_db.select(_db.visits)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final v in visits) {
      final pCode = patientCodeById[v.patientId] ?? v.patientId;
      final pName = patientNameById[v.patientId] ?? '';
      final cName = clinicNameById[v.clinicId] ?? v.clinicId;
      visitsSheet.appendRow([
        _cellValue(v.id),
        _cellValue(pCode),
        _cellValue(pName),
        _cellValue(cName),
        _cellValue(v.visitType),
        _cellValue(v.consultationType),
        _cellValue(v.disease),
        _cellValue(v.chiefComplaint ?? ''),
        _cellValue(v.referralSource ?? ''),
        _cellValue(v.outcome ?? ''),
        _cellValue(v.visitDate),
        _cellValue(v.nextFollowUpDate),
        _cellValue(v.notes ?? ''),
      ]);
    }

    // 4. Cash Memos Sheet
    final memosSheet = excel['Cash Memos'];
    final memoHeaders = [
      'Memo Number', 'Patient Code', 'Patient Name', 'Clinic',
      'Consultation Fee', 'Medicine Fee', 'Other Fee', 'Discount',
      'Total', 'Paid Amount', 'Payment Method', 'Notes', 'Date',
    ];
    memosSheet.appendRow(memoHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(memosSheet, memoHeaders.length);

    final memos = await (_db.select(_db.cashMemos)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final m in memos) {
      final pCode = patientCodeById[m.patientId] ?? m.patientId;
      final pName = patientNameById[m.patientId] ?? '';
      final cName = clinicNameById[m.clinicId] ?? m.clinicId;
      memosSheet.appendRow([
        _cellValue(m.memoNumber),
        _cellValue(pCode),
        _cellValue(pName),
        _cellValue(cName),
        _cellValue(m.consultationFee),
        _cellValue(m.medicineFee),
        _cellValue(m.otherFee),
        _cellValue(m.discount),
        _cellValue(m.total),
        _cellValue(m.paidAmount),
        _cellValue(m.paymentMethod),
        _cellValue(m.notes ?? ''),
        _cellValue(m.memoDate),
      ]);
    }

    // 5. Expenses Sheet
    final expensesSheet = excel['Expenses'];
    final expenseHeaders = [
      'Expense ID', 'Clinic', 'Category', 'Subcategory', 'Amount',
      'Payment Method', 'Recurring', 'Notes', 'Date',
    ];
    expensesSheet.appendRow(expenseHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(expensesSheet, expenseHeaders.length);

    final expenses = await (_db.select(_db.expenses)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final e in expenses) {
      final cName = clinicNameById[e.clinicId] ?? e.clinicId;
      expensesSheet.appendRow([
        _cellValue(e.id),
        _cellValue(cName),
        _cellValue(e.category),
        _cellValue(e.subcategory ?? ''),
        _cellValue(e.amount),
        _cellValue(e.paymentMethod),
        _cellValue(e.isRecurring ? 'Yes' : 'No'),
        _cellValue(e.notes ?? ''),
        _cellValue(e.date),
      ]);
    }

    // 6. Prescriptions Sheet
    final prescriptionsSheet = excel['Prescriptions'];
    final rxHeaders = [
      'Prescription ID', 'Patient Code', 'Patient Name', 'Remedy Name',
      'Potency', 'Vehicle', 'Dose', 'Frequency', 'Duration (Days)', 'Diet / Regimen Advice', 'Date',
    ];
    prescriptionsSheet.appendRow(rxHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(prescriptionsSheet, rxHeaders.length);

    final prescriptions = await (_db.select(_db.prescriptions)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final r in prescriptions) {
      final pCode = patientCodeById[r.patientId] ?? r.patientId;
      final pName = patientNameById[r.patientId] ?? '';
      prescriptionsSheet.appendRow([
        _cellValue(r.id),
        _cellValue(pCode),
        _cellValue(pName),
        _cellValue(r.remedyName),
        _cellValue(r.potency),
        _cellValue(r.vehicle ?? ''),
        _cellValue(r.doseCount ?? ''),
        _cellValue(r.frequency ?? ''),
        _cellValue(r.durationDays ?? ''),
        _cellValue(r.dietaryAdvice ?? ''),
        _cellValue(r.createdAt),
      ]);
    }

    // 7. Complaints Sheet
    final complaintsSheet = excel['Complaints'];
    final complaintHeaders = [
      'Complaint ID', 'Patient Code', 'Patient Name', 'Complaint', 'Location',
      'Side', 'Sensation', 'Severity (1-10)', 'Aggravation', 'Amelioration', 'Date',
    ];
    complaintsSheet.appendRow(complaintHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(complaintsSheet, complaintHeaders.length);

    final complaints = await (_db.select(_db.complaints)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final comp in complaints) {
      final pCode = patientCodeById[comp.patientId] ?? comp.patientId;
      final pName = patientNameById[comp.patientId] ?? '';
      complaintsSheet.appendRow([
        _cellValue(comp.id),
        _cellValue(pCode),
        _cellValue(pName),
        _cellValue(comp.complaintName),
        _cellValue(comp.location ?? ''),
        _cellValue(comp.side ?? ''),
        _cellValue(comp.sensation ?? ''),
        _cellValue(comp.severity),
        _cellValue(comp.aggravatingFactors ?? ''),
        _cellValue(comp.amelioratingFactors ?? ''),
        _cellValue(comp.createdAt),
      ]);
    }

    // 8. Investigations Sheet
    final investigationsSheet = excel['Investigations'];
    final investigationHeaders = [
      'Test ID', 'Patient Code', 'Patient Name', 'Test Name',
      'Category', 'Observed Value', 'Unit', 'Status', 'Date',
    ];
    investigationsSheet.appendRow(investigationHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(investigationsSheet, investigationHeaders.length);

    final investigations = await (_db.select(_db.investigations)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final inv in investigations) {
      final pCode = patientCodeById[inv.patientId] ?? inv.patientId;
      final pName = patientNameById[inv.patientId] ?? '';
      final val = inv.stringValue ?? (inv.numericValue?.toString() ?? '');
      investigationsSheet.appendRow([
        _cellValue(inv.id),
        _cellValue(pCode),
        _cellValue(pName),
        _cellValue(inv.testName),
        _cellValue(inv.testCategory),
        _cellValue(val),
        _cellValue(inv.unit ?? ''),
        _cellValue(inv.flag),
        _cellValue(inv.testDate),
      ]);
    }

    // 9. Camps Sheet
    final campsSheet = excel['Camps'];
    final campHeaders = [
      'Camp ID', 'Clinic', 'Camp Name', 'Location / Venue',
      'Date', 'Cost / Budget', 'Attendance', 'Notes',
    ];
    campsSheet.appendRow(campHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(campsSheet, campHeaders.length);

    final camps = await (_db.select(_db.camps)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final cmp in camps) {
      final cName = clinicNameById[cmp.clinicId] ?? (cmp.clinicId ?? '');
      campsSheet.appendRow([
        _cellValue(cmp.id),
        _cellValue(cName),
        _cellValue(cmp.name),
        _cellValue(cmp.location ?? ''),
        _cellValue(cmp.date),
        _cellValue(cmp.cost),
        _cellValue(cmp.attendance),
        _cellValue(cmp.notes ?? ''),
      ]);
    }

    // 10. Referral Partners Sheet
    final referralSheet = excel['Referral Partners'];
    final referralHeaders = [
      'Partner ID', 'Partner Name', 'Category', 'Contact Person',
      'Phone', 'Address', 'Total Referrals', 'Visits Count', 'Notes',
    ];
    referralSheet.appendRow(referralHeaders.map((h) => xlsx.TextCellValue(h)).toList());
    _styleHeaderRow(referralSheet, referralHeaders.length);

    final referralContacts = await (_db.select(_db.referralContacts)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    for (final refContact in referralContacts) {
      referralSheet.appendRow([
        _cellValue(refContact.id),
        _cellValue(refContact.name),
        _cellValue(refContact.category),
        _cellValue(refContact.contactPerson ?? ''),
        _cellValue(refContact.phone ?? ''),
        _cellValue(refContact.address ?? ''),
        _cellValue(refContact.referralCount),
        _cellValue(refContact.visitCount),
        _cellValue(refContact.notes ?? ''),
      ]);
    }

    final encoded = excel.encode();
    return encoded ?? [];
  }

  /// Produces the full backup as a single CSV document.
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
        'id', 'patient_code', 'serial_no', 'name', 'phone', 'whatsapp', 'age', 'gender',
        'area', 'address', 'occupation', 'primary_clinic_id',
        'primary_disease', 'referral_source', 'notes', 'created_at',
      ]));
    for (final p in patients) {
      buffer.writeln(_row([
        p.id, p.patientCode, p.serialNo, p.name, p.phone, p.whatsapp, p.age, p.gender,
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
        e.paymentMethod, e.isRecurring ? 'Yes' : 'No', e.notes, _date(e.date),
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
  static String suggestedFileName(DateTime now, {String extension = 'xlsx'}) {
    String two(int v) => v.toString().padLeft(2, '0');
    final ext = extension.startsWith('.') ? extension.substring(1) : extension;
    return 'clinicpilot-backup-'
        '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}.$ext';
  }

  static List<int> encode(String csv) => utf8.encode(csv);
}
