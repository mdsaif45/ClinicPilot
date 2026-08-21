import 'package:excel/excel.dart' as xlsx;

/// The exact sheet names and header rows the template - and the importer
/// that reads a filled one back - agree on. Defined once so the template
/// generator and the reader can never drift apart from each other.
class ImportTemplateSchema {
  const ImportTemplateSchema._();

  static const patientsSheet = 'Patients';
  static const visitsSheet = 'Visits';
  static const cashMemosSheet = 'Cash Memos';
  static const expensesSheet = 'Expenses';
  static const readMeSheet = 'Read Me';

  static const patientsHeaders = [
    'Serial No.',
    'Clinic',
    'Name',
    'Phone',
    'WhatsApp',
    'Age',
    'Gender',
    'Area',
    'Disease',
    'Referral Source',
  ];

  static const visitsHeaders = [
    'Patient Serial No.',
    'Clinic',
    'Visit Date',
    'Visit Type',
    'Consultation Type',
    'Disease',
    'Outcome',
  ];

  static const cashMemosHeaders = [
    'Patient Serial No.',
    'Clinic',
    'Date',
    'Consultation Fee',
    'Medicine Fee',
    'Other Fee',
    'Discount',
    'Paid Amount',
    'Payment Method',
  ];

  static const expensesHeaders = [
    'Clinic',
    'Date',
    'Category',
    'Subcategory',
    'Amount',
    'Payment Method',
  ];

  static const genders = ['Male', 'Female', 'Other'];
  static const visitTypes = ['new', 'repeat'];
  static const consultationTypes = ['clinic', 'online', 'camp'];
  static const outcomes = [
    'improved',
    'no_change',
    'worse',
    'recovered',
    'lost_followup',
  ];
  static const paymentMethods = ['Cash', 'UPI', 'Card', 'Bank Transfer'];
  static const expenseCategories = [
    'Rent',
    'Electricity',
    'Staff Salary',
    'Medicine Purchase',
    'Furniture',
    'Marketing',
    'Camp',
    'Internet',
    'Travel',
    'Personal',
    'Miscellaneous',
  ];
}

/// Builds the blank workbook a doctor downloads, fills in Excel or Sheets,
/// and imports back through ImportService.
///
/// Nothing is accepted for import that did not start from this template -
/// that constraint, not a forgiving parser, is what actually closes off the
/// "any hand-built file might crash on import" problem. An example row
/// (clearly marked) shows the shape without the doctor having to guess it
/// from a blank header row.
class ImportTemplateService {
  const ImportTemplateService._();

  static xlsx.CellStyle get _headerStyle => xlsx.CellStyle(
        bold: true,
        backgroundColorHex: xlsx.ExcelColor.fromHexString('#0F5132'),
        fontColorHex: xlsx.ExcelColor.fromHexString('#FFFFFF'),
      );

  static xlsx.CellStyle get _exampleStyle => xlsx.CellStyle(
        italic: true,
        fontColorHex: xlsx.ExcelColor.fromHexString('#6C757D'),
      );

  static void _writeHeader(xlsx.Sheet sheet, List<String> headers) {
    sheet.appendRow(headers.map((h) => xlsx.TextCellValue(h)).toList());
    for (var col = 0; col < headers.length; col++) {
      sheet
          .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .cellStyle = _headerStyle;
      sheet.setColumnWidth(col, 20);
    }
  }

  static void _writeExampleRow(xlsx.Sheet sheet, List<Object?> cells) {
    final rowIndex = sheet.maxRows;
    sheet.appendRow(cells.map((c) {
      if (c == null) return null;
      if (c is num) return xlsx.DoubleCellValue(c.toDouble());
      return xlsx.TextCellValue(c.toString());
    }).toList());
    for (var col = 0; col < cells.length; col++) {
      sheet
          .cell(xlsx.CellIndex.indexByColumnRow(
              columnIndex: col, rowIndex: rowIndex))
          .cellStyle = _exampleStyle;
    }
  }

  static List<int> build() {
    final book = xlsx.Excel.createExcel();
    book.rename('Sheet1', ImportTemplateSchema.patientsSheet);

    final patients = book[ImportTemplateSchema.patientsSheet];
    _writeHeader(patients, ImportTemplateSchema.patientsHeaders);
    _writeExampleRow(patients, [
      'DELETE-THIS-EXAMPLE-1', 'Example Clinic', 'Asha Rao', '9800000001',
      '', 34, 'Female', 'Kharagpur', 'Migraine', 'Walk-in',
    ]);

    final visits = book[ImportTemplateSchema.visitsSheet];
    _writeHeader(visits, ImportTemplateSchema.visitsHeaders);
    _writeExampleRow(visits, [
      'DELETE-THIS-EXAMPLE-1', 'Example Clinic', '2026-03-14', 'new',
      'clinic', 'Migraine', 'improved',
    ]);

    final memos = book[ImportTemplateSchema.cashMemosSheet];
    _writeHeader(memos, ImportTemplateSchema.cashMemosHeaders);
    _writeExampleRow(memos, [
      'DELETE-THIS-EXAMPLE-1', 'Example Clinic', '2026-03-14', 300, 100,
      0, 0, 400, 'Cash',
    ]);

    final expenses = book[ImportTemplateSchema.expensesSheet];
    _writeHeader(expenses, ImportTemplateSchema.expensesHeaders);
    _writeExampleRow(expenses, [
      'Example Clinic', '2026-03-01', 'Rent', '', 3000, 'Cash',
    ]);

    final readMe = book[ImportTemplateSchema.readMeSheet];
    readMe.setColumnWidth(0, 90);
    var row = 0;
    void line(String text, {bool bold = false}) {
      readMe.appendRow([xlsx.TextCellValue(text)]);
      if (bold) {
        readMe
            .cell(xlsx.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .cellStyle = xlsx.CellStyle(bold: true);
      }
      row++;
    }

    line('ClinicPilot Import Template', bold: true);
    line('');
    line('Delete the example row on each sheet before importing - it is '
        'marked DELETE-THIS-EXAMPLE and will otherwise be rejected as a '
        'row for a clinic or serial that does not exist.');
    line('');
    line('Patients (required - at least one real row)', bold: true);
    line('Clinic must exactly match a clinic already in the app - import '
        'does not create clinics, since a clinic carries settings (rent, '
        'default fee, open days) a spreadsheet row cannot define.');
    line('Serial No., Clinic, Name, Phone, Age, Gender and Disease are '
        'required. Gender must be one of: ${ImportTemplateSchema.genders.join(', ')}');
    line('');
    line('Visits and Cash Memos (optional - can be left empty)', bold: true);
    line('Patient Serial No. + Clinic must match a row on the Patients '
        'sheet - that pair is how a row here links back to a patient, '
        'since a spreadsheet cannot reference an internal database id.');
    line('Visit Type: ${ImportTemplateSchema.visitTypes.join(', ')}. '
        'Consultation Type: ${ImportTemplateSchema.consultationTypes.join(', ')}. '
        'Outcome (optional): ${ImportTemplateSchema.outcomes.join(', ')}');
    line('Payment Method: ${ImportTemplateSchema.paymentMethods.join(', ')}');
    line('');
    line('Expenses (optional - can be left empty)', bold: true);
    line('Clinic must match an existing clinic. Category: '
        '${ImportTemplateSchema.expenseCategories.join(', ')}');
    line('');
    line('A row with a problem is skipped and reported after import - it '
        'does not stop the rows that are valid from being imported.');

    return book.encode()!;
  }
}
