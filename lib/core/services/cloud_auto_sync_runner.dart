import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../cloud/cloud_storage_registry.dart';
import '../database/app_database.dart';
import 'cloud_auto_sync.dart';

/// Executes the automated cloud backup schedule.
///
/// Reads the schedule state out of Hive, asks [CloudAutoSyncSchedule] whether
/// a run is due, and reuses the same upload path as the manual "Back Up Now"
/// button so both produce identical archives.
class CloudAutoSyncRunner {
  const CloudAutoSyncRunner._();

  static Box get _box => Hive.box('settings');

  static bool get isEnabled =>
      Hive.isBoxOpen('settings') &&
      _box.get(kCloudAutoSyncEnabledKey, defaultValue: false) == true;

  static String get frequency =>
      Hive.isBoxOpen('settings')
          ? _box.get(
                kCloudAutoSyncFrequencyKey,
                defaultValue: CloudAutoSyncSchedule.defaultFrequency,
              )
              as String
          : CloudAutoSyncSchedule.defaultFrequency;

  static DateTime? get lastRun {
    if (!Hive.isBoxOpen('settings')) return null;
    final raw = _box.get(kCloudAutoSyncLastRunKey) as String?;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static String? get lastResult =>
      Hive.isBoxOpen('settings')
          ? _box.get(kCloudAutoSyncLastResultKey) as String?
          : null;

  static Future<void> setEnabled(bool value) async =>
      _box.put(kCloudAutoSyncEnabledKey, value);

  static Future<void> setFrequency(String value) async =>
      _box.put(kCloudAutoSyncFrequencyKey, value);

  /// Runs an automated cloud backup if one is due.
  ///
  /// Returns the decision taken, so a caller can surface why nothing
  /// happened. Never throws: this is called during app start-up, and a failed
  /// backup must not stop the doctor reaching their patient list.
  static Future<CloudAutoSyncDecision> checkAndRun({
    required AppDatabase db,
    required CloudStorageRegistry registry,
    required bool unlocked,
    DateTime? now,
  }) async {
    if (kIsWeb || !Hive.isBoxOpen('settings')) {
      return CloudAutoSyncDecision.disabled;
    }

    try {
      final connector = registry.activeConnector;
      final connectorReady = connector != null && await connector.isConnected();

      final decision = CloudAutoSyncSchedule.decide(
        enabled: isEnabled,
        unlocked: unlocked,
        connectorReady: connectorReady,
        lastRun: lastRun,
        frequency: frequency,
        now: now ?? DateTime.now(),
      );

      if (!decision.shouldRun) return decision;

      final result = await registry.createAndUploadBackup(db);

      // Only a successful upload advances the schedule; a failed one is
      // retried on the next launch rather than being silently skipped for a
      // whole interval.
      if (result.success) {
        await _box.put(
          kCloudAutoSyncLastRunKey,
          (now ?? DateTime.now()).toIso8601String(),
        );
        await _box.put(
          kCloudAutoSyncLastResultKey,
          'Uploaded ${result.fileName}',
        );
      } else {
        await _box.put(
          kCloudAutoSyncLastResultKey,
          'Failed: ${result.errorMessage ?? 'unknown error'}',
        );
      }

      return decision;
    } catch (e) {
      debugPrint('Cloud auto sync failed: $e');
      try {
        await _box.put(kCloudAutoSyncLastResultKey, 'Failed: $e');
      } catch (_) {}
      return CloudAutoSyncDecision.disabled;
    }
  }
}
