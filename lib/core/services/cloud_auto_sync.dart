/// Hive settings keys for the automated cloud sync schedule.
const kCloudAutoSyncEnabledKey = 'cloud_auto_sync_enabled';
const kCloudAutoSyncFrequencyKey = 'cloud_auto_sync_frequency';
const kCloudAutoSyncLastRunKey = 'cloud_auto_sync_last_run';
const kCloudAutoSyncLastResultKey = 'cloud_auto_sync_last_result';

/// Why an automated cloud sync did or did not run.
///
/// Distinguishing the reasons matters because they need different handling:
/// a locked subscription is a billing prompt, a missing connector is a setup
/// prompt, and "not due yet" is the normal quiet case.
enum CloudAutoSyncDecision {
  /// Every precondition is met and the interval has elapsed.
  run,

  /// The doctor has not switched automated sync on.
  disabled,

  /// Automated sync is a Pro feature and this practice is Free or expired.
  locked,

  /// No cloud provider is connected, so there is nowhere to upload.
  noConnector,

  /// Enabled and eligible, but the interval has not elapsed yet.
  notDue;

  bool get shouldRun => this == CloudAutoSyncDecision.run;
}

/// Decides when an automated cloud backup should run.
///
/// Kept as a pure function of its inputs — no Hive, Riverpod or network — so
/// the scheduling rules can be tested directly. The runner supplies the
/// current state; this decides.
class CloudAutoSyncSchedule {
  const CloudAutoSyncSchedule._();

  /// Selectable intervals, mirroring the local periodic backup wording so the
  /// two backup screens read the same way.
  static const List<String> frequencies = [
    'Every 6 hours',
    'Every day',
    'Every 2 days',
    'Once per week',
  ];

  static const String defaultFrequency = 'Every day';

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
      default:
        return const Duration(days: 1);
    }
  }

  /// Resolves whether a sync is due.
  ///
  /// [lastRun] null means the schedule has never run, which is treated as due
  /// immediately so switching the feature on produces a first backup rather
  /// than waiting out a full interval.
  static CloudAutoSyncDecision decide({
    required bool enabled,
    required bool unlocked,
    required bool connectorReady,
    required DateTime? lastRun,
    required String frequency,
    required DateTime now,
  }) {
    if (!enabled) return CloudAutoSyncDecision.disabled;
    if (!unlocked) return CloudAutoSyncDecision.locked;
    if (!connectorReady) return CloudAutoSyncDecision.noConnector;
    if (lastRun == null) return CloudAutoSyncDecision.run;

    // A clock moved backwards (timezone change, manual correction) would
    // otherwise park the schedule until the stored future time passed.
    if (lastRun.isAfter(now)) return CloudAutoSyncDecision.run;

    final elapsed = now.difference(lastRun);
    return elapsed >= frequencyToDuration(frequency)
        ? CloudAutoSyncDecision.run
        : CloudAutoSyncDecision.notDue;
  }
}
