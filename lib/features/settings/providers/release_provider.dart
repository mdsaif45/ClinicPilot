import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/update_service.dart';
import 'update_provider.dart';

const _kCachedRelease = 'cached_latest_release';
const _kSkippedVersion = 'update_skipped_version';

/// The version the app is actually running.
final runningVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  } catch (_) {
    return 'unknown';
  }
});

/// Latest release notes, cached in the settings table after the first fetch.
///
/// The release page must open instantly and work offline - the doctor may be
/// in a clinic with no signal - so the network result is written to the
/// database and served from there on later opens while a refresh runs.
final latestReleaseProvider = FutureProvider<AppRelease?>((ref) async {
  final db = ref.watch(databaseProvider);
  final service = ref.watch(updateServiceProvider);

  Future<AppRelease?> readCache() async {
    final row = await (db.select(db.settings)
          ..where((t) => t.key.equals(_kCachedRelease)))
        .getSingleOrNull();
    if (row == null) return null;
    try {
      return AppRelease.fromGitHubJson(jsonDecode(row.value));
    } catch (_) {
      return null;
    }
  }

  final fresh = await service.fetchLatestRelease();
  if (fresh != null) {
    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _kCachedRelease,
            value: jsonEncode(fresh.rawJson),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
    return fresh;
  }

  // Offline or rate limited: show whatever was last seen rather than nothing.
  return readCache();
});

/// Update prompt state, persisted so "Later" survives a restart.
class UpdatePromptNotifier extends StateNotifier<AppRelease?> {
  final AppDatabase _db;
  final Ref _ref;

  UpdatePromptNotifier(this._db, this._ref) : super(null);

  /// Returns the release worth prompting about, or null.
  ///
  /// A version the user dismissed with "Later" never prompts again; they can
  /// still reach it from the App Version screen whenever they choose.
  Future<void> evaluate() async {
    final release = await _ref.read(availableUpdateProvider.future);
    if (release == null) return;

    final skipped = await (_db.select(_db.settings)
          ..where((t) => t.key.equals(_kSkippedVersion)))
        .getSingleOrNull();

    if (skipped?.value == release.version) return;
    state = release;
  }

  /// Never prompt for this version again.
  Future<void> skip(AppRelease release) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _kSkippedVersion,
            value: release.version,
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
    state = null;
  }

  void dismiss() => state = null;
}

final updatePromptProvider =
    StateNotifierProvider<UpdatePromptNotifier, AppRelease?>((ref) {
  return UpdatePromptNotifier(ref.watch(databaseProvider), ref);
});
