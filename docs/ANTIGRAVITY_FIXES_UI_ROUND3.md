# ClinicPilot — UI Fixes (Round 3)

> **Read this whole document before writing any code.**
> Same rules as before: **implementation only — no git commits, branches, PRs, tags
> or releases.** The reviewer handles all git operations after verification.

Three defects found during device and browser testing. All are UI-only — **no schema
changes, no migrations**.

Context: the app is used by a physician between patients, on a phone, often in a hurry.
Every one of these costs him time or makes him second-guess what he tapped.

---

## FIX 1 — Top app bar text is invisible

`lib/core/router/app_router.dart`

The `AppBar` places a clinic `DropdownButton` in `title` and a period `DropdownButton`
in `actions`. The dropdown **items** set `color: Colors.white` explicitly, but the
**selected value** rendered in the bar inherits the default text style. Against the
light `AppBar` background the label is white-on-light, so "This Month" and the clinic
name are effectively unreadable — see the screenshots: the text is there but washed out.

### Fix

Do not rely on inherited styles for anything drawn on the `AppBar`. Set the colour
explicitly on both the selected value and the items, resolved from the theme rather
than hardcoded:

```dart
final onPrimary = Theme.of(context).colorScheme.onPrimary;
```

Requirements:

- [ ] Selected clinic name and selected period label are clearly legible in the bar
- [ ] Use `selectedItemBuilder` on both `DropdownButton`s so the collapsed (in-bar)
      appearance is styled independently of the expanded menu items
- [ ] Dropdown menu items keep sufficient contrast against `dropdownColor`
- [ ] Verify in **both** light and dark theme
- [ ] The `AppBar` must have an explicit `backgroundColor` and `foregroundColor` so
      this cannot drift again

Note: the current code hardcodes `Colors.white` for icons in several places. Replace
those with `colorScheme.onPrimary` too, so the bar stays consistent if the theme
changes.

---

## FIX 2 — Age and Gender fields are misaligned

`lib/features/patients/presentation/add_patient_dialog.dart` (~line 89)

```dart
Row(children: [
  Expanded(child: CustomTextField(label: 'Age', prefixIcon: Icons.calendar_today, ...)),
  const SizedBox(width: 12),
  Expanded(child: DropdownButtonFormField<String>(...)),
])
```

Two problems visible in the screenshot:

1. **Mismatched heights and baselines.** `CustomTextField` and
   `DropdownButtonFormField` use different `InputDecoration` defaults, so the two
   controls in the same `Row` do not line up.
2. **Wrong icon for Age.** `Icons.calendar_today` reads as a date picker. Age is a
   number typed by hand — the calendar icon suggests tapping opens a date selector,
   which it does not.

### Fix

- [ ] Give both fields the **same** `InputDecoration` treatment so heights and
      baselines match. Either extend `CustomTextField` to support a dropdown variant,
      or apply an identical `InputDecoration` to both — do not leave them on
      different defaults.
- [ ] Replace `Icons.calendar_today` with a numeric/person icon (e.g. `Icons.numbers`
      or `Icons.cake_outlined`)
- [ ] Constrain Age input: `keyboardType: TextInputType.number` plus
      `FilteringTextInputFormatter.digitsOnly`, and validate the range 0–120 with a
      clear message ("Enter age 0-120") rather than the current "Valid age"
- [ ] Check the row at a narrow width (360dp) — labels must not clip or overflow

While you are in this dialog, audit the other rows for the same inconsistency and make
the whole form visually uniform.

---

## FIX 3 — Patient selection does not scale (most important)

`lib/features/cashmemo/presentation/new_cash_memo_dialog.dart` (~line 85 onward)

Patients are selected from a plain `DropdownButtonFormField`. That is a flat, scrolling
list. Today it holds one test patient. At a few hundred it becomes unusable, and it
fails badly in two specific ways:

```
1. no search   -> scrolling hundreds of entries to find one person
2. no identity -> two patients named "Fatima" are indistinguishable
```

The second is the dangerous one: **billing the wrong patient silently corrupts
lifetime-value and per-clinic revenue**, and nothing in the UI would reveal the
mistake.

### Fix — replace the dropdown with a searchable patient picker

Build a reusable widget, since the same problem will appear in the Add Visit flow:

```
lib/features/patients/presentation/patient_picker.dart
```

Behaviour:

- [ ] Tapping the field opens a full-screen (or large modal) picker, not a dropdown
- [ ] Search field is **auto-focused** on open, filtering as the user types
- [ ] Search matches **name, phone, and patient code** (`P-2026-00001`)
- [ ] Each result row shows enough to disambiguate two people with the same name:
      ```
      Fatima Begum                      P-2026-00042
      98xxxxxx21 · 34F · Babu Bazar · last visit 12 Aug
      ```
- [ ] **Recent patients first** when the search box is empty — order by most recent
      visit. In a clinic the next memo is nearly always for someone just seen, so this
      alone removes most searching.
- [ ] Results are **query-limited in SQL** (`LIMIT`, e.g. 50), not fetched-then-filtered
      in Dart. Do not load every patient into memory.
- [ ] Debounce the search input (~250 ms) so each keystroke does not run a query
- [ ] "No patients found" empty state, with an action to register a new patient inline
- [ ] Once selected, the field shows the patient's **name AND code** so the choice is
      verifiable before saving
- [ ] Keyboard-friendly: usable without a mouse (this also matters for browser testing)

### Also apply to Add Visit

`lib/features/visits/presentation/add_visit_dialog.dart` selects a patient the same
way. Use the same `PatientPicker` widget there. Do not duplicate the logic.

### Provider

Add a search provider alongside the existing patient providers, e.g.:

```dart
// Returns recent patients when the query is empty, otherwise SQL-filtered matches.
final patientSearchProvider =
    FutureProvider.family<List<Patient>, String>((ref, query) async { ... });
```

It must filter `isDeleted = false`, like every other query in the app.

---

## Testing

- [ ] Widget test: `PatientPicker` filters by name, by phone, and by patient code
- [ ] Widget test: empty query returns recent-first ordering
- [ ] Widget test: soft-deleted patients never appear in results
- [ ] Unit test: age validator rejects `-1`, `121`, `abc`; accepts `0`, `45`, `120`
- [ ] Existing 46 tests still pass

Seed a test database with ~200 patients, several sharing a first name, and confirm the
picker stays responsive and that duplicates are distinguishable.

---

## Definition of done

```
[ ] flutter analyze --no-fatal-infos   -> 0 errors
[ ] flutter test                       -> all green, >= 50 tests
[ ] flutter build apk --release        -> builds
[ ] flutter build web --release        -> builds
```

### Manual verification before reporting done

1. App bar: clinic name and period label legible, light **and** dark theme
2. Patient form: Age and Gender aligned; age rejects letters and out-of-range values
3. Cash Memo: open the picker, type 3 letters, select a patient — confirm the chosen
   name **and code** are displayed before saving
4. Repeat step 3 in Add Visit
5. Narrow width (360dp): no overflow warnings in the console

---

## Rules of engagement

- **No git operations.**
- **No schema changes.** This round is UI only; do not touch `lib/core/database/tables/`.
- Follow existing conventions: feature folders, Riverpod (`StreamProvider` for lists,
  `StateNotifierProvider` for mutations), formatting via `core/utils/formatters.dart`.
- Do not add new dependencies without justifying them in your report.
- If a fix conflicts with something in the codebase, **stop and report it** rather
  than guessing.

### Report when finished

1. Files created / modified
2. Test results
3. Both build results (APK and web)
4. Screenshots or a description of the app bar in light and dark theme
5. Anything you could not complete, and why
