import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:clinic_pilot/core/services/backup_container_service.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/settings/presentation/backup_restore_screen.dart';
import 'package:clinic_pilot/features/settings/presentation/periodic_backups_screen.dart';
import 'package:clinic_pilot/features/settings/presentation/restore_preview_dialog.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync('cp_backup_test_');
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  });

  testWidgets('BackupRestoreScreen renders dual-tier backup and export options', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BackupRestoreScreen(),
        ),
      ),
    );

    expect(find.text('Backup and restore'), findsOneWidget);
    expect(find.text('Create Data Backup (.cpbak)'), findsOneWidget);
    expect(find.text('Restore from Backup'), findsOneWidget);
    expect(find.text('Periodic Backups'), findsOneWidget);
    expect(find.text('Export to Excel (.xlsx)'), findsOneWidget);
    expect(find.text('Export to CSV (.csv)'), findsOneWidget);
    expect(find.text('Import Patients from Excel'), findsOneWidget);
  });

  testWidgets('RestorePreviewDialog displays exact record counts and media count', (tester) async {
    final metadata = BackupMetadata(
      app: 'ClinicPilot',
      formatVersion: 2,
      appVersion: '0.8.7',
      schemaVersion: 15,
      createdAt: DateTime.now(),
      checksumSha256: 'test_hash_123',
      mediaCount: 18,
      hasMedia: true,
      counts: {
        'patients': 120,
        'patientCaseRecords': 120,
        'complaints': 240,
        'prescriptions': 310,
        'investigations': 45,
        'visits': 450,
        'cashMemos': 420,
        'expenses': 85,
        'clinics': 3,
      },
    );

    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: RestorePreviewDialog(
            metadata: metadata,
            onConfirm: () async {
              confirmed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Restore Practice Data'), findsOneWidget);
    expect(find.text('Backup File Validated'), findsOneWidget);
    expect(find.text('120'), findsNWidgets(2)); // Patients & Case Records
    expect(find.text('450'), findsOneWidget); // Visits
    expect(find.text('420'), findsOneWidget); // Cash Memos
    expect(find.text('Photos & Lab Reports (PDF)'), findsOneWidget);
    expect(find.text('18'), findsOneWidget); // Media count
    expect(find.text('Restore Data Now'), findsOneWidget);

    await tester.tap(find.text('Restore Data Now'));
    await tester.pump();

    expect(confirmed, isTrue);
  });

  testWidgets('PeriodicBackupsScreen toggles enabled and displays settings', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PeriodicBackupsScreen(),
        ),
      ),
    );

    expect(find.text('Periodic backups'), findsOneWidget);
    expect(find.text('Enable periodic backups'), findsOneWidget);

    // Toggle switch
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Last automated backup'), findsOneWidget);
    expect(find.text('Backups in storage'), findsOneWidget);
    expect(find.text('Run backup now'), findsOneWidget);
    expect(find.text('Backups output directory'), findsOneWidget);
    expect(find.text('Backup creation frequency'), findsOneWidget);
    expect(find.text('Delete old backups'), findsOneWidget);
    expect(find.text('Max number of backups'), findsOneWidget);
  });
}
