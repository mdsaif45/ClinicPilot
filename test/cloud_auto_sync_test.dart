import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/services/cloud_auto_sync.dart';

void main() {
  final now = DateTime(2026, 9, 9, 12, 0);

  CloudAutoSyncDecision decide({
    bool enabled = true,
    bool unlocked = true,
    bool connectorReady = true,
    DateTime? lastRun,
    String frequency = 'Every day',
  }) => CloudAutoSyncSchedule.decide(
    enabled: enabled,
    unlocked: unlocked,
    connectorReady: connectorReady,
    lastRun: lastRun,
    frequency: frequency,
    now: now,
  );

  group('CloudAutoSyncSchedule.frequencyToDuration', () {
    test('maps every offered frequency', () {
      expect(
        CloudAutoSyncSchedule.frequencyToDuration('Every 6 hours'),
        equals(const Duration(hours: 6)),
      );
      expect(
        CloudAutoSyncSchedule.frequencyToDuration('Every day'),
        equals(const Duration(days: 1)),
      );
      expect(
        CloudAutoSyncSchedule.frequencyToDuration('Every 2 days'),
        equals(const Duration(days: 2)),
      );
      expect(
        CloudAutoSyncSchedule.frequencyToDuration('Once per week'),
        equals(const Duration(days: 7)),
      );
    });

    test('an unknown frequency falls back to daily, never to never', () {
      expect(
        CloudAutoSyncSchedule.frequencyToDuration('nonsense'),
        equals(const Duration(days: 1)),
      );
    });

    test('every offered frequency is mapped explicitly', () {
      for (final f in CloudAutoSyncSchedule.frequencies) {
        expect(
          CloudAutoSyncSchedule.frequencyToDuration(f),
          isNot(equals(Duration.zero)),
        );
      }
    });
  });

  group('CloudAutoSyncSchedule.decide — preconditions', () {
    test('disabled short-circuits before anything else', () {
      expect(
        decide(enabled: false, unlocked: false, connectorReady: false),
        equals(CloudAutoSyncDecision.disabled),
      );
    });

    test('a Free or expired practice is locked, not silently disabled', () {
      expect(decide(unlocked: false), equals(CloudAutoSyncDecision.locked));
    });

    test('no connected provider is reported distinctly', () {
      expect(
        decide(connectorReady: false),
        equals(CloudAutoSyncDecision.noConnector),
      );
    });

    test('the lock is checked before the connector', () {
      // A Free practice with no provider is a billing prompt, not a setup one.
      expect(
        decide(unlocked: false, connectorReady: false),
        equals(CloudAutoSyncDecision.locked),
      );
    });
  });

  group('CloudAutoSyncSchedule.decide — timing', () {
    test('never run before means run now, not wait a full interval', () {
      expect(decide(lastRun: null), equals(CloudAutoSyncDecision.run));
    });

    test('runs once the interval has elapsed', () {
      expect(
        decide(lastRun: now.subtract(const Duration(days: 1))),
        equals(CloudAutoSyncDecision.run),
      );
    });

    test('holds while the interval has not elapsed', () {
      expect(
        decide(lastRun: now.subtract(const Duration(hours: 23))),
        equals(CloudAutoSyncDecision.notDue),
      );
    });

    test('exactly on the interval counts as due', () {
      expect(
        decide(
          lastRun: now.subtract(const Duration(hours: 6)),
          frequency: 'Every 6 hours',
        ),
        equals(CloudAutoSyncDecision.run),
      );
    });

    test('a longer frequency holds where a shorter one would run', () {
      final lastRun = now.subtract(const Duration(days: 2));
      expect(
        decide(lastRun: lastRun, frequency: 'Every day'),
        equals(CloudAutoSyncDecision.run),
      );
      expect(
        decide(lastRun: lastRun, frequency: 'Once per week'),
        equals(CloudAutoSyncDecision.notDue),
      );
    });

    test('a last run in the future runs rather than parking the schedule', () {
      // A timezone change or manual clock correction would otherwise stall
      // backups until the stored future time passed.
      expect(
        decide(lastRun: now.add(const Duration(days: 3))),
        equals(CloudAutoSyncDecision.run),
      );
    });
  });

  group('CloudAutoSyncDecision.shouldRun', () {
    test('only run means run', () {
      expect(CloudAutoSyncDecision.run.shouldRun, isTrue);
      for (final d in CloudAutoSyncDecision.values.where(
        (d) => d != CloudAutoSyncDecision.run,
      )) {
        expect(d.shouldRun, isFalse, reason: '$d must not trigger an upload');
      }
    });
  });
}
