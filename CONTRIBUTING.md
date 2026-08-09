# Contributing to ClinicPilot

Thanks for your interest. This project is built for real clinical use, so a few rules
here are stricter than in a typical side project — particularly around **patient data
and database migrations**.

## Before you start

- For anything non-trivial, **open an issue first**. It avoids wasted work when a
  feature is deliberately out of scope.
- Check the [roadmap](README.md#roadmap). Case taking, prescriptions, AI features and
  cloud sync are intentionally excluded for now.
- Bug reports are most useful with: what you did, what you expected, what happened,
  and your Flutter version.

**Never include real patient data** in an issue, PR, screenshot or test fixture.
Use fabricated records.

## Development setup

Requires Flutter 3.29.2 and JDK 17–21. Gradle 8.12 does not support JDK 25.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
```

If Gradle fails with a bare version number like `25.0.2`, point Flutter at a
supported JDK — machine-local, never committed:

```bash
flutter config --jdk-dir="/path/to/jdk-21"
```

## Workflow

1. Branch from `main` using `feat/`, `fix/`, `docs/` or `chore/` prefixes
2. Make your change
3. Run `flutter analyze` and `flutter test` — both must be clean
4. Open a PR against `main`

CI runs analyze and the full test suite on every PR. It must be green before merge.

### Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):

```
feat(growth): add referral source revenue breakdown
fix(migration): guard addColumn against existing v1 columns
docs(readme): document the visits event model
```

Explain **why** in the body, not just what — the diff already shows what changed.

Do **not** add AI co-author trailers to commits.

## Code conventions

Match the surrounding code. The essentials:

- Feature folders: `features/<name>/presentation/` and `features/<name>/providers/`
- `StreamProvider` for lists, `StateNotifierProvider` for mutations
- IDs are `String` UUIDs, not auto-increment integers
- Money is `RealColumn` (double)
- Currency and dates always go through `core/utils/formatters.dart`
- Deletes are **soft** (`isDeleted`); every aggregate must filter them out
- Never edit `app_database.g.dart` — regenerate it

### Attribution rules

These are easy to get wrong and silently corrupt every report:

- Revenue per clinic comes from **`cash_memos.clinicId`** — never
  `patients.primaryClinicId`
- Patient counts per clinic come from **`visits.clinicId`** — never the patients table
- `visitType` is computed once at insert and stored, never recomputed on read

## Database changes

The app is upgraded in place on devices holding real patient records. A careless
migration destroys data that cannot be recovered.

Any schema change must:

1. Bump `schemaVersion` in `app_database.dart`
2. Add an `onUpgrade` branch, guarding every `addColumn` with `_addColumnIfMissing`
   — adding a column that already exists throws and leaves the app unable to open
3. Copy data for renamed columns **before** anything downstream depends on it
4. Ship a migration test that builds the **previous** schema with raw SQL, seeds it,
   upgrades, and asserts zero row loss **and** idempotency
5. Be verified by installing the previous release and upgrading over it on a real
   device or emulator — no uninstall

See `test/migration_test.dart` for the v1 → v2 example.

A PR that changes the schema without a migration test will not be merged.

## Testing

- Database logic: use an in-memory database — `AppDatabase(NativeDatabase.memory())`
- Cover the aggregate that your change affects, especially per-clinic and
  period-boundary maths
- Test fixtures use fabricated patients only

## Scope and review

This app is a **decision tool**, not a medical record system. Changes that make it
harder to answer *"which clinic is actually profitable"* are unlikely to be accepted,
even if individually reasonable.

Review looks for correctness of the data model and migration safety first, then UI.

## Code of Conduct

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
