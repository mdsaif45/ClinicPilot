# ADR-005: Active Clinic Tenancy Scoping & Cross-Clinic Aggregation in a Single Local Database

## Metadata
- **Status**: Accepted
- **Date**: 2026-03-14
- **Deciders**: Platform Architecture Team, Lead Data Architect, Practice Operations Lead
- **Consulted**: Multi-Practice Clinicians, Accounting & GST Advisors
- **Informed**: Mobile Engineers, QA Test Leads

---

## Context
A significant proportion of outpatient medical practitioners—particularly in private practice across India and developing economies—operate across multiple physical consultation centers:
- A doctor may practice at **Clinic A (Morning OPD)** in the city center and **Clinic B (Evening OPD)** in a residential suburb.
- Clinicians frequently conduct weekly or monthly **Charitable Rural Health Camps** as distinct operational units.
- Individual clinics carry distinct overhead structures: different commercial rents, separate reception staff, distinct drug dispensing inventories, and unique tax identifiers (**GSTIN**).

### Operational Tenancy Requirements
1. **Strict Operational Isolation**:
   During active consultations at Clinic A, the doctor’s interface must be strictly scoped to Clinic A:
   - Daily patient queues and appointments must reflect Clinic A attendees.
   - Drug dispensing must decrement stock from Clinic A’s inventory shelf, not Clinic B’s.
   - Cash memos, receipts, and invoices must print Clinic A’s header, address, phone number, and GSTIN.
   - Clinic expenses (rent, electricity, assistant salary) must be booked against the appropriate facility.
2. **Consolidated Practice Intelligence**:
   From a financial and regulatory perspective, the doctor is a single professional entity. The software must deliver:
   - Consolidated total revenue and net practice earnings across all branches.
   - Consolidated GST tax liabilities for annual tax filings.
   - Comparative performance analytics (**Clinic Comparison**): contrasting footfall conversion rates, average revenue per patient, and profitability between Clinic A and Clinic B.
3. **Cross-Facility Patient Mobility**:
   A patient first registered at Clinic A may experience an acute symptom exacerbation and attend Clinic B. The doctor requires instant access to the patient's longitudinal case history and past prescriptions without cumbersome account switching or manual data exporting.

---

## Options Considered

The architecture team evaluated three tenancy isolation architectures:

| Evaluation Dimension | 1. Single DB + Row-Level Tenancy & Reactive Provider Scoping (Chosen) | 2. Multi-Database Architecture (Isolated SQLite DB Per Clinic) | 3. Cloud-Hosted Multi-Tenant Isolation |
| :--- | :--- | :--- | :--- |
| **Operational Isolation** | Strong; enforced at repository and Riverpod provider layer | Absolute physical file-level partition | High; enforced by database server security policies |
| **Consolidated Analytics** | Instant; standard SQL `GROUP BY clinic_id` across tables | Extremely difficult; requires complex SQLite `ATTACH DATABASE` or in-memory merging | Good, but requires cloud network round-trips |
| **Switching Latency** | Sub-millisecond; reactive state update in Riverpod | High (1-3 seconds); closing DB connection, reloading engine, rebuilding state | Dependent on network connection latency |
| **Patient Mobility** | Seamless; unified patient record with multi-clinic visit history | Fragmented; duplicate patient records across isolated database files | Seamless, but subject to internet connectivity |
| **Backup Simplicity** | Single unified `.cpbak` archive covers the entire medical practice | Multiple disparate database files requiring fragmented backups | Cloud backup; high recurring cost |
| **Offline Independence** | 100% offline; direct local disk I/O | 100% offline | Completely broken during offline clinical sessions |

### Detailed Evaluation of Alternatives

- **Option 2: Multi-Database Architecture (Separate SQLite Database per Clinic)**
  - *Pros*: Guarantees zero risk of cross-clinic data leakage at the file system level.
  - *Cons*: Prevents consolidated practice analytics. Generating a year-end practice tax report requires opening, querying, and merging multiple disparate databases. If a patient visits a second clinic branch, the doctor cannot view their prior medical history without manually exporting and importing records. Switching active clinics requires closing SQLite handles and re-initializing the entire app state.
- **Option 3: Cloud-Hosted Multi-Tenant Isolation**
  - *Pros*: Industry-standard SaaS model using schema or row-level security (RLS).
  - *Cons*: Violates the core offline-first mandate of ClinicPilot. Clinics in rural areas or basement suites cannot tolerate internet dependency for daily consultations.

---

## Decision

We chose a **Single Unified Local Database with Row-Level `clinic_id` Tenancy and Reactive Provider Scoping**.

1. **Relational Schema Partitioning**:
   Every operational, transactional, and inventory table in `AppDatabase` includes an explicit foreign key column referencing `Clinics.id`:
   - `Visits.clinicId`
   - `CashMemos.clinicId`
   - `Expenses.clinicId`
   - `Footfalls.clinicId`
   - `Camps.clinicId`
   - `Medicines.clinicId`
   - `Patients.primaryClinicId` (Patients are globally accessible across the practice, linked primarily to their originating clinic).

2. **Reactive Active Clinic Notifier (`lib/features/clinics/providers/clinic_provider.dart`)**:
   The active clinic state is maintained in Riverpod via `ActiveClinicIdNotifier`, persisting the active selection to the SQLite `Settings` table (`active_clinic_id`):
   ```dart
   class ActiveClinicIdNotifier extends StateNotifier<String?> {
     final AppDatabase _db;
     ActiveClinicIdNotifier(this._db) : super(null) {
       _loadFromSettings();
     }
     Future<void> setClinicId(String newId) async {
       state = newId;
       await _db.into(_db.settings).insertOnConflictUpdate(
         SettingsCompanion.insert(
           key: 'active_clinic_id',
           value: newId,
           updatedAt: Value(DateTime.now()),
         ),
       );
     }
   }
   ```

3. **Provider-Level Scoping for Daily Transactions**:
   Transactional providers (e.g., `dashboardStatsProvider`, `inventoryListProvider`, `cashMemosProvider`) watch `activeClinicIdProvider`. When `activeClinicId` mutates:
   - Transactional views automatically filter database queries by the selected clinic.
   - In-progress consultations automatically bind newly inserted rows (`visits`, `prescriptions`, `cashMemos`) to the active clinic ID.

4. **Dedicated Cross-Clinic Aggregation Layer**:
   Analytical screens (such as `ClinicComparisonScreen`, `ProfitSummaryScreen`, and `FinancesScreen`) explicitly bypass single-clinic filters, executing aggregate SQL queries across all clinics to provide:
   - Side-by-side revenue and patient volume comparisons.
   - Consolidated practice profit and loss statements.
   - Universal inventory valuation across all practice locations.

---

## Rationale

1. **Instantaneous Clinic Switching Without App Restart**:
   Toggling the `ClinicSwitcher` in the application top-bar instantaneously notifies Riverpod listeners. The UI updates its data streams in sub-milliseconds without closing database files, unmounting the navigation shell, or causing screen flickers.
2. **Longitudinal Care Continuity Across Facilities**:
   Patients belong to the doctor's practice rather than a single physical building. A patient registered at Clinic A who presents at Clinic B retains their unified medical record, past prescriptions, and diagnostic reports, ensuring safe clinical continuity without duplicate records.
3. **Automated Tax and Operational Accounting**:
   Solo practitioners file a single unified income tax return but must manage individual clinic rent, electricity, and local staff payroll. A single database allows instant consolidation of all business income and expenses while preserving accurate cost accounting per clinic location.
4. **Resilient Onboarding and Migration**:
   During the v1 to v2 database upgrade, legacy single-clinic databases were smoothly migrated into multi-clinic schemas via automatic assignment to `clinic_old` and `clinic_new` placeholders (`_seedClinics()` in `lib/core/database/app_database.dart`), preserving 100% of historical patient data.

---

## Consequences

### Positive Impacts
- **Zero-Latency Switching**: Switching clinics in the UI occurs in real-time with zero database teardown cost.
- **Holistic Practice Visibility**: Doctors gain immediate comparative insights into which clinic location generates superior margins, patient loyalty, and footfall conversions.
- **Unified Inventory Tracking**: Multi-clinic doctors can monitor stock balances across branches and balance medicine inventory before ordering new batches.
- **Streamlined Backup & Restore**: A single `.cpbak` backup file archives all clinic branches atomically, eliminating partial sync or fragmented state risks.

### Negative Trade-offs
- **Risk of Developer Omission**: If a developer forgets to apply the `clinicId.equals(activeClinicId)` filter in a transactional query, rows from another clinic could inadvertently be displayed.
- **Patient Code Collisions**: Multiple clinics sharing paper registers could encounter register serial number collisions.

### Mitigation Strategies
- Enforce unique compound indices in SQLite: `UNIQUE(clinic_id, serial_no)` in `lib/core/database/app_database.dart` guarantees that serial numbers never collide within a single clinic.
- Standardize query wrappers and repository helpers that mandate clinic parameters.
- Provide comprehensive automated tests (e.g. `clinic_health_score_test.dart`, `dashboard_daily_navigation_test.dart`) validating tenancy isolation under concurrent clinic fixtures.

---

## Reconsideration Trigger

This architectural decision shall be formally reopened if:
1. **Independent Multi-Doctor Partnership Tenancy**: ClinicPilot expands to support multi-doctor group practices where legal agreements require cryptographic or physical data isolation preventing Dr. X from accessing Dr. Y's patient records in a shared clinic facility.
2. **Cloud-Synchronized Multi-Branch Enterprise Scaling**: The platform introduces distributed enterprise synchronization where clinic branches operate independent edge servers with selective cloud reconciliation.
