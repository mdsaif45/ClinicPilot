# ClinicPilot — Implementation Brief for v0.3 (Release Signing + In-App Updates)

> **Read this whole document before writing any code.**
> This is a self-contained spec. You do not need the previous conversation.
> Do **not** create git commits, branches, PRs, tags, or releases. Implementation only.
> The reviewer handles all git/GitHub operations after your work is verified.

---

## 0. Context

ClinicPilot is an offline-first Flutter app used by **Dr. Zaid**, a homeopathic
physician running two clinics in Khidderpore, Kolkata. It tracks revenue, expenses,
profit per clinic, and new-vs-repeat patients. All data lives in a local SQLite
database via Drift. There is no server and no account.

**v0.2.0 is released and installed on his phone with real patient data.**

### The goal of v0.3

Right now, updating the app means: build an APK, transfer it to the phone, find it in
a file manager, install it manually. The doctor should instead:

```
open app -> Settings shows "Update available: v0.3.0"
         -> taps Update
         -> APK downloads with visible progress
         -> Android's installer prompt appears
         -> he confirms -> app updates
```

### One constraint you must not try to engineer around

**Android cannot silently install an APK or auto-restart the app.** The
`REQUEST_INSTALL_PACKAGES` permission lets you *launch* the system installer; the user
must then confirm on an OS-controlled dialog. This is an OS security guarantee. Do not
attempt root, shell, or accessibility-service workarounds. The target flow is
**one tap to download, then one system confirmation** — which is already a large
improvement over manual file transfer.

---

## 1. Current state of the repository

```
Flutter 3.29.2 + Dart 3.7.2
├── Riverpod     state management
├── GoRouter     StatefulShellRoute, 5-tab bottom nav
├── Drift ORM    -> SQLite  (schemaVersion 2)
├── fl_chart     analytics charts
├── pdf          cash memo receipts
└── intl         Rs / INR + date formatting
```

```
lib/
  core/
    database/    app_database.dart (schemaVersion 2), tables/, connection/
    providers/   period_provider.dart
    router/      app_router.dart
    services/    pdf_service.dart
    theme/       app_theme.dart          emerald/teal Material 3
    utils/       formatters.dart
    widgets/     stat_card | custom_text_field | custom_badge
  features/
    dashboard/ patients/ visits/ cashmemo/ expenses/ growth/ clinics/ settings/
      presentation/   +   providers/
  main.dart
test/
  unit_test.dart        29 tests
  migration_test.dart   v1 -> v2 migration, raw SQL v1 schema
  widget_test.dart
```

**Conventions you must follow:**
- Feature folders: `features/<name>/presentation/` and `features/<name>/providers/`
- Riverpod: `StreamProvider` for lists, `StateNotifierProvider` for mutations
- IDs are `String` UUIDs (`uuid` package)
- Money is `RealColumn` (double)
- Currency/date rendering goes through `core/utils/formatters.dart`
- Soft delete (`isDeleted`) everywhere; every aggregate filters it out
- Never hand-edit `app_database.g.dart` — regenerate with
  `dart run build_runner build --delete-conflicting-outputs`

**Relevant current state:**
- `pubspec.yaml` -> `version: 0.2.0+2`
- `android/app/build.gradle.kts` release buildType uses
  `signingConfig = signingConfigs.getByName("debug")`
- `.gitignore` has **no** keystore entries
- No HTTP client dependency yet
- `lib/features/settings/presentation/settings_screen.dart` exists, currently with
  "Manage Clinics" and "Export Backup Data (CSV)" `ListTile` cards

---

## 2. PART A — Release signing (do this FIRST, it blocks Part B)

### Why this comes first

Android will only install an update if the new APK is signed with the **same key** as
the installed one. v0.2.0 shipped **debug-signed**. Switching to a real keystore is a
one-time breaking change: the doctor must uninstall and reinstall, **which erases his
patient database**. Doing it now, before the in-app updater exists, means it only ever
happens once.

> **Warn the user explicitly in your final report:** the keystore file and its
> passwords must be backed up somewhere permanent. If the keystore is lost, no future
> update can ever be installed over the existing app — the only recovery is
> uninstall + reinstall, which destroys all patient data.

### A1. Configure Gradle signing from a properties file

Create `android/key.properties.example` (committed, a template — **never** the real
one):

```properties
storePassword=changeme
keyPassword=changeme
keyAlias=clinicpilot
storeFile=clinicpilot-release.jks
```

Update `android/app/build.gradle.kts`. Load the properties if present and fall back to
debug signing so that a fresh clone, and CI without secrets, still builds:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}
```

### A2. Protect the keystore in `.gitignore`

Add:

```gitignore
# Android release signing — NEVER commit these
android/key.properties
**/*.jks
**/*.keystore
```

`android/key.properties.example` must remain committed.

### A3. Document keystore generation

Add `docs/RELEASE_SIGNING.md` covering:

- The `keytool` command to generate the keystore:
  ```
  keytool -genkey -v -keystore clinicpilot-release.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias clinicpilot
  ```
- Where to place the file and how to fill `key.properties`
- **Back it up.** Losing it makes future updates impossible.
- The one-time uninstall/reinstall required when moving off debug signing, and that
  it erases the local database — so export CSV first
- How to base64 the keystore for GitHub Actions:
  `base64 -w 0 clinicpilot-release.jks > keystore.base64.txt`
- The four repository secrets needed:
  `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`

### A4. Wire signing into `.github/workflows/release.yml`

Insert a step **before** the `flutter build apk` step. It must be a no-op when secrets
are absent, so forks and untagged runs still build:

```yaml
      - name: Decode keystore and write key.properties
        if: ${{ secrets.KEYSTORE_BASE64 != '' }}
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/clinicpilot-release.jks
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=clinicpilot-release.jks
          EOF
```

Do not echo secret values to the log. Leave the rest of the workflow unchanged.

---

## 3. PART B — In-app update checker

### B1. Dependencies

Add to `pubspec.yaml`:

```yaml
  http: ^1.2.0              # GitHub Releases API + APK download
  package_info_plus: ^8.0.0 # read the running app's version
  open_filex: ^4.4.0        # hand the downloaded APK to the system installer
  permission_handler: ^11.3.0
```

`path_provider` is already a dependency; reuse it for the download directory.

### B2. Android manifest

`android/app/src/main/AndroidManifest.xml` needs, inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

`open_filex` supplies its own `FileProvider`; do not add a second one. If you must
declare one, use a unique authority such as `${applicationId}.fileprovider` and a
matching `provider_paths.xml`.

### B3. `lib/core/services/update_service.dart`

```dart
class AppRelease {
  final String version;      // normalised, no leading 'v'  e.g. "0.3.0"
  final String tagName;      // raw tag                     e.g. "v0.3.0"
  final String notes;        // release body markdown
  final String? apkUrl;      // browser_download_url of the .apk asset
  final int apkSizeBytes;
  final DateTime publishedAt;
}
```

Responsibilities:

- `GET https://api.github.com/repos/mdsaif45/ClinicPilot/releases/latest`
  with header `Accept: application/vnd.github+json`
- Parse `tag_name`, `body`, `published_at`, and the first asset whose name ends
  in `.apk` (`browser_download_url`, `size`)
- Read the running version with `package_info_plus`
- Compare **semantically**, not with string equality:
  ```dart
  // "0.10.0" must be treated as NEWER than "0.9.0" — string compare gets this wrong.
  int compareVersions(String a, String b);   // -1 | 0 | 1
  ```
  Strip a leading `v`, split on `.`, compare each part numerically, treat a missing
  part as 0, and ignore any `+build` suffix.
- `Future<AppRelease?> checkForUpdate()` — returns the release only when it is strictly
  newer than the installed version, otherwise `null`
- `Stream<double> downloadApk(AppRelease)` — emits progress 0.0–1.0, writes to the app
  cache directory, and returns the file path on completion
- Launch the installer via `OpenFilex.open(path)`

**Failure handling — the app must never crash or hang because of this feature:**

- Wrap every network call in try/catch; on failure return `null` and stay silent
- 10 second connect timeout, 60 second download timeout
- No internet, GitHub down, rate limited (HTTP 403), malformed JSON, or a release with
  no APK asset must all degrade to "no update available"
- The unauthenticated GitHub API allows 60 requests/hour per IP. That is ample for one
  check per app start, but never retry in a loop.

### B4. `lib/features/settings/providers/update_provider.dart`

```dart
final updateServiceProvider = Provider<UpdateService>(...);

// Checked once per app start. Null when up to date or the check failed.
final availableUpdateProvider = FutureProvider<AppRelease?>(...);

// Download progress state for the UI
final updateDownloadProvider = StateNotifierProvider<...>(...);
```

The check runs **at app start**, in the background, and must never block the first
frame or show a loading spinner over the UI.

### B5. UI

**Settings screen** — add an "App Updates" card following the existing `ListTile`
card style used by "Manage Clinics" and "Export Backup Data (CSV)":

```
Up to date:
  [icon] App Version
         v0.2.0  ·  You are on the latest version
         [Check for updates]

Update available:
  [badge] Update Available          v0.3.0
          29.1 MB  ·  released 2 days ago
          <collapsible release notes>
          [ Download & Install ]

Downloading:
  [====================        ]  62%
  18.1 MB of 29.1 MB            [Cancel]

Ready:
  Downloaded. Tap Install, then confirm on the Android prompt.
  [ Install ]
```

**Dashboard** — a small, dismissible badge on the Settings icon when an update is
available. It must never be a modal or an interstitial: the doctor opens this app
between patients, so nothing may block the dashboard.

**Copy that manages expectations** — before launching the installer, show:

> Android will ask you to confirm this installation. Your clinic data will not be
> affected by the update.

If "install from unknown sources" is not granted, explain plainly that Android
requires the permission and offer a button that opens the settings page.

### B6. Manual only

No auto-download and no auto-install. The check is automatic; every action that
consumes data or changes the installed app is user-initiated. Do not add a background
service or a periodic task.

---

## 4. Testing

Add to `test/` (do not modify the existing migration tests):

**Version comparison — the highest-value tests here:**
- [ ] `0.3.0 > 0.2.0`
- [ ] `0.10.0 > 0.9.0`   (naive string comparison fails this)
- [ ] `1.0.0 > 0.99.99`
- [ ] `0.2.0 == 0.2.0` -> no update offered
- [ ] `0.2.0 < 0.3.0` when the installed build is newer -> no update offered
- [ ] leading `v` stripped: `v0.3.0` vs `0.3.0`
- [ ] `+build` suffix ignored: `0.2.0+2` vs `0.2.0+5` -> equal
- [ ] malformed input (`"abc"`, `""`, `"1.x.0"`) does not throw

**Release parsing (mock the HTTP client — no live network calls in tests):**
- [ ] Valid GitHub JSON parses into `AppRelease`
- [ ] Release with no `.apk` asset -> treated as no update
- [ ] HTTP 403 rate limit -> returns null, no throw
- [ ] Malformed JSON -> returns null, no throw
- [ ] Network timeout -> returns null, no throw

Target: **>= 40 tests total**, all green.

---

## 5. Definition of done

```
[ ] flutter analyze --no-fatal-infos   -> 0 errors
[ ] flutter test                       -> all green, >= 40 tests
[ ] flutter build apk --release        -> builds WITHOUT key.properties (debug fallback)
[ ] flutter build apk --release        -> builds WITH a local test keystore, signed
[ ] git check-ignore android/key.properties   -> ignored
[ ] No .jks or key.properties in `git status`
[ ] Update check fails silently with aeroplane mode on
[ ] Settings shows the correct installed version
```

### Manual verification before you report done

1. Build a signed APK with a throwaway local keystore, install it
2. Turn on aeroplane mode, open the app — no crash, no hang, no error dialog
3. Turn networking back on, open Settings — it reports up to date against v0.2.0
   (the running build is newer, so nothing should be offered)
4. Confirm the version string displayed matches `pubspec.yaml`

You cannot fully test the download path until a newer release exists. Verify the
request URL and the parsing against the real endpoint:
`https://api.github.com/repos/mdsaif45/ClinicPilot/releases/latest`

---

## 6. Rules of engagement

- **No git operations.** No commits, branches, PRs, tags or releases.
- **Never commit a real keystore, `key.properties`, or any password.** If you generate
  a keystore for local testing, confirm it is git-ignored and say so in your report.
- Do not modify the database schema; v0.3 adds no tables or columns.
- Do not add auto-install, background services, or periodic update polling.
- Do not touch the existing migration tests.
- If a spec detail conflicts with the codebase, **stop and report it** rather than
  guessing.

### Report when finished

1. Files created / modified
2. Test results, with the version-comparison tests called out
3. Both build results: with and without `key.properties`
4. Confirmation that no keystore or password is tracked by git
5. Anything you could not complete, and why
