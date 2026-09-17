# ClinicPilot Documentation Portal

Welcome to the central documentation knowledge base for **ClinicPilot** ([github.com/mdsaif45/ClinicPilot](https://github.com/mdsaif45/ClinicPilot)).

ClinicPilot is an autonomous, offline-first clinical operating system designed specifically for solo outpatient doctors running high-volume, multi-clinic Outpatient Departments (OPD) with specialized depth in homeopathic medicine and practice economics.

---

## 🧭 Documentation Map

The documentation is organized into six structured pillars:

```
docs/
├── architecture/          # Technical system design, storage tiering, data models & engines
├── decisions/             # Formal Architecture Decision Records (ADR-001 to ADR-006)
├── product/               # Vision, core axioms, Dr. Zaid persona, and clinical scope
├── roadmap/               # Milestone capability matrix (M1 through M6+ / v1.0)
├── research/              # Competitive analysis, UX studies, economics & legacy archives
└── project/               # Governance, progress tracker, and release signing workflows
```

---

## 🏛️ 1. Architecture & Engineering

Technical blueprints detailing the offline-first foundation, reactive state management, data integrity, and domain engines.

| Document | Description |
|---|---|
| [**Architecture Overview**](architecture/architecture-overview.md) | 3-tier modular architecture, Riverpod 2.x reactive state flow, GoRouter `StatefulShellRoute` multi-branch navigation, and storage tiering. |
| [**Data Model & Relational Schema**](architecture/data-model.md) | Comprehensive specification of all 15 Drift SQLite tables (Schema v18), foreign keys, covering indices, and hybrid JSON case records. |
| [**Clinical Case Engine**](architecture/clinical-case-engine.md) | Architectural dive into the 17-section homeopathic case taking engine, multi-methodology repertorial totality algorithms, and Hering's Law progression. |
| [**Quality Gates & Theme Compliance**](architecture/quality-gates.md) | Zero-hardcoded-colors enforcement via `theme_compliance_test.dart`, static analysis standards, cryptographic testing, and CI/CD criteria. |
| [**Architecture Portal README**](architecture/README.md) | Architectural philosophy, system boundary diagrams, and technology stack breakdown. |

---

## ⚖️ 2. Architecture Decision Records (ADRs)

Formal records documenting the context, options evaluated, trade-offs, and rationale behind architectural decisions.

| ADR | Title | Status | Summary |
|---|---|---|---|
| [**ADR-001**](decisions/ADR-001-offline-first-sqlite.md) | Offline-First Persistence via Drift SQLite Engine | `Accepted` | Strict relational integrity, sub-millisecond local queries, zero network spinners, and DISHA/HIPAA compliance. |
| [**ADR-002**](decisions/ADR-002-zero-hardcoded-tokens.md) | Centralized Design Tokens & Enforced Theme Compliance Gate | `Accepted` | Zero-hardcoded-colors policy in `tokens.dart` guarded by AST automated regression tests. |
| [**ADR-003**](decisions/ADR-003-stateful-shell-navigation.md) | GoRouter StatefulShellRoute for Multi-Branch State Preservation | `Accepted` | Multi-branch navigation preserving form and scroll state across 5 tabs with decoupled clinic switching. |
| [**ADR-004**](decisions/ADR-004-case-record-synthesis.md) | Dynamic JSON Lineage & Backward-Compatible Case Records | `Accepted` | Hybrid relational envelope + versioned JSON columns for the 17-section clinical case schema. |
| [**ADR-005**](decisions/ADR-005-multi-clinic-isolation.md) | Active Clinic Tenancy Scoping & Cross-Clinic Aggregation | `Accepted` | Row-level tenant partitioning via `clinic_id` in a single SQLite database with Riverpod provider scoping. |
| [**ADR-006**](decisions/ADR-006-encrypted-backup.md) | AES-GCM 256-bit Encrypted Local Container Backup (`.cpbak`) | `Accepted` | Complete database + media export in an encrypted container with SHA-256 checksum integrity verification. |
| [**Decisions README**](decisions/README.md) | ADR Governance & Master Registry | — | ADR lifecycle state machine, template anatomy, and contribution guidelines. |

---

## 🎯 3. Product Strategy & Clinical Domain

Product vision, target user persona, clinical operational workflows, and deep homeopathic domain requirements.

| Document | Description |
|---|---|
| [**Product Vision**](product/vision.md) | Autonomous solo-doctor operating system, persona deep-dive (Dr. Zaid), multi-clinic unit economics, profit-per-clinic mandate, and patient acquisition CRM. |
| [**Product Principles**](product/principles.md) | Five non-negotiable axioms: Speed > Polish, Offline > Cloud, Ergonomic Flow, Local-First Data Sovereignty, and Cognitive Offloading. |
| [**OPD Operating Workflows**](product/opd-workflows.md) | Realistic 6-phase journey of a 2-hour evening OPD: arrival, rapid intake, 17-section encounter, dispensing, billing, and daily clinic reconciliation. |
| [**Homeopathic Clinical Scope**](product/homeopathic-clinical-scope.md) | Comprehensive posology guide: Decimal (X), Centesimal (C), LM scales, vehicles (globules, powders, mother tinctures), repertorial scoring, and miasmatic triage. |
| [**Product Portal README**](product/README.md) | High-level product summary, 5 primary interaction modes, and core architectural pillars. |

---

## 🗺️ 4. Capability Roadmap

Phased product development milestones, versioning cadence, and engineering quality gates.

| Document | Description |
|---|---|
| [**Capability Roadmap**](roadmap/roadmap.md) | Detailed capability breakdown from Milestone 1 through Milestone 6+ / v1.0 (OPD Core, Multi-Clinic, 17-Section Case Engine, Pharmacy Inventory, Encrypted Backup, Multi-Platform). |
| [**Roadmap Governance**](roadmap/README.md) | Vertical Slice delivery methodology, Semantic Versioning (SemVer) cadence, and quality verification gates. |

---

## 🔬 5. Research & Raw Archives

Competitive intelligence, clinical ergonomics research, market sizing, and historical raw records.

| Document | Description |
|---|---|
| [**Competitive Analysis**](research/competitive-analysis.md) | Deep KEEP / IMPROVE / COMBINE / INNOVATE / DEFER / REJECT analysis comparing ClinicPilot against Practo, Cliniko, Hompath, RadarOpus, and Vyapar. |
| [**Feature Scoring Matrix**](research/feature-matrix.md) | Impact, effort, and risk evaluation across feature candidates scored for fast-paced OPD solo practitioners. |
| [**Product Opportunity**](research/product-opportunity.md) | Market sizing (325,000+ Indian AYUSH homeopaths), ethical freemium economics (₹125/mo formula), and grassroots distribution. |
| [**OPD UX Ergonomics Analysis**](research/ux-analysis.md) | In-situ touch targets (48dp minimum), thumb-zone layouts, high-contrast lighting readability, and 60-second encounter entry ergonomics. |
| [**Doubts & Historical FAQ**](research/_raw/doubts-and-faq.md) | Consolidated archive of engineering inquiries: APK sizing, R8 safety, barcode scanning, modder defenses, and cloud storage connectors. |
| [**Legacy Prompts Archive**](research/_raw/legacy-prompts/) | Preserved foundation prompt records: v0.1 through v0.4 design documents and fixes. |
| [**Research Portal README**](research/README.md) | Research methodology overview, qualitative shadowing insights, and directory navigation. |

---

## 🛠️ 6. Project Management & Operations

Project management guidelines, sprint progression, and deployment operations.

| Document | Description |
|---|---|
| [**Project Governance & Standards**](project/README.md) | Architecture patterns, state management rules, Drift migration protocols, theme governance, and Git branch discipline. |
| [**Progress & Sprint Tracker**](project/progress.md) | Live implementation status of 12 core modules, technical debt log (TD-01 to TD-05), and automated test coverage metrics. |
| [**Release Signing Guide**](project/release-signing.md) | Android keystore generation, `key.properties` configuration, GitHub Actions CI secrets, split-ABI APK, and AAB signing. |

---

## ⚡ Quick Links for Developers & Contributors

- **Running Quality Checks**:
  ```bash
  flutter test test/theme_compliance_test.dart
  flutter analyze --no-fatal-infos
  flutter test
  ```
- **Key Files**:
  - Main Database Schema: `lib/core/database/app_database.dart`
  - Design Tokens & Colors: `lib/core/theme/tokens.dart` & `lib/core/theme/app_palette.dart`
  - Case Record Models: `lib/features/clinical/models/case_record_models.dart`
  - Navigation Shell: `lib/core/routing/app_router.dart`
