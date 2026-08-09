# ClinicPilot — Round 2 Fixes (post-review)

> Review of your v0.1.1 + v0.2 work: schema, features and tests are **good**.
> 28 tests pass, `flutter analyze` has 0 errors, `default_clinic` is fully gone.
> The items below are defects found during review and live device testing.
> Same rules as before: **implementation only, no git commits/branches/PRs/tags.**

**Critical context that changes priorities:** Dr. Zaid has **already installed v0.1.0
and entered real patient data**. The v1 -> v2 migration is no longer theoretical — it
will run on a phone containing live patient records. Fix #1 is the highest priority
item in this document.

---

## FIX 1 — CRITICAL: v1 -> v2 migration loses data / crashes  (issue #23)

The `onUpgrade` path has **never been executed** — all 28 tests start from `onCreate`
at v2, so nothing exercised it. It contains three defects.

### Defect 1a: duplicate column aborts the migration

The v1 `patients` table **already has** `referralSource`:

```dart
// v1, shipped in v0.1.0
TextColumn get clinicId => text().references(Clinics, #id)();
TextColumn get disease => text()();
TextColumn get referralSource => text()();   // <-- ALREADY EXISTS
```

But `app_database.dart` calls:

```dart
await m.addColumn(patients, patients.referralSource);   // duplicate column name
```

SQLite raises `duplicate column name: referral_source`, the migration throws, and the
app fails to open on the doctor's phone.

**Fix:** only add a column when it is genuinely absent. Add a helper:

```dart
Future<bool> _hasColumn(String table, String column) async {
  final rows = await customSelect('PRAGMA table_info($table)').get();
  return rows.any((r) => r.data['name'] == column);
}

Future<void> _addColumnIfMissing(
  Migrator m, TableInfo table, GeneratedColumn column) async {
  if (!await _hasColumn(table.actualTableName, column.name)) {
    await m.addColumn(table, column);
  }
}
```

Route **every** `addColumn` in `onUpgrade` through `_addColumnIfMissing`.

### Defect 1b: renamed columns are never copied

The v2 schema renames two v1 columns, but the migration only *adds* the new ones —
they land empty:

```
v1 patients.clinicId  ->  v2 patients.primaryClinicId   (added, EMPTY)
v1 patients.disease   ->  v2 patients.primaryDisease    (added, EMPTY)
```

Consequence: every existing patient loses clinic attribution and disease. Disease
analytics render blank, and the doctor's real data looks wrong on first launch.

**Fix:** copy the data **before** the visits backfill, in step 2.5:

```dart
// 2.5 Copy renamed v1 columns into their v2 equivalents.
// Must run BEFORE the visits backfill.
await customStatement('''
  UPDATE patients
  SET primary_clinic_id = clinic_id,
      primary_disease   = disease
  WHERE primary_clinic_id IS NULL OR primary_clinic_id = ''
''');
```

Note SQLite keeps the old physical columns (Drift never drops them), so `clinic_id`
and `disease` are still readable at this point. That is exactly why this copy works —
and why it must happen inside the same migration.

### Defect 1c: backfill depends on that same stale column

`app_database.dart:73` reads `COALESCE(p.clinic_id, 'clinic_old')`. It is
*accidentally* correct for the reason above. Once 1b runs, switch it to the v2 column
so the intent is explicit:

```sql
COALESCE(p.primary_clinic_id, 'clinic_old')
```

### Required test (the spec called this highest-value; it is still missing)

Build a **real v1 database**, then upgrade. Do not fake it by starting at v2.

```dart
test('v1 -> v2 migration preserves all data', () async {
  // 1. Create a v1-shaped database by hand
  final underlying = NativeDatabase.memory();
  // create v1 tables with the ORIGINAL v1 column set:
  //   patients(id, name, phone, age, gender, clinic_id, disease,
  //            referral_source, created_at)
  //   cash_memos(id, memo_number, patient_id, consultation_fee, medicine_fee,
  //              other_fee, discount, total, payment_method, created_at)
  //   clinics(id, name, address, created_at)
  //   expenses(id, clinic_id, category, amount, notes, date)
  // set user_version = 1
  // insert: 1 clinic, 3 patients, 4 cash memos, 2 expenses

  // 2. Open with AppDatabase -> triggers onUpgrade
  // 3. Assert:
  //    - patients.length == 3          (zero row loss)
  //    - cash_memos.length == 4
  //    - every patient has non-empty primaryClinicId AND primaryDisease
  //    - visits.length == 3            (one backfilled visit each)
  //    - every visit.visitType == 'new'
  //    - every memo has non-null clinicId AND visitId
  //    - every memo.paidAmount == memo.total
  //    - every patient.patientCode is non-empty
});
```

Also add: **running the migration twice must be a no-op**, not a crash.

### Manual verification (required before you report done)

1. Install the existing v0.1.0 APK on a device/emulator
2. Add 2–3 patients and a couple of cash memos
3. Install the new build **over the top** (do not uninstall)
4. Confirm: app opens, all patients present, disease + clinic populated, visits exist

---

## FIX 2 — Rent is not prorated, so profit is wrong on most periods

`lib/features/growth/providers/clinic_comparison_provider.dart:85`

```dart
final rent = clinic.monthlyRent;                          // full month, always
final netProfit = revenue - (variableExpenses + rent);
```

A **full month** of rent is subtracted no matter which period is selected:

```
Filter = Today   -> 400 - (0 + 8000)     = -7600   nonsense
Filter = Month   -> 18000 - (2000+8000)  =  8000   correct only here
```

Net profit is the doctor's headline metric, and it reads catastrophically wrong on 4
of the 5 filter settings.

**Fix — prorate rent by the fraction of the month the period covers:**

```dart
// Rent is a monthly fixed cost; charge only the portion covering this period.
double _proratedRent(double monthlyRent, DateTimeRange range) {
  if (monthlyRent <= 0) return 0;
  final daysInPeriod = range.end.difference(range.start).inDays + 1;
  final daysInMonth = DateUtils.getDaysInMonth(range.start.year, range.start.month);
  return monthlyRent * (daysInPeriod / daysInMonth);
}
```

In the UI, label the row **"Rent (prorated)"** whenever the period is not a full
calendar month, so the number is never mistaken for the full monthly figure.

Add tests:
- Today -> roughly `monthlyRent / daysInMonth`
- This Month -> exactly `monthlyRent`
- Custom 15-day range in a 30-day month -> `monthlyRent / 2`

---

## FIX 3 — Remove `org.gradle.java.home` (breaks CI)  (issue #16)

`android/gradle.properties` currently contains:

```properties
org.gradle.java.home=C:/Program Files/Java/jdk-21
```

That path does not exist on `ubuntu-latest`. Gradle aborts before compiling — the same
class of failure that broke the previous three CI runs. It works on your machine only
because that path happens to exist locally.

**Delete that line.** The file must end up exactly:

```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
```

CI sets its own JDK via `actions/setup-java`; locally Flutter resolves the JDK from
Android Studio. Neither needs this line. If you need a specific local JDK, use
`flutter config --jdk-dir=...` — it is machine-local and never committed.

---

## FIX 4 — Dashboard selection is not visible  (issue #24)

From device testing: tapping a stat card or the clinic switcher gives no visible
feedback; the user cannot tell what is selected or that a tap registered.

- [ ] Visible pressed/ripple state on stat cards and Quick Action buttons
      (wrap tappable cards in `InkWell`/`Material` so the ripple actually renders)
- [ ] Active clinic clearly indicated in the switcher: selected check + clinic colour
- [ ] Selected bottom-nav tab needs stronger contrast — the current pale green
      selected state is hard to distinguish from unselected
- [ ] Verify contrast in both light and dark themes

---

## FIX 5 — Patient edit is missing  (issue #25)

There is no way to edit a patient after registration; a typo in name/phone/age is
permanent.

- [ ] Edit action on the patient list row **and** on the patient profile screen
- [ ] Editable fields: name, phone, whatsapp, age, gender, area, address,
      occupation, notes
- [ ] Set `updatedAt` on save
- [ ] Same edit treatment for Cash Memo and Expense entries
- [ ] Delete stays **soft** (`isDeleted = true`), never a physical row delete

---

## Definition of done

```
[ ] flutter analyze                -> 0 errors
[ ] flutter test                   -> all green, >= 32 tests
[ ] migration test present and passing (real v1 schema -> v2)
[ ] migration is idempotent (running twice does not crash)
[ ] grep -n "java.home" android/gradle.properties   -> NO MATCH
[ ] rent prorates correctly for Today / This Month / Custom
[ ] flutter build apk --release    -> APK produced
[ ] MANUAL: v0.1.0 APK -> upgrade install -> data intact, app opens
```

## Report back

1. Files changed
2. Test results, including the new migration test output
3. Result of the manual v0.1.0 -> v0.2 upgrade test on a real device/emulator
4. Anything you could not complete, and why
