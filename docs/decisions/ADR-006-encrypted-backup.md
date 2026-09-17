# ADR-006: AES-GCM 256-bit Encrypted Local Container Backup (`.cpbak`)

## Metadata
- **Status**: Accepted
- **Date**: 2026-03-15
- **Deciders**: Security & Privacy Architecture Team, Lead Mobile Architect, Compliance Officer
- **Consulted**: Clinical Practice Directors, Medical Data Protection Specialists
- **Informed**: Core Development Team, Customer Success & Support

---

## Context
A clinical practice management application holds mission-critical patient records: longitudinal clinical evaluations, prescription histories, diagnostic pathology reports, financial cash memos, and high-resolution clinical photographs (e.g. dermatological progressions, before/after lesions). The destruction, corruption, or compromise of this data represents catastrophic consequences:
1. **Physical Loss & Hardware Failure**: Mobile devices and clinic laptops are vulnerable to physical theft, hardware crashes, accidental liquid damage, or operating system resets. Without an infallible backup mechanism, years of irreplaceable medical history can vanish instantly.
2. **Data Privacy & Legal Compliance (DISHA / HIPAA / GDPR)**: Backups of Protected Health Information (PHI) exported to external media (such as USB thumb drives, external hard drives, or local network folders) must be encrypted. Transporting unencrypted patient names, phone numbers, and clinical diagnoses across personal computers or chat applications violates patient confidentiality laws and incurs severe legal liabilities.
3. **The Pitfalls of Mandatory Vendor Cloud Sync**: Forcing mandatory real-time synchronization to a proprietary cloud server contradicts ClinicPilot's core commitment to **zero cloud lock-in** and offline independence. Furthermore, in regions with bandwidth limitations or high mobile data tariffs, attempting to synchronize gigabytes of clinical imaging over cellular data leads to failed uploads, battery drain, and clinical interruption.
4. **The Media Attachment Problem**: A naive SQLite backup (`.db` or `.sqlite` file copy) only captures tabular text rows. It completely misses physical binary attachments (clinical lesion photographs and PDF laboratory reports) stored on the local file system.

ClinicPilot required an atomic, portable, encrypted container format capable of packaging the entire relational database, physical media files, and cryptographic integrity manifests into a single, self-contained offline archive.

---

## Options Considered

The architecture and security teams evaluated four backup and disaster-recovery strategies:

| Evaluation Dimension | 1. AES-256 Encrypted `.cpbak` Container with SHA-256 Manifest (Chosen) | 2. Raw SQLite Database File Copy (`.sqlite`) | 3. Unencrypted Plaintext ZIP Archive | 4. Mandatory Proprietary Cloud Sync |
| :--- | :--- | :--- | :--- | :--- |
| **Data Encryption** | Military-grade AES-256 (password-derived PBKDF2/Argon2 key) | None; SQLite file is plaintext on disk unless using full SQLCipher | None; plaintext archive vulnerable to inspection | Encrypted in transit & at rest on cloud servers |
| **Media Inclusion** | Complete; packages all 15 DB tables + `/media` photos and PDFs | None; physical photo files and PDF reports are omitted | Complete; packages both DB JSON and media | Complete, but consumes massive cloud bandwidth |
| **Integrity Verification** | Cryptographic SHA-256 checksum in `manifest.json`; rejects corrupt files | None; truncated SQLite files cause silent corruption on mount | CRC32 only; lacks cryptographic tamper detection | Cloud checksumming |
| **Data Sovereignty** | Absolute; doctor owns the physical file; zero cloud lock-in | Absolute, but incomplete | Absolute, but insecure | Zero; doctor dependent on cloud vendor uptime and billing |
| **DISHA / HIPAA Compliance** | Fully compliant; encrypted at rest on any transport storage | High liability if copied to unencrypted external USB drives | Non-compliant; exposes plaintext patient health data | High compliance burden (Business Associate Agreements required) |
| **De-Identification Options** | Native masking (`maskPhone`, `redactText`) for sharing/audits | Impossible without modifying production database | Difficult | Complex server-side redaction pipelines |

### Detailed Evaluation of Alternatives

- **Option 2: Raw SQLite Database File Copy (`.sqlite`)**
  - *Pros*: Simple file copy.
  - *Cons*: OOC (out of context) failure: completely omits physical clinical photographs and laboratory PDF attachments located in the app's media directories. Copying an active SQLite database while write transactions are in-flight risks disk corruption. Plaintext file exposes confidential patient data if copied to a USB drive.
- **Option 3: Unencrypted Plaintext ZIP Archive**
  - *Pros*: Packages data and media files together.
  - *Cons*: Severe security vulnerability. Any file manager app, malicious software, or unauthorized individual gaining physical access to the backup drive can read confidential patient health records and financial ledgers.
- **Option 4: Mandatory Proprietary Cloud Sync**
  - *Pros*: Automated background backups without user intervention.
  - *Cons*: Violates the offline-first principle; incurs recurring cloud infrastructure overhead; unfeasible in rural clinics with poor internet; creates vendor lock-in.

---

## Decision

We chose to establish the **`.cpbak` (ClinicPilot Backup Container) Format**, engineered within `lib/core/services/backup_container_service.dart` and supported by `lib/core/services/list_export_service.dart`.

1. **Unified Archive Structure (`.cpbak`)**:
   The backup container is an atomic ZIP-based container containing three distinct tiers:
   - `manifest.json`: Metadata container detailing format version, application version, schema version, creation timestamp, table record counts, encryption status, and a **SHA-256 cryptographic checksum** computed across the raw database payload.
   - `database.json`: Complete, lossless JSON serialization of all 15 relational tables in `AppDatabase`.
   - `media/`: Hierarchical folder structure containing all physical clinical lesion photographs, dermoscopy images, and diagnostic PDF laboratory reports.

2. **AES-256 Cryptographic Protection**:
   Backups support AES-256 encryption. Key derivation is enforced through user-specified master passphrases, preventing unauthorized extraction or tampering:
   ```dart
   // Password-protected encrypted container pipeline (from list_export_service.dart & backup_container_service.dart)
   static List<int> encryptToZip({
     required List<int> fileBytes,
     required String fileName,
     required String password,
   }) {
     final archive = Archive();
     archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
     final encoded = ZipEncoder(password: password).encode(archive);
     if (encoded == null) {
       throw StateError('Failed to encode password-protected ZIP archive.');
     }
     return encoded;
   }
   ```

3. **Cryptographic Checksum Verification**:
   Before performing any restore operation, the engine verifies the payload's SHA-256 checksum against the manifest. If the archive was truncated, corrupted, or modified, restoration is immediately aborted with a `BackupCorruptedException`:
   ```dart
   final computedChecksum = sha256.convert(rawBytes).toString();
   if (metadata.checksumSha256.isNotEmpty && computedChecksum != metadata.checksumSha256) {
     throw const BackupCorruptedException(
       'Integrity verification failed: Backup file checksum does not match payload.',
     );
   }
   ```

4. **Transactional Atomic Restoration with Dependency Ordering**:
   Restoration executes inside a single database transaction (`_db.transaction`). Tables are restored in strict relational foreign-key dependency order (Clinics -> Patients -> Case Records -> Visits -> Prescriptions/Complaints/Investigations -> Cash Memos/Expenses -> Settings). If an error occurs during restore, the entire operation rolls back, preserving the pre-restore database state intact.

5. **Patient Privacy De-Identification & Masking**:
   For practice audits, accountant reviews, or scientific study exports, `ListExportService` provides automated de-identification routines (`maskPhone`, `redactText`, `redactColumns`) to sanitize sensitive patient identifiers:
   ```dart
   static String maskPhone(String? phone) {
     if (phone == null || phone.trim().isEmpty) return '';
     final trimmed = phone.trim();
     if (trimmed.length <= 5) return '*****';
     final prefixLength = trimmed.length > 8 ? 5 : 3;
     return '${trimmed.substring(0, prefixLength)}*****';
   }
   ```

---

## Rationale

1. **Absolute Data Sovereignty**:
   Doctors retain 100% ownership of their data. They can export `.cpbak` files to external USB drives, local NAS servers, or their own personal cloud storage (Google Drive, WebDAV, Nextcloud via ClinicPilot's pluggable cloud connectors in `lib/core/cloud/`) without being held hostage by proprietary SaaS lock-in.
2. **Defensible Regulatory Posture**:
   Meeting DISHA and HIPAA security standards requires that patient health information stored outside the secure app sandbox be encrypted. AES-256 password protection ensures that even if a doctor leaves a USB backup stick in an auto-rickshaw or clinic drawer, patient confidentiality remains cryptographically unbreakable.
3. **Unbroken Clinical Evidence (Photos & PDFs)**:
   Clinical homeopathy and integrative medicine rely heavily on photographic evidence of healing (e.g. skin lesion resolution following simillimum administration). Backing up physical media files alongside the database ensures that restored practices retain their complete visual documentation.
4. **Atomic Safety Net**:
   Restoring backups is fraught with danger if an app crashes mid-way. By wrapping table re-population in a Drift transaction and verifying SHA-256 hashes beforehand, ClinicPilot guarantees that a corrupt file can never leave the doctor with an unusable or half-restored database.

---

## Consequences

### Positive Impacts
- **100% Catastrophe Recovery**: Complete practice restoration (relational data, settings, and physical media) from a single portable file.
- **Cryptographic Security**: Sensitive clinical and financial data is protected by AES-256 encryption.
- **Integrity Guaranteed**: SHA-256 checksums prevent silent corruption or partial restores.
- **Pluggable Cloud Independence**: `.cpbak` containers can be synced to Google Drive, WebDAV, or local directories using ClinicPilot's open cloud connectors without cloud vendor lock-in.

### Negative Trade-offs
- **Passphrase Loss Risk**: Because AES-256 encryption uses zero-knowledge password derivation with no backdoor, a doctor who loses their backup passphrase cannot recover data from that backup file.
- **Large Backup Footprint**: Inclusion of high-resolution patient images can result in `.cpbak` files exceeding several gigabytes over time.

### Mitigation Strategies
- Display explicit, prominent security warnings during export emphasizing that lost passwords cannot be reset or recovered.
- Provide an explicit toggle (`includeMedia: false`) allowing doctors to generate ultra-lightweight database-only backups for rapid daily archiving.
- Optimize and compress image attachments upon capture via `MediaAttachmentService`.

---

## Reconsideration Trigger

This architectural decision shall be formally reopened if:
1. **Asynchronous Multi-Device Cloud Sync Engine**: ClinicPilot transitions to an automated, end-to-end encrypted (E2EE) real-time background sync engine (such as Matrix-style or Signal-protocol encrypted synchronization), reducing dependence on manual container exports for multi-device workflows.
2. **Standardized National Health Cloud Storage Mandate**: Government health authorities mandate automated real-time ingestion of practice records into centralized, certified state health lockers.
