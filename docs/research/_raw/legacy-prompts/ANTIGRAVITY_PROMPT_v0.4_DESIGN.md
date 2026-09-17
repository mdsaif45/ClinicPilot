# ClinicPilot — Implementation Brief for v0.4 (Identity + Design System + Redesign)

> **Read this whole document before writing any code.**
> Self-contained spec. You do not need the previous conversation.
> **Implementation only — no git commits, branches, PRs, tags or releases.**
> The reviewer handles all git operations after verification.

---

## 0. Context

ClinicPilot is an offline-first Flutter app for **Dr. Zaid**, a homeopathic physician
running two clinics in Khidderpore, Kolkata. It answers three questions:

1. Money in, money out, money left — per clinic
2. Which patient and which case was charged
3. How the two clinics compare, on **profit** not revenue

All data is local (Drift → SQLite). No server, no account.

**How he actually uses it:** on a phone, standing, *between patients*, in a hurry.
This single fact should drive every design decision below. Every 300 ms of animation
is 300 ms he waits. Every extra tap is friction during a consultation.

### Current state

```
Flutter 3.29.2 · Riverpod · GoRouter (5-tab shell) · Drift/SQLite (schema v2)
fl_chart · pdf · intl · http/package_info_plus/open_filex (in-app updates)

lib/
  core/
    database/   app_database.dart (schemaVersion 2), tables/, connection/
    providers/  period_provider.dart
    router/     app_router.dart          <- AppBar + bottom NavigationBar shell
    services/   pdf_service.dart, update_service.dart
    theme/      app_theme.dart           <- emerald/teal Material 3
    utils/      formatters.dart, validators.dart
    widgets/    custom_badge | custom_dropdown_field | custom_text_field | stat_card
  features/
    dashboard/ patients/ visits/ cashmemo/ expenses/ growth/ clinics/ settings/
      presentation/  +  providers/
test/   59 tests passing
```

**Conventions — follow these:**
- `features/<name>/presentation/` and `features/<name>/providers/`
- Riverpod: `StreamProvider` for lists, `StateNotifierProvider` for mutations
- IDs are `String` UUIDs; money is `RealColumn` (double)
- All currency/date rendering via `core/utils/formatters.dart`
- Every query filters `isDeleted = false`
- Never hand-edit `app_database.g.dart`

**Out of scope for v0.4:** no schema changes, no new features, no case taking,
no prescriptions, no AI, no cloud sync. This is identity + presentation only.

---

## 1. Design reference

The target quality bar is a well-made AniList client. What makes it work is
**information density without clutter** — study these patterns and reuse them:

```
HERO HEADER      backdrop image, dark overlay, identity content on top
METRIC STRIP     4 values in a row, thin dividers between, big number with a
                 small muted label beneath. No cards, no borders, no chrome.
SEGMENTED TABS   a row of icon-only pills; ONE content area swaps beneath them.
                 Deep data without deep navigation - the key pattern.
INFO ROWS        flat label/value rows. Label muted left, value strong right.
CHIP ROW         outlined pills, wrapped
RANKED LIST      icon + single line of text, repeated, zero decoration
CONTENT RAIL     section title + "→", horizontally scrolling cards beneath.
                 Keeps the vertical page short.
SETTINGS         icon + title + subtitle, where the SUBTITLE IS THE CURRENT
                 VALUE ("Theme / Follow system"). Grouped under muted headers.
```

### How this maps onto ClinicPilot

```
ANIME DETAIL                  ->  PATIENT PROFILE
──────────────────────────────────────────────────────────────
backdrop + poster             ->  avatar + name + patient code + clinic badge
Ep 8 · 85% · 140,979          ->  Visits · Lifetime ₹ · Avg bill · Pending ₹
genre chips                   ->  disease + referral-source chips
Info | Relations | Stats |    ->  Info | Visits | Payments | Insights
  Info: duration, dates       ->    phone, age, gender, area, occupation,
                                    first seen, last seen, next follow-up
  Stats: rankings             ->    outcome breakdown, visit frequency,
                                    clinic split
  Threads                     ->    visit timeline (chronological)
```

The patient profile currently surfaces a fraction of what the database already
holds. The segmented-tab pattern is how the rest becomes reachable.

---

## 2. PART A — App identity

### A1. Install name

`android/app/src/main/AndroidManifest.xml` currently has
`android:label="clinic_pilot"` — that is what appears under the launcher icon.

```xml
android:label="ClinicPilot"
```

Also fix `pubspec.yaml`, which still says `description: "A new Flutter project."`:

```yaml
description: "Offline-first practice intelligence for small clinics. Know. Grow. Repeat."
```

Do **not** change `name: clinic_pilot` in pubspec (it is the Dart package name and
changing it breaks every import).

### A2. App icon

Design a new mark: **an upward growth arrow whose line becomes an ECG/pulse trace.**
It should read as "clinic" and "growth" simultaneously, matching the tagline
*Know. Grow. Repeat.*

Requirements:

- [ ] Author as **SVG** at `assets/branding/app_icon.svg` (committed as the source)
- [ ] Must remain legible at **48dp** — test it small before committing to detail
- [ ] Use the existing emerald/teal brand colour (`#0F5132` family) from
      `core/theme/app_theme.dart`
- [ ] Generate Android launcher assets via `flutter_launcher_icons`:
      standard, **adaptive** (separate foreground/background), and **monochrome**
      for Android 13+ themed icons
- [ ] Adaptive foreground must respect the safe zone — content within the centre
      66% or it gets clipped by the launcher mask
- [ ] Also produce `web/favicon.png` and the `web/icons/` set

Add to `dev_dependencies` and configure:

```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/branding/app_icon.png"
  adaptive_icon_background: "#0F5132"
  adaptive_icon_foreground: "assets/branding/app_icon_foreground.png"
  adaptive_icon_monochrome: "assets/branding/app_icon_monochrome.png"
  web: { generate: true }
```

Then run `dart run flutter_launcher_icons`.

### A3. APK naming

Release APKs are currently `app-release.apk` — meaningless once several are
downloaded. Rename to `ClinicPilot-v<version>.apk` in
`.github/workflows/release.yml`, **after** the build step and **before** the upload
steps:

```yaml
      - name: Rename APK with version
        run: |
          VERSION="${{ github.ref_name }}"
          [ -z "$VERSION" ] && VERSION="dev"
          mv build/app/outputs/flutter-apk/app-release.apk \
             "build/app/outputs/flutter-apk/ClinicPilot-${VERSION}.apk"
```

Update both the `upload-artifact` path and the `action-gh-release` `files:` entry to
match (a glob such as `build/app/outputs/flutter-apk/ClinicPilot-*.apk` is fine).

> **Important:** `lib/core/services/update_service.dart` finds the download URL by
> taking the first release asset whose name ends in `.apk`. Confirm the rename does
> not break that lookup — it should not, but verify the matching logic.

---

## 3. PART B — Design system

Create `lib/core/design/`.

### B1. `tokens.dart`

Single source of truth. No magic numbers anywhere else in the app.

```dart
abstract class Spacing {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32;
}

abstract class Radii {
  static const double sm = 8, md = 12, lg = 16, pill = 999;
}

/// Motion is deliberately restrained. This app is used between patients -
/// animation that makes the user wait is a defect, not polish.
abstract class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 240); // ceiling, use rarely
  static const Curve curve = Curves.easeOutCubic;
}
```

### B2. Extend `core/theme/app_theme.dart`

- [ ] Full Material 3 `ColorScheme` from the emerald/teal seed, **light and dark**
- [ ] A real typography scale (display / headline / title / body / label)
- [ ] Component themes so screens stop styling individually:
      `cardTheme`, `chipTheme`, `listTileTheme`, `inputDecorationTheme`,
      `dividerTheme`, `appBarTheme`, `navigationBarTheme`
- [ ] Tabular figures for money columns where available, so digits align
- [ ] **Every colour must come from `ColorScheme`.** No hardcoded `Color(0xFF...)`
      outside the theme file. There are existing violations — fix them as you go.

---

## 4. PART C — Shared components

`lib/core/widgets/`. **This is the highest-value part of v0.4.** Screens are
currently built from bespoke one-off layouts; every new screen re-invents the same
patterns. Build these first, then rebuild screens on top of them.

Each must be stateless where possible, theme-driven, and documented with a one-line
comment explaining when to use it.

| Component | Purpose |
|---|---|
| `SectionHeader` | Title + optional trailing action ("→"). Every section uses this. |
| `MetricStrip` | The 4-up row: big value, small muted label, thin dividers. Scrolls horizontally if it overflows. |
| `InfoRow` | Flat label/value row. Muted label left, strong value right. |
| `ChipRow` | Wrapped outlined chips (diseases, referral sources, categories). |
| `EntityHeader` | Hero header: avatar/initial, title, subtitle, badges. Used by patient profile and clinic screens. |
| `SegmentedTabs` | Icon-pill row + `AnimatedSwitcher` body. Takes a list of (icon, label, builder). |
| `ContentRail` | `SectionHeader` + horizontal scroller. Keeps pages short. |
| `EmptyState` | Icon + message + optional action. Replaces every ad-hoc "no data" text. |
| `AppListTile` | Icon + title + subtitle row, for settings and list screens. |
| `SettingsGroup` | Muted section header wrapping `AppListTile`s. |
| `MoneyText` | Formats via `Formatters`, colours by sign (profit/loss), tabular figures. |
| `AppCard` | Consistent padding, radius and elevation. Replaces raw `Card`/`Container`. |

**Rule: if a visual pattern appears on two screens, it becomes a component.** Do not
copy layout code between screens.

Delete or fold in the existing `stat_card.dart` / `custom_badge.dart` if
`MetricStrip` / `AppCard` supersede them — do not leave two ways to do one thing.

---

## 5. PART D — Screen redesigns

Rebuild on the components above. **No behaviour or query changes** — same data,
better presentation.

### D1. Patient profile (highest value — do this first)

Currently shows a fraction of the stored data. Restructure as:

```
EntityHeader        avatar · name · P-2026-00042 · clinic badge · edit action
MetricStrip         Visits · Lifetime ₹ · Avg bill · Pending ₹
ChipRow             primary disease · referral source
SegmentedTabs
  Info      phone, whatsapp, age, gender, area, address, occupation,
            first seen, last seen, next follow-up, notes
  Visits    chronological timeline: date · clinic · new/repeat · disease ·
            outcome · amount
  Payments  memo list with totals; pending amounts highlighted
  Insights  outcome breakdown, visit frequency, clinic split
```

### D2. Dashboard

```
greeting + active clinic
MetricStrip     Revenue · Expenses · Profit · Patients   (today)
goal progress   monthly target
ContentRail     recent patients
ContentRail     recent memos
quick actions
```

### D3. Settings

Adopt the reference pattern exactly: grouped rows where **the subtitle shows the
current value**.

```
DISPLAY       Theme            Follow system
              Color palette    Default
GOALS         Monthly revenue  ₹50,000
              New patients     10
CLINICS       Manage clinics   2 clinics
DATA          Export CSV
              Backup
ABOUT         Version          0.4.0 (4)
              GitHub repository
              Check for updates
```

### D4. Lists (patients, cash memo, expenses)

Consistent row anatomy, `EmptyState` when empty, `SectionHeader` for grouping.
Money right-aligned with `MoneyText` so columns line up.

### D5. Growth / comparison

`SectionHeader` + `AppCard` around charts; `MetricStrip` for headline numbers.
Charts must use `ColorScheme` colours, not hardcoded values.

---

## 6. PART E — Motion and scrolling

**Restrained.** Motion must communicate *where something came from*, never decorate.

- [ ] `SliverAppBar` collapsing header on patient profile and dashboard
- [ ] `Hero` transition from a patient row to the profile
- [ ] `AnimatedSwitcher` (`Motion.base`) for segmented-tab body swaps
- [ ] Subtle list fade/slide-in — **cap the stagger**: apply to the first ~8 items
      only, then render the rest immediately. A 200-item list must not animate 200
      times.
- [ ] `InkWell` feedback on every tappable surface
- [ ] All scrollables get `BouncingScrollPhysics` (or platform-adaptive) consistently

**Do not** add: count-up numbers, animated chart draw-in, page-transition
choreography, parallax, shimmer on fast-loading local data. All of it costs the
doctor time.

Respect `MediaQuery.disableAnimations` for accessibility.

---

## 7. Testing

- [ ] All **59 existing tests must still pass** — this is presentation-only work
- [ ] Widget test per new component: renders, handles empty/null, respects theme
- [ ] Golden tests are **optional**; if flaky in CI, skip them rather than fight them
- [ ] Widget test: patient profile renders every tab without throwing
- [ ] Widget test: `EmptyState` shows when a list is empty

Target: **>= 75 tests**, all green.

---

## 8. Definition of done

```
[ ] flutter analyze --no-fatal-infos   -> 0 errors
[ ] flutter test                       -> all green, >= 75 tests
[ ] flutter build apk --release        -> builds
[ ] flutter build web --release        -> builds
[ ] Installed app shows "ClinicPilot", not "clinic_pilot"
[ ] New launcher icon renders: standard, adaptive, themed/monochrome
[ ] grep -rn "Color(0xFF" lib/ --include=*.dart | grep -v theme/  -> no results
[ ] No layout code duplicated across screens
```

### Manual verification before reporting done

1. Install and confirm the launcher name and icon (check the themed icon too)
2. Patient profile: every segmented tab renders with real and with empty data
3. Rotate the device / resize the window — no overflow warnings in the console
4. Narrow width (360 dp) — no clipping anywhere
5. **Light and dark theme** on every redesigned screen
6. Scroll a long list — smooth, and the stagger does not replay endlessly

---

## 9. Rules of engagement

- **No git operations.**
- **No schema changes.** Do not touch `lib/core/database/tables/`.
- **No behaviour changes.** Same queries, same numbers, same flows.
- Do not add dependencies beyond `flutter_launcher_icons` (and
  `flutter_svg` only if genuinely required) without justifying it in your report.
- If a redesign would require a schema or query change, **stop and report it**
  rather than changing the data layer.

### Report when finished

1. Files created / modified, grouped by part (A–E)
2. Test results
3. Both build results (APK and web)
4. Screenshots of the new icon (launcher, adaptive, themed) and of each redesigned
   screen in light and dark theme
5. Any component you chose not to build, and why
6. Anything you could not complete
