import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'backup_container_service.dart';

/// Background scheduler and execution engine for automated periodic practice backups.
class PeriodicBackupRunner {
  /// Converts human-readable frequency string into [Duration].
  static Duration frequencyToDuration(String frequency) {
    switch (frequency) {
      case 'Every 6 hours':
        return const Duration(hours: 6);
      case 'Every day':
        return const Duration(days: 1);
      case 'Every 2 days':
        return const Duration(days: 2);
      case 'Once per week':
        return const Duration(days: 7);
      case 'Twice per month':
        return const Duration(days: 15);
      case 'Once per month':
        return const Duration(days: 30);
      default:
        return const Duration(days: 7);
    }
  }

  /// Resolves the directory where periodic backups should be stored.
  static Future<Directory?> resolveBackupDirectory({String? customPath}) async {
    if (kIsWeb) return null;

    try {
      if (customPath != null &&
          customPath.trim().isNotEmpty &&
          !customPath.startsWith('/Documents/')) {
        final dir = Directory(customPath);
        if (await dir.exists()) {
          return dir;
        }
      }

      // Safe default under application documents
      final appDir = await getApplicationDocumentsDirectory();
      final defaultDir = Directory(p.join(appDir.path, 'ClinicPilot_Backups'));
      if (!await defaultDir.exists()) {
        await defaultDir.create(recursive: true);
      }
      return defaultDir;
    } catch (e) {
      debugPrint('Error resolving periodic backup directory: $e');
      return null;
    }
  }

  /// Checks if a scheduled backup is currently due.
  static bool isBackupDue() {
    if (!Hive.isBoxOpen('settings')) return false;

    final box = Hive.box('settings');
    final enabled = box.get('periodic_backup_enabled', defaultValue: false) == true;
    if (!enabled) return false;

    final lastRunStr = box.get('periodic_backup_last_run') as String?;
    if (lastRunStr == null || lastRunStr.isEmpty) return true;

    final lastRun = DateTime.tryParse(lastRunStr);
    if (lastRun == null) return true;

    final frequency = box.get('periodic_backup_frequency', defaultValue: 'Once per week') as String;
    final duration = frequencyToDuration(frequency);

    return DateTime.now().difference(lastRun) >= duration;
  }

  /// Silently checks and executes periodic backup if due (e.g. on app launch or resume).
  static Future<void> checkAndRunPeriodicBackup(AppDatabase db) async {
    if (kIsWeb) return;

    try {
      if (isBackupDue()) {
        await executeBackup(db);
      }
    } catch (e) {
      debugPrint('Periodic backup check failed: $e');
    }
  }

  /// Executes a periodic backup immediately and manages backup rotation.
  static Future<File?> executeBackup(
    AppDatabase db, {
    bool isManualTrigger = false,
  }) async {
    if (kIsWeb) return null;

    try {
      final box = Hive.box('settings');
      final customPath = box.get('periodic_backup_directory') as String?;
      final targetDir = await resolveBackupDirectory(customPath: customPath);

      if (targetDir == null) return null;

      // 1. Build .cpbak bytes with all database tables + patient media
      final backupBytes = await BackupContainerService(db).buildBackupBytes(includeMedia: true);

      // 2. Generate timestamped file name
      final now = DateTime.now();
      final timestamp =
          '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'ClinicPilot_AutoBackup_$timestamp.cpbak';
      final filePath = p.join(targetDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(backupBytes);

      // 3. Rotate old backups if enabled
      final deleteOld = box.get('periodic_backup_delete_old', defaultValue: true) == true;
      final maxCount = (box.get('periodic_backup_max_count', defaultValue: 10) as num).toInt();

      if (deleteOld && maxCount > 0) {
        await _rotateOldBackups(targetDir, maxCount);
      }

      // 4. Save last run state
      await box.put('periodic_backup_last_run', now.toIso8601String());
      await box.put('periodic_backup_last_file', fileName);

      return file;
    } catch (e) {
      debugPrint('Failed to execute periodic backup: $e');
      return null;
    }
  }

  /// Deletes older backup files exceeding the max count.
  static Future<void> _rotateOldBackups(Directory directory, int maxCount) async {
    try {
      final backupFiles = <File>[];
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File &&
            p.basename(entity.path).startsWith('ClinicPilot_AutoBackup_') &&
            p.extension(entity.path).toLowerCase() == '.cpbak') {
          backupFiles.add(entity);
        }
      }

      // Sort newest first
      backupFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Delete files beyond maxCount
      if (backupFiles.length > maxCount) {
        for (var i = maxCount; i < backupFiles.length; i++) {
          try {
            await backupFiles[i].delete();
          } catch (e) {
            debugPrint('Failed to delete old backup file: ${backupFiles[i].path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error rotating backups: $e');
    }
  }

  /// Retrieves list of existing periodic backup files.
  static Future<List<File>> getExistingBackups() async {
    if (kIsWeb) return [];

    try {
      final box = Hive.box('settings');
      final customPath = box.get('periodic_backup_directory') as String?;
      final targetDir = await resolveBackupDirectory(customPath: customPath);
      if (targetDir == null || !await targetDir.exists()) return [];

      final backupFiles = <File>[];
      await for (final entity in targetDir.list(followLinks: false)) {
        if (entity is File &&
            (p.basename(entity.path).startsWith('ClinicPilot_') &&
                p.extension(entity.path).toLowerCase() == '.cpbak')) {
          backupFiles.add(entity);
        }
      }

      backupFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return backupFiles;
    } catch (e) {
      debugPrint('Error getting existing backups: $e');
      return [];
    }
  }
}
