import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/entitlement/entitlement_model.dart';
import '../../../core/entitlement/entitlement_provider.dart';
import '../services/letterhead_branding.dart';

/// Reads the stored branding images off disk, regardless of entitlement.
///
/// Kept separate from [letterheadBrandingProvider] so the settings screen can
/// still show a doctor the logo they uploaded after a subscription lapses,
/// while printing reverts to the plain letterhead.
final storedLetterheadBrandingProvider = FutureProvider<LetterheadBranding>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  return LetterheadBrandingStore(db).load();
});

/// Branding as it should actually be printed, after the Pro gate.
final letterheadBrandingProvider = FutureProvider<LetterheadBranding>((
  ref,
) async {
  final stored = await ref.watch(storedLetterheadBrandingProvider.future);
  final unlocked = ref.watch(
    featureUnlockedProvider(AppFeature.customLetterheadBranding),
  );
  return LetterheadBranding.effective(stored: stored, unlocked: unlocked);
});

/// Loads, replaces and clears the clinic logo and doctor signature.
///
/// Images are copied into the app's documents directory rather than
/// referenced where the picker found them, since a gallery or cache path is
/// not guaranteed to survive to the next print.
class LetterheadBrandingStore {
  final AppDatabase _db;
  static final ImagePicker _picker = ImagePicker();

  LetterheadBrandingStore(this._db);

  Future<String?> _readPath(String key) async {
    final row =
        await (_db.select(_db.settings)
          ..where((t) => t.key.equals(key))).getSingleOrNull();
    final value = row?.value.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  Future<Uint8List?> _readImage(String key) async {
    final path = await _readPath(key);
    if (path == null) return null;
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (e) {
      // A missing or unreadable image must never stop a prescription being
      // printed, so fall back to the plain letterhead.
      debugPrint('Could not read letterhead image at $path: $e');
      return null;
    }
  }

  Future<LetterheadBranding> load() async {
    return LetterheadBranding(
      logo: await _readImage(kLetterheadLogoPathKey),
      signature: await _readImage(kLetterheadSignaturePathKey),
    );
  }

  Future<void> _writePath(String key, String? path) async {
    await _db
        .into(_db.settings)
        .insert(
          SettingsCompanion.insert(
            key: key,
            value: path ?? '',
            updatedAt: drift.Value(DateTime.now()),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
  }

  /// Picks an image and stores it as the logo or signature.
  ///
  /// Returns true when a new image was saved, false when the doctor cancelled.
  Future<bool> pickAndSave({required bool isLogo}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      // Letterhead art prints small; capping the source keeps the PDF light
      // enough to send over WhatsApp from a rural clinic connection.
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return false;

    final dir = await getApplicationDocumentsDirectory();
    final brandingDir = Directory(p.join(dir.path, 'branding'));
    if (!await brandingDir.exists()) {
      await brandingDir.create(recursive: true);
    }

    final ext = p.extension(picked.path).toLowerCase();
    final name = isLogo ? 'clinic_logo' : 'doctor_signature';
    // Timestamped so replacing an image cannot be masked by a cached read of
    // the previous file at the same path.
    final target = p.join(
      brandingDir.path,
      '$name-${DateTime.now().millisecondsSinceEpoch}${ext.isEmpty ? '.png' : ext}',
    );

    await File(picked.path).copy(target);

    final key = isLogo ? kLetterheadLogoPathKey : kLetterheadSignaturePathKey;
    final previous = await _readPath(key);
    await _writePath(key, target);

    if (previous != null && previous != target) {
      try {
        final old = File(previous);
        if (await old.exists()) await old.delete();
      } catch (_) {
        // Leaving a stale file behind is harmless; failing the save is not.
      }
    }
    return true;
  }

  /// Removes the stored logo or signature.
  Future<void> clear({required bool isLogo}) async {
    final key = isLogo ? kLetterheadLogoPathKey : kLetterheadSignaturePathKey;
    final path = await _readPath(key);
    await _writePath(key, null);
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best effort — the setting is already cleared.
      }
    }
  }
}

final letterheadBrandingStoreProvider = Provider<LetterheadBrandingStore>((
  ref,
) {
  return LetterheadBrandingStore(ref.watch(databaseProvider));
});
