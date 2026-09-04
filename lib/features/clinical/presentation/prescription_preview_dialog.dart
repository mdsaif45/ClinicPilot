import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/prescription_pdf_service.dart';
import '../../settings/providers/doctor_profile_provider.dart';

/// Full-screen dialog displaying an interactive, print-ready preview of a patient's
/// medical prescription (Rx) with sharing, printing, and file export actions.
class PrescriptionPreviewDialog extends StatelessWidget {
  final Patient patient;
  final Clinic clinic;
  final DoctorProfile doctorProfile;
  final List<Prescription> prescriptions;
  final List<Complaint> complaints;
  final String? diagnosis;
  final String? additionalAdvice;
  final DateTime? nextFollowUpDate;

  const PrescriptionPreviewDialog({
    super.key,
    required this.patient,
    required this.clinic,
    required this.doctorProfile,
    required this.prescriptions,
    this.complaints = const [],
    this.diagnosis,
    this.additionalAdvice,
    this.nextFollowUpDate,
  });

  static Future<void> show(
    BuildContext context, {
    required Patient patient,
    required Clinic clinic,
    required DoctorProfile doctorProfile,
    required List<Prescription> prescriptions,
    List<Complaint> complaints = const [],
    String? diagnosis,
    String? additionalAdvice,
    DateTime? nextFollowUpDate,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => PrescriptionPreviewDialog(
              patient: patient,
              clinic: clinic,
              doctorProfile: doctorProfile,
              prescriptions: prescriptions,
              complaints: complaints,
              diagnosis: diagnosis,
              additionalAdvice: additionalAdvice,
              nextFollowUpDate: nextFollowUpDate,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sanitizedName = patient.name.trim().replaceAll(RegExp(r'\s+'), '_');
    final dateSuffix = DateFormat('yyyyMMdd').format(DateTime.now());
    final fileName = 'Rx_${sanitizedName}_$dateSuffix.pdf';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prescription Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${patient.name} • ${clinic.name}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close Preview',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: PdfPreview(
        build:
            (format) => PrescriptionPdfService.generatePrescriptionPdf(
              patient: patient,
              clinic: clinic,
              doctorProfile: doctorProfile,
              prescriptions: prescriptions,
              complaints: complaints,
              diagnosis: diagnosis,
              additionalAdvice: additionalAdvice,
              nextFollowUpDate: nextFollowUpDate,
            ),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: fileName,
      ),
    );
  }
}
