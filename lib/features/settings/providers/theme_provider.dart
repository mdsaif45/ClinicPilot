import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/design/app_palette.dart';

/// Appearance preferences, persisted in the existing `settings` key/value table
/// so no schema change is needed.
class ThemePrefs {
  final AppThemeMode mode;
  final AppPalette palette;
  final bool blackVariant;

  const ThemePrefs({
    this.mode = AppThemeMode.system,
    this.palette = AppPalette.emerald,
    this.blackVariant = false,
  });

  ThemePrefs copyWith({
    AppThemeMode? mode,
    AppPalette? palette,
    bool? blackVariant,
  }) {
    return ThemePrefs(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
      blackVariant: blackVariant ?? this.blackVariant,
    );
  }
}

const _kMode = 'theme_mode';
const _kPalette = 'theme_palette';
const _kBlack = 'theme_black_variant';

class ThemeNotifier extends StateNotifier<ThemePrefs> {
  final AppDatabase _db;

  ThemeNotifier(this._db) : super(const ThemePrefs()) {
    _load();
  }

  Future<String?> _read(String key) async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _write(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
  }

  Future<void> _load() async {
    // A failure here must not stop the app from starting — fall back to
    // defaults and let the user re-pick.
    try {
      state = ThemePrefs(
        mode: AppThemeMode.fromName(await _read(_kMode)),
        palette: AppPalette.fromName(await _read(_kPalette)),
        blackVariant: (await _read(_kBlack)) == 'true',
      );
    } catch (_) {
      state = const ThemePrefs();
    }
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _write(_kMode, mode.name);
  }

  Future<void> setPalette(AppPalette palette) async {
    state = state.copyWith(palette: palette);
    await _write(_kPalette, palette.name);
  }

  Future<void> setBlackVariant(bool enabled) async {
    state = state.copyWith(blackVariant: enabled);
    await _write(_kBlack, enabled.toString());
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemePrefs>((ref) {
  return ThemeNotifier(ref.watch(databaseProvider));
});
