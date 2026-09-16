# ClinicPilot — Implementation Brief for v0.1.1 + v0.2

> **Read this whole document before writing any code.**
> This is a self-contained spec. You do not need the previous conversation.
> Do **not** create git commits, branches, PRs, tags, or releases. Implementation only.
> The reviewer handles all git/GitHub operations after your work is verified.

---

## 0. Who this app is for (read this — it explains every decision below)

The user is **Dr. Zaid**, a homeopathic physician in Babu Bazar, Khidderpore, Kolkata.
He runs **two clinics** on alternate evenings (6:30–9:30 PM, Mon–Sat).

His actual business problem, in his own numbers:

```
Before 2nd clinic:  1 clinic, 6 days/week  -> Rs 15-16k/month
After  2nd clinic:  each 3 days/week       -> old Rs 8k + new ~Rs 0
Last 3 months:      8 NEW patients / 18 REPEAT visits
```

The diagnosis: his bottleneck is **patient acquisition**, not retention. His old
clinic costs Rs 3,000/month rent; the new one costs Rs 8,000/month. Revenue alone
misleads him — he needs **profit per clinic**.

He asked for exactly three things (verbatim, translated from his Hindi audio note):

1. **Money in, money out, money left**
2. **Which patient / which case was charged** for each payment
3. **Comparison of growth between both clinics**

Everything in this spec exists to answer one of those three. When you face a design
choice, pick the option that best answers them.

**Target: Rs 50,000/month.** The app is a decision tool, not a medical record system.
There is **no case-taking, no prescriptions, no AI** in this scope.

---

## 1. Current state of the repository

Flutter app, offline-first, already working and merged to `main`:

```
Flutter 3.29.2 + Dart
├── Riverpod        state management
├── GoRouter        StatefulShellRoute, 5-tab bottom nav
├── Drift ORM       -> SQLite   (schemaVersion = 1)
├── fl_chart        charts
├── pdf + printing  cash memo receipts
└── intl            Rs / INR + date formatting
```

```
lib/
  core/
    database/
      app_database.dart          @DriftDatabase, schemaVersion 1
      app_database.g.dart        GENERATED — never edit by hand
      database_provider.dart     Riverpod singleton
      connection/                native.dart | web.dart | connection.dart
      tables/                    clinics | patients | cash_memos | expenses
    router/app_router.dart
    services/pdf_service.dart
    theme/app_theme.dart         emerald/teal Material 3
    utils/formatters.dart        Rs currency, dates
    widgets/                     stat_card | custom_text_field | custom_badge
  features/
    dashboard/ patients/ cashmemo/ expenses/ growth/
      presentation/   +   providers/
  main.dart
test/
  unit_test.dart      3 formatter tests only
  widget_test.dart
```

**Existing conventions you must follow:**
- Feature folders: `features/<name>/presentation/` and `features/<name>/providers/`
- Riverpod: `StreamProvider` for lists, `StateNotifierProvider` for mutations
- IDs are `String` UUIDs (`uuid` package), **not** auto-increment ints
- Money is `RealColumn` (double)
- Currency/date rendering always goes through `core/utils/formatters.dart`
- After any table change run: `dart run build_runner build --delete-conflicting-outputs`

---

## 2. PART A — v0.1.1: Unbreak the build (do this first)

The GitHub Actions release workflow has failed on all 3 runs. The `v0.1.0` release
exists but has **zero assets** — the doctor cannot install anything. Nothing else
matters until an APK exists.

### A1. Fix `android/gradle.properties`

Current committed content requests ~12 GB of heap on a runner that has ~7 GB, so the
Gradle daemon never starts:

```properties
# REPLACE the jvmargs line with this:
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
```

**Never commit** `org.gradle.java.home=...`. It is a Windows-only absolute path that
breaks Linux CI. If it is present in the working tree, remove that line.

### A2. Fix `android/settings.gradle.kts`

Flutter 3.29.2 with AGP 8.7.0 requires Kotlin >= 1.9.x. The committed value is `1.8.22`:

```kotlin
id("org.jetbrains.kotlin.android") version "1.9.24" apply false
```

### A3. Rewrite `.github/workflows/release.yml`

Problems: hardcoded `tag_name: v0.1.0` (every run overwrites the same release), and
the deprecated `flutter pub run build_runner`.

```yaml
name: Build & Release ClinicPilot APK

on:
  push:
    tags: ['v*']
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build-apk:
    name: Build Android APK & Release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Set up Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.2'
          channel: 'stable'
          cache: true

      - run: flutter pub get

      - name: Run code generation (Drift ORM)
        run: dart run build_runner build --delete-conflicting-outputs

      - run: flutter analyze --no-fatal-infos
      - run: flutter test

      - name: Build Android APK
        run: flutter build apk --release

      # Always available, even for workflow_dispatch runs with no tag
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: clinicpilot-apk
          path: build/app/outputs/flutter-apk/app-release.apk

      - name: Attach APK to GitHub Release
        if: startsWith(github.ref, 'refs/tags/')
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ github.ref_name }}
          name: ClinicPilot ${{ github.ref_name }}
          generate_release_notes: true
          files: build/app/outputs/flutter-apk/app-release.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### A4. Add `.github/workflows/ci.yml` (PR gate)

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.2'
          channel: 'stable'
          cache: true
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze --no-fatal-infos
      - run: flutter test
```

### A5. Verify locally before moving on

```bash
flutter clean && flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release
```

All five must pass. Report the APK path and size when done.

---

## 3. PART B — Database schema v2 (THE MOST IMPORTANT SECTION)

> Get this right and every chart, report and comparison becomes a simple query.
> Get it wrong and no amount of UI work can recover the missing data.
> **Read this entire section before touching a single table file.**

### B0. Why the current schema cannot work

Today a patient is **one row with one `createdAt`** and one permanently-attached
`clinicId`. But every question the doctor asks is about **encounters**, not people:

```
"8 new / 18 repeat"           -> needs 26 events; we store 26 people at best
"which clinic performs"       -> a patient who visits BOTH is credited to one
"avg patients per clinic day" -> no per-day event to count
"who is overdue for f/u"      -> no next-visit date anywhere
```

The fix is a classic **identity vs. event** split:

```
patients   = WHO             (stable identity, one row per human)
visits     = WHEN/WHERE/WHY  (one row per encounter)   <-- NEW, the hinge
cash_memos = MONEY for one encounter
expenses   = money out, per clinic
clinics    = WHERE
```

Do this migration **now**, while the database is effectively empty. Once the doctor
starts entering real data it becomes an expensive, risky operation.

### B1. Target entity-relationship model

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

   settings (key-value: app config + goals)
```

Cardinality, stated precisely:

- `clinic  1 --- N   visits`      every encounter happens at exactly one clinic
- `patient 1 --- N   visits`      a person returns many times, possibly to both clinics
- `visit   1 --- 0..1 cash_memo`  an encounter may be free (camp / follow-up) or billed
- `clinic  1 --- N   expenses`    every expense belongs to one clinic
- `patient N --- 1   clinic`      `primaryClinicId` = where they *first* came; analytics only, never used for attribution

### B2. `clinics` — extend the existing table

```dart
// lib/core/database/tables/clinics.dart
import 'package:drift/drift.dart';

class Clinics extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();

  // Monthly fixed rent. Enables true profit-per-clinic without forcing the
  // doctor to key in a rent expense row every month.
  RealColumn get monthlyRent => real().withDefault(const Constant(0.0))();

  // Default consultation fee; pre-fills the cash memo form.
  RealColumn get defaultConsultationFee => real().withDefault(const Constant(0.0))();

  // Which evenings this clinic opens: comma-separated ints, Mon=1..Sun=7.
  // e.g. "1,3,5". Needed for "average patients per CLINIC DAY" — dividing by
  // calendar days would understate an alternate-day clinic by ~50%.
  TextColumn get openDays => text().withDefault(const Constant('1,2,3,4,5,6'))();

  TextColumn get colorHex => text().withDefault(const Constant('#0F5132'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### B3. `patients` — identity only

Per-visit concerns (`disease`, `referralSource`) move to `visits`, but keep a
denormalised copy of the **first** values so the directory list renders without a join.

```dart
// lib/core/database/tables/patients.dart
import 'package:drift/drift.dart';
import 'clinics.dart';

class Patients extends Table {
  TextColumn get id => text()();

  // Human-readable sequential code shown in the UI: "P-2026-00042"
  TextColumn get patientCode => text()();

  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get whatsapp => text().nullable()();
  IntColumn  get age => integer()();
  TextColumn get gender => text()();               // Male | Female | Other
  TextColumn get area => text().nullable()();      // locality — hyperlocal marketing
  TextColumn get address => text().nullable()();
  TextColumn get occupation => text().nullable()();

  // Where this patient FIRST came. Analytics only.
  // NEVER use for revenue attribution — that always comes from visits.clinicId.
  TextColumn get primaryClinicId => text().references(Clinics, #id)();

  // Denormalised copies of the FIRST visit, for list display without a join.
  // Source of truth is always the visits table.
  TextColumn get primaryDisease => text().nullable()();
  TextColumn get referralSource => text().nullable()();

  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### B4. `visits` — THE NEW TABLE (most important)

```dart
// lib/core/database/tables/visits.dart
import 'package:drift/drift.dart';
import 'clinics.dart';
import 'patients.dart';

class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();

  // Revenue and patient-count attribution ALWAYS uses this column.
  TextColumn get clinicId => text().references(Clinics, #id)();

  // 'new' | 'repeat'
  //
  // COMPUTED AT INSERT TIME and STORED — do not derive it at query time.
  // Rule: 'new' if this patient has zero prior visits, else 'repeat'.
  // Storing it keeps historical reports stable even if an older visit is later
  // back-dated or deleted, and turns the monthly "new patients" figure into a
  // plain COUNT instead of a correlated subquery.
  TextColumn get visitType => text()();

  // 'clinic' | 'online' | 'camp'  — powers camp conversion tracking
  TextColumn get consultationType => text().withDefault(const Constant('clinic'))();

  TextColumn get disease => text()();                  // primary condition this visit
  TextColumn get chiefComplaint => text().nullable()();

  // Asked only on a NEW visit ("How did you hear about us?"). Null on repeats.
  TextColumn get referralSource => text().nullable()();

  // 'improved' | 'no_change' | 'worse' | 'recovered' | 'lost_followup' | null
  TextColumn get outcome => text().nullable()();

  DateTimeColumn get visitDate => dateTime()();
  DateTimeColumn get nextFollowUpDate => dateTime().nullable()(); // powers overdue list

  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### B5. `cash_memos` — add clinic + visit link

```dart
// lib/core/database/tables/cash_memos.dart
import 'package:drift/drift.dart';
import 'patients.dart';
import 'clinics.dart';
import 'visits.dart';

class CashMemos extends Table {
  TextColumn get id => text()();
  TextColumn get memoNumber => text()();               // "CM-2026-00001"

  TextColumn get patientId => text().references(Patients, #id)();

  // NEW — without this, revenue-per-clinic is impossible.
  TextColumn get clinicId => text().references(Clinics, #id)();

  // NEW — ties money to the specific encounter.
  TextColumn get visitId => text().nullable().references(Visits, #id)();

  RealColumn get consultationFee => real().withDefault(const Constant(0.0))();
  RealColumn get medicineFee => real().withDefault(const Constant(0.0))();
  RealColumn get otherFee => real().withDefault(const Constant(0.0))();
  RealColumn get discount => real().withDefault(const Constant(0.0))();

  RealColumn get total => real()();                    // (consult+med+other) - discount

  // Partial payment support. Set to `total` for a fully-paid memo;
  // pending = total - paidAmount. The doctor explicitly asked
  // "how much money is left".
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();

  TextColumn get paymentMethod => text()();            // Cash | UPI | Card | Bank Transfer
  TextColumn get notes => text().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### B6. `expenses` — add subcategory + recurring flag

```dart
// lib/core/database/tables/expenses.dart
import 'package:drift/drift.dart';
import 'clinics.dart';

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get clinicId => text().references(Clinics, #id)();

  // Rent | Electricity | Staff Salary | Medicine Purchase | Furniture
  // | Marketing | Camp | Internet | Travel | Miscellaneous
  TextColumn get category => text()();

  // Free text, e.g. a camp name — lets the doctor total one camp's cost
  TextColumn get subcategory => text().nullable()();

  RealColumn get amount => real()();
  TextColumn get paymentMethod => text().withDefault(const Constant('Cash'))();

  // True for rent/electricity — separates fixed cost from variable spend
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### B7. `settings` — key/value store

Replaces the hardcoded `monthlyGoal: 50000.0` in `dashboard_provider.dart:85`.

```dart
// lib/core/database/tables/settings.dart
import 'package:drift/drift.dart';

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();     // store as String, parse on read
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
```

Seed these keys on create:

| key | default | meaning |
|---|---|---|
| `monthly_revenue_goal` | `50000` | the doctor's headline Rs target |
| `monthly_new_patient_goal` | `10` | new patients per month target |
| `active_clinic_id` | first clinic id | remembered selection |
| `currency_symbol` | `Rs ` | |
| `db_schema_version` | `2` | |

### B8. Indices — required, not optional

Every analytics query filters by date and groups by clinic. Create these in
`onCreate` **and** in the `onUpgrade` step:

```sql
CREATE INDEX IF NOT EXISTS idx_visits_date          ON visits (visit_date);
CREATE INDEX IF NOT EXISTS idx_visits_clinic_date   ON visits (clinic_id, visit_date);
CREATE INDEX IF NOT EXISTS idx_visits_patient       ON visits (patient_id);
CREATE INDEX IF NOT EXISTS idx_visits_type_date     ON visits (visit_type, visit_date);
CREATE INDEX IF NOT EXISTS idx_visits_followup      ON visits (next_follow_up_date);
CREATE INDEX IF NOT EXISTS idx_memos_created        ON cash_memos (created_at);
CREATE INDEX IF NOT EXISTS idx_memos_clinic_date    ON cash_memos (clinic_id, created_at);
CREATE INDEX IF NOT EXISTS idx_memos_patient        ON cash_memos (patient_id);
CREATE INDEX IF NOT EXISTS idx_memos_visit          ON cash_memos (visit_id);
CREATE INDEX IF NOT EXISTS idx_expenses_date        ON expenses (date);
CREATE INDEX IF NOT EXISTS idx_expenses_clinic_date ON expenses (clinic_id, date);
CREATE INDEX IF NOT EXISTS idx_patients_phone       ON patients (phone);
```

### B9. Migration v1 -> v2 (must not lose a row)

```dart
// lib/core/database/app_database.dart
@DriftDatabase(tables: [Clinics, Patients, Visits, CashMemos, Expenses, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedClinics();
      await _seedSettings();
      await _createIndices();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // 1. new tables
        await m.createTable(visits);
        await m.createTable(settings);

        // 2. new columns on existing tables
        await m.addColumn(clinics, clinics.phone);
        await m.addColumn(clinics, clinics.monthlyRent);
        await m.addColumn(clinics, clinics.defaultConsultationFee);
        await m.addColumn(clinics, clinics.openDays);
        await m.addColumn(clinics, clinics.colorHex);
        await m.addColumn(clinics, clinics.isActive);
        await m.addColumn(clinics, clinics.isDeleted);
        // ... patients:   patientCode, whatsapp, area, address, occupation,
        //                 primaryDisease, notes, isDeleted, updatedAt
        // ... cashMemos:  clinicId, visitId, paidAmount, notes, isDeleted
        // ... expenses:   subcategory, paymentMethod, isRecurring, isDeleted

        // 3. BACKFILL — one visit per existing patient, marked 'new'.
        //    Uses the patient's own createdAt and clinicId so history is preserved.
        await customStatement('''
          INSERT INTO visits (id, patient_id, clinic_id, visit_type,
                              consultation_type, disease, referral_source,
                              visit_date, is_deleted, created_at)
          SELECT
            'mig-' || p.id, p.id, p.clinic_id, 'new', 'clinic',
            COALESCE(p.disease, 'Unknown'), p.referral_source,
            p.created_at, 0, p.created_at
          FROM patients p
        ''');

        // 4. Link existing memos to the backfilled visit + inherit clinic
        await customStatement('''
          UPDATE cash_memos
          SET visit_id  = 'mig-' || patient_id,
              clinic_id = (SELECT p.clinic_id FROM patients p
                           WHERE p.id = cash_memos.patient_id)
          WHERE visit_id IS NULL
        ''');

        // 5. Historical memos assumed fully paid
        await customStatement(
          'UPDATE cash_memos SET paid_amount = total WHERE paid_amount = 0');

        // 6. Backfill patient_code
        await customStatement('''
          UPDATE patients SET patient_code = 'P-MIG-' || substr(id, 1, 8)
          WHERE patient_code IS NULL OR patient_code = ''
        ''');

        await _seedSettings();
        await _createIndices();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

**Seed two real clinics**, replacing the single `default_clinic` placeholder. Use
stable ids `clinic_old` and `clinic_new`; the doctor renames them in Settings.

```
clinic_old : 2 years old,  monthlyRent 3000
clinic_new : Babu Bazar, Khidderpore (main road), monthlyRent 8000
```

### B10. Schema rules — do not violate these

1. **Revenue per clinic = `cash_memos.clinicId`.** Never `patients.primaryClinicId`.
2. **Patient counts per clinic = `visits.clinicId`.** Never the patients table.
3. **`visitType` is written once at insert.** Never recomputed on read.
4. **Every aggregate filters `isDeleted = false`.** No exceptions.
5. **Never hand-edit `app_database.g.dart`.** Always regenerate.
6. **No hardcoded `'default_clinic'` anywhere.** If you type that string, you are wrong.

---

## 4. PART C — Features

Build in this order. Each block is independently testable.

### C1. Clinic management + active-clinic selector  (v0.1.1, GitHub issue #17)

This is the doctor's **#1 requirement** and is currently non-functional:
`add_patient_dialog.dart:67` and `add_expense_dialog.dart:57` both hardcode
`clinicId: 'default_clinic'`, so every row lands in the same clinic and
"Clinic A vs Clinic B" always compares a clinic against nothing.

- New feature folder `features/clinics/`
- Clinics list screen: add / edit / archive
  Fields: name, address, phone, monthlyRent, defaultConsultationFee, openDays, colour
- `activeClinicProvider` — persisted to `settings.active_clinic_id`, survives restart
- Clinic switcher in the app bar (visible on every screen), showing the clinic colour
- Clinic selector **required** on Patient, Visit, Cash Memo and Expense forms,
  defaulting to the active clinic
- Delete the `'default_clinic'` literal from the entire codebase

### C2. Visit-aware patient + memo flow  (v0.2, issue #18)

- Registering a patient **also creates their first visit** (`visitType = 'new'`)
- "Add Visit" action on an existing patient -> `visitType = 'repeat'`
- `visitType` computed at insert: `'new'` when the patient has zero prior visits
- Cash Memo form: pick patient -> pick/create visit -> fees -> `clinicId` from the visit
- Referral source asked **only** on a new visit
- Memo numbering stays `CM-YYYY-NNNNN`; patient codes `P-YYYY-NNNNN`

> Note: the existing memo-number generator uses `SELECT COUNT(*)`, which reuses a
> number after a deletion. Switch to `MAX(rowid)`-based or per-year sequence in
> `settings` so numbers are never duplicated.

### C3. Global period filter  (v0.2, issue #20)

Bug: `growth_provider.dart:60` sums **all-time** revenue with no date filter while the
dashboard shows month-scoped figures — the two screens contradict each other.

- Shared `periodProvider`: Today | This Week | This Month | Last Month | Custom range
- Growth, Clinic Comparison, Disease and Referral analytics all honour it
- Every provider also computes the **previous equivalent period** for growth %
- Selected period always visible in the app bar

### C4. Clinic Comparison screen  (v0.2, issue #19)

The doctor's literal ask. Side-by-side for the selected period:

| Metric | Clinic A | Clinic B |
|---|--:|--:|
| Revenue | | |
| Expenses | | |
| **Net Profit** | | |
| New patients | | |
| Repeat patients | | |
| Total visits | | |
| Avg revenue / patient | | |
| Avg patients / clinic day | | |
| Growth % vs prev period | | |

Rules:
- Profit is the headline. Revenue alone misleads: the old clinic earns less but costs
  Rs 3k/month, the new one costs Rs 8k/month.
- "Avg patients per clinic day" divides by **open days** (from `clinics.openDays`),
  not calendar days.
- Highlight the better performer per row.
- Must not crash with one clinic or zero data.

### C5. Patient profile + visit timeline  (v0.2, issue #21)

- Tap a patient in the directory -> profile screen
- Header: total visits, lifetime revenue, average bill, last visit, next follow-up
- Chronological visit timeline: date, clinic, new/repeat, disease, amount, outcome
- Each visit links to its memo with PDF re-print
- Outstanding amount = `SUM(total - paidAmount)`

### C6. Edit & delete  (v0.2, issue #22)

- Edit + delete for Patient, Visit, Cash Memo, Expense, Clinic
- Confirmation dialog before delete
- **Soft delete** (`isDeleted = true`) — never physically remove rows
- Every aggregate excludes soft-deleted rows

### C7. Settings screen  (v0.2)

- Monthly revenue goal (replaces the hardcoded `50000.0`)
- Monthly new-patient goal
- Manage clinics
- Manage expense categories
- Export data to CSV (the doctor raised data-safety explicitly)

---

## 5. Testing — required, not optional

The current suite is 3 formatter tests. That is why the broken schema shipped
unnoticed. Add real tests using an in-memory database:

```dart
final db = AppDatabase(NativeDatabase.memory());
```

**Migration tests (highest value)**
- [ ] Seed a v1 database with patients + memos, upgrade to v2, assert **zero row loss**
- [ ] Every patient gets exactly one backfilled visit
- [ ] Every pre-existing memo ends up with a non-null `clinicId` and `visitId`

**Business-logic tests**
- [ ] First visit -> `'new'`; second visit for the same patient -> `'repeat'`
- [ ] Revenue for clinic A excludes clinic B's memos
- [ ] Profit = revenue - expenses, per clinic, within the period
- [ ] A patient visiting both clinics is counted in each clinic's visit totals
- [ ] Soft-deleted memo is excluded from every aggregate
- [ ] Period filter boundaries: month start/end inclusive, no off-by-one
- [ ] `total = (consult + medicine + other) - discount`
- [ ] Memo numbers never duplicate after a delete

Target: **>= 25 meaningful tests**, all green via `flutter test`.

---

## 6. Definition of done

```
[ ] flutter analyze                 -> 0 errors
[ ] flutter test                    -> all green, >= 25 tests
[ ] dart run build_runner build --delete-conflicting-outputs  -> clean
[ ] flutter build apk --release     -> APK produced
[ ] grep -r "default_clinic" lib/   -> ONLY in the seed function
[ ] Two clinics visible, switchable, and data attributes correctly to each
[ ] Clinic Comparison shows different numbers per clinic with seeded test data
[ ] Existing v1 database upgrades to v2 without data loss
```

### Manual smoke test before you report done

1. Create clinic A and clinic B
2. Register patient P1 at A (should record a **new** visit)
3. Add a repeat visit for P1 at B (should record a **repeat** visit)
4. Create a cash memo at each clinic with different amounts
5. Add an expense at each clinic
6. Open Clinic Comparison -> the two columns must show **different, correct** numbers
7. Switch the period filter -> numbers change coherently
8. Open P1's profile -> 2 visits, correct lifetime revenue

---

## 7. Rules of engagement

- **No git operations.** No commits, branches, PRs, tags or releases. Implementation only.
- Follow the existing folder and Riverpod conventions described in section 1.
- Do not add new dependencies without saying why in your final report.
- Do not build case-taking, prescriptions, AI, auth or cloud sync — all out of scope.
- If a spec detail conflicts with something in the codebase, **stop and report it**
  rather than guessing.

### Report when finished

1. Files created / modified
2. Test results (`flutter test` output summary)
3. APK build result + size
4. Anything you could not complete, and why
5. Any deviation from this spec, and the reason
