import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/app_database.dart';
import '../../features/settings/providers/doctor_profile_provider.dart';

/// Service responsible for compiling clinical data, doctor profile,
/// clinic letterhead, complaints, and remedies into a professional,
/// print-ready Medical Prescription (Rx) PDF document.
class PrescriptionPdfService {
  const PrescriptionPdfService._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static final _primaryColor = PdfColor.fromHex('#0F5132'); // Brand Emerald
  static final _textDark = PdfColor.fromHex('#1F2937'); // Slate 800
  static final _textMuted = PdfColor.fromHex('#4B5563'); // Slate 600
  static final _bgLight = PdfColor.fromHex('#F9FAFB'); // Slate 50
  static final _borderColor = PdfColor.fromHex('#E5E7EB'); // Slate 200
  static final _accentLight = PdfColor.fromHex('#E8F5E9'); // Light Mint

  /// Generates a complete, single- or multi-page PDF prescription document.
  static Future<Uint8List> generatePrescriptionPdf({
    required Patient patient,
    required Clinic clinic,
    required DoctorProfile doctorProfile,
    required List<Prescription> prescriptions,
    List<Complaint> complaints = const [],
    String? diagnosis,
    DateTime? prescriptionDate,
    String? additionalAdvice,
    DateTime? nextFollowUpDate,
  }) async {
    final pdf = pw.Document();
    final date = prescriptionDate ?? DateTime.now();
    final effectiveDiagnosis = diagnosis ?? patient.primaryDisease;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        header:
            (pw.Context context) =>
                _buildLetterheadHeader(clinic, doctorProfile),
        footer:
            (pw.Context context) =>
                _buildFooter(context, doctorProfile, clinic),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 12),
            _buildPatientDetailsBar(patient, date),
            pw.SizedBox(height: 14),

            // Clinical Assessment / Complaints (if present)
            if (complaints.isNotEmpty ||
                (effectiveDiagnosis != null &&
                    effectiveDiagnosis.isNotEmpty)) ...[
              _buildClinicalAssessmentSection(complaints, effectiveDiagnosis),
              pw.SizedBox(height: 14),
            ],

            // ℞ (Rx) Prescriptions Table
            _buildRxSection(prescriptions),
            pw.SizedBox(height: 16),

            // Advice, Dietary Modalities & Follow-up
            _buildAdviceAndFollowUpSection(
              prescriptions,
              additionalAdvice,
              nextFollowUpDate,
            ),
            pw.SizedBox(height: 24),

            // Signature Block
            _buildSignatureBlock(doctorProfile),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Top clinic and doctor letterhead
  static pw.Widget _buildLetterheadHeader(Clinic clinic, DoctorProfile doctor) {
    final doctorName =
        doctor.displayName.startsWith('Dr')
            ? doctor.displayName
            : 'Dr. ${doctor.displayName}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left: Doctor Info
            pw.Expanded(
              flex: 5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    doctorName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  if (doctor.qualification.isNotEmpty)
                    pw.Text(
                      doctor.qualification,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  if (doctor.regNumber.isNotEmpty)
                    pw.Text(
                      'Reg. No: ${doctor.regNumber}',
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                    ),
                  if (doctor.phone.isNotEmpty)
                    pw.Text(
                      'Mobile: ${doctor.phone}',
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            // Right: Clinic Info
            pw.Expanded(
              flex: 5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    clinic.name,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                  if (clinic.address != null &&
                      clinic.address!.trim().isNotEmpty)
                    pw.Text(
                      clinic.address!.trim(),
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                      textAlign: pw.TextAlign.right,
                    ),
                  if (clinic.phone != null && clinic.phone!.trim().isNotEmpty)
                    pw.Text(
                      'Clinic Ph: ${clinic.phone!.trim()}',
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                      textAlign: pw.TextAlign.right,
                    ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 2,
          decoration: pw.BoxDecoration(color: _primaryColor),
        ),
      ],
    );
  }

  /// Patient Demographics Bar
  static pw.Widget _buildPatientDetailsBar(Patient patient, DateTime date) {
    final displayId =
        patient.serialNo.isNotEmpty
            ? patient.serialNo
            : patient.patientCode.isNotEmpty
            ? patient.patientCode
            : patient.id.length >= 6
            ? patient.id.substring(0, 6).toUpperCase()
            : patient.id;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _bgLight,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text(
                    'Patient: ',
                    style: pw.TextStyle(fontSize: 10, color: _textMuted),
                  ),
                  pw.Text(
                    patient.name,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Age / Sex: ${patient.age > 0 ? "${patient.age} Yrs" : "N/A"} / ${patient.gender.isNotEmpty ? patient.gender : "N/A"}  |  Ph: ${patient.phone.isNotEmpty ? patient.phone : "N/A"}',
                style: pw.TextStyle(fontSize: 9, color: _textMuted),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Date: ${_dateFormat.format(date)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Patient ID: #$displayId',
                style: pw.TextStyle(fontSize: 9, color: _textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Clinical Assessment / Complaints
  static pw.Widget _buildClinicalAssessmentSection(
    List<Complaint> complaints,
    String? diagnosis,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (diagnosis != null && diagnosis.trim().isNotEmpty) ...[
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Diagnosis / Clinical Assessment: ',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    diagnosis.trim(),
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ),
              ],
            ),
            if (complaints.isNotEmpty) pw.SizedBox(height: 6),
          ],
          if (complaints.isNotEmpty) ...[
            pw.Text(
              'Chief Complaints:',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: _textMuted,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Wrap(
              spacing: 12,
              runSpacing: 4,
              children:
                  complaints.map((c) {
                    final durationStr =
                        c.duration != null && c.duration!.isNotEmpty
                            ? ' (${c.duration})'
                            : '';
                    final severityStr =
                        c.severity > 0 ? ' [${c.severity}/10]' : '';
                    return pw.Text(
                      '- ${c.complaintName}$durationStr$severityStr',
                      style: pw.TextStyle(fontSize: 9, color: _textDark),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// ℞ (Rx) Prescriptions Table
  static pw.Widget _buildRxSection(List<Prescription> prescriptions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'Rx',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              '(Medicines / Prescribed Remedies)',
              style: pw.TextStyle(
                fontSize: 9,
                color: _textMuted,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        if (prescriptions.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _bgLight,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: _borderColor, width: 0.8),
            ),
            child: pw.Center(
              child: pw.Text(
                'No medicines prescribed for this visit.',
                style: pw.TextStyle(fontSize: 10, color: _textMuted),
              ),
            ),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: _borderColor, width: 0.8),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.6), // #
              1: pw.FlexColumnWidth(3.0), // Medicine Name
              2: pw.FlexColumnWidth(1.4), // Potency / Form
              3: pw.FlexColumnWidth(2.0), // Dosage & Frequency
              4: pw.FlexColumnWidth(1.2), // Duration
              5: pw.FlexColumnWidth(2.6), // Instructions
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: _primaryColor),
                children: [
                  _buildTableHeaderCell('#'),
                  _buildTableHeaderCell('Remedy / Medicine'),
                  _buildTableHeaderCell('Potency / Form'),
                  _buildTableHeaderCell('Dosage & Freq.'),
                  _buildTableHeaderCell('Duration'),
                  _buildTableHeaderCell('Instructions'),
                ],
              ),
              // Data Rows
              for (var i = 0; i < prescriptions.length; i++)
                _buildPrescriptionRow(i + 1, prescriptions[i], i.isEven),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildTableHeaderCell(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.TableRow _buildPrescriptionRow(
    int index,
    Prescription rx,
    bool isEven,
  ) {
    final dosageFreq = [
      if (rx.doseCount != null && rx.doseCount!.isNotEmpty) rx.doseCount,
      if (rx.frequency != null && rx.frequency!.isNotEmpty) rx.frequency,
    ].join(' - ');

    final potencyForm = [
      if (rx.potency.isNotEmpty) rx.potency,
      if (rx.vehicle != null && rx.vehicle!.isNotEmpty) rx.vehicle,
    ].join(' in ');

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: isEven ? _bgLight : PdfColors.white),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            '$index',
            style: pw.TextStyle(fontSize: 9, color: _textMuted),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            rx.remedyName,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _textDark,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            potencyForm.isNotEmpty ? potencyForm : '-',
            style: pw.TextStyle(fontSize: 9, color: _textDark),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            dosageFreq.isNotEmpty ? dosageFreq : '-',
            style: pw.TextStyle(fontSize: 9, color: _textDark),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            rx.durationDays != null && rx.durationDays!.isNotEmpty
                ? rx.durationDays!
                : '-',
            style: pw.TextStyle(fontSize: 9, color: _textDark),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            rx.instructions != null && rx.instructions!.isNotEmpty
                ? rx.instructions!
                : '-',
            style: pw.TextStyle(fontSize: 8.5, color: _textMuted),
          ),
        ),
      ],
    );
  }

  /// General Advice, Diet, and Follow-up
  static pw.Widget _buildAdviceAndFollowUpSection(
    List<Prescription> prescriptions,
    String? additionalAdvice,
    DateTime? nextFollowUpDate,
  ) {
    final rxDietAdvice = prescriptions
        .map((p) => p.dietaryAdvice)
        .where((a) => a != null && a.trim().isNotEmpty)
        .join('; ');

    final adviceList = [
      if (additionalAdvice != null && additionalAdvice.trim().isNotEmpty)
        additionalAdvice.trim(),
      if (rxDietAdvice.isNotEmpty) 'Diet & Regimen: $rxDietAdvice',
    ];

    final generalAdvice =
        adviceList.isNotEmpty
            ? adviceList.join('\n')
            : 'Take medicines regularly as directed. Avoid raw onion, garlic, camphor, and strong coffee 30 minutes before and after doses.';

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _bgLight,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _borderColor, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 7,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Advice / Instructions:',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  generalAdvice,
                  style: pw.TextStyle(fontSize: 8.5, color: _textDark),
                ),
              ],
            ),
          ),
          if (nextFollowUpDate != null) ...[
            pw.SizedBox(width: 12),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(
                color: _accentLight,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: _primaryColor, width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'Next Follow-Up',
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _dateFormat.format(nextFollowUpDate),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Signature Block
  static pw.Widget _buildSignatureBlock(DoctorProfile doctor) {
    final doctorName =
        doctor.displayName.startsWith('Dr')
            ? doctor.displayName
            : 'Dr. ${doctor.displayName}';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 160, height: 36),
            pw.Container(width: 180, height: 1, color: _textMuted),
            pw.SizedBox(height: 4),
            pw.Text(
              doctorName,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
            if (doctor.qualification.isNotEmpty)
              pw.Text(
                doctor.qualification,
                style: pw.TextStyle(fontSize: 8.5, color: _textMuted),
              ),
            if (doctor.regNumber.isNotEmpty)
              pw.Text(
                'Reg. No: ${doctor.regNumber}',
                style: pw.TextStyle(fontSize: 8, color: _textMuted),
              ),
          ],
        ),
      ],
    );
  }

  /// Document Footer
  static pw.Widget _buildFooter(
    pw.Context context,
    DoctorProfile doctor,
    Clinic clinic,
  ) {
    return pw.Column(
      children: [
        pw.Divider(color: _borderColor, thickness: 0.8),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated securely via ClinicPilot  |  Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 7.5, color: _textMuted),
            ),
            pw.Text(
              _dateTimeFormat.format(DateTime.now()),
              style: pw.TextStyle(fontSize: 7.5, color: _textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
