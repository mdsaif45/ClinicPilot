# ClinicPilot — Comprehensive Capability Roadmap

> **Engineering Milestones, Feature Specifications, Schema Evolution & Acceptance Criteria**  
> *From Local Clinical Prototype to the Autonomous Practice Operating System.*

---

## Roadmap Architecture & Overview

This document provides the definitive, granular breakdown of features across all development milestones of **ClinicPilot**. Each milestone is structured with clear clinical rationale, technical architecture, database schema impacts, and strict acceptance criteria.

```mermaid
gantt
    title ClinicPilot Capability Delivery Timeline
    dateFormat  YYYY-MM-DD
    section Completed
    M1: Core OPD Engine & Local Database       :done, m1, 2025-10-01, 2025-12-15
    section Current / Active
    M2: Multi-Clinic Tenancy & Finances        :active, m2, 2026-01-10, 2026-04-15
    section Planned
    M3: 17-Section Case Taking & Repertory     :m3, 2026-04-16, 2026-07-31
    M4: Pharmacy Inventory & Dispensing        :m4, 2026-08-01, 2026-10-31
    M5: Encrypted Backup & P2P Sync            :m5, 2026-11-01, 2027-01-31
    section Future
    M6+: v1.0 Production Readiness & Platforms :m6, 2027-02-01, 2027-06-30
```

---

## Milestone 1 (M1): Core OPD Engine & Local Database
**Status**: ✅ Completed / Production Baseline (`v0.1.0` – `v0.4.0`)  
**Core Objective**: Establish a crash-proof, 100% offline local-first database architecture and fast patient registry for single-clinic outpatient operations.

### 1.1 Clinical Context & Problem Solved
Solo practitioners entering an evening clinic cannot tolerate slow cloud sync or complex hospital menus. M1 delivered instant (< 150ms) patient search, simple profile creation, visit logging, and basic cash billing so the doctor could discard paper intake notebooks.

### 1.2 Delivered Features & Technical Scope
- **Drift SQLite Relational Persistence**:
  - Offline-first SQLite database managed via Drift ORM with compile-time query verification.
  - Core tables: `Patients`, `Visits`, `CashMemos`, `Settings`.
- **High-Velocity Patient Management**:
  - Sub-second indexing on patient name, mobile number, and unique auto-incrementing serial code.
  - Demographics capture: Name, Age, Sex, Locality/Area, Phone, WhatsApp preference.
- **Fundamental Visit Logging**:
  - Record date, chief complaint text, diagnosis summary, and basic visit remarks.
- **Basic Cash Memo Generator**:
  - Calculation of consultation fee and remedy fee.
  - Cash vs. UPI indicator.
  - PDF receipt generation via `pdf` and `printing` packages.
- **Design Tokens & Theme Foundation**:
  - Centralized design system in `tokens.dart` and `app_theme.dart` (Emerald/Teal Material 3 palette).
  - Automated compliance test forbidding hardcoded color values.

### 1.3 Schema Definition (`schemaVersion: 1 – 4`)
- `Patients`: `id` (UUID text), `patientCode` (indexed text), `name`, `phone`, `age`, `gender`, `area`, `createdAt`.
- `Visits`: `id`, `patientId` (FK), `visitDate`, `complaint`, `notes`, `nextFollowUpDate`.
- `CashMemos`: `id`, `patientId`, `visitId`, `amount`, `paymentMethod` (Cash, UPI), `createdAt`.

### 1.4 Acceptance Criteria (Verified)
- [x] App operates with 0ms network latency when device is in Airplane Mode.
- [x] Patient search across 2,000 dummy records executes in < 150ms.
- [x] Zero hardcoded colors outside design tokens.
- [x] Test suite passing with 100% coverage on core formatters and math utilities.

---

## Milestone 2 (M2): Multi-Clinic Scoping & Financial Analytics
**Status**: 🔄 In Progress (`v0.5.0` – `v0.7.0`)  
**Core Objective**: Enable multi-clinic tenancy, location-specific expense tracking, true net profit calculation, and end-of-day cash reconciliation.

### 2.1 Clinical Context & Problem Solved
Doctors like Dr. Zaid rotate across two or three evening clinics on alternate days (e.g. Babu Bazar @ ₹3,000/mo rent vs. Kidderpore High Road @ ₹8,000/mo rent). Traditional software aggregates all finances into one bucket, hiding whether a branch clinic is profitable or losing money. M2 isolates every financial transaction by physical location.

### 2.2 Features in Development
- **Multi-Clinic Tenancy Engine**:
  - Top-bar active clinic selector with distinct color identification.
  - Complete data scoping: Patients, queues, visits, memos, and expenses strictly filtered by `activeClinicId`.
- **Granular Expense Tracker**:
  - Category tagging: Clinic Rent, Electricity, Staff / Attendant Tips, Disposables/Bottles, Courier, Miscellaneous.
  - Quick-log expense bottom sheet callable from anywhere in the app in 2 taps.
- **Clinic Growth & Comparative Analytics**:
  - Side-by-side performance cards: Clinic A vs. Clinic B.
  - True Net Profit calculation:
    $$\text{Net Profit} = \text{Gross Collections} - (\text{Operating Expenses} + \text{Daily Accrued Rent} + \text{Medicine COGS})$$
  - Footfall composition metrics: New Registrations vs. Returning Follow-ups.
- **End-of-Day Financial Reconciliation**:
  - Closing summary screen reconciling drawer cash vs. UPI digital transfers.
  - Daily closing report exportable via WhatsApp or PDF.

### 2.3 Schema Definition (`schemaVersion: 5 – 10`)
- `Clinics`: `id`, `name`, `address`, `phone`, `monthlyRent`, `defaultConsultationFee`, `openDays`, `colorHex`, `isActive`.
- `Expenses`: `id`, `clinicId` (FK), `amount`, `category`, `description`, `expenseDate`, `paymentMode`.
- `CashMemos`: Added `clinicId` foreign key and multi-item line breakdown (`consultationCharge`, `medicineCharge`, `discount`).

### 2.4 Acceptance Criteria (Definition of Done)
- [ ] Switching active clinic instantly updates all dashboard metrics and patient rosters without app restart.
- [ ] Daily net profit accurately subtracts fractional monthly rent (e.g. `monthlyRent / openDaysCount`).
- [ ] Financial ledger allows exporting date-filtered CSV of collections and expenses.
- [ ] Migration tests verify that pre-existing single-clinic memos gracefully assign to the primary clinic without data loss.

---

## Milestone 3 (M3): 17-Section Homeopathic Case Taking & Repertory Engine
**Status**: 📋 Planned (`v0.8.0`)  
**Core Objective**: Provide a rapid, structured 17-section classical homeopathic case interrogation engine with on-device rubric lookup and totality scoring.

### 3.1 Clinical Context & Problem Solved
Homeopathic case taking requires evaluating mental temperament, thermal reactions, physical generals, and miasmatic background. Generic clinic apps provide only a free-text notes box, forcing doctors back to paper diaries. M3 equips the doctor with a sub-3-minute digital case sheet tailored to Kentian, Boenninghausen, and Boger repertorial methodologies.

### 3.2 Planned Capabilities
- **17-Section Master Case Sheet Architecture**:
  1. *Patient Identification & Demographics*
  2. *Chief Complaints (Location, Sensation, Modality, Concomitants)*
  3. *History of Present Illness (Chronological evolution)*
  4. *Past Medical History & Suppressions*
  5. *Family Medical History & Hereditary Diathesis*
  6. *Developmental & Milestones History (Pediatric)*
  7. *Physical Generals (Thermal: Chilly/Hot, Weather affinities, Appetite, Thirst)*
  8. *Physical Generals: Desires, Aversions & Intolerances*
  9. *Physical Generals: Sleep, Dreams & Positions*
  10. *Mental Generals, Disposition & Mind (Fears, Anxiety, Consolation, Mood)*
  11. *Menstrual & Obstetric History (Female)*
  12. *Clinical Examination & Vitals (Pulse, BP, Tongue, Pallor)*
  13. *Miasmatic Analysis (Psoric, Sycotic, Syphilitic, Tubercular triage)*
  14. *Case Totality & Synthesis*
  15. *Clinical & Differential Diagnosis*
  16. *Prescription & Posology Plan (Remedy, Potency, Vehicle, Repetition)*
  17. *Follow-Up Assessment & Prognostic Evaluation (Hering's Law)*
- **High-Speed On-Device Repertory Search**:
  - Offline FTS5 search across standardized homeopathic rubrics.
  - Multi-rubric pinning to active case with automatic remedy totality grading.
- **Longitudinal Complaint Progression Tracker**:
  - Baseline symptom severity vs. follow-up progress chips (`Cured`, `Better >50%`, `Same`, `Worse`).
- **One-Tap Posology Presets**:
  - Scales: Centesimal (`30C`, `200C`, `1M`), Decimal (`6X`, `12X`), 50-Millesimal (`LM 0/1` – `LM 0/30`).
  - Vehicles: Cane Sugar Globules (#20/#30), Sugar of Milk powders, Mother Tincture drops.

### 3.3 Schema Definition (`schemaVersion: 11 – 15`)
- `PatientCaseRecords`: `id`, `patientId`, `clinicId`, `recordDate`, `caseDataJson` (synthesized 17-section model), `totalityScoreJson`, `isActive`.
- `Complaints`: `id`, `caseId`, `complaint`, `location`, `sensation`, `modalities`, `severity`, `duration`.
- `Prescriptions`: `id`, `caseId`, `visitId`, `remedyName`, `potency`, `scale`, `vehicle`, `dosage`, `durationDays`.

### 3.4 Acceptance Criteria
- [ ] Doctor can complete and save an acute case record in < 90 seconds.
- [ ] Chronic case sheet supports saving partial sections without mandatory field errors.
- [ ] Repertory search returns matching rubrics in < 100ms.
- [ ] Historical case sheets render in a clean, printable PDF with doctor letterhead.

---

## Milestone 4 (M4): Pharmacy Inventory & Automated Dispensing
**Status**: 📋 Planned (`v0.8.5`)  
**Core Objective**: Track chamber medicine stock, automate single-tap dispensing deductions, alert on low inventory, and calculate inventory cost-of-goods-sold (COGS).

### 4.1 Clinical Context & Problem Solved
Unlike allopathic doctors who write external prescriptions for pharmacies, solo homeopaths dispense remedies directly from their chamber shelves. Stockouts of key remedies (e.g. *Arnica 200C* or *Nux Vomica 30C*) stall consultations, while expired mother tinctures lead to wasted capital. M4 turns dispensing into an automatic, background inventory transaction.

### 4.2 Planned Capabilities
- **Medicine Catalog & Formulary**:
  - Master catalog of 600+ homeopathic single remedies, mother tinctures, and biochemic combinations.
  - Multi-potency tracking: Each remedy tracks stock levels across distinct potencies and forms (e.g. *Sulphur* tracked separately under `30C 100ml`, `200C 30ml`, and `1M 1 dram`).
- **Single-Tap Automated Dispensing**:
  - Selecting a remedy on the prescription screen automatically checks and decrements the corresponding chamber inventory.
  - Option to flag unmedicated blank vehicles (Globules, Lactose sugar) consumed per visit.
- **Stock Alerts & Reorder Level Engine**:
  - Visual amber/red warning badges when volume falls below doctor-defined threshold (e.g. < 15ml remaining).
  - One-tap "Purchase Reorder List" generated for medicine wholesalers.
- **Barcode & Label Integration**:
  - Quick camera barcode scanning to add incoming wholesale stock batches.
  - Generation of ESC/POS mini thermal stickers for dispensed medicine vials.

### 4.3 Schema Definition (`schemaVersion: 16 – 18`)
- `Medicines`: `id`, `brand`, `name`, `potency`, `form` (Dilution, Mother Tincture, Trituration), `currentStock`, `reorderLevel`, `unit` (ml, dram, gm), `expiryDate`, `costPrice`, `retailPrice`.
- `InventoryTransactions`: `id`, `medicineId` (FK), `clinicId` (FK), `type` (Purchase, Dispensed, Wastage, Adjustment), `quantity`, `referenceId` (CashMemo / Prescription ID), `timestamp`.

### 4.4 Acceptance Criteria
- [ ] Prescribing a remedy decrements stock immediately without navigating away from the clinical encounter.
- [ ] Low-stock banner lists all depleted remedies grouped by manufacturer/wholesaler.
- [ ] Daily closing report reflects accurate estimated Cost of Goods Sold (COGS).

---

## Milestone 5 (M5): Encrypted Local Backup & Selective P2P Sync
**Status**: 📋 Planned (`v0.9.0`)  
**Core Objective**: Provide zero-server-cost encrypted cloud backup, exportable disaster recovery containers, and peer-to-peer Wi-Fi synchronization across doctor devices.

### 5.1 Clinical Context & Problem Solved
Doctors fear losing their phone or having it damaged, which would erase years of clinical histories. However, storing patient data on third-party cloud servers introduces recurring subscription costs and violates patient confidentiality under data privacy laws (e.g. India's DPDP Act). M5 delivers military-grade backup directly to the doctor's personal storage with ₹0 server overhead.

### 5.2 Planned Capabilities
- **Zero-Knowledge Encrypted Backup Container (`.cpbak`)**:
  - Full SQLite database + media attachments packed into a compressed archive.
  - Hardware-accelerated AES-GCM 256-bit encryption salted with doctor’s master passphrase.
- **Doctor-Owned Cloud Backup (Google Drive AppData)**:
  - Direct integration with Google Drive AppData API using doctor's personal Google account.
  - Automated midnight backup schedule when phone is charging and on Wi-Fi.
  - Vendor never sees or hosts clinical data; zero monthly server bill for developer or doctor.
- **Local Peer-to-Peer (P2P) Wi-Fi Sync**:
  - Synchronize clinical records between doctor’s mobile phone and consultation desk laptop/tablet over local clinic Wi-Fi.
  - Conflict-Free Replicated Data Type (CRDT) or timestamped revision resolution.
- **Full Data Portability Export**:
  - One-tap export to standardized SQLite, CSV, and clinical PDF dossiers.

### 5.3 Technical Implementation
- AES-256 GCM authenticated encryption via `cryptography` Dart package.
- Streamed chunk-based backup generation to prevent out-of-memory errors on low-tier mobile devices.
- SHA-256 integrity checksum verification prior to restoring backup containers.

### 5.4 Acceptance Criteria
- [ ] `.cpbak` archive cannot be decrypted or inspected without the exact master passphrase.
- [ ] Restoring backup on a new device fully recovers all patients, clinics, cases, and financial records.
- [ ] App operates seamlessly without internet; Google Drive sync fails gracefully with clear status indicator.

---

## Milestone 6+ / v1.0: Production Readiness, Thermal Printing & Multi-Platform
**Status**: 🚀 Future Roadmap (`v1.0.0+`)  
**Core Objective**: Polish ClinicPilot into a commercially hardened, multi-platform desktop/tablet practice operating system ready for broad public distribution.

### 6.1 Planned Capabilities
- **ESC/POS Wireless Thermal Printing**:
  - Direct Bluetooth / USB connectivity to 58mm and 80mm thermal receipt and label printers.
  - Clean typographic layout for cash memos, clinic tokens, and medicine bottle stickers.
- **Modular Specialty Switcher (Expanding Beyond Homeopathy)**:
  - Settings switch allowing the doctor to toggle clinical engines:
    - *Homeopathy*: 17-Section Case Record + Repertory.
    - *General Allopathic / Polyclinic*: Standard **SOAP Notes** (Subjective, Objective, Assessment, Plan) + Vital Signs Charting.
    - *Dental Practice*: Interactive 32-tooth odontogram chart (FDI / Universal numbering).
- **Practice Growth Hub & Attribution Intelligence**:
  - Camp ROI Engine: Track 30/60/90-day patient revenue generated per community health camp.
  - Chemist & Referral Partner CRM: Attribution of patient flow to local pharmacies and diagnostic labs.
  - 1-Tap Google Review accelerator for satisfied patients.
- **Multi-Platform Desktop Optimization**:
  - Native Flutter builds for Windows, macOS, and Linux.
  - Keyboard-first shortcuts for rapid desktop chamber data entry (`Ctrl+N` new patient, `Ctrl+Enter` save bill).
- **Public Play Store & App Store Distribution**:
  - Google Play Store production release with signed Android App Bundle (AAB).
  - Micro-tier freemium monetization (core app free forever; ₹199/month for cloud sync and branded letterhead PDF).

---

## Roadmap Capability Matrix

| Feature Area | M1 (Foundations) | M2 (Finances) | M3 (Clinical) | M4 (Inventory) | M5 (Sync/Backup) | M6+ (v1.0 GA) |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Offline SQLite Database** | ✅ Core | ✅ Tenancy | ✅ Case JSON | ✅ Stock Ledger | ✅ Encrypted | ✅ Multi-device |
| **Patient Management** | ✅ Fast search | ✅ Clinic scoped | ✅ Case link | ✅ Rx History | ✅ Portability | ✅ Portal Export |
| **Finances & Billing** | Basic Memo | ✅ P&L per clinic | Fee Presets | Auto-pricing | Cloud audit | Thermal Print |
| **Case Taking & Notes** | Basic text | Simple visits | ✅ 17-Section | Rx linkage | Encrypted files | SOAP / Dental |
| **Repertory & Posology** | ❌ | ❌ | ✅ Kent/Boenning | Stock check | ❌ | AI Modality (Opt) |
| **Inventory & Pharmacy** | ❌ | ❌ | ❌ | ✅ Full Catalog | Batch backup | Barcode scanner |
| **Cloud / Backup** | ❌ | Manual CSV | ❌ | ❌ | ✅ GDrive / P2P | Background Sync |
| **Growth Intelligence** | ❌ | Basic counts | ❌ | ❌ | ❌ | ✅ Camp / Review |
