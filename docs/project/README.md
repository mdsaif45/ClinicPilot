# ClinicPilot Project Engineering & Governance Portal

Welcome to the **ClinicPilot Engineering & Project Governance Portal**. This guide defines the repository architecture, code conventions, design system governance, quality gates, and deployment protocols governing ClinicPilot development.

---

## Table of Contents
1. [Mission & Core Product Philosophy](#1-mission--core-product-philosophy)
2. [Codebase Architecture & Directory Structure](#2-codebase-architecture--directory-structure)
3. [Engineering Standards & Coding Guidelines](#3-engineering-standards--coding-guidelines)
   - [State Management with Riverpod](#31-state-management-with-riverpod)
   - [Database & Schema Migrations with Drift](#32-database--schema-migrations-with-drift)
   - [Design System & Theme Token Rules](#33-design-system--theme-token-rules)
4. [Git Discipline & Branching Strategy](#4-git-discipline--branching-strategy)
   - [Branch Naming Protocol](#41-branch-naming-protocol)
   - [Commit Message Standards](#42-commit-message-standards)
   - [Pull Request & Review Workflow](#43-pull-request--review-workflow)
5. [Testing & Quality Assurance Gates](#5-testing--quality-assurance-gates)
6. [Release Signing & Production Deployment](#6-release-signing--production-deployment)
7. [Project Documentation Index](#7-project-documentation-index)

---

## 1. Mission & Core Product Philosophy

ClinicPilot is a fast, 100% offline-first practice intelligence and clinical case management mobile app engineered for solo homeopathic and independent physicians. It is designed to be operated **with one hand, standing up, between patients during crowded evening clinics**.

```
PRIORITIES:
Speed > Features > Polish
Offline > Cloud
Growth Intelligence > Bureaucratic Clinic Management
```

---

## 2. Codebase Architecture & Directory Structure

```
ClinicPilot/
├── android/                 # Android native runner, keystore config, build.gradle.kts
├── assets/                  # Local vector assets, icons, fonts
├── docs/                    # Project, research, and product documentation
│   ├── project/             # Engineering guidelines, release signing, progress tracker
│   │   ├── README.md        # This portal guide
│   │   ├── release-signing.md
│   │   └── progress.md
│   └── research/            # Clinical ergonomics, competitive benchmarks, market sizing
│       ├── README.md
│       ├── competitive-analysis.md
│       ├── feature-matrix.md
│       ├── product-opportunity.md
│       ├── ux-analysis.md
│       └── _raw/            # Historical technical FAQs and legacy prompt archives
├── lib/
│   ├── core/                # Shared domain-agnostic foundation
│   │   ├── database/        # Drift database tables, DAOs, schema migrations
│   │   ├── design/          # Design tokens (tokens.dart, app_palette.dart)
│   │   ├── providers/       # Global shared Riverpod state providers
│   │   ├── router/          # GoRouter shell & deep link definitions
│   │   ├── services/        # PDF generation, backup/export, update checkers
│   │   ├── theme/           # app_theme.dart (exclusive location for color literals)
│   │   ├── utils/           # String formatters, date utilities, validators
│   │   └── widgets/         # 28+ reusable high-contrast clinical UI widgets
│   ├── features/            # Vertical feature slices (presentation + providers)
│   │   ├── analytics/       # Retention rates, clinic health score, P&L
│   │   ├── cases/           # 16-section Master Record, complaint severity logs
│   │   ├── clinics/         # Multi-branch switching, rent prorating, settings
│   │   ├── consultation/    # Active OPD encounter flow & posology steppers
│   │   ├── crm/             # Outreach camps, referral networks, Google review pipeline
│   │   ├── expenses/        # Categorized operational expenditures
│   │   ├── patients/        # Patient directory, search, phone chips
│   │   ├── posology/        # Remedy lookup, potencies, repetition schedules
│   │   └── visits/          # Longitudinal visit timelines & cash memos
│   └── main.dart            # Application entrypoint & initialization
└── test/                    # 367+ automated unit, widget, and Drift migration tests
```

---

## 3. Engineering Standards & Coding Guidelines

### 3.1 State Management with Riverpod
- Use `StreamProvider` for continuous reactive SQLite queries emitted by Drift DAOs.
- Use `StateNotifierProvider` or `AutoDisposeAsyncNotifier` for mutation workflows.
- Always check `if (!context.mounted) return;` before navigating or displaying snackbars after an `await` boundary.
- Handle `AsyncValue.when` explicitly for loading, error, and data states without swallowing critical stack traces.

### 3.2 Database & Schema Migrations with Drift
- **UUID Identifiers**: Primary keys are universally unique strings (`String UUID`).
- **Monetary Values**: Financial quantities are stored as `RealColumn (double)`.
- **Soft Deletion**: All operational tables implement an `isDeleted` boolean column. All UI queries must filter `isDeleted = false`.
- **Schema Code Generation**: Never manually edit generated `app_database.g.dart` files. After any schema or DAO edit, run:
  ```powershell
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- **Schema Version Migrations**:
  - Implement non-destructive migrations in `app_database.dart` using `CREATE UNIQUE INDEX` rather than modifying existing primary keys in place.
  - Write explicit schema migration verification tests in `test/core/database/` for every incremented schema version.

### 3.3 Design System & Theme Token Rules
- **Single Source of Truth**:
  - `lib/core/design/tokens.dart`: Governs spacing (`xs=4`, `sm=8`, `md=12`, `lg=16`, `xl=24`, `xxl=32`), border radii (`sm=8`, `md=12`, `lg=16`, `pill=999`), and animation durations (`fast=120ms`, `base=180ms`, `slow=240ms`).
  - `lib/core/design/app_palette.dart`: Governs raw chromatic hex codes.
- **Zero Color Literals in Feature Code**:
  - Feature widgets must **never** hardcode `Color(0x...)` or use `Colors.blue`.
  - Colors must be accessed strictly via `Theme.of(context).colorScheme` or custom theme extensions.
  - Automated CI theme tests fail the build if unapproved raw color literals appear in `lib/features/`.

---

## 4. Git Discipline & Branching Strategy

```
STRICT GIT RULES:
NEVER:
├── force-push to any shared branch
├── commit with --no-verify
├── amend an already-pushed commit
├── run git add . / git add -A (always stage explicit files)
└── merge a PR without explicit user approval

ALWAYS:
├── branch from freshly-pulled main
├── name branches: feat/<name>, fix/<name>, chore/<name>
├── write commit messages explaining WHY, not WHAT
├── run flutter analyze + flutter test before opening PRs
└── squash-merge and delete feature branches upon completion
```

### 4.1 Branch Naming Protocol
- `feat/<feature-slug>`: New user-facing capabilities or enhancements (e.g. `feat/pdf-rx-generator`).
- `fix/<issue-slug>`: Bug fixes or stability patches (e.g. `fix/posology-dialog-overflow`).
- `chore/<task-slug>`: Dependency upgrades, CI updates, or refactoring (e.g. `chore/migrate-research-docs`).

### 4.2 Commit Message Standards
Commits must explain **WHY** a change was made and the architectural rationale, not simply restate what files were modified:

```bash
git commit -F - <<'EOF'
feat(posology): add rapid potency quick-chips in consultation flow

Reduces time-per-prescription from 45 seconds to 10 seconds by replacing
free-text typing with one-tap potency chips (6C, 30C, 200C, 1M). Eliminates
typos during peak evening clinic rush.
EOF
```

### 4.3 Pull Request & Review Workflow
1. Push branch to remote: `git push origin feat/<feature-name>`.
2. Open Pull Request using the formal template (`.github/pull_request_template.md`).
3. Link the PR to the active Milestone and relevant GitHub Issue.
4. Verify all automated CI checks pass (`gh pr view <n> --json statusCheckRollup`).
5. Obtain explicit maintainer approval before performing a clean squash-merge.

---

## 5. Testing & Quality Assurance Gates

Quality gates run locally and on GitHub Actions CI (`.github/workflows/verify.yml`):

1. **Static Analysis**:
   ```powershell
   flutter analyze
   ```
   *Gate requirement: Zero warnings, zero errors, zero hints.*
2. **Automated Test Suite**:
   ```powershell
   flutter test
   ```
   *Gate requirement: 100% pass rate across all 367+ automated tests.*
3. **Format Verification**:
   ```powershell
   dart format --set-exit-if-changed .
   ```
4. **Dependency CVE Scanning**:
   - Automated `Dependency Review` action scans all pull requests for known CVEs in upstream packages.

---

## 6. Release Signing & Production Deployment

For comprehensive release procedures, Android keystore generation, and GitHub Actions CI secrets configuration:
- Refer to [**Release Signing Guide**](release-signing.md).
- Production signed split-ABI APKs:
  ```powershell
  flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
  ```
- Production Google Play App Bundle (AAB):
  ```powershell
  flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
  ```

---

## 7. Project Documentation Index

- [**Release Signing Documentation**](release-signing.md): Keystore management, `.jks` configuration, and CI secret setup.
- [**Project Progress & Sprint Tracker**](progress.md): Implementation matrix, active development, technical debt, and sprint planning.
- [**Research Portal Index**](../research/README.md): Gateway to clinical ergonomics, market sizing, and competitive benchmarks.
- [**Competitive Analysis**](../research/competitive-analysis.md): Benchmark vs Practo, Cliniko, Hompath, and open-source stacks.
- [**Clinical UX Research**](../research/ux-analysis.md): Ergonomics for high-intensity Outpatient Departments.
