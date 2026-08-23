import 'package:clinic_pilot/core/utils/id_generator.dart';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart' as xlsx;

import '../database/app_database.dart';
import 'import_template_service.dart';


/// One row that could not be imported, with enough context to find and fix
/// it in the spreadsheet.
class ImportRowError {
  final String sheet;
  final int rowNumber; // 1-based, matching what a spreadsheet shows.
  final String reason;

  const ImportRowError(this.sheet, this.rowNumber, this.reason);

  @override
  String toString() => '$sheet row $rowNumber: $reason';
}

/// What a filled template would produce, before the doctor confirms it.
/// Built by [ImportService.validate] and shown as a preview - the doctor
/// sees exactly what will happen before anything is written.
class ImportPreview {
  final int patientCount;
  final int visitCount;
  final int memoCount;
  final int expenseCount;
  final List<ImportRowError> errors;

  const ImportPreview({
    required this.patientCount,
    required this.visitCount,
    required this.memoCount,
    required this.expenseCount,
    required this.errors,
  });

  bool get hasImportableData => patientCount > 0;
}

class _ValidPatientRow {
  final String serialNo;
  final String clinicId;
  final String name;
  final String phone;
  final String? whatsapp;
  final int age;
  final String gender;
  final String? area;
  final String disease;
  final String? referralSource;

  const _ValidPatientRow({
    required this.serialNo,
    required this.clinicId,
    required this.name,
    required this.phone,
    this.whatsapp,
    required this.age,
    required this.gender,
    this.area,
    required this.disease,
    this.referralSource,
  });
}

class _ValidVisitRow {
  final String patientSerialNo;
  final String clinicId;
  final DateTime visitDate;
  final String visitType;
  final String consultationType;
  final String disease;
  final String? outcome;

  const _ValidVisitRow({
    required this.patientSerialNo,
    required this.clinicId,
    required this.visitDate,
    required this.visitType,
    required this.consultationType,
    required this.disease,
    this.outcome,
  });
}

class _ValidMemoRow {
  final String patientSerialNo;
  final String clinicId;
  final DateTime date;
  final double consultationFee;
  final double medicineFee;
  final double otherFee;
  final double discount;
  final double paidAmount;
  final String paymentMethod;

  const _ValidMemoRow({
    required this.patientSerialNo,
    required this.clinicId,
    required this.date,
    required this.consultationFee,
    required this.medicineFee,
    required this.otherFee,
    required this.discount,
    required this.paidAmount,
    required this.paymentMethod,
  });
}

class _ValidExpenseRow {
  final String clinicId;
  final DateTime date;
  final String category;
  final String? subcategory;
  final double amount;
  final String paymentMethod;

  const _ValidExpenseRow({
    required this.clinicId,
    required this.date,
    required this.category,
    this.subcategory,
    required this.amount,
    required this.paymentMethod,
  });
}

/// Validated rows ready to insert, produced once by [ImportService.validate]
/// and handed to [ImportService.commit] so the two never disagree about
/// what passed.
class _ValidatedImport {
  final List<_ValidPatientRow> patients;
  final List<_ValidVisitRow> visits;
  final List<_ValidMemoRow> memos;
  final List<_ValidExpenseRow> expenses;
  final List<ImportRowError> errors;

  const _ValidatedImport({
    required this.patients,
    required this.visits,
    required this.memos,
    required this.expenses,
    required this.errors,
  });
}

/// Reads a filled-in template workbook, validates it, and - once the doctor
/// confirms the preview - writes everything in one transaction.
///
/// Only ever runs against an empty database (enforced by the caller, which
/// gates the whole feature on countRows() == 0), so there is no existing
/// data to merge against and no serial-number collision to consider beyond
/// what the sheet itself contains.
class ImportService {
  final AppDatabase _db;

  const ImportService(this._db);

  /// Reads every cell in a row as plain text, trimmed. A blank cell and a
  /// missing column both come back as ''.
  static List<String> _rowText(List<xlsx.Data?> row, int columnCount) {
    return List.generate(columnCount, (i) {
      if (i >= row.length) return '';
      final value = row[i]?.value;
      return switch (value) {
        null => '',
        xlsx.TextCellValue v => v.value.text?.trim() ?? '',
        xlsx.IntCellValue v => v.value.toString(),
        xlsx.DoubleCellValue v => v.value.toString(),
        xlsx.DateTimeCellValue v => v.asDateTimeLocal().toIso8601String(),
        xlsx.DateCellValue v => v.asDateTimeLocal().toIso8601String(),
        xlsx.BoolCellValue v => v.value.toString(),
        _ => value.toString().trim(),
      };
    });
  }

  static DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    // Handles both a plain "2026-03-14" the doctor typed and the ISO string
    // _rowText already produced from a real Excel date cell.
    return DateTime.tryParse(raw);
  }

  static double? _parseAmount(String raw) {
    if (raw.isEmpty) return 0;
    return double.tryParse(raw);
  }

  /// Verifies the workbook has every expected sheet with the expected
  /// header row, before reading a single data row. A wrong file - or a
  /// template a doctor started renaming columns in - is rejected here with
  /// one clear error, rather than surfacing as confusing row-level ones.
  static String? _verifyStructure(xlsx.Excel book) {
    final required = {
      ImportTemplateSchema.patientsSheet: ImportTemplateSchema.patientsHeaders,
      ImportTemplateSchema.visitsSheet: ImportTemplateSchema.visitsHeaders,
      ImportTemplateSchema.cashMemosSheet:
          ImportTemplateSchema.cashMemosHeaders,
      ImportTemplateSchema.expensesSheet: ImportTemplateSchema.expensesHeaders,
    };

    for (final entry in required.entries) {
      final sheet = book.tables[entry.key];
      if (sheet == null) {
        return 'This file has no "${entry.key}" sheet. Use the downloaded '
            'template rather than a different workbook.';
      }
      if (sheet.rows.isEmpty) {
        return 'The "${entry.key}" sheet has no header row.';
      }
      final header = _rowText(sheet.rows[0], entry.value.length);
      for (var i = 0; i < entry.value.length; i++) {
        if (header[i] != entry.value[i]) {
          return 'The "${entry.key}" sheet\'s columns do not match the '
              'template (expected "${entry.value[i]}" in column '
              '${i + 1}). Download a fresh template rather than editing '
              'column headers.';
        }
      }
    }
    return null;
  }

  static bool _isExampleRow(List<String> cells) =>
      cells.isNotEmpty && cells[0].contains('DELETE-THIS-EXAMPLE');

  /// Reads and validates a workbook without writing anything. Two passes:
  /// Patients first, building a (serial, clinic) -> clinicId lookup from
  /// only the rows that themselves validated; then Visits/Memos/Expenses,
  /// each checked against that lookup. A row whose patient failed pass one
  /// fails pass two with a reason that says so, rather than a generic
  /// "patient not found".
  static Future<ImportPreview> validate(
    List<int> bytes,
    Map<String, String> clinicIdsByName,
  ) async {
    final result = await _validateInternal(bytes, clinicIdsByName);
    return ImportPreview(
      patientCount: result.patients.length,
      visitCount: result.visits.length,
      memoCount: result.memos.length,
      expenseCount: result.expenses.length,
      errors: result.errors,
    );
  }

  static Future<_ValidatedImport> _validateInternal(
    List<int> bytes,
    Map<String, String> clinicIdsByName,
  ) async {
    final book = xlsx.Excel.decodeBytes(bytes);

    final structureError = _verifyStructure(book);
    if (structureError != null) {
      return _ValidatedImport(
        patients: const [],
        visits: const [],
        memos: const [],
        expenses: const [],
        errors: [ImportRowError('Workbook', 0, structureError)],
      );
    }

    final errors = <ImportRowError>[];

    // Pass 1: Patients. Key is (serialNo, clinicId) - the same pair the
    // database's own unique index is keyed on - so two patients with the
    // same serial at different clinics are correctly distinct entries.
    final patients = <_ValidPatientRow>[];
    final patientLookup = <String, _ValidPatientRow>{};
    String patientKey(String serial, String clinicId) => '$clinicId::$serial';

    final patientRows = book.tables[ImportTemplateSchema.patientsSheet]!.rows;
    for (var i = 1; i < patientRows.length; i++) {
      final rowNum = i + 1;
      final cells = _rowText(
          patientRows[i], ImportTemplateSchema.patientsHeaders.length);
      if (_isExampleRow(cells)) continue;
      if (cells.every((c) => c.isEmpty)) continue; // a fully blank row

      final serial = cells[0];
      final clinicName = cells[1];
      final name = cells[2];
      final phone = cells[3];
      final whatsapp = cells[4];
      final ageRaw = cells[5];
      final gender = cells[6];
      final area = cells[7];
      final disease = cells[8];
      final referralSource = cells[9];

      String? error;
      if (serial.isEmpty) {
        error = 'Serial No. is required';
      } else if (clinicName.isEmpty) {
        error = 'Clinic is required';
      } else if (!clinicIdsByName.containsKey(clinicName)) {
        error = 'Clinic "$clinicName" not found - add it in Settings first';
      } else if (name.isEmpty) {
        error = 'Name is required';
      } else if (phone.isEmpty) {
        error = 'Phone is required';
      } else if (int.tryParse(ageRaw) == null) {
        error = 'Age must be a number';
      } else if (!ImportTemplateSchema.genders.contains(gender)) {
        error = 'Gender must be one of: '
            '${ImportTemplateSchema.genders.join(', ')}';
      } else if (disease.isEmpty) {
        error = 'Disease is required';
      }

      if (error == null) {
        final clinicId = clinicIdsByName[clinicName]!;
        final key = patientKey(serial, clinicId);
        if (patientLookup.containsKey(key)) {
          error = 'Serial $serial is used twice for this clinic in this '
              'sheet';
        }
      }

      if (error != null) {
        errors.add(ImportRowError(
            ImportTemplateSchema.patientsSheet, rowNum, error));
        continue;
      }

      final clinicId = clinicIdsByName[clinicName]!;
      final row = _ValidPatientRow(
        serialNo: serial,
        clinicId: clinicId,
        name: name,
        phone: phone,
        whatsapp: whatsapp.isEmpty ? null : whatsapp,
        age: int.parse(ageRaw),
        gender: gender,
        area: area.isEmpty ? null : area,
        disease: disease,
        referralSource: referralSource.isEmpty ? null : referralSource,
      );
      patients.add(row);
      patientLookup[patientKey(serial, clinicId)] = row;
    }

    // Pass 2: Visits, keyed against the lookup pass 1 just built. A row
    // referencing a patient that itself failed pass 1 fails here too, with
    // a reason that points back at the actual cause.
    final visits = <_ValidVisitRow>[];
    final visitRows = book.tables[ImportTemplateSchema.visitsSheet]!.rows;
    for (var i = 1; i < visitRows.length; i++) {
      final rowNum = i + 1;
      final cells =
          _rowText(visitRows[i], ImportTemplateSchema.visitsHeaders.length);
      if (_isExampleRow(cells)) continue;
      if (cells.every((c) => c.isEmpty)) continue;

      final serial = cells[0];
      final clinicName = cells[1];
      final dateRaw = cells[2];
      final visitType = cells[3];
      final consultationType = cells[4];
      final disease = cells[5];
      final outcome = cells[6];

      String? error;
      final clinicId = clinicIdsByName[clinicName];
      if (clinicName.isEmpty || clinicId == null) {
        error = 'Clinic "$clinicName" not found';
      } else if (serial.isEmpty ||
          !patientLookup.containsKey(patientKey(serial, clinicId))) {
        error = 'No valid patient with Serial $serial at "$clinicName" on '
            'the Patients sheet';
      } else if (_parseDate(dateRaw) == null) {
        error = 'Visit Date is required and must be a real date';
      } else if (!ImportTemplateSchema.visitTypes.contains(visitType)) {
        error = 'Visit Type must be one of: '
            '${ImportTemplateSchema.visitTypes.join(', ')}';
      } else if (!ImportTemplateSchema.consultationTypes
          .contains(consultationType)) {
        error = 'Consultation Type must be one of: '
            '${ImportTemplateSchema.consultationTypes.join(', ')}';
      } else if (disease.isEmpty) {
        error = 'Disease is required';
      } else if (outcome.isNotEmpty &&
          !ImportTemplateSchema.outcomes.contains(outcome)) {
        error = 'Outcome must be blank or one of: '
            '${ImportTemplateSchema.outcomes.join(', ')}';
      }

      if (error != null) {
        errors.add(
            ImportRowError(ImportTemplateSchema.visitsSheet, rowNum, error));
        continue;
      }

      visits.add(_ValidVisitRow(
        patientSerialNo: serial,
        clinicId: clinicId!,
        visitDate: _parseDate(dateRaw)!,
        visitType: visitType,
        consultationType: consultationType,
        disease: disease,
        outcome: outcome.isEmpty ? null : outcome,
      ));
    }

    // Pass 2: Cash Memos, same linking rule as Visits.
    final memos = <_ValidMemoRow>[];
    final memoRows = book.tables[ImportTemplateSchema.cashMemosSheet]!.rows;
    for (var i = 1; i < memoRows.length; i++) {
      final rowNum = i + 1;
      final cells = _rowText(
          memoRows[i], ImportTemplateSchema.cashMemosHeaders.length);
      if (_isExampleRow(cells)) continue;
      if (cells.every((c) => c.isEmpty)) continue;

      final serial = cells[0];
      final clinicName = cells[1];
      final dateRaw = cells[2];
      final consultationFeeRaw = cells[3];
      final medicineFeeRaw = cells[4];
      final otherFeeRaw = cells[5];
      final discountRaw = cells[6];
      final paidAmountRaw = cells[7];
      final paymentMethod = cells[8];

      String? error;
      final clinicId = clinicIdsByName[clinicName];
      if (clinicName.isEmpty || clinicId == null) {
        error = 'Clinic "$clinicName" not found';
      } else if (serial.isEmpty ||
          !patientLookup.containsKey(patientKey(serial, clinicId))) {
        error = 'No valid patient with Serial $serial at "$clinicName" on '
            'the Patients sheet';
      } else if (_parseDate(dateRaw) == null) {
        error = 'Date is required and must be a real date';
      } else if (_parseAmount(consultationFeeRaw) == null ||
          _parseAmount(medicineFeeRaw) == null ||
          _parseAmount(otherFeeRaw) == null ||
          _parseAmount(discountRaw) == null ||
          _parseAmount(paidAmountRaw) == null) {
        error = 'Every fee, discount and paid amount must be a number';
      } else if (!ImportTemplateSchema.paymentMethods
          .contains(paymentMethod)) {
        error = 'Payment Method must be one of: '
            '${ImportTemplateSchema.paymentMethods.join(', ')}';
      }

      if (error != null) {
        errors.add(ImportRowError(
            ImportTemplateSchema.cashMemosSheet, rowNum, error));
        continue;
      }

      memos.add(_ValidMemoRow(
        patientSerialNo: serial,
        clinicId: clinicId!,
        date: _parseDate(dateRaw)!,
        consultationFee: _parseAmount(consultationFeeRaw)!,
        medicineFee: _parseAmount(medicineFeeRaw)!,
        otherFee: _parseAmount(otherFeeRaw)!,
        discount: _parseAmount(discountRaw)!,
        paidAmount: _parseAmount(paidAmountRaw)!,
        paymentMethod: paymentMethod,
      ));
    }

    // Expenses: clinic-only, no patient link.
    final expenses = <_ValidExpenseRow>[];
    final expenseRows =
        book.tables[ImportTemplateSchema.expensesSheet]!.rows;
    for (var i = 1; i < expenseRows.length; i++) {
      final rowNum = i + 1;
      final cells = _rowText(
          expenseRows[i], ImportTemplateSchema.expensesHeaders.length);
      if (_isExampleRow(cells)) continue;
      if (cells.every((c) => c.isEmpty)) continue;

      final clinicName = cells[0];
      final dateRaw = cells[1];
      final category = cells[2];
      final subcategory = cells[3];
      final amountRaw = cells[4];
      final paymentMethod = cells[5];

      String? error;
      final clinicId = clinicIdsByName[clinicName];
      if (clinicName.isEmpty || clinicId == null) {
        error = 'Clinic "$clinicName" not found';
      } else if (_parseDate(dateRaw) == null) {
        error = 'Date is required and must be a real date';
      } else if (!ImportTemplateSchema.expenseCategories
          .contains(category)) {
        error = 'Category must be one of: '
            '${ImportTemplateSchema.expenseCategories.join(', ')}';
      } else if (_parseAmount(amountRaw) == null) {
        error = 'Amount must be a number';
      } else if (!ImportTemplateSchema.paymentMethods
          .contains(paymentMethod)) {
        error = 'Payment Method must be one of: '
            '${ImportTemplateSchema.paymentMethods.join(', ')}';
      }

      if (error != null) {
        errors.add(ImportRowError(
            ImportTemplateSchema.expensesSheet, rowNum, error));
        continue;
      }

      expenses.add(_ValidExpenseRow(
        clinicId: clinicId!,
        date: _parseDate(dateRaw)!,
        category: category,
        subcategory: subcategory.isEmpty ? null : subcategory,
        amount: _parseAmount(amountRaw)!,
        paymentMethod: paymentMethod,
      ));
    }

    return _ValidatedImport(
      patients: patients,
      visits: visits,
      memos: memos,
      expenses: expenses,
      errors: errors,
    );
  }

  /// Writes a previously-validated workbook. Re-validates first rather than
  /// trusting a stale preview - the doctor could edit the file and reopen
  /// the same import screen without a fresh pick.
  ///
  /// Insert order matches the tables' own foreign keys: patients before
  /// visits and memos (both reference patientId), and every table after
  /// clinics, which the caller must already have. One transaction, so a
  /// failure partway through leaves nothing behind rather than half a
  /// restore.
  Future<ImportPreview> commit(
    List<int> bytes,
    Map<String, String> clinicIdsByName,
  ) async {
    final result = await _validateInternal(bytes, clinicIdsByName);
    if (result.patients.isEmpty) {
      return ImportPreview(
        patientCount: 0,
        visitCount: 0,
        memoCount: 0,
        expenseCount: 0,
        errors: result.errors,
      );
    }

    final year = DateTime.now().year;
    final now = DateTime.now();

    // serial+clinic -> the id assigned to that patient, so Visits and Memos
    // can attach to the row this same commit is about to create.
    final patientIds = <String, String>{};
    String key(String serial, String clinicId) => '$clinicId::$serial';

    await _db.transaction(() async {
      for (var i = 0; i < result.patients.length; i++) {
        final p = result.patients[i];
        final id = IdGenerator.generate();
        final code = 'P-$year-${(i + 1).toString().padLeft(5, '0')}';
        patientIds[key(p.serialNo, p.clinicId)] = id;

        await _db.into(_db.patients).insert(PatientsCompanion.insert(
              id: id,
              patientCode: Value(code),
              serialNo: Value(p.serialNo),
              name: p.name,
              phone: p.phone,
              whatsapp: Value(p.whatsapp),
              age: p.age,
              gender: p.gender,
              area: Value(p.area),
              primaryClinicId: Value(p.clinicId),
              primaryDisease: Value(p.disease),
              referralSource: Value(p.referralSource),
              createdAt: Value(now),
              updatedAt: Value(now),
            ));
      }

      for (final v in result.visits) {
        final patientId = patientIds[key(v.patientSerialNo, v.clinicId)]!;
        await _db.into(_db.visits).insert(VisitsCompanion.insert(
              id: IdGenerator.generate(),
              patientId: patientId,
              clinicId: v.clinicId,
              visitType: v.visitType,
              consultationType: Value(v.consultationType),
              disease: v.disease,
              outcome: Value(v.outcome),
              visitDate: v.visitDate,
              createdAt: Value(now),
            ));
      }

      for (final m in result.memos) {
        final patientId = patientIds[key(m.patientSerialNo, m.clinicId)]!;
        final total =
            (m.consultationFee + m.medicineFee + m.otherFee) - m.discount;
        await _db.into(_db.cashMemos).insert(CashMemosCompanion.insert(
              id: IdGenerator.generate(),
              memoNumber: 'CM-IMPORT-${IdGenerator.generate().substring(0, 8)}',
              patientId: patientId,
              clinicId: Value(m.clinicId),
              consultationFee: Value(m.consultationFee),
              medicineFee: Value(m.medicineFee),
              otherFee: Value(m.otherFee),
              discount: Value(m.discount),
              total: total,
              paidAmount: Value(m.paidAmount),
              paymentMethod: m.paymentMethod,
              memoDate: Value(m.date),
              createdAt: Value(now),
            ));
      }

      for (final e in result.expenses) {
        await _db.into(_db.expenses).insert(ExpensesCompanion.insert(
              id: IdGenerator.generate(),
              clinicId: e.clinicId,
              category: e.category,
              subcategory: Value(e.subcategory),
              amount: e.amount,
              paymentMethod: Value(e.paymentMethod),
              date: e.date,
              createdAt: Value(now),
            ));
      }
    });

    return ImportPreview(
      patientCount: result.patients.length,
      visitCount: result.visits.length,
      memoCount: result.memos.length,
      expenseCount: result.expenses.length,
      errors: result.errors,
    );
  }
}
