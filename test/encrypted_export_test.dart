import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/services/list_export_service.dart';
import 'package:clinic_pilot/core/widgets/export_action.dart';
import 'package:clinic_pilot/core/widgets/export_format_sheet.dart';

class _SamplePatient {
  final String name;
  final String phone;
  final String address;
  final String notes;
  final double balance;

  const _SamplePatient({
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
    required this.balance,
  });
}

void main() {
  group('ListExportService Encryption & Redaction Unit Tests', () {
    test(
      'encryptToZip and decryptFromZip round-trips correctly with password',
      () {
        final originalText =
            'PatientID,Name,Diagnosis\nP001,John Doe,Hypertension';
        final originalBytes = utf8.encode(originalText);
        const password = 'ClinicSecurePassword2026';
        const fileName = 'patients_report.csv';

        final zipBytes = ListExportService.encryptToZip(
          fileBytes: originalBytes,
          fileName: fileName,
          password: password,
        );

        expect(zipBytes, isNotEmpty);

        // Decrypt with correct password
        final decryptedArchive = ListExportService.decryptFromZip(
          zipBytes,
          password: password,
        );

        expect(decryptedArchive.files.length, equals(1));
        expect(decryptedArchive.files.first.name, equals(fileName));
        final extractedBytes =
            decryptedArchive.files.first.content as List<int>;
        expect(utf8.decode(extractedBytes), equals(originalText));
      },
    );

    test(
      'decryptFromZip fails or produces invalid content with wrong password',
      () {
        final originalBytes = utf8.encode('Secret Patient Health Information');
        const password = 'CorrectPassword123';
        const wrongPassword = 'WrongPassword456';

        final zipBytes = ListExportService.encryptToZip(
          fileBytes: originalBytes,
          fileName: 'data.txt',
          password: password,
        );

        try {
          final wrongArchive = ListExportService.decryptFromZip(
            zipBytes,
            password: wrongPassword,
          );
          // If it doesn't throw, the extracted content should not match plaintext
          if (wrongArchive.files.isNotEmpty) {
            final extracted =
                wrongArchive.files.first.content as List<int>? ?? [];
            expect(extracted, isNot(equals(originalBytes)));
          }
        } catch (e) {
          expect(e, isNotNull);
        }
      },
    );

    test('maskPhone preserves prefix and masks suffix', () {
      expect(ListExportService.maskPhone('9876543210'), equals('98765*****'));
      expect(
        ListExportService.maskPhone('+919876543210'),
        equals('+9198*****'),
      );
      expect(ListExportService.maskPhone('1234'), equals('*****'));
      expect(ListExportService.maskPhone(''), equals(''));
      expect(ListExportService.maskPhone(null), equals(''));
    });

    test('redactText masks sensitive clinical remarks', () {
      expect(
        ListExportService.redactText('Patient has recurrent asthma'),
        equals('[REDACTED]'),
      );
      expect(ListExportService.redactText(''), equals(''));
      expect(ListExportService.redactText(null), equals(''));
    });

    test(
      'redactColumns masks phone and notes while preserving other columns',
      () {
        final columns = [
          ExportColumn<_SamplePatient>('Patient Name', (p) => p.name),
          ExportColumn<_SamplePatient>('Phone Number', (p) => p.phone),
          ExportColumn<_SamplePatient>('Residential Address', (p) => p.address),
          ExportColumn<_SamplePatient>('Clinical Notes', (p) => p.notes),
          ExportColumn<_SamplePatient>('Balance (₹)', (p) => p.balance),
        ];

        final redacted = ListExportService.redactColumns(columns);

        const patient = _SamplePatient(
          name: 'Rahul Verma',
          phone: '9876543210',
          address: 'Boring Road, Patna',
          notes: 'Suffering from chronic eczema',
          balance: 500.0,
        );

        expect(redacted[0].value(patient), equals('Rahul Verma'));
        expect(redacted[1].value(patient), equals('98765*****'));
        expect(redacted[2].value(patient), equals('[REDACTED]'));
        expect(redacted[3].value(patient), equals('[REDACTED]'));
        expect(redacted[4].value(patient), equals(500.0));
      },
    );
  });

  group('ExportOptionsSheet Widget Tests', () {
    testWidgets('renders format options, notice card, and action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ExportOptionsSheet(hasPatientData: true)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Export Records'), findsOneWidget);
      expect(find.text('Patient Privacy Notice'), findsOneWidget);
      expect(find.text('Choose Format'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('XLSX'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('Privacy Guard (De-Identify)'), findsOneWidget);
      expect(find.text('Password Protection'), findsOneWidget);
      expect(find.text('Export File'), findsOneWidget);
    });

    testWidgets('hides notice card when hasPatientData is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ExportOptionsSheet(hasPatientData: false)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Export Records'), findsOneWidget);
      expect(find.text('Patient Privacy Notice'), findsNothing);
    });

    testWidgets('enabling password switch reveals password input & validates', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      ExportOptions? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (ctx) => ElevatedButton(
                    onPressed: () async {
                      result = await pickExportOptions(
                        ctx,
                        hasPatientData: true,
                      );
                    },
                    child: const Text('Open Sheet'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap password switch
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2)); // Privacy switch & Password switch
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      expect(find.text('Set Archive Password *'), findsOneWidget);
      expect(find.text('Encrypt & Save'), findsOneWidget);

      // Attempt export without entering password
      await tester.tap(find.text('Encrypt & Save'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a password to encrypt your export'),
        findsOneWidget,
      );

      // Enter short password
      await tester.enterText(find.byType(TextField), '12');
      await tester.tap(find.text('Encrypt & Save'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 4 characters'),
        findsOneWidget,
      );

      // Enter valid password and toggle Privacy Guard
      await tester.enterText(find.byType(TextField), 'SafePass@2026');
      await tester.tap(switches.first); // Privacy Guard
      await tester.pumpAndSettle();

      await tester.tap(find.text('Encrypt & Save'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.isPasswordProtected, isTrue);
      expect(result!.password, equals('SafePass@2026'));
      expect(result!.redactSensitiveData, isTrue);
    });

    testWidgets('ExportAction button renders and opens options sheet on tap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final rows = [
        const _SamplePatient(
          name: 'Pooja Sharma',
          phone: '9876543210',
          address: 'Patna',
          notes: 'Migraine',
          balance: 200.0,
        ),
      ];

      final columns = [
        ExportColumn<_SamplePatient>('Name', (p) => p.name),
        ExportColumn<_SamplePatient>('Phone', (p) => p.phone),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                ExportAction<_SamplePatient>(
                  screenSlug: 'patients',
                  title: 'Patients',
                  rows: rows,
                  columns: columns,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final exportButton = find.byType(ExportAction<_SamplePatient>);
      expect(exportButton, findsOneWidget);

      await tester.tap(exportButton);
      await tester.pumpAndSettle();

      expect(find.text('Export Records'), findsOneWidget);
      expect(find.text('Patient Privacy Notice'), findsOneWidget);
    });
  });
}
