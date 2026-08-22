# ClinicPilot — Session Handoff

Last updated: **2026-08-21**, end of a long working session. Read this before doing anything — it has the rules, the workflow, exactly what shipped, and what's next.

---

## 0. Who this is for

Dr. Zaid, a homeopathic physician running two clinics on alternate evenings in Khidderpore, Kolkata. Offline-first Flutter app. The user (repo owner) is the developer/reviewer; Claude acts as implementer, reviewer, and release manager under the rules below.

---

## 1. Standing rules (do not deviate without being told)

These came from explicit user instructions earlier in the project. They override default behavior.

1. **Never add `Co-Authored-By: Claude` (or any AI co-author trailer) to any commit.** No exceptions, no asking — just omit it.
2. **Commit and push freely. NEVER merge a PR unless the user explicitly says so in that turn.** A prior approval to merge does **not** carry forward to the next PR — ask (or wait to be told) every time. This was violated once early in the project (PRs #41, #42 merged without asking) and corrected; do not repeat that mistake.
3. **Verify, don't trust.** Before reporting anything done: run `flutter analyze`, run the full test suite, and where practical do a real build (`flutter build apk --release`). Do not accept "it should work" — actually run it.
4. **Caveman-mode response style** (user's global CLAUDE.md): minimum tokens, ASCII diagrams over prose, no filler/hedging/recaps, bullets over paragraphs. Add a `THEORY:` block only for genuinely foundational concepts the user likely doesn't know.
5. **User's email**: saif@vegam.co — for attribution only, never sent to any external service.
6. **Git safety**: never force-push, never `--no-verify`, never amend a shared/pushed commit (create a new commit instead), never `rm -rf`/discard uncommitted work without checking `git status` first.
7. **Don't touch unrelated files.** This repo has untracked `chatgpt-chat/*.md` and `*.xlsx` files (patient case notes, pre-existing, not part of any feature) — never stage or commit these. Every commit this session staged an explicit file list, never `git add -A` / `git add .`.
8. **No scope creep.** Don't add unrequested abstractions, comments explaining *what* code does (only *why*, and only when non-obvious), or defensive code for cases that can't happen.

---

## 2. Git / GitHub workflow actually used this session

### Branching
- One feature branch per PR, always cut from a freshly-pulled `main`: `git checkout main -q && git pull -q && git checkout -b <name>`.
- Branch names used: `fix/onboarding-keyboard-flow`, `feat/list-export`, `feat/serial-number`, `fix/patient-export-serial-column`, `feat/backup-import`.
- If a branch was started before a dependency merged, it gets **reset onto the new `main`** once that dependency lands (`git reset --hard main`) rather than rebasing commit-by-commit — this repo's history stays linear and squash-merged, so reset is safe and simpler.

### Commits
- Every commit message: **why**, not what (the diff already shows what). No AI co-author trailer (rule #1).
- Heredoc (`git commit -F -` with a `<<'EOF' ... EOF` block) used for every commit message to avoid quoting issues — do this, not `-m` with embedded quotes.
- Stage explicit file lists (`git add <file1> <file2> ...`), never a blanket add.

### PRs
- `gh pr create` with a full structured body: what changed, why, architecture notes, verification results (test count, analyzer, build), and a "Branch note" if the base had to catch up to a dependency.
- **CI is polled before any merge decision**: `gh pr view <n> --json statusCheckRollup` in a loop until `COMPLETED`. Never merge on a still-running or failed check.
- **Merge command used**: `gh pr merge <n> --squash --delete-branch` — **only after the user explicitly says to merge in that turn.**
- When two PRs both touch the same files and one depends on the other, merge the dependency first, then re-check `mergeable`/`mergeStateStatus` on the second before merging it (don't assume it's still clean).

### Issues
- Filed with `gh issue create` for concrete bugs found (e.g. #46 memo/expense date bug, #48 personal-data-in-generic-app bug) — each closed automatically by its fixing PR via `Closes #N` in the commit/PR body.
- This session did **not** create or manage milestones — three pre-existing milestones exist (v0.1.1, v0.2, v0.4 Design System), untouched.

### Releases
- **Not part of this session.** Current shipped version: `0.3.0+3`, schema v5. No `git tag` or `gh release` was cut this session — several schema/feature changes landed (schema v4→v5, three new features) that are **not yet in any tagged release**. The user said "release not required for this fix" / hasn't asked for a new tag — do not cut one without being asked.
- If asked to release: bump `pubspec.yaml` version, confirm GitHub Actions signing secrets are still valid (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` — set once, should still be there), tag, push tag, let `release.yml` build.

---

## 3. Coding rules established/reinforced this session

- **Drift schema changes**: never use `Table.uniqueKeys` for a constraint that might need to be dropped/rebuilt during a migration test — SQLite refuses `ALTER TABLE ... DROP COLUMN` on a column referenced by a table-level `UNIQUE` constraint, which breaks this project's entire "simulate the pre-upgrade shape" migration-test pattern. **Use a plain `CREATE UNIQUE INDEX IF NOT EXISTS` instead**, created once in `onCreate` and once in the relevant `if (from < N)` migration block via a small shared helper method (see `_createPatientSerialIndex()` in `app_database.dart` as the pattern).
- **Migration backfills must use the table's actual primary key (`id`) for uniqueness placeholders, never a derived/generated field** like `patientCode` — the existing v1→v2 migration's `patientCode = 'P-MIG-' || substr(id, 1, 8)` collides whenever two ids share an 8-character prefix, which real short sequential v1 ids did. Don't inherit that bug into a new migration.
- **`AsyncValue.guard` in a Riverpod notifier swallows thrown exceptions into `state`, it does not rethrow.** Any method whose caller relies on a `try/catch` around the call (i.e. anything that must surface a DB constraint failure to the UI) must explicitly `throw result.error!` after checking `result.hasError`. Fixed once in `PatientNotifier.updatePatient`; check for this pattern before assuming any other guarded notifier method actually propagates errors.
- **PDF text has no Rupee glyph** (Helvetica base font) — any currency value rendered to PDF must go through a `Rs. 1234.00`-style formatter, never the `₹` formatter used for on-screen/CSV/XLSX. Pattern: `ExportColumn.pdfFormat` — an optional per-column override that only the PDF renderer consults; CSV/XLSX always get the raw typed value.
- **Never hardcode a real name, clinic name, or locality anywhere in `lib/`** — a regex guard test (`test/no_personal_data_test.dart`) scans `lib/` for `Zaid|Khidderpore|Babu Bazar` and fails the suite if found. This caught a real slip mid-session (an import-template example row). Use "Example Clinic" / generic names for any placeholder or template content.
- **Theme compliance**: `test/theme_compliance_test.dart` scans `lib/` for hardcoded `Colors.*`/`Color(0xFF...)` outside `core/theme/`, `core/design/`, and filenames matching `pdf_service`/`pdf_export_service` (PDF renders to paper, not the live theme, so fixed colors there are correct). Any new PDF-rendering file should match that filename pattern or the exemption list needs updating.
- **Export/report column specs are plain top-level functions**, not inline widget code — e.g. `patientsExportColumns()`, `cashMemoExportColumns()`, `growthExportEntries()`. This lets exact output be pinned in a unit test without a widget tree or the platform file-picker channel. Keep doing this for any new export.
- **CustomTextField gained `focusNode`/`autofocus`/`textInputAction`/`onFieldSubmitted`** as optional params (all default to prior behavior) — reuse these rather than reinventing keyboard-flow wiring.
- **A live async validation check inside a `TextFormField.validator` doesn't work** — `validator` only re-runs on explicit `validate()` calls, it won't react to a Riverpod provider resolving on its own. Pattern used: watch the provider in the widget's own `build()`, compute a plain bool/string, pass it into the field's `errorText`/`validator` closure, and force a rebuild on every keystroke via `onChanged: (_) => setState(() {})`.
- **Two-pass validation for cross-referencing spreadsheet rows**: validate the "parent" sheet first (build a lookup from only rows that themselves passed), then validate "child" sheets against that lookup — a child row referencing a parent that failed gets its own clear reason, not a generic failure.

---

## 4. What shipped this session (chronological)

All merged to `main`, squash-merged, in this order:

| PR | What | Key risk found & fixed |
|----|------|------------------------|
| #56 | Onboarding: autofocus + Enter/Next through both pages | Enter could bypass the same empty-name guard the Continue button enforced — fixed to check it too |
| #57 | Per-list CSV/XLSX/PDF export (Patients, Finances, Growth) | Discovered mid-work that Patients/Finances no longer have app bars (changed in earlier session) — plan's "put export in the app bar" assumption was wrong; adapted to a `trailing` slot on the shared `SectionSwitch` widget instead |
| #58 | Manual per-clinic Serial No. on patients | `Table.uniqueKeys` broke the whole migration-test suite (see §3) — switched to explicit index. Also found & fixed the `AsyncValue.guard` swallowed-exception bug, and the pre-existing v1→v2 `patientCode` collision bug (see §3) |
| #59 | Small follow-up: add the Serial No. column to the Patients export (deferred from #58 since #57 wasn't in #58's base yet) | — |
| #60 | Template-driven bulk import (Patients/Visits/Cash Memos/Expenses via a generated `.xlsx` template, two-pass validation, preview screen, transactional commit) | Caught my own mistake before push: example rows used the real practice's clinic name — the personal-data guard test caught it |

Also merged earlier in the session, from prior work: #47 (memo/expense date fields), #49 (generic-app placeholders + day-of-week chips), #50 (patients follow-ups tab + double-submit fix).

**Net result:**
- Schema: v4 → **v5** (added `patients.serial_no` + unique index on `(primary_clinic_id, serial_no)`)
- New features live: per-list export (CSV/XLSX/PDF) on Patients/Finances/Growth; manual Serial No. on patients; full backup-style import via a downloadable template
- `pubspec.yaml` version still `0.3.0+3` — **not bumped, not released**

---

## 5. Two planning artifacts exist (both fully executed now)

- **[Serial No. and Footfalls](https://claude.ai/code/artifact/0b25cd7c-3316-4b1f-bc67-a29c3459e952)** — Serial No. shipped (#58). **Footfalls (the lead/conversion-tracking tab) was never started.** If the user wants it, re-read this artifact first — it has the full design (4th tab under Patients: Directory/Follow-ups/Footfalls, one-tap logging, link-to-patient-at-registration for conversion tracking).
- **[Onboarding Focus and Data Export](https://claude.ai/code/artifact/cb06bd77-7583-46c9-bae7-e5c02e14bcb5)** — fully executed (#56, #57, #58, #59, #60).

To update either artifact from a future session, publish with the same `url` (use `Artifact` tool, `action: list` to re-find the URL if needed) — do not publish fresh, it creates a duplicate.

---

## 6. What's next (not started, not asked for yet)

Nothing is currently in progress. Candidates, in rough priority if the user wants to continue this line of work:

1. **Footfalls feature** — see artifact above. Fully designed, zero code written.
2. **Cut a release** — schema v5 and three features have shipped since `0.3.0+3` with no tag. The user will say when.
3. **Stale-looking open issues worth a look** (not verified this session, just noticed while writing this handoff):
   - **#34** "Patient form: Age and Gender fields misaligned" — likely already fixed (Age/Gender alignment was fixed in `edit_patient_dialog.dart` in an earlier session). Verify and close if so.
   - **#33** "Top app bar: clinic and period labels are unreadable" — app bar was substantially reworked since this was filed (Patients/Finances lost their app bars entirely). Re-check if still applicable.
   - #37, #38 (design system / patient profile tabs redesign) and #51–55 (old phased roadmap issues) — not reviewed this session, unclear if still relevant to current app shape.
4. Nothing else was requested or implied by the user.

---

## 7. Environment notes

- Flutter SDK at `C:/Apps/flutter/bin/flutter.bat` — use the full path in Bash, not bare `flutter`, in this shell setup.
- `flutter pub run build_runner build --delete-conflicting-outputs` regenerates `app_database.g.dart` after any table/schema change — always run this and check the diff before testing.
- A background `chatgpt-chat/` folder with untracked patient-data files sits in the repo root — **never stage, never delete, not related to any task** unless the user explicitly asks about it.
- GitHub repo: `mdsaif45/ClinicPilot`. CI workflow: `analyze-and-test` (runs on every PR). Release workflow: `release.yml` (only runs on a pushed tag, needs the 4 signing secrets already configured in repo settings).
