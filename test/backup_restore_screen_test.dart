import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/settings/presentation/backup_restore_screen.dart';
import 'package:clinic_pilot/features/settings/presentation/periodic_backups_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync('cp_backup_test_');
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  });

  testWidgets('BackupRestoreScreen renders main backup and restore options', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BackupRestoreScreen(),
        ),
      ),
    );

    expect(find.text('Backup and restore'), findsOneWidget);
    expect(find.text('Create data backup'), findsOneWidget);
    expect(find.text('Restore from backup'), findsOneWidget);
    expect(find.text('Periodic backups'), findsOneWidget);
  });

  testWidgets('PeriodicBackupsScreen toggles enabled and displays settings', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const PeriodicBackupsScreen(),
      ),
    );

    expect(find.text('Periodic backups'), findsOneWidget);
    expect(find.text('Enable periodic backups'), findsOneWidget);

    // Toggle switch
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Backups output directory'), findsOneWidget);
    expect(find.text('Backup creation frequency'), findsOneWidget);
    expect(find.text('Delete old backups'), findsOneWidget);
    expect(find.text('Max number of backups'), findsOneWidget);
  });
}
