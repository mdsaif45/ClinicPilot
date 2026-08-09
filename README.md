<div align="center">

# ClinicPilot

**Know. Grow. Repeat.**

Offline-first practice intelligence for small clinics.
Built for a two-clinic homeopathy practice that needed to know *which* clinic
actually makes money — not just how much came in.

[![CI](https://github.com/mdsaif45/ClinicPilot/actions/workflows/ci.yml/badge.svg)](https://github.com/mdsaif45/ClinicPilot/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/mdsaif45/ClinicPilot?include_prereleases&sort=semver)](https://github.com/mdsaif45/ClinicPilot/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-02569B?logo=flutter)](https://flutter.dev)

</div>

---

## Why this exists

Most clinic software is a digital register: it records what happened. It rarely
answers *why the practice is growing or stagnating*.

This app was built for a real problem. A physician running two clinics on alternate
evenings watched his income **fall** after opening the second location:

```
1 clinic,  6 days/week   ->  Rs 15-16k / month
2 clinics, 3 days each   ->  Rs 8k + almost 0
```

Revenue alone could not explain it. The old clinic costs Rs 3,000/month in rent; the
new one costs Rs 8,000. The clinic earning *less* was the one actually making money.

ClinicPilot answers three questions, every day:

1. **Money in, money out, money left** — per clinic
2. **Which patient, and which case, was charged** for every payment
3. **How the two clinics compare** — on profit, not revenue

---

## Features

| | |
|---|---|
| **Dashboard** | Today's revenue, expenses, net profit, patient count, and progress toward the monthly goal |
| **Patients** | Registration, searchable directory, profile with lifetime value and full visit timeline |
| **Visits** | Every encounter recorded as an event — automatically classified new vs repeat |
| **Cash Memo** | Consultation / medicine / other charges, discount, partial payment, PDF receipt |
| **Expenses** | Categorised spend with subcategories and recurring-cost flags |
| **Growth** | Revenue vs expense trends, referral-source and disease breakdowns |
| **Clinic Comparison** | Side-by-side profit, new vs repeat patients, and patients per open clinic day |
| **Settings** | Revenue and new-patient goals, clinic management, CSV export |

Everything works **fully offline**. No account, no server, no network dependency.

---

## Architecture

```
Flutter
├── Riverpod     state management
├── GoRouter     StatefulShellRoute, 5-tab navigation
├── Drift ORM    type-safe queries + migrations
│     └── SQLite   on-device storage
├── fl_chart     analytics charts
└── pdf          cash memo receipts
```

### Data model

The core design decision is separating **identity** from **events**:

```
                    +-----------+
                    |  clinics  |
                    +-----------+
                     |    |    |
        +------------+    |    +------------+
        |                 |                 |
        v                 v                 v
   +----------+     +----------+     +------------+
   | patients |     |  visits  |     |  expenses  |
   +----------+     +----------+     +------------+
        |                 |
        | 1            N  |
        +-----------------+
                          | 1
                          v 0..1
                   +------------+
                   | cash_memos |
                   +------------+
```

- `patients` — **who** (one row per person)
- `visits` — **when / where / why** (one row per encounter)
- `cash_memos` — **money** for one encounter

Storing a patient as a single row makes "8 new vs 18 repeat" impossible to compute,
and misattributes anyone who visits both clinics. Modelling each visit as an event is
what makes per-clinic profit and retention answerable at all.

`visitType` (`new` / `repeat`) is computed at insert and **stored**, so historical
reports stay stable and monthly counts are a plain `COUNT`.

---

## Getting started

**Requirements:** Flutter 3.29.2, JDK 17–21 (Gradle 8.12 does not support JDK 25).

```bash
git clone https://github.com/mdsaif45/ClinicPilot.git
cd ClinicPilot
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Building a release APK:

```bash
flutter build apk --release
```

If Gradle fails with a bare JDK version number, point Flutter at a supported JDK.
This setting is machine-local and never committed:

```bash
flutter config --jdk-dir="/path/to/jdk-21"
```

---

## Development

```bash
flutter test        # unit, database and migration tests
flutter analyze     # static analysis
```

After changing any table under `lib/core/database/tables/`, regenerate the Drift code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Never edit `app_database.g.dart` by hand.

### Project layout

```
lib/
  core/
    database/    tables, migrations, connection (native | web)
    providers/   cross-feature providers (period filter)
    router/      GoRouter configuration
    services/    PDF generation
    theme/       Material 3 theme
    utils/       currency and date formatters
    widgets/     shared widgets
  features/
    <feature>/
      presentation/   screens and dialogs
      providers/      Riverpod providers
```

### Conventions

- IDs are `String` UUIDs, not auto-increment integers
- Money is stored as `RealColumn` (double)
- Deletes are **soft** (`isDeleted`); every aggregate filters them out
- Revenue is attributed via `cash_memos.clinicId`, patient counts via `visits.clinicId`
- Currency and dates always render through `core/utils/formatters.dart`

---

## Database migrations

Schema changes must preserve existing data — this app holds real patient records on
a device that is upgraded in place.

When adding a schema version:

1. Bump `schemaVersion` in `app_database.dart`
2. Add an `onUpgrade` branch guarding each `addColumn` with `_addColumnIfMissing`
3. Copy data for any renamed column **before** it is relied on downstream
4. Add a migration test that builds the **previous** schema with raw SQL, seeds it,
   upgrades, and asserts zero row loss plus idempotency
5. Verify by installing the previous release and upgrading over it on a real device

See `test/migration_test.dart` for the v1 → v2 example.

---

## Roadmap

| Version | Status | Scope |
|---|---|---|
| v0.1 | Released | Dashboard, patients, cash memo, expenses, growth charts |
| v0.2 | Merged | Visits event model, multi-clinic, clinic comparison, period filters, patient profile, edit/delete |
| v0.3 | Planned | In-app update checker, signed release keystore, backup & restore |
| v1.0 | Planned | 30 days of real clinic use, then refinement based on actual usage |

Deliberately **out of scope** for now: case taking, prescriptions, AI features, and
cloud sync. The app is a decision tool, not a medical record system.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security issues: see [SECURITY.md](SECURITY.md)
— please do not open a public issue for those.

## License

[MIT](LICENSE)
