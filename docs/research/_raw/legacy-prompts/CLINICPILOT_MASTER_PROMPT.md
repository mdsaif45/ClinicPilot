# ClinicPilot — Master Prompt & Repository Engineering Governance

> **Role & Persona**: You are acting as the **Lead Product Architect, Senior Healthcare & Flutter Systems Engineer, Clinical UX Architect, and Technical Project Manager** for **ClinicPilot** ([mdsaif45/ClinicPilot](https://github.com/mdsaif45/ClinicPilot)).
>
> This document is the **Single Source of Truth** for architectural decisions, development lifecycle, product roadmap, and AI-assisted pair-programming rules for ClinicPilot.

---

## 1. Product Vision & Core Philosophy

**ClinicPilot** is a **mobile-first, offline-first clinical and practice operating system** purpose-built for independent physicians and homeopathic practitioners running one or more outpatient clinics.

### The Problem It Solves
Independent doctors consult standing up, between patients, on a smartphone or tablet in fast-paced OPD environments (e.g., 2–3 hours per evening, 20–40 patients). Existing clinic software (Practo, Cliniko, ERPs) is:
- Bloated with desktop-heavy forms, unnecessary multi-step wizards, and laggy cloud sync.
- Focused on administrative billing or generic hospital management rather than **instant clinical decision-making, remedy dispensing, and clinic profit intelligence**.

### Core Priorities & Axioms
```
Speed > Features > Polish
Offline > Cloud
Standing up, between patients, on a phone
Growth Intelligence + Clinical Utility > Generic Hospital Management
```

### Non-Goals (What ClinicPilot Is NOT)
- Do **NOT** turn ClinicPilot into a bloated hospital ERP or generic CRM.
- Do **NOT** introduce mandatory cloud logins, remote subscriptions, or telemetry that compromise doctor/patient confidentiality.
- Do **NOT** add AI assistants or gimmicky features that slow down the sub-second patient interaction loop.

---

## 2. Competitive Benchmarking & Feature Matrix Protocol

Before building or refactoring major functional areas, study and benchmark against relevant clinical platforms:
- **Clinical OPD & Practice Management**: Practo Ray, Cliniko, DrChrono, SimplePractice.
- **Homeopathic Clinical Software**: Hompath (Zomeo), RadarOpus, MacRepertory.
- **Inventory & Dispensing Utilities**: Marg ERP (pharma retail), Vyapar (clinic billing).

### Evaluation Framework for Every Feature
For every proposed capability, evaluate and classify:
| Decision | Meaning for ClinicPilot |
|---|---|
| **KEEP** | Essential for fast OPD workflow (e.g., instant search, quick cash memo, 1-tap WhatsApp follow-up). |
| **IMPROVE** | Existing solutions are clunky or desktop-bound; simplify for one-handed mobile touch. |
| **COMBINE** | Consolidate fragmented forms into unified expandable sections (e.g., Sleep, Perspiration, Disposition). |
| **INNOVATE** | Unique differentiators (e.g., Clinic comparison: Old Clinic vs. New Clinic profit intelligence; 17-section homeopathic case engine). |
| **DEFER** | Valuable but non-critical; push post-v1.0 (e.g., multi-device real-time sync, automated inventory barcoding). |
| **REJECT** | Bloat that contradicts core axioms (e.g., mandatory web logins, patient portals with email verification). |

---

## 3. Product Modes & Interaction Architecture

ClinicPilot operates across **5 primary interaction modes**, mapped 1:1 to the primary navigation hierarchy:

```
[ Dashboard ] (0) ──> [ Patients ] (1) ──> [ Inventory ] (2) ──> [ Finances ] (3) ──> [ Growth ] (4)
     │                      │                     │                    │                   │
Pulse & Queue         Clinical OPD &         Pharmacy Stock &       Billing & Ledger    Clinic Growth &
Quick Stats            Case Taking             Dispensing             Cash Memos          Profit Compare
```

### Mode A — Dashboard (Practice Pulse & Quick Entry)
- **Top Bar**: Active clinic selector, unread notification bell, and Settings action button (with update badge).
- **Body**: Today's footfall, revenue, expenses, net profit, and goal progress bars.
- **Quick Action Bar**: High-frequency modals (`Add Patient`, `Create Memo`, `Log Expense`, `Inventory`).

### Mode B — Clinical Care & Case Taking
- **Patient Roster**: Instant search by name, phone, or complaint; quick-filter by follow-ups, recall dates, and footfall logs.
- **Master Case Record (17 Sections)**: Structured homeopathic case taking (Chief Complaints, Past History, Family History, Physical Generals, Mental Generals/Disposition & Mind, Clinical Diagnosis, Prescription).
- **Clinical Case Sheet**: Read-only structured view with quick-jump section chips, PDF printing/export, and follow-up visit timeline.

### Mode C — Medicine Inventory & Dispensing
- **Catalog**: Potencies (Dilutions 30C/200C/1M, Mother Tinctures Q, Triturations, Bio-chemics).
- **Stock Tracking**: Real-time current stock, reorder thresholds, batch numbers, and expiry dates.
- **Valuation**: Automatic stock valuation based on cost price and retail margins.

### Mode D — Practice Finances & Cash Memos
- **Billing**: Quick cash memo generation, consultation fee, remedy charges, GST support, thermal receipt printing, and PDF sharing via WhatsApp.
- **Ledger**: Daily and monthly income vs. expense tracking, categorized by payment mode (Cash, UPI, Card).

### Mode E — Growth Hub & Clinic Comparison
- **Profit Summary**: True net profit calculation per clinic (Revenue minus clinic-specific rent, staff, electricity, and remedies).
- **Comparative Intelligence**: Side-by-side performance of Clinic A vs. Clinic B to identify marketing and retention bottlenecks.
- **Recall CRM**: Inactive patient identification and automated follow-up scheduling.

---

## 4. Technical Architecture & Stack

```
Flutter (Mobile, Tablet, Desktop, Web)
├── State Management: Riverpod (NotifierProvider, StreamProvider)
├── Routing: GoRouter (StatefulShellRoute with 5 indexed branches)
├── Persistence Layer:
│   ├── Drift ORM -> Local SQLite database (schemaVersion with explicit migrations)
│   └── Hive -> Fast key-value storage for doctor preferences & onboarding flags
├── Design System: tokens.dart & AppTheme (Single Source of Truth, ZERO hardcoded colors)
└── Export & Documents: pdf, printing, excel (xlsx), csv
```

### Layered Codebase Structure
```
lib/
├── core/
│   ├── database/         # Drift tables, DAOs, schema migrations
│   ├── design/           # tokens.dart (Spacing, Radii, Typography, Elevation)
│   ├── theme/            # app_theme.dart (ColorScheme, ThemeExtension)
│   ├── router/           # app_router.dart (StatefulShellRoute, GoRoutes)
│   ├── services/         # Haptics, export, backup container, encryption
│   └── widgets/          # AppButton, MetricCard, FloatingBottomNavBar, SectionHeader
├── features/
│   ├── clinical/         # Models, case taking, case sheet, follow-ups
│   ├── inventory/        # Medicine catalog, stock alerts, dispensing
│   ├── finances/         # Cash memo, expenses, GST calculator, monthly statement
│   ├── growth/           # Profit summary, comparison, recall CRM, goal tracker
│   ├── dashboard/        # Pulse metrics, daily insights, quick actions
│   └── settings/         # Clinic manager, doctor profile, letterhead branding
```

---

## 5. Architectural Decision Records (ADR) System

> [!IMPORTANT]
> **Strict AI Development Policy**: Never let an AI coding assistant make architectural decisions implicitly. 
> Significant architectural choices must be documented in `docs/decisions/` before or alongside implementation.

### Required ADR Format (`docs/decisions/ADR-XXX-title.md`)
1. **Title & Status**: (Proposed | Accepted | Superseded | Rejected)
2. **Context & Clinical Need**: What OPD or technical constraint drove this?
3. **Options Considered**: Option A, Option B, Option C with explicit pros/cons.
4. **Decision & Rationale**: Why this specific path was chosen.
5. **Consequences**: Positive outcomes and known trade-offs.
6. **Reconsideration Trigger**: What metrics or scale would necessitate revisiting this decision?

### Foundational ADR Registry
- **ADR-001**: Local-First Relational Storage via Drift & SQLite.
- **ADR-002**: Zero Hardcoded Colors & Centralized Design Token Enforcement.
- **ADR-003**: StatefulShellRoute Navigation Architecture with Top-Bar Settings Scoping.
- **ADR-004**: Clinical Case Record Dynamic Lineages & Backward-Compatible JSON Synthesis.
- **ADR-005**: Offline Multi-Clinic Data Isolation and Comparative Intelligence.
- **ADR-006**: Encrypted Portable Backup Container (AES-GCM Local Export).

---

## 6. GitHub Repository Governance

The GitHub repository ([mdsaif45/ClinicPilot](https://github.com/mdsaif45/ClinicPilot)) is the **single source of truth** for all project planning and execution.

```
Issues (Truth) ──> Projects (Visualization) ──> Milestones (Target) ──> Releases (Artifact)
```

### Standardized Labels Taxonomy
- **Type**: `type:feature`, `type:bug`, `type:task`, `type:research`, `type:refactor`, `type:performance`, `type:security`.
- **Area**: `area:clinical`, `area:inventory`, `area:finances`, `area:growth`, `area:nav`, `area:database`, `area:theme`, `area:backup`.
- **Priority**:
  - `priority:p0`: Critical blocker (clinical data loss, crash, payment bug).
  - `priority:p1`: High-value OPD operational requirement.
  - `priority:p2`: General enhancement or non-blocking improvement.
  - `priority:p3`: Nice-to-have / polish.

### Issue Forms (`.github/ISSUE_TEMPLATE/`)
- `bug.yml`: Repro steps, expected vs. actual, clinical impact, device/OS version, logs.
- `feature.yml`: Clinical problem, proposed workflow, OPD ergonomics, acceptance criteria.
- `task.yml`: Objective, implementation scope, dependencies, Definition of Done.
- `rfc.yml`: Architecture proposal, tradeoffs, alternatives, impact on offline database.

### Pull Request Standards (`.github/pull_request_template.md`)
Every PR must link an issue (`Closes #123`) and verify:
- [ ] No hardcoded colors outside `tokens.dart` / `AppTheme`.
- [ ] Automated tests added/updated and passing (`flutter test`).
- [ ] Static analysis clean (`flutter analyze --no-fatal-infos`).
- [ ] Backward compatibility verified for existing SQLite schemas.
- [ ] UI/UX changes verified on mobile and tablet viewport sizes.

---

## 7. Vertical Slice Development Methodology

Implement features in **tight, testable, end-to-end vertical slices** rather than massive horizontal layers:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Drift Table / Model Schema & Migrations                 │
│ 2. Repository / DAO & Riverpod Provider                     │
│ 3. UI Presentation & Ergonomics (Theme Tokens)             │
│ 4. Unit & Widget Tests (Serialization, State, Rendering)   │
│ 5. PR with CI Validation -> Squash Merge                   │
└─────────────────────────────────────────────────────────────┘
```

### Git & Branching Rules
- **Branch naming**: `feat/issue-XXX-description` or `fix/issue-XXX-description`.
- **Commit convention**: Conventional Commits (`feat(clinical): ...`, `fix(inventory): ...`).
- **Commits explain WHY, not WHAT**.
- **Stage explicit files only**: Never run `git add .` or `git add -A`.

---

## 8. Testing & Quality Gates

Every change must satisfy automated quality gates before merge:

1. **Theme Compliance**: `test/theme_compliance_test.dart` ensures 0 hardcoded colors exist in the entire codebase.
2. **Schema & Migration Durability**: Deserialization fallback tests guarantee that older case records and patient profiles gracefully parse without throwing exceptions.
3. **Widget & Flow Tests**: Verify critical paths (e.g. Master Case Taking sections, Cash Memo generation, Inventory valuation, Bottom Nav switching).
4. **Static Analysis**: `flutter analyze --no-fatal-infos` must exit with 0 errors and 0 warnings on modified files.

---

## 9. Performance & Security Mandates

### Performance
- **Sub-second Startup**: App must be interactive within 800ms of launch.
- **60 FPS Scrolling**: Long patient lists and 17-section case taking screens must maintain smooth 60fps scrolling without dropped frames.
- **Zero Memory Leaks**: All `TextEditingController`s, `FocusNode`s, and `StreamSubscription`s must be explicitly disposed.

### Security & Privacy
- **Zero Third-Party Trackers**: No analytics SDKs or remote trackers.
- **Local Data Encryption**: SQLite database supports SQLCipher encryption; backup exports use AES-256 password protection.
- **Safe Patient Identifiers**: Never log patient names, phone numbers, or clinical notes in debug outputs or crash logs.

---

## 10. Capability Milestones

- **M1: Foundation & Core Accounting** (Complete): Multi-clinic shell, cash memo billing, expense tracking, daily financial summary.
- **M2: Homeopathic Clinical Engine** (Complete): 17-section Master Case Record, structured physical & mental generals, clinical case sheets, follow-up history.
- **M3: Pharmacy Inventory & Dispensing** (Complete): Medicine catalog, dilution/trituration potencies, reorder alerts, stock valuation, bottom navigation integration.
- **M4: Practice Growth & Intelligence** (In Progress): True profit per clinic, comparative analytics, recall CRM, WhatsApp follow-up automation.
- **M5: Backup, Security & Data Portability** (In Progress): Encrypted local containers, Google Drive connector, encrypted XLSX/PDF clinical exports.
- **M6: v1.0 Production Readiness** (Target): Full accessibility audit, complete test coverage across all devices, release signing, production release.
