import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../database/app_database.dart';

class PdfService {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  // Generate printable PDF binary data for a Cash Memo
  static Future<Uint8List> generateCashMemoPdf({
    required CashMemo cashMemo,
    required Patient patient,
    // No default: a receipt is a document the patient keeps, and a fallback
    // here would print somebody else's clinic name on it.
    required String clinicName,
    String clinicTagline = "Your Clinic. Measured.",
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#0F5132'); // Emerald
    final textDark = PdfColor.fromHex('#212529');
    final textMuted = PdfColor.fromHex('#6C757D');
    final bgLight = PdfColor.fromHex('#F8F9FA');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        clinicName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.Text(
                        clinicTagline,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      clinicName.toLowerCase().contains('online') ||
                              clinicName.toLowerCase().contains('teleconsult')
                          ? 'TELECONSULTATION RECEIPT'
                          : 'CASH MEMO',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: primaryColor, thickness: 1.5),
              pw.SizedBox(height: 16),

              // Memo Meta & Patient Details Card
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: bgLight,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PATIENT DETAILS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: textMuted,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          patient.name,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        pw.Text(
                          'Phone: ${patient.phone}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Age/Gender: ${patient.age} yrs / ${patient.gender}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Disease: ${patient.primaryDisease ?? "N/A"}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'MEMO INFO',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: textMuted,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Memo #: ${cashMemo.memoNumber}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Date: ${_dateFormat.format(cashMemo.memoDate)}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Payment Method: ${cashMemo.paymentMethod}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Itemized Charges Table
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.8,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          'Amount (INR)',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  _buildTableRow(
                    'Consultation Fee',
                    'Rs. ${cashMemo.consultationFee.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    'Medicine Charges',
                    'Rs. ${cashMemo.medicineFee.toStringAsFixed(2)}',
                  ),
                  if (cashMemo.otherFee > 0)
                    _buildTableRow(
                      'Other Charges',
                      'Rs. ${cashMemo.otherFee.toStringAsFixed(2)}',
                    ),
                  if (cashMemo.discount > 0)
                    _buildTableRow(
                      'Discount (-)',
                      'Rs. ${cashMemo.discount.toStringAsFixed(2)}',
                    ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Total Calculation Card
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: bgLight,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: primaryColor, width: 1.5),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Paid:',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Rs. ${cashMemo.total.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Footer Note
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for visiting $clinicName!',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'For follow-up appointments, please call ${patient.phone.isNotEmpty ? "clinic support" : ""}.',
                      style: pw.TextStyle(fontSize: 10, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildTableRow(String title, String amount) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            amount,
            style: const pw.TextStyle(fontSize: 12),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }
}
