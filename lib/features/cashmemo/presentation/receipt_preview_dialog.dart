import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/pdf_service.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  final CashMemo cashMemo;
  final Patient patient;
  final String clinicName;

  const ReceiptPreviewDialog({
    super.key,
    required this.cashMemo,
    required this.patient,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receipt ${cashMemo.memoNumber}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateCashMemoPdf(
          cashMemo: cashMemo,
          patient: patient,
          clinicName: clinicName,
        ),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
