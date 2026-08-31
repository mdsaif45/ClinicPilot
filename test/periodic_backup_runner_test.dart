import 'dart:io';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/services/periodic_backup_runner.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late Box settingsBox;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync('periodic_backup_test_');
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('settings')) {
      settingsBox = await Hive.openBox('settings');
    } else {
      settingsBox = Hive.box('settings');
    }
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await settingsBox.clear();
  });

  tearDown(() async {
    await db.close();
  });

  tearDownAll(() async {
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('PeriodicBackupRunner Unit Tests', () {
    test('frequencyToDuration correctly maps all frequency options', () {
      expect(PeriodicBackupRunner.frequencyToDuration('Every 6 hours'), equals(const Duration(hours: 6)));
      expect(PeriodicBackupRunner.frequencyToDuration('Every day'), equals(const Duration(days: 1)));
      expect(PeriodicBackupRunner.frequencyToDuration('Every 2 days'), equals(const Duration(days: 2)));
      expect(PeriodicBackupRunner.frequencyToDuration('Once per week'), equals(const Duration(days: 7)));
      expect(PeriodicBackupRunner.frequencyToDuration('Twice per month'), equals(const Duration(days: 15)));
      expect(PeriodicBackupRunner.frequencyToDuration('Once per month'), equals(const Duration(days: 30)));
      expect(PeriodicBackupRunner.frequencyToDuration('Unknown'), equals(const Duration(days: 7)));
    });

    test('isBackupDue respects enabled flag and elapsed durations', () async {
      // 1. Disabled
      await settingsBox.put('periodic_backup_enabled', false);
      expect(PeriodicBackupRunner.isBackupDue(), isFalse);

      // 2. Enabled and never run
      await settingsBox.put('periodic_backup_enabled', true);
      await settingsBox.delete('periodic_backup_last_run');
      expect(PeriodicBackupRunner.isBackupDue(), isTrue);

      // 3. Enabled and run 1 hour ago with "Every day" frequency
      await settingsBox.put('periodic_backup_frequency', 'Every day');
      await settingsBox.put('periodic_backup_last_run', DateTime.now().subtract(const Duration(hours: 1)).toIso8601String());
      expect(PeriodicBackupRunner.isBackupDue(), isFalse);

      // 4. Enabled and run 25 hours ago with "Every day" frequency -> due!
      await settingsBox.put('periodic_backup_last_run', DateTime.now().subtract(const Duration(hours: 25)).toIso8601String());
      expect(PeriodicBackupRunner.isBackupDue(), isTrue);
    });

    test('executeBackup generates .cpbak file and rotates old backups', () async {
      final customBackupDir = Directory('${tempDir.path}/custom_backups');
      await customBackupDir.create(recursive: true);

      await settingsBox.put('periodic_backup_enabled', true);
      await settingsBox.put('periodic_backup_directory', customBackupDir.path);
      await settingsBox.put('periodic_backup_delete_old', true);
      await settingsBox.put('periodic_backup_max_count', 2);

      // 1. Seed sample data
      await db.into(db.clinics).insert(
            Clinic(
              id: 'c1',
              name: 'Clinic A',
              monthlyRent: 10000,
              defaultConsultationFee: 400,
              openDays: 'Mon,Tue',
              colorHex: '#1976D2',
              isActive: true,
              isDeleted: false,
              createdAt: DateTime.now(),
            ),
          );

      // 2. Execute 1st backup
      final file1 = await PeriodicBackupRunner.executeBackup(db);
      expect(file1, isNotNull);
      expect(file1!.existsSync(), isTrue);
      expect(file1.path.endsWith('.cpbak'), isTrue);

      // Verify Hive updated
      expect(settingsBox.get('periodic_backup_last_run'), isNotNull);

      // Wait a tiny bit and execute 2nd backup
      await Future.delayed(const Duration(milliseconds: 50));
      final file2 = await PeriodicBackupRunner.executeBackup(db);
      expect(file2, isNotNull);

      // Execute 3rd backup (since maxCount = 2, oldest should be pruned)
      await Future.delayed(const Duration(milliseconds: 50));
      final file3 = await PeriodicBackupRunner.executeBackup(db);
      expect(file3, isNotNull);

      final remainingBackups = await PeriodicBackupRunner.getExistingBackups();
      expect(remainingBackups.length, lessThanOrEqualTo(2));
    });
  });
}
