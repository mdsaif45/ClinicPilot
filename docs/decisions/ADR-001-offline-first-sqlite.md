# ADR-001: Offline-First Persistence via Drift SQLite Engine

## Metadata
- **Status**: Accepted
- **Date**: 2026-03-10
- **Deciders**: Core Architecture Team, Lead Mobile Architect, Clinical Domain Lead
- **Consulted**: Regulatory Compliance Officer (DISHA/HIPAA), Senior Flutter Engineers
- **Informed**: Product Management, QA Engineering

---

## Context
ClinicPilot is a clinical practice management and electronic health record (EHR) application designed primarily for solo practitioners and multi-clinic doctors (specializing in homeopathy, general practice, and outpatient care). Clinical consultations in private clinics, tier-2/tier-3 cities, rural health camps, or basement consulting rooms occur in environments with unreliable, intermittent, or completely absent internet connectivity.

A doctor attending 30 to 50 patients per day operates under extreme time constraints (3 to 7 minutes per patient). The user interface cannot tolerate network request timeouts, offline latency spinners, authentication handshakes, or server downtime during vital operations such as:
1. Dispensing medications and checking drug stock balances.
2. Generating sequential tax/cash memos with strict GST compliance.
3. Capturing multi-section clinical case notes and baseline symptom totality.
4. Reviewing longitudinal patient visit history and past prescriptions.

Furthermore, medical practice records contain Protected Health Information (PHI/PSHI). Regulatory frameworks such as **DISHA (Digital Information Security in Healthcare Act - India)** and **HIPAA (Health Insurance Portability and Accountability Act - US)** mandate stringent requirements concerning data residency, processing transparency, and access control. Mandatory cloud tenancy exposes solo practitioners to data breach liabilities, third-party vendor sub-processor auditing complexities, and recurring subscription costs that impede adoption.

Therefore, ClinicPilot required an architectural foundation that guarantees 100% offline autonomy, sub-millisecond local query latencies, strict ACID relational integrity across 15 interconnected tables, and seamless long-term schema evolvability.

---

## Options Considered

The architecture team evaluated five persistence paradigms for Flutter:

| Criteria | 1. Drift + SQLite (Chosen) | 2. Realm (MongoDB) | 3. ObjectBox | 4. Hive / Isar | 5. Firebase Firestore |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Data Model** | Relational (SQL Tables, Foreign Keys, Indices) | Object Document Graph | Object-oriented NoSQL | Key-Value / Object store | Cloud NoSQL Document Store |
| **Offline Reliability** | Native 100% offline; direct disk I/O | Offline-first with sync capabilities | Native offline NoSQL | Native offline key-value | Online-first; local cache can desync/fail |
| **Relational Integrity** | Strict ACID; `PRAGMA foreign_keys = ON`; cascading constraints | Object links; soft constraints | Relations via IDs; weak constraint enforcement | None; manual ID management across boxes | None; requires Cloud Functions for consistency |
| **Complex Aggregations** | Rich SQL (`SUM`, `GROUP BY`, joins, window functions) | Limited query language; difficult multi-table joins | Fast object queries, but complex math requires memory load | Manual Dart iteration in memory | Costly read fan-outs; cloud aggregation queries |
| **Migration Toolchain** | Declarative `MigrationStrategy`, step-by-step SQL migrations, schema verification | Rigid schema migrations; schema versioning can break sync | Basic schema versioning; structural renames are brittle | Manual box transformation scripts; prone to corruption | Schema-less, but app code requires defensive handling |
| **Data Sovereignty** | Single open standard `.sqlite` file on device; zero cloud lock-in | Proprietary binary file format | Proprietary C++ binary engine | Proprietary binary format | Cloud-hosted; data resides on Google Cloud servers |
| **Compliance (DISHA/HIPAA)** | Fully local; doctor retains absolute ownership of database | Local storage compliant, but cloud sync incurs regulatory scope | Local storage compliant | Local storage compliant | High compliance burden; cross-border data transfer risks |

### Detailed Evaluation of Alternatives

- **Option 2: Realm (MongoDB)**
  - *Pros*: Extremely fast object access, elegant Dart model bindings.
  - *Cons*: Proprietary core engine, complicated licensing history, complex migrations when structural schemas diverge, and lack of standard external SQL tooling (e.g., SQLite Viewer, DBeaver) for independent database diagnosis or data recovery.
- **Option 3: ObjectBox**
  - *Pros*: Exceptional raw write speeds via C-level bindings.
  - *Cons*: Limited analytical capabilities for financial ledger math (e.g., month-over-month revenue, daily profit summaries, footfall breakdowns) requiring massive in-memory Dart filtering; proprietary storage format.
- **Option 4: Hive / Isar**
  - *Pros*: Pure Dart implementation, lightweight, zero native C-compilation friction.
  - *Cons*: Lacks foreign key constraints. In a clinical and billing system, deleting a patient without cascading checks could orphan visits, prescriptions, and cash memos. Index corruption during unexpected power cuts or app crashes has been documented in high-concurrency environments.
- **Option 5: Firebase Cloud Firestore**
  - *Pros*: Effortless multi-device cloud synchronization and authentication.
  - *Cons*: Latency during cold starts in poor connectivity; eventual consistency creates severe risks of duplicate receipt invoice numbering; violates offline-first guarantee; exposes doctor to ongoing cloud read/write billing.

---

## Decision

We chose **Drift (formerly Moor) over SQLite** as ClinicPilot’s primary persistence engine.

1. **Drift Type-Safe Abstraction**: Drift provides compile-time query verification, strongly typed table definitions, and auto-generated data classes (`app_database.g.dart`), eliminating runtime SQL syntax errors.
2. **Explicit Foreign Key Enforcement**: Enforce relational integrity at the SQLite driver layer via `PRAGMA foreign_keys = ON` executed in the `beforeOpen` lifecycle hook.
3. **Deterministic Incremental Migrations**: Implement all database upgrades through an explicit, versioned `MigrationStrategy.onUpgrade` switchboard (currently evolved through Schema Version 18 in `lib/core/database/app_database.dart`), utilizing idempotent helper routines such as `_addColumnIfMissing()`.
4. **Reactive State Integration**: Expose database queries via Drift reactive streams (`watch()`) directly bound to Flutter Riverpod providers, enabling instant UI reactivity when clinical entities mutate.
5. **Cross-Platform Compatibility**: Support native mobile platforms (Android/iOS) and desktop (Windows/macOS/Linux) via `package:sqlite3`, while maintaining Web compatibility via WASM SQLite (`sqlite3.wasm` and web worker bridges in `lib/core/database/connection/web.dart`).

---

## Rationale

1. **Mission-Critical ACID Ledger Integrity**:
   A clinical consultation is an atomic financial and medical event: saving an encounter generates a `Visit`, mutates inventory in `Medicines`, creates `Complaints`, records `Prescriptions`, and registers a `CashMemo`. Drift wraps this operation in a single database transaction (`_db.transaction(...)`). If any component fails (e.g. invalid drug ID or constraint violation), the entire transaction rolls back cleanly, guaranteeing zero orphaned clinical records.

2. **Complex Financial and Analytical SQL**:
   ClinicPilot delivers immediate business analytics (daily gross revenue, net profit after expenses, active clinic comparison, disease distributions, repeat patient retention). SQLite executes aggregate SQL queries (`SUM(paid_amount)`, `COUNT(DISTINCT patient_id)`) across tens of thousands of records in under 3 milliseconds, avoiding expensive in-memory Dart collection operations.

3. **Absolute Data Sovereignty & Regulatory Posture**:
   Under DISHA and HIPAA, storing patient data exclusively within an encrypted, sandboxed local SQLite file ensures that the doctor retains 100% legal ownership and physical possession of clinical data. No patient identifying information is transmitted to third-party cloud servers without explicit user-driven backup action.

4. **Robust Schema Evolution Lifecycle**:
   As ClinicPilot grew from an early clinic register (v1) to a full EHR with 15 tables (v18), Drift’s migration toolchain ensured zero data loss across real-world upgrades:
   ```dart
   // Example from lib/core/database/app_database.dart
   MigrationStrategy get migration => MigrationStrategy(
     onCreate: (Migrator m) async {
       await m.createAll();
       await _seedSettings();
       await _createIndices();
       await _createPatientSerialIndex();
     },
     onUpgrade: (Migrator m, int from, int to) async {
       if (from < 2) { /* Table additions & legacy backfills */ }
       if (from < 15) { /* Clinical baseline & image attachment columns */ }
       if (from < 17) { /* GST tax rates & invoicing columns */ }
       if (from < 18) { /* Barcode scanning column */ }
     },
     beforeOpen: (details) async {
       await customStatement('PRAGMA foreign_keys = ON');
     },
   );
   ```

---

## Consequences

### Positive Impacts
- **Zero Latency**: UI interaction is instantaneous (sub-5ms response time) regardless of cell reception or airplane mode.
- **Zero Cloud Infrastructure Cost**: Doctors incur no monthly server fees or database licensing costs to operate their practice.
- **Auditable & Recoverable**: The database is a single standard file (`app_database.sqlite`) accessible via standard forensic and inspection tools if physical recovery is ever required.
- **Deterministic Testing**: Fast, in-memory SQLite instances (`NativeDatabase.memory()`) execute the entire 90+ test suite in seconds without network mocking.

### Negative Trade-offs
- **Manual Sync Architecture**: Multi-device real-time collaboration across separate physical devices (e.g., reception desk and doctor laptop) is not provided natively and requires explicit backup/restore or peer synchronization.
- **Code Generation Overhead**: Schema modifications require running `dart run build_runner build` to regenerate Dart companion models and table mappings.
- **Web Platform Complexity**: Running SQLite in modern browsers requires WebAssembly (`sqlite3.wasm`) and SharedArrayBuffer web worker configurations.

### Mitigation Strategies
- Provide an encrypted, atomic backup and restore engine (`.cpbak` container via `BackupContainerService`) that allows seamless database migration between devices.
- Maintain pre-compiled Drift outputs checked into version control for CI speed, enforcing build cleanliness in PR gates.
- Isolate connection implementations cleanly under `lib/core/database/connection/` with conditional compilation (`native.dart` vs. `web.dart`).

---

## Reconsideration Trigger

This architectural decision shall be formally reopened if:
1. **Multi-Terminal Real-Time Concurrency**: ClinicPilot expands to hospital-scale multi-user environments where 5+ clinicians and receptionists concurrently mutate the same practice records over a local Wi-Fi LAN, demanding an embedded multi-master replication engine (such as CRDT-enabled SQLite via `cr-sqlite` / `ElectricSQL` or an embedded client-server architecture).
2. **Regulatory Mandate for Centralized Health Cloud**: National digital health authorities (such as India's ABDM / Ayushman Bharat Digital Mission) mandate persistent real-time cloud endpoint synchronization for all licensed EHR software, rendering purely local persistence insufficient as the sole data store.
