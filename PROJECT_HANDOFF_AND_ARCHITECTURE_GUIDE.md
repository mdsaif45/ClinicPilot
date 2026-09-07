# ClinicPilot: Master Project Handoff & Architecture Guide

> **Confidential & Comprehensive Engineering Handoff Document**  
> **Target Audience:** Next Senior AI Coding Agent / Platform Refactoring Team  
> **Codebase:** `mdsaif45/ClinicPilot`  
> **Technology Stack:** Flutter (SDK ^3.7.2), Dart, Drift ORM (SQLite / SQLCipher, Schema v16), Flutter Riverpod (v2.5.1), GoRouter (v13.2.0), AES-GCM / PBKDF2 Cryptography.  
> **Status:** Production-grade MVP / Private Beta, 450+ automated unit & widget tests passing, 0 analyzer warnings, 100% theme compliance.

---

## Table of Contents
1. [Platform Mission & Architectural Philosophy](#1-platform-mission--architectural-philosophy)
2. [Evolutionary Journey, Earlier Mistakes & Course Corrections](#2-evolutionary-journey-earlier-mistakes--course-corrections)
3. [Milestones Completed to Date (Milestones 1–7)](#3-milestones-completed-to-date-milestones-17)
4. [Master File-by-File Inventory](#4-master-file-by-file-inventory)
   - [4.1 Project Root & Configuration](#41-project-root--configuration)
   - [4.2 Core Architecture (`lib/core/`)](#42-core-architecture-libcore)
     - [Cloud Storage & Sync (`core/cloud/`)](#cloud-storage--sync-corecloud)
     - [Database & Drift Tables (`core/database/`)](#database--drift-tables-coredatabase)
     - [Design Tokens & Breakpoints (`core/design/`)](#design-tokens--breakpoints-coredesign)
     - [Entitlement & Pro Licensing (`core/entitlement/`)](#entitlement--pro-licensing-coreentitlement)
     - [Core Providers (`core/providers/`)](#core-providers-coreproviders)
     - [App Routing (`core/router/`)](#app-routing-corerouter)
     - [Services & Cryptography (`core/services/`)](#services--cryptography-coreservices)
     - [Theme (`core/theme/`)](#theme-coretheme)
     - [Utilities & Validators (`core/utils/`)](#utilities--validators-coreutils)
     - [Reusable Design System Widgets (`core/widgets/`)](#reusable-design-system-widgets-corewidgets)
   - [4.3 Feature Modules (`lib/features/`)](#43-feature-modules-libfeatures)
     - [Activity & Practice Journal (`features/activity/`)](#activity--practice-journal-featuresactivity)
     - [Cash Memo & Dispensing Billing (`features/cashmemo/`)](#cash-memo--dispensing-billing-featurescashmemo)
     - [Clinical Case Sheets, Odontogram & SOAP (`features/clinical/`)](#clinical-case-sheets-odontogram--soap-featuresclinical)
     - [Clinics & Multi-Location (`features/clinics/`)](#clinics--multi-location-featuresclinics)
     - [Dashboard & Executive Overview (`features/dashboard/`)](#dashboard--executive-overview-featuresdashboard)
     - [Expenses & Outflow (`features/expenses/`)](#expenses--outflow-featuresexpenses)
     - [Finances & Cash Flow (`features/finances/`)](#finances--cash-flow-featuresfinances)
     - [Growth Hub, Referral CRM & Camps (`features/growth/`)](#growth-hub-referral-crm--camps-featuresgrowth)
     - [Medicine Inventory & Valuation (`features/inventory/`)](#medicine-inventory--valuation-featuresinventory)
     - [Onboarding & Setup (`features/onboarding/`)](#onboarding--setup-featuresonboarding)
     - [Patients, Footfalls & Recall (`features/patients/`)](#patients-footfalls--recall-featurespatients)
     - [Security, PIN & Privacy (`features/security/`)](#security-pin--privacy-featuressecurity)
     - [Settings, Cloud Backup & Upgrades (`features/settings/`)](#settings-cloud-backup--upgrades-featuressettings)
     - [Visits & Follow-Up Scheduling (`features/visits/`)](#visits--follow-up-scheduling-featuresvisits)
5. [Drift Database Schema & Migration Architecture (v16)](#5-drift-database-schema--migration-architecture-v16)
6. [State Management & Riverpod Data-Flow Rules](#6-state-management--riverpod-data-flow-rules)
7. [Strict Design System & Zero Hardcoded Color Compliance](#7-strict-design-system--zero-hardcoded-color-compliance)
8. [Data Privacy, DPDP 2023 & HIPAA Protection Standards](#8-data-privacy-dpdp-2023--hipaa-protection-standards)
9. [Testing Pipeline & Verification Matrix](#9-testing-pipeline--verification-matrix)
10. [Roadmap, Refactoring Targets & Next Agent Instructions](#10-roadmap-refactoring-targets--next-agent-instructions)

---

## 1. Platform Mission & Architectural Philosophy

ClinicPilot is an **offline-first practice intelligence platform** created for independent medical practitioners, polyclinics, homeopathic physicians, and dentists. The operating mantra is **"Know. Grow. Repeat."**

### Core Architectural Pillars
1. **Zero Cloud Lock-in / Local-First Sovereign Storage**:
   - All primary clinical and financial data lives in an on-device encrypted SQLite database (`app_database.sqlite`).
   - The app functions 100% offline. Network outages in semi-urban/rural clinics never interrupt patient consultation or dispensing.
2. **Pluggable Cloud Sync Without Centralized Hosting**:
   - Instead of maintaining an expensive, vulnerable centralized backend containing patient health data, ClinicPilot uses sovereign `.cpbak` encrypted backup containers.
   - Doctors connect their own Google Drive or WebDAV/Nextcloud storage. The app performs zero-knowledge client-side encryption (AES-256-GCM + PBKDF2) *before* data leaves the device.
3. **Multi-Clinic Native**:
   - Modern doctors in developing markets practice across multiple physical clinics (e.g. morning hospital OPD, evening private clinic). The platform allows instant clinic switching, partitioned billing, and comparative analytics.
4. **Strict Regulatory Compliance (DPDP Act 2023 & HIPAA)**:
   - Built-in phone number masking (`98****3210`), clinical notes redaction, and AES-256 encrypted ZIP exports to prevent data leaks on shared clinic front-desk computers.

---

## 2. Evolutionary Journey, Earlier Mistakes & Course Corrections

When refactoring or expanding this platform, understanding *why* previous implementations failed is essential.

### Mistake 1: Single-Clinic Assumption
- **Earlier Approach**: Initially, patients, visits, and cash memos were modeled as belonging to a single monolithic practice.
- **Why it failed**: Real-world doctors move between locations. Cash memos generated at Clinic A were appearing in Clinic B's daily cash register, making end-of-day accounting impossible.
- **Course Correction**: Added `clinics` table in Schema v2, linked `primaryClinicId` to patients, added `clinicId` to cash memos, expenses, and footfalls. Introduced `ClinicSwitcher`, `FinancesClinicFilterProvider`, and `ClinicComparisonScreen`.

### Mistake 2: Unstructured Visit Notes vs Specialized Medical Workflows
- **Earlier Approach**: Medical visits simply had a generic text column for `notes`.
- **Why it failed**: Doctors needed structured clinical records. Homeopaths require repertorization and symptom modalities; dentists require tooth-by-tooth odontograms (FDI two-digit notation); general practitioners require SOAP notes and vital signs (BP, Pulse, SpO2).
- **Course Correction**: Created `PatientCaseRecords`, `Complaints`, `Investigations`, `Prescriptions`, `OdontogramChartWidget` (Schema v12), and `SoapNoteScreen` (Schema v13).

### Mistake 3: Hardcoded Color Literals and Theme Drift
- **Earlier Approach**: Early UI screens had direct color calls such as `Colors.blue`, `Colors.green[600]`, and raw hex codes.
- **Why it failed**: It broke Dark Mode rendering, degraded accessibility, created jarring visual inconsistencies, and made rebranding difficult.
- **Course Correction**: Established `tokens.dart` (`Spacing`, `Radii`, `AppElevation`), `AppPalette`, and `AppTheme`. Built an automated CI gate (`test/theme_compliance_test.dart`) that inspects the AST and fails the build if any hardcoded color literal exists outside `core/theme/` and `core/design/`.

### Mistake 4: Unencrypted Plaintext Exports
- **Earlier Approach**: Exporting patient lists or cash registers generated raw, unencrypted `.csv` and `.xlsx` files straight to downloads.
- **Why it failed**: Violates India's Digital Personal Data Protection (DPDP) Act 2023 and HIPAA. If a receptionist exported files, unmasked patient mobile numbers and clinical conditions were exposed.
- **Course Correction**: Milestone 6 introduced `ListExportService.encryptToZip()`, `maskPhone()`, `redactText()`, and `ExportOptionsSheet` with explicit DPDP/HIPAA patient consent prompts.

### Mistake 5: Disconnected Inventory vs Cash Memo Billing
- **Earlier Approach**: Medicine stock tracking was separate from cash memo billing. Doctors had to enter a medicine fee manually in the cash memo, then open the inventory tab separately to deduct stock.
- **Why it failed**: High cognitive load and frequent inventory inaccuracies. Doctors forgot to adjust stock during busy clinic rush hours.
- **Course Correction**: Milestone 7 created `DispenseMedicinePickerSheet`, embedded direct inventory search and selection into `NewCashMemoDialog`, auto-calculated fees, appended dispensed remedies into memo notes, and atomically decremented stock in SQLite upon memo generation.

### Mistake 6: Monolithic File Bloat
- **Earlier Approach**: Initial iterations placed providers, data models, dialogs, and screens in single multi-thousand-line files.
- **Course Correction**: Strict modular feature-first separation:
  `features/<feature_name>/presentation/`, `presentation/widgets/`, `providers/`, and `models/`.

---

## 3. Milestones Completed to Date (Milestones 1–7)

1. **Milestone 1: Multi-Clinic Architecture & Financial Partitioning**:
   Multi-clinic creation, active clinic switching, clinic-filtered transaction history, and comparative clinic profitability analytics.
2. **Milestone 2: Patient Management, Smart Patient Picker & Recall CRM**:
   Full demographic tracking, serial numbers (`P-YYYY-NNNNN`), auto-linking primary clinic, smart search picker with debounce, and automated WhatsApp recall scheduling.
3. **Milestone 3: Clinical Case Sheet, Complaints, Investigations & Prescriptions**:
   Structured complaint logging, investigation attachments (photos, PDFs) with full-screen zoom, prescription generator, and branded PDF print engine.
4. **Milestone 4: Odontogram (Dental Chart) & SOAP Notes with Vital Signs**:
   Interactive 32-tooth odontogram with condition status (Caries, Missing, Filled, Crown, Extraction), and SOAP note authoring with vitals strip.
5. **Milestone 5: Medicine Inventory & Stock Valuation (Schema v15)**:
   Full in-clinic pharmacy inventory: stock tracking, low/out-of-stock badges, reorder thresholds, batch/expiry tracking, and total inventory valuation metrics.
6. **Milestone 6: Encrypted Export & DPDP/HIPAA Privacy Guard (Schema v16)**:
   Password-protected encrypted ZIP container export, telephone masking, diagnosis redaction, and compliance warnings.
7. **Milestone 7: Direct Medicine Dispensing & Stock Deduction in Cash Memos**:
   In-dialog inventory medicine picker, auto-filling medicine fees, and atomic inventory stock deduction upon cash memo issuance.

---

## 4. Master File-by-File Inventory

Every single file in `lib/` and the project root is cataloged below with its role, dependencies, and consumers.

### 4.1 Project Root & Configuration

| File Path | Purpose & What It Does | Where It Calls / Dependencies | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `pubspec.yaml` | Declares Flutter SDK version (^3.7.2), dependencies (drift, riverpod, go_router, fl_chart, pdf, etc.), assets, and metadata. | Flutter pub repository | Flutter tooling, CI/CD |
| `analysis_options.yaml` | Configures Dart analyzer rules, `flutter_lints`, strict type inference, and style rules. | `package:flutter_lints/flutter.yaml` | `flutter analyze`, IDE language server |
| `build.yaml` | Build runner configuration for Drift code generation (`app_database.g.dart`). | `drift_dev` | `dart run build_runner build` |
| `lib/main.dart` | Application entrypoint. Initializes Flutter bindings, Hive, SQLCipher/SQLite, initializes Riverpod `ProviderScope`, and boots `ClinicPilotApp`. | `AppRouter`, `AppTheme`, `SecurityProvider`, `DatabaseProvider` | Flutter engine |

---

### 4.2 Core Architecture (`lib/core/`)

#### Cloud Storage & Sync (`core/cloud/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/cloud/cloud_storage_connector.dart` | Abstract interface defining cloud storage capabilities: `upload()`, `download()`, `listFiles()`, `testConnection()`, and `getQuota()`. | Dart core, `dart:typed_data` | Implemented by `GoogleDriveConnector`, `WebDavConnector`, `FolderSyncConnector`. |
| `core/cloud/cloud_storage_registry.dart` | Service locator / registry managing available cloud backup connectors and active provider selection. | `CloudStorageConnector` | `CloudBackupScreen`, `PeriodicBackupRunner`. |
| `core/cloud/connectors/folder_sync_connector.dart` | Local filesystem / external SD-card / USB sync connector. | `dart:io`, `path_provider` | `CloudStorageRegistry`, `SettingsScreen`. |
| `core/cloud/connectors/google_drive_connector.dart` | Google Drive API connector using OAuth2 tokens and REST API v3 to upload and download encrypted `.cpbak` containers. | `package:http`, Google Drive API | `CloudStorageRegistry`, `CloudBackupScreen`. |
| `core/cloud/connectors/webdav_connector.dart` | WebDAV connector allowing sync to Nextcloud, ownCloud, or private NAS servers. | `package:http`, WebDAV protocol | `CloudStorageRegistry`, `CloudBackupScreen`. |

#### Database & Drift Tables (`core/database/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/database/app_database.dart` | The central type-safe database definition (Drift). Configures all 15 tables, Schema Version (v16), indices, and migration callbacks (`onUpgrade`). | Drift ORM, all table files in `tables/` | `DatabaseProvider`, all repositories and feature providers. |
| `core/database/app_database.g.dart` | Auto-generated Drift boilerplate containing companion classes, table dataclasses, and query parsers. | Generated by `drift_dev` | `AppDatabase`. |
| `core/database/database_provider.dart` | Riverpod provider exposing the singleton `AppDatabase` instance across the widget tree. | `AppDatabase`, `flutter_riverpod` | Consumed by every feature provider and controller. |
| `core/database/connection/connection.dart` | Conditional import router dispatching native vs web database connections. | `native.dart`, `web.dart` | `app_database.dart`. |
| `core/database/connection/native.dart` | Configures native SQLite / SQLCipher connection with WAL mode and foreign key pragmas. | `package:drift/native.dart`, `sqlite3` | `connection.dart`. |
| `core/database/connection/web.dart` | Configures WebAssembly / IndexedDB SQLite connection for browser environments. | `package:drift/wasm.dart` | `connection.dart`. |
| `core/database/tables/clinics.dart` | Drift table schema for `Clinics`: id, name, address, phone, default fee, monthly rent, open days, color hex, active/deleted flags. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/patients.dart` | Drift table schema for `Patients`: id, patient code (`P-YYYY-NNNNN`), name, phone, whatsapp, age, gender, primaryClinicId, primaryDisease, referralSource. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/visits.dart` | Drift table schema for `Visits`: id, patientId, clinicId, visitDate, reason, diagnosis, fee, followUpDate, notes. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/cash_memos.dart` | Drift table schema for `CashMemos`: id, memoNumber (`CM-YYYY-NNNNN`), patientId, clinicId, consultationFee, medicineFee, otherFee, discount, total, paidAmount, notes. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/expenses.dart` | Drift table schema for `Expenses`: id, clinicId, category, subcategory, amount, paymentMethod, expenseDate, isRecurring. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/settings.dart` | Drift table schema for key-value application settings: doctor profile, currency, security PIN, cloud sync configs. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/review_requests.dart` | Drift table schema for Google Review CRM tracking: patientId, clinicId, status, rating, sentiment. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/footfalls.dart` | Drift table schema for clinic daily visitor counts (inquiries, companions, walk-ins). | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/camps.dart` | Drift table schema for Medical Outreach Camps: name, location, date, footfall count, conversions, expenses. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/patient_case_records.dart` | Drift table schema for detailed clinical case records, timeline milestones, and clinical summaries. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/complaints.dart` | Drift table schema for patient symptoms, severity (1–10), onset, duration, modalities. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/prescriptions.dart` | Drift table schema for prescribed remedies: medicine name, potency, dosage, frequency, duration, instructions. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/investigations.dart` | Drift table schema for lab reports, pathology, imaging, attachments (file paths), values, and findings. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/referral_contacts.dart` | Drift table schema for referring physicians, pharmacies, and partners. | `package:drift/drift.dart` | `AppDatabase`. |
| `core/database/tables/medicines.dart` | Drift table schema for in-clinic pharmacy inventory: name, category, potency, form, currentStock, unit, reorderLevel, costPrice, sellingPrice, batch, expiry. | `package:drift/drift.dart` | `AppDatabase`. |

#### Design Tokens & Breakpoints (`core/design/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/design/app_palette.dart` | Defines brand color constants and semantic palettes for Light and Dark modes. | `dart:ui` | `AppTheme`. |
| `core/design/breakpoints.dart` | Responsive layout thresholds: mobile (<600px), tablet (600–1024px), desktop (>1024px). | Flutter core | Layout widgets, navigation rails, dialogs. |
| `core/design/tokens.dart` | Design tokens: `Spacing` (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32), `Radii`, `AppElevation`, `Durations`. | Flutter core | Used across all presentation UI files. |

#### Entitlement & Pro Licensing (`core/entitlement/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/entitlement/entitlement_model.dart` | Data class representing tier entitlements (Free vs Pro: multi-clinic limits, cloud sync, analytics). | Dart core | `EntitlementService`, `EntitlementProvider`. |
| `core/entitlement/entitlement_provider.dart` | Riverpod provider exposing current subscription/entitlement status. | `EntitlementService` | UI upgrade sheets, feature gates, Pro badges. |
| `core/entitlement/entitlement_service.dart` | Service checking license keys and entitlement verification. | Flutter Secure Storage, SharedPreferences | `EntitlementProvider`. |

#### Core Providers (`core/providers/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/providers/period_provider.dart` | StateProvider managing active reporting periods (Today, This Week, This Month, This Year, Custom Range). | Riverpod | Dashboard, Finances, Growth Hub, Practice Activity. |
| `core/providers/security_provider.dart` | StateNotifier managing app lock status, PIN validation, biometric auth, and session timeouts. | `SecurityService`, Riverpod | `LockScreen`, App lifecycle listener, Router guard. |

#### App Routing (`core/router/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/router/app_router.dart` | Declarative GoRouter configuration. Defines navigation shell, tab routing (Dashboard, Patients, Cash Memos, Finances, Growth, Settings), and security lock redirects. | `go_router`, all screen widgets, `SecurityProvider` | `main.dart`. |

#### Services & Cryptography (`core/services/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/services/app_haptics.dart` | Device haptic feedback wrapper (`selection()`, `success()`, `warning()`, `error()`). | `package:flutter/services.dart` | Buttons, dialog actions, bottom sheets. |
| `core/services/backup_container_service.dart` | Generates and restores sovereign `.cpbak` encrypted backup containers. Packs SQLite DB + media attachments into an encrypted payload using AES-256-GCM and PBKDF2. | `dart:io`, `package:archive`, `package:crypto` | `BackupRestoreScreen`, `CloudBackupScreen`, `PeriodicBackupRunner`. |
| `core/services/contact_service.dart` | Utility service for launching WhatsApp messages, phone calls, and SMS to patients with dynamic greeting templates. | `package:url_launcher` | Patient profile, recall list, review tracker. |
| `core/services/database_encryption_service.dart` | Generates and manages SQLCipher database encryption keys via hardware-backed Keystore/Keychain. | `package:flutter_secure_storage`, `package:crypto` | `connection/native.dart`. |
| `core/services/export_service.dart` | Base exporter service converting tabular clinical/financial records into CSV, XLSX, and JSON. | `package:excel`, `dart:convert` | `ExportAction`, `ExportFormatSheet`. |
| `core/services/import_service.dart` | Validates and imports legacy patient data from CSV/Excel spreadsheets with error reporting. | `package:excel`, Drift database | `ImportPreviewScreen`. |
| `core/services/import_template_service.dart` | Generates downloadable Excel templates for bulk patient import. | `package:excel` | `ImportPreviewScreen`. |
| `core/services/list_export_service.dart` | Advanced export service with DPDP 2023 / HIPAA privacy controls: phone masking, diagnosis redaction, and password-protected ZIP encryption. | `package:archive`, `package:crypto`, `package:excel` | All feature export sheets. |
| `core/services/list_pdf_export_service.dart` | Generates formatted printable PDF tables for financial statements, patient rosters, and inventory logs. | `package:pdf`, `package:printing` | `ExportOptionsSheet`, Financial reports. |
| `core/services/master_disease_service.dart` | Curated medical & homeopathic disease lookup service for ICD-10 and common clinical complaints. | In-memory disease registry | `DiseaseAutocompleteField`. |
| `core/services/media_attachment_service.dart` | Handles image picking, camera capture, thumbnail generation, and disk storage for clinical investigation files. | `package:image_picker`, `path_provider` | `AddEditInvestigationDialog`, `OdontogramChartWidget`. |
| `core/services/patient_export_service.dart` | Exports comprehensive patient clinical dossiers (case sheets, visits, prescriptions) into single PDF documents. | `package:pdf`, `package:printing` | `PatientProfileScreen`. |
| `core/services/pdf_service.dart` | Base PDF canvas engine, letterhead layout renderer, and font embedding. | `package:pdf`, `package:printing` | `PrescriptionPdfService`, `ListPdfExportService`. |
| `core/services/periodic_backup_runner.dart` | Background scheduler that checks daily/weekly backup schedules and triggers automated local/cloud `.cpbak` creation. | `BackupContainerService`, `CloudStorageRegistry` | `main.dart`, App lifecycle resume. |
| `core/services/prescription_pdf_service.dart` | Generates prescription slips with clinic branding, doctor registration number, Rx symbol, remedies table, and signature block. | `package:pdf`, `package:printing` | `PrescriptionPreviewDialog`. |
| `core/services/sample_data_seeder.dart` | Seeds sample clinic, patients, visits, cash memos, and inventory for testing or new user onboarding. | `AppDatabase`, `demo_data/*` | `OnboardingScreen`, Test harness. |
| `core/services/security_service.dart` | Manages PIN hashing (SHA-256 + salt), biometric authentication prompts, and auto-lock timeouts. | `package:local_auth`, `flutter_secure_storage` | `SecurityProvider`, `LockScreen`. |
| `core/services/update_service.dart` | Checks GitHub Releases API for new app versions and presents update notifications. | `package:http`, `package:package_info_plus` | `AppUpdateCard`, `AppVersionScreen`. |
| `core/services/demo_data/demo_crm_data.dart` | Hardcoded demo dataset for referral contacts and camps. | None | `SampleDataSeeder`. |
| `core/services/demo_data/demo_disease_archetypes.dart` | Hardcoded demo dataset for homeopathic remedies and disease profiles. | None | `SampleDataSeeder`. |
| `core/services/demo_data/demo_patient_roster.dart` | Hardcoded demo dataset for patients, visits, and cash memos. | None | `SampleDataSeeder`. |
| `core/services/file_saver/*` | Cross-platform file saving abstraction (`file_saver_io.dart` for Desktop/Mobile, `file_saver_web.dart` for Browser download blobs). | `dart:io`, `dart:html` | `ListExportService`, `BackupContainerService`. |

#### Theme (`core/theme/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/theme/app_theme.dart` | Builds ThemeData for Light and Dark modes. Configures `ColorScheme`, `TextTheme`, `CardTheme`, `InputDecorationTheme`, `AppBarTheme`. | `AppPalette`, `tokens.dart` | `main.dart`, `ThemeProvider`. |

#### Utilities & Validators (`core/utils/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `core/utils/date_input_formatter.dart` | `TextInputFormatter` enforcing `DD/MM/YYYY` date formatting with automatic slash insertions. | Flutter services | Date text fields. |
| `core/utils/formatters.dart` | Currency formatters (₹ / $), date-time formatters (Intl), and phone number formatters. | `package:intl` | Entire presentation layer. |
| `core/utils/id_generator.dart` | Cryptographically random unique ID generator for entity IDs. | `package:uuid` | All companion inserts. |
| `core/utils/validators.dart` | Form validation rules: phone number (10-digit), positive currency amounts, required strings. | Dart core | Form input dialogs. |

#### Reusable Design System Widgets (`core/widgets/`)

| File Path | Purpose & What It Does | Where It's Called From |
| :--- | :--- | :--- |
| `core/widgets/animated_counter.dart` | Animated numeric counter for dashboard metrics and cash sums. | `MetricCard`, `DashboardScreen`. |
| `core/widgets/animated_nav_icon.dart` | Smooth scale/bounce icon animation for bottom navigation. | `FloatingBottomNavBar`. |
| `core/widgets/app_button.dart` | Primary, secondary, outline, and destructive themed action buttons. | All dialogs and screens. |
| `core/widgets/app_card.dart` | Standard container card with subtle border and elevation. | Dashboard, profile, settings. |
| `core/widgets/app_confirm_dialog.dart` | Modal confirmation dialog for destructive actions (Delete, Wipe, Reset). | Delete patient, delete clinic, delete memo. |
| `core/widgets/app_form_dialog.dart` | Responsive modal wrapper for input forms. | Add/edit dialogs across features. |
| `core/widgets/app_list_tile.dart` | Standardized list item with leading icon, title, subtitle, and trailing badge. | Settings, patient list. |
| `core/widgets/chip_row.dart` | Horizontal scrolling chip filter bar. | Inventory categories, patient filters. |
| `core/widgets/choice_chip_field.dart` | Form field containing selectable choice chips. | Gender selection, payment methods. |
| `core/widgets/clinic_switcher.dart` | Header dropdown allowing instantaneous active clinic switching. | App bar on all primary tabs. |
| `core/widgets/content_rail.dart` | Responsive vertical navigation rail for Desktop / Tablet viewports. | `AppRouter` shell. |
| `core/widgets/custom_badge.dart` | Semantic pill badge for status (Active, Due, Low Stock, Caries). | Lists, tables, profile header. |
| `core/widgets/custom_text_field.dart` | Styled text input with floating label, prefix/suffix icons, and error display. | All forms and dialogs. |
| `core/widgets/date_field.dart` | Date picker field with native calendar modal and DD/MM/YYYY text input. | Visit forms, memo dialogs, expense forms. |
| `core/widgets/day_selector_field.dart` | Multi-select day-of-week picker for clinic operational days. | `AddEditClinicDialog`. |
| `core/widgets/disease_autocomplete_field.dart` | Autocomplete input searching master disease database. | Patient registration, visit diagnosis. |
| `core/widgets/document_attachment_gallery.dart` | Grid preview of attached patient medical reports with camera capture. | `AddEditInvestigationDialog`. |
| `core/widgets/empty_illustration.dart` | Vector SVG / Icon illustration for empty lists. | `EmptyState`. |
| `core/widgets/empty_state.dart` | Standard placeholder when search or list yields 0 records. | All list screens. |
| `core/widgets/entity_header.dart` | Prominent detail page header showing title, avatar, tags, and quick actions. | `PatientProfileScreen`. |
| `core/widgets/export_action.dart` | Standard export button triggering the DPDP/HIPAA export sheet. | App bar on all data tables. |
| `core/widgets/export_format_sheet.dart` | Modal bottom sheet letting users choose Excel, CSV, or PDF format. | `ExportAction`. |
| `core/widgets/floating_bottom_nav_bar.dart` | Floating bottom navigation bar with icons and badges. | Mobile scaffold shell. |
| `core/widgets/full_screen_image_viewer.dart` | Interactive zoomable viewer for medical scans and clinical photos. | Investigation attachments, dental scans. |
| `core/widgets/image_comparison_gallery.dart` | Before/After side-by-side comparison viewer for dermatology and dental cases. | Clinical case records. |
| `core/widgets/info_row.dart` | Key-value display row for detail cards. | Transaction details, patient profile. |
| `core/widgets/metric_card.dart` | Dashboard metric card showing icon, number, trend percentage, and subtitle. | Dashboard, Finances, Growth Hub. |
| `core/widgets/metric_strip.dart` | Horizontal scrollable or wrapped row of metric cards. | Financial overview, inventory metrics. |
| `core/widgets/money_text.dart` | Themed currency text rendering ₹ symbol with superscript decimals. | Cash memos, finances, invoices. |
| `core/widgets/period_selector.dart` | Segmented button or dropdown toggling Today, This Week, Month, Year. | Dashboard, Finances, Reports. |
| `core/widgets/picker_field.dart` | Read-only input field that opens a selection sheet or modal on tap. | Patient picker, clinic picker. |
| `core/widgets/pro_badge.dart` | Small badge demarcating Pro-tier features. | Settings, analytics features. |
| `core/widgets/remedy_autocomplete_field.dart` | Autocomplete input searching remedies and potencies. | Prescription dialog, inventory dialog. |
| `core/widgets/section_header.dart` | Standardized section header with title, icon, and optional trailing action. | Settings, patient profile sections. |
| `core/widgets/section_switch.dart` | Settings switch tile with icon, title, description, and toggle. | Appearance, security settings. |
| `core/widgets/segmented_tabs.dart` | Pill-style segmented control for switching sub-views. | Clinical tabs, patient profile tabs. |
| `core/widgets/shimmer_loading.dart` | Skeleton loading placeholder while streams are awaiting data. | Patient list, transaction list. |
| `core/widgets/stat_card.dart` | Compact statistical tile for secondary metrics. | Clinic comparison, health score. |
| `core/widgets/swipeable_sections.dart` | Horizontal page view allowing swipe transitions between tabs. | Patient profile sections. |
| `core/widgets/whatsapp_template_picker.dart` | Bottom sheet for selecting pre-composed WhatsApp message templates. | Patient profile, recall screen. |

---

### 4.3 Feature Modules (`lib/features/`)

#### Activity & Practice Journal (`features/activity/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/practice_activity_screen.dart` | Primary screen displaying clinic activity ring, hourly rush, and weekly benchmarks. | `PracticeActivityProvider`, activity chart widgets | App router (`/activity`). |
| `presentation/practice_journal_screen.dart` | Chronological audit feed of all clinic actions (patient visited, memo issued, expense paid). | `PracticeJournalProvider`, `ActivityJournalFeed` | Practice activity tab. |
| `presentation/widgets/activity_journal_feed.dart` | Scrollable timeline feed of clinic events. | `JournalItemDetailSheet` | `PracticeJournalScreen`. |
| `presentation/widgets/double_activity_ring.dart` | Circular activity ring visualizing patient goal progress vs financial goal progress. | `package:fl_chart` | `PracticeActivityScreen`. |
| `presentation/widgets/hourly_rush_chart.dart` | Bar chart showing peak patient check-in hours to optimize clinic staffing. | `package:fl_chart` | `PracticeActivityScreen`. |
| `presentation/widgets/journal_item_detail_sheet.dart` | Detail modal for a specific activity item showing full audit metadata. | Core design tokens | `ActivityJournalFeed`. |
| `presentation/widgets/monthly_bubble_matrix.dart` | Heatmap bubble matrix of clinic footfalls across days of the month. | Custom painter | `PracticeActivityScreen`. |
| `presentation/widgets/weekly_benchmark_chart.dart` | Bar chart comparing this week's patient volume against previous weeks. | `package:fl_chart` | `PracticeActivityScreen`. |
| `providers/practice_activity_provider.dart` | Computes hourly rush metrics, activity ring scores, and weekly performance trends. | `AppDatabase`, `DatabaseProvider` | Activity screens and widgets. |
| `providers/practice_journal_provider.dart` | Aggregates visits, cash memos, and expenses into a unified reactive stream of journal entries. | `AppDatabase`, `DatabaseProvider` | `PracticeJournalScreen`. |

#### Cash Memo & Dispensing Billing (`features/cashmemo/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/cash_memo_screen.dart` | Main list screen for cash memos with search, date range filter, summary chips, and export. | `CashMemoProvider`, `NewCashMemoDialog`, `ReceiptPreviewDialog` | App router (`/cashmemos`). |
| `presentation/new_cash_memo_dialog.dart` | Creation dialog for cash memos. Features direct inventory dispensing, auto-calculated medicine fees, discount calculations, and atomic stock deduction. | `CashMemoProvider`, `InventoryProvider`, `DispenseMedicinePickerSheet` | `CashMemoScreen`, `PatientProfileScreen`. |
| `presentation/edit_cash_memo_dialog.dart` | Dialog for modifying an existing cash memo (adjusting fees, discount, or payment method). | `CashMemoProvider` | `CashMemoScreen`. |
| `presentation/receipt_preview_dialog.dart` | Formatted receipt preview with print and PDF sharing capabilities. | `PdfService`, `printing` | `CashMemoScreen`. |
| `presentation/widgets/dispense_medicine_picker_sheet.dart` | Bottom sheet modal allowing clinicians to search inventory, select remedies, adjust quantities, and return dispensed items. | `InventoryProvider`, `tokens.dart` | `NewCashMemoDialog`. |
| `providers/cash_memo_provider.dart` | Riverpod `CashMemoNotifier` and streams for creating, updating, soft-deleting, and querying cash memos. Generates sequential IDs (`CM-YYYY-NNNNN`). | `AppDatabase`, `DatabaseProvider` | Cash memo presentation layer. |

#### Clinical Case Sheets, Odontogram & SOAP (`features/clinical/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `models/case_record_models.dart` | Plain Dart models for structured clinical observations, physical generals, and modalities. | Dart core | Clinical providers and screens. |
| `models/dental_chart_model.dart` | Model representing tooth condition state (Tooth ID 11–48, condition enum, notes). | Dart core | `OdontogramChartWidget`, `DentalChartScreen`. |
| `models/investigation_templates.dart` | Built-in lab test templates (CBC, Lipid Profile, Thyroid, Urine Routine). | Dart core | `AddEditInvestigationDialog`. |
| `models/soap_note_model.dart` | Model representing Subjective, Objective, Assessment, and Plan data + vital signs. | Dart core | `SoapNoteScreen`. |
| `presentation/clinical_case_sheet_screen.dart` | Primary clinical workstation screen displaying patient history, complaints, investigations, and prescriptions. | Clinical providers, `ComplaintListView`, `PrescriptionListView` | `PatientProfileScreen`, App router. |
| `presentation/dental_chart_screen.dart` | Specialized dental odontogram screen for oral health examinations and procedures. | `OdontogramChartWidget`, `ToothConditionSheet` | `ClinicalCaseSheetScreen`. |
| `presentation/master_case_taking_screen.dart` | In-depth classical homeopathic case taking screen (mind, thermal state, miasmatic analysis). | Case record providers | `ClinicalCaseSheetScreen`. |
| `presentation/soap_note_screen.dart` | Dedicated SOAP note authoring screen with vitals input strip. | Case record providers, `VitalSignsCard` | `ClinicalCaseSheetScreen`. |
| `presentation/add_edit_complaint_dialog.dart` | Dialog to log or update patient symptoms, severity scale, and modalities. | `ComplaintProvider` | `ComplaintListView`. |
| `presentation/add_edit_investigation_dialog.dart` | Dialog to record lab tests, reference ranges, and attach report photos/PDFs. | `InvestigationProvider`, `MediaAttachmentService` | `InvestigationListView`. |
| `presentation/add_edit_prescription_dialog.dart` | Dialog to prescribe medicines with auto-complete remedies, potencies, and instructions. | `PrescriptionProvider`, `RemedyAutocompleteField` | `PrescriptionListView`. |
| `presentation/prescription_preview_dialog.dart` | High-fidelity preview of printable clinic prescription slip. | `PrescriptionPdfService`, `printing` | `ClinicalCaseSheetScreen`. |
| `presentation/widgets/complaint_list_view.dart` | Card list of active and resolved patient complaints. | `ComplaintProvider` | `ClinicalCaseSheetScreen`. |
| `presentation/widgets/investigation_list_view.dart` | Card list of lab investigations with document attachment thumbnails. | `InvestigationProvider` | `ClinicalCaseSheetScreen`. |
| `presentation/widgets/prescription_list_view.dart` | Formatted table of prescribed remedies with dosage instructions. | `PrescriptionProvider` | `ClinicalCaseSheetScreen`. |
| `presentation/widgets/odontogram_chart_widget.dart` | Interactive 32-tooth interactive graphic supporting adult & pediatric FDI dental notation. | `DentalChartModel`, `ToothConditionSheet` | `DentalChartScreen`. |
| `presentation/widgets/tooth_condition_sheet.dart` | Action sheet to mark tooth condition (Caries, Missing, Filled, Crown, Root Canal). | `DentalChartModel` | `OdontogramChartWidget`. |
| `presentation/widgets/vital_signs_card.dart` | Compact widget displaying BP, Pulse, Temperature, SpO2, and Weight. | Core design tokens | `SoapNoteScreen`, Case sheets. |
| `providers/case_record_provider.dart` | Riverpod providers managing master case records, milestones, and timeline entries. | `AppDatabase`, `DatabaseProvider` | Clinical screens. |
| `providers/complaint_provider.dart` | Riverpod controller and streams for managing patient complaint records. | `AppDatabase`, `DatabaseProvider` | Complaint widgets and screens. |
| `providers/investigation_provider.dart` | Riverpod controller and streams for managing lab investigation orders and reports. | `AppDatabase`, `DatabaseProvider` | Investigation widgets and screens. |
| `providers/prescription_provider.dart` | Riverpod controller and streams for managing prescription items. | `AppDatabase`, `DatabaseProvider` | Prescription widgets and screens. |

#### Clinics & Multi-Location (`features/clinics/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/clinics_screen.dart` | Management screen listing all configured clinic locations with rent, open days, and active status. | `ClinicProvider`, `AddEditClinicDialog` | Settings tab, App router. |
| `presentation/add_edit_clinic_dialog.dart` | Form dialog to create or edit a clinic location (name, address, default consultation fee, color). | `ClinicProvider`, `DaySelectorField` | `ClinicsScreen`. |
| `providers/clinic_provider.dart` | Riverpod state notifiers and stream providers for clinic CRUD, active clinic state, and fee lookups. | `AppDatabase`, `DatabaseProvider` | Consumed across the entire application. |

#### Dashboard & Executive Overview (`features/dashboard/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/dashboard_screen.dart` | Main landing hub. Displays active clinic overview, today's footfall, revenue, pending dues, quick actions, and insights. | `DashboardProvider`, `PeriodProvider`, `MetricCard`, `ClinicSwitcher` | App router (`/dashboard`). |
| `presentation/widgets/clinic_health_score_card.dart` | Widget showing 0–100 operational health score based on revenue consistency and recall rate. | `HealthScoreProvider` | `DashboardScreen`. |
| `presentation/widgets/daily_insight_card.dart` | AI/rule-based clinical practice insight (e.g. "30% jump in respiratory cases this week"). | `DailyInsightProvider` | `DashboardScreen`. |
| `presentation/widgets/goal_tracker_card.dart` | Visual progress bar toward monthly patient and revenue goals. | `DashboardProvider` | `DashboardScreen`. |
| `presentation/widgets/notification_center_sheet.dart` | Bottom sheet displaying alerts for pending follow-ups, low stock, and expiring medicines. | Core providers | `DashboardScreen`. |
| `providers/dashboard_provider.dart` | Computes dashboard aggregate metrics (total footfalls, money collected, dues, active patients). | `AppDatabase`, `DatabaseProvider` | `DashboardScreen`. |

#### Expenses & Outflow (`features/expenses/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/expenses_screen.dart` | List screen for tracking clinic overheads (Rent, Utilities, Staff, Supplies). | `ExpenseProvider`, `AddExpenseDialog` | Finances sub-tab. |
| `presentation/add_expense_dialog.dart` | Dialog to log an expense with category, subcategory, payment method, and recurring flag. | `ExpenseProvider`, `DateField` | `ExpensesScreen`. |
| `presentation/edit_expense_dialog.dart` | Dialog to edit an existing expense record. | `ExpenseProvider` | `ExpensesScreen`. |
| `providers/expense_provider.dart` | Riverpod controller and streams for managing clinic expenses. | `AppDatabase`, `DatabaseProvider` | Expense screens. |

#### Finances & Cash Flow (`features/finances/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/finances_screen.dart` | Central financial cockpit with tabs for Money Received, Money Spent, Statements, and Payment Methods. | Financial providers, `ClinicFilterPill` | App router (`/finances`). |
| `presentation/money_received_screen.dart` | Ledger of all incoming cash memo payments and pending due balances. | `TransactionHistoryProvider` | `FinancesScreen`. |
| `presentation/money_spent_screen.dart` | Ledger of all outgoing clinic expenditures and supplier payouts. | `ExpenseProvider` | `FinancesScreen`. |
| `presentation/monthly_statement_screen.dart` | Monthly P&L breakdown showing Gross Revenue, Expenses, Net Profit, and Tax estimates. | `MonthlyStatementProvider`, `ListPdfExportService` | `FinancesScreen`. |
| `presentation/payment_method_breakdown_screen.dart` | Pie chart showing distribution across Cash, UPI, Card, and Bank Transfer. | `PaymentMethodBreakdownProvider`, `fl_chart` | `FinancesScreen`. |
| `presentation/sort_by_bottom_sheet.dart` | Modal to sort transactions by Date, Amount, or Patient Name. | Core design tokens | Financial ledger screens. |
| `presentation/transaction_detail_screen.dart` | Comprehensive audit view of a single financial transaction. | `AppDatabase` | Ledger screens. |
| `presentation/transaction_history_screen.dart` | Combined transaction history feed merging memos and expenses. | `TransactionHistoryProvider` | `FinancesScreen`. |
| `presentation/widgets/finances_clinic_filter_pill.dart` | Clinic selector pill specifically filtering financial ledgers. | `FinancesClinicFilterProvider` | `FinancesScreen`. |
| `providers/finances_clinic_filter_provider.dart` | StateProvider maintaining the active clinic filter for financial queries. | Riverpod | Financial screens and providers. |
| `providers/monthly_statement_provider.dart` | Computes monthly P&L figures, rent allocations, and profit margins. | `AppDatabase`, `DatabaseProvider` | `MonthlyStatementScreen`. |
| `providers/payment_method_breakdown_provider.dart` | Groups transaction volume by payment instrument for charting. | `AppDatabase`, `DatabaseProvider` | `PaymentMethodBreakdownScreen`. |
| `providers/transaction_history_provider.dart` | Streams unified transactions matching period and clinic filters. | `AppDatabase`, `DatabaseProvider` | Financial ledger screens. |

#### Growth Hub, Referral CRM & Camps (`features/growth/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/growth_hub_screen.dart` | Master growth cockpit with quick access to CRM, Camps, Reviews, and Analytics. | Growth providers | App router (`/growth`). |
| `presentation/growth_screen.dart` | Detailed growth screen with trend visualizations and patient acquisition funnels. | `GrowthProvider`, `fl_chart` | Growth hub. |
| `presentation/camp_manager_screen.dart` | Community outreach camp tracker: registrations, screenings, and conversions. | `CampProvider`, `AddEditCampDialog` | Growth hub. |
| `presentation/add_edit_camp_dialog.dart` | Dialog to schedule or record a free medical camp. | `CampProvider` | `CampManagerScreen`. |
| `presentation/clinic_comparison_screen.dart` | Side-by-side comparative analytics across multiple clinic branches. | `ClinicComparisonProvider` | Growth hub. |
| `presentation/disease_analytics_screen.dart` | Epidemiological breakdown showing top diseases treated, cure rates, and trends. | `DiseaseAnalyticsProvider`, `fl_chart` | Growth hub. |
| `presentation/profit_summary_screen.dart` | Executive profit margin analysis and break-even projections. | `ProfitProvider` | Growth hub. |
| `presentation/referral_crm_screen.dart` | Partner CRM tracking incoming referrals from doctors, labs, and patients. | `ReferralCrmProvider`, `AddEditReferralContactDialog` | Growth hub. |
| `presentation/referral_source_screen.dart` | Analysis of patient acquisition channels (Word of mouth, Google, Camps). | `ReferralProvider` | Growth hub. |
| `presentation/record_review_dialog.dart` | Dialog to log Google Review feedback and sentiment. | `ReviewProvider` | Growth hub. |
| `presentation/add_edit_referral_contact_dialog.dart` | Dialog to register or edit a referral partner contact. | `ReferralCrmProvider` | `ReferralCrmScreen`. |
| `providers/camp_provider.dart` | Riverpod controller and streams for managing medical outreach camps. | `AppDatabase`, `DatabaseProvider` | `CampManagerScreen`. |
| `providers/clinic_comparison_provider.dart` | Computes cross-branch revenue, patient volume, and margin differentials. | `AppDatabase`, `DatabaseProvider` | `ClinicComparisonScreen`. |
| `providers/daily_insight_provider.dart` | Analyzes recent clinic events to synthesize daily smart alerts. | `AppDatabase`, `DatabaseProvider` | `DailyInsightCard`. |
| `providers/disease_analytics_provider.dart` | Aggregates diagnosis records into frequency rankings and trends. | `AppDatabase`, `DatabaseProvider` | `DiseaseAnalyticsScreen`. |
| `providers/growth_provider.dart` | Computes patient retention rates, growth velocity, and acquisition trends. | `AppDatabase`, `DatabaseProvider` | `GrowthScreen`. |
| `providers/health_score_provider.dart` | Calculates composite practice health score (0–100). | `AppDatabase`, `DatabaseProvider` | `ClinicHealthScoreCard`. |
| `providers/profit_provider.dart` | Calculates net profit ratios and cost-per-patient metrics. | `AppDatabase`, `DatabaseProvider` | `ProfitSummaryScreen`. |
| `providers/referral_crm_provider.dart` | Manages referral contact registry and counts referred patients. | `AppDatabase`, `DatabaseProvider` | `ReferralCrmScreen`. |
| `providers/referral_provider.dart` | Computes referral channel breakdown. | `AppDatabase`, `DatabaseProvider` | `ReferralSourceScreen`. |
| `providers/review_provider.dart` | Manages review requests and tracks ratings. | `AppDatabase`, `DatabaseProvider` | Review dialogs. |

#### Medicine Inventory & Valuation (`features/inventory/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/inventory_screen.dart` | Primary pharmacy inventory management screen: search, category chips, stock badges, valuation metrics strip, and add/edit dialogs. | `InventoryProvider`, `AddEditMedicineDialog`, `ExportAction` | Settings > Practice Management, App router (`/inventory`). |
| `presentation/widgets/add_edit_medicine_dialog.dart` | Dialog to add a new remedy or edit stock, batch, expiry, unit, cost, and selling price. | `InventoryProvider`, `RemedyAutocompleteField` | `InventoryScreen`. |
| `providers/inventory_provider.dart` | Riverpod `InventoryController` (CRUD, `adjustStock()`) and streams (`inventoryStreamProvider`, `filteredInventoryProvider`, `inventoryValuationProvider`). | `AppDatabase`, `DatabaseProvider` | Inventory presentation, `NewCashMemoDialog`, `DispenseMedicinePickerSheet`. |

#### Onboarding & Setup (`features/onboarding/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/onboarding_screen.dart` | Multi-step welcome wizard: Doctor name, primary clinic setup, consultation fee, sample data option. | `OnboardingProvider`, `SampleDataSeeder` | App router (initial route if unconfigured). |
| `providers/onboarding_provider.dart` | Manages onboarding state and stores initial clinic configuration. | `AppDatabase`, `DatabaseProvider` | `OnboardingScreen`. |

#### Patients, Footfalls & Recall (`features/patients/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/patients_screen.dart` | Main patient directory with search, clinic filtering, patient cards, and add patient action. | `PatientProvider`, `AddPatientDialog`, `ExportAction` | App router (`/patients`). |
| `presentation/patients_tab_screen.dart` | Shell tab containing Patients, Footfalls, and Recall screens. | `SegmentedTabs` | App router. |
| `presentation/patient_profile_screen.dart` | Comprehensive 360-degree patient dossier: visits, case sheets, prescriptions, cash memos, dues, WhatsApp messaging. | `PatientProvider`, `ClinicalCaseSheetScreen`, `NewCashMemoDialog` | App router (`/patients/:id`). |
| `presentation/patient_picker.dart` | Searchable patient selection modal with instant creation option. | `PatientProvider` | `NewCashMemoDialog`, Visit dialogs. |
| `presentation/add_patient_dialog.dart` | Full patient registration form (Name, Phone, WhatsApp, Age, Gender, Clinic, Disease, Referral). Generates sequential `P-YYYY-NNNNN`. | `PatientProvider`, `DiseaseAutocompleteField` | `PatientsScreen`, `PatientPicker`. |
| `presentation/edit_patient_dialog.dart` | Dialog to edit patient demographics and contact details. | `PatientProvider` | `PatientProfileScreen`. |
| `presentation/footfalls_screen.dart` | Quick daily counter for clinic inquiries, walk-ins, and attendant visits. | `FootfallProvider`, `AddFootfallDialog` | `PatientsTabScreen`. |
| `presentation/add_footfall_dialog.dart` | Dialog to log visitor headcounts. | `FootfallProvider` | `FootfallsScreen`. |
| `presentation/recall_screen.dart` | Automated recall CRM: identifies overdue follow-ups, sends pre-formatted WhatsApp reminders. | `RecallProvider`, `ContactService` | `PatientsTabScreen`. |
| `providers/patient_provider.dart` | Riverpod `PatientNotifier` and streams for patient CRUD, patient search with debounce, and profile fetching. | `AppDatabase`, `DatabaseProvider` | Patient presentation layer. |
| `providers/footfall_provider.dart` | Riverpod controller and streams for clinic daily footfall counts. | `AppDatabase`, `DatabaseProvider` | `FootfallsScreen`. |
| `providers/recall_provider.dart` | Identifies patients whose scheduled follow-up date has arrived or lapsed. | `AppDatabase`, `DatabaseProvider` | `RecallScreen`. |

#### Security, PIN & Privacy (`features/security/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/lock_screen.dart` | PIN keypad and biometric authentication barrier shown when app is locked. | `SecurityProvider`, `AppHaptics` | `AppRouter` guard. |
| `presentation/pin_setup_dialog.dart` | Dialog to set up, change, or disable 4-digit security PIN. | `SecurityProvider` | `SecurityPrivacyScreen`. |
| `presentation/security_privacy_screen.dart` | Settings hub for app lock, biometric toggle, database encryption status, and data wiper. | `SecurityProvider`, `DatabaseEncryptionService` | Settings tab. |
| `presentation/security_settings_card.dart` | Summary security card embedded in main settings. | `SecurityProvider` | `SettingsScreen`. |

#### Settings, Cloud Backup & Upgrades (`features/settings/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/settings_screen.dart` | Central settings navigation menu: Profile, Clinics, Inventory, Backup, Security, Appearance, About. | Settings providers | App router (`/settings`). |
| `presentation/appearance_section.dart` | Theme selection (System, Light, Dark) and brand accent configuration. | `ThemeProvider` | `SettingsScreen`. |
| `presentation/doctor_profile_screen.dart` | Manages doctor credentials (Name, Degrees, Reg No, Letterhead header/footer, Signature image). | `DoctorProfileProvider` | `SettingsScreen`. |
| `presentation/backup_restore_screen.dart` | Sovereign backup hub: create local `.cpbak`, restore from file, inspect manifest, and view history. | `BackupContainerService`, `RestorePreviewDialog` | `SettingsScreen`. |
| `presentation/cloud_backup_screen.dart` | Google Drive / WebDAV cloud sync configuration and status. | `CloudStorageRegistry`, `BackupContainerService` | `SettingsScreen`. |
| `presentation/periodic_backups_screen.dart` | Configure automated daily/weekly backup schedules and retention rules. | `PeriodicBackupRunner` | `SettingsScreen`. |
| `presentation/restore_preview_dialog.dart` | Pre-restore inspection modal showing backup date, database size, and record counts before overwriting. | `BackupContainerService` | `BackupRestoreScreen`. |
| `presentation/import_preview_screen.dart` | Staging screen for reviewing Excel/CSV patient imports before database commit. | `ImportService`, `ImportTemplateService` | `SettingsScreen`. |
| `presentation/app_version_screen.dart` | About screen showing build number, commit hash, licenses, and update checks. | `UpdateProvider`, `ReleaseProvider` | `SettingsScreen`. |
| `presentation/app_update_card.dart` | Card notifying user when a new GitHub release is available. | `UpdateProvider` | `SettingsScreen`. |
| `presentation/widgets/pro_upgrade_sheet.dart` | Modal highlighting Pro-tier capabilities with payment/activation CTA. | `EntitlementProvider` | Feature gates. |
| `presentation/widgets/subscription_status_card.dart` | Card showing current active license tier and expiration. | `EntitlementProvider` | `SettingsScreen`. |
| `providers/doctor_profile_provider.dart` | Riverpod notifier managing doctor profile settings in the database. | `AppDatabase`, `DatabaseProvider` | `DoctorProfileScreen`. |
| `providers/theme_provider.dart` | StateNotifier managing ThemeMode (System, Light, Dark) persisted in settings. | `AppDatabase`, `DatabaseProvider` | `main.dart`, `AppearanceSection`. |
| `providers/update_provider.dart` | Checks for newer app versions via GitHub API. | `UpdateService` | Update cards and screens. |
| `providers/release_provider.dart` | Fetches release notes and changelogs. | `UpdateService` | `AppVersionScreen`. |

#### Visits & Follow-Up Scheduling (`features/visits/`)

| File Path | Purpose & What It Does | Where It Calls | Where It's Called From |
| :--- | :--- | :--- | :--- |
| `presentation/add_visit_dialog.dart` | Form dialog to log a clinic consultation (reason, diagnosis, fee, follow-up date). | `VisitProvider`, `DiseaseAutocompleteField` | `PatientProfileScreen`. |
| `presentation/schedule_follow_up_dialog.dart` | Quick dialog to schedule or update next appointment date with WhatsApp alert. | `VisitProvider`, `ContactService` | `PatientProfileScreen`. |
| `providers/visit_provider.dart` | Riverpod controller and streams for managing patient visit history. | `AppDatabase`, `DatabaseProvider` | Visit dialogs and timelines. |

---

## 5. Drift Database Schema & Migration Architecture (v16)

The persistent database is powered by **Drift ORM** (formerly Moor) targeting SQLite (with native SQLCipher encryption capability).

```
   +-------------------------------------------------------------+
   |                     AppDatabase (v16)                       |
   +-------------------------------------------------------------+
          |                  |                   |
          v                  v                   v
     +---------+       +------------+      +-----------+
     | Clinics |       |  Settings  |      | Medicines |
     +---------+       +------------+      +-----------+
          |
          | 1:N
          v
     +----------+ 1:N  +--------------------+ 1:N +--------------+
     | Patients |----->| PatientCaseRecords |---->| Complaints   |
     +----------+      +--------------------+     +--------------+
       |      |                  | 1:N            | Investigations
       |      |                  v                +--------------+
       |      |         +---------------+         | Prescriptions
       |      |         |  SOAP Notes   |         +--------------+
       |      |         +---------------+
       |      |                  | 1:N
       |      |                  v
       |      |         +---------------+
       |      |         | Dental Charts |
       |      |         +---------------+
       |      |
       | 1:N  | 1:N
       v      v
  +--------+ +-----------+
  | Visits | | CashMemos | (Auto-deducts stock from Medicines)
  +--------+ +-----------+
```

### Schema Migration History
- **v1**: Single-clinic prototype.
- **v2**: Multi-clinic architecture (`Clinics`, `Visits`, `Settings`, column backfills, patient-clinic migration).
- **v3**: Clinical case records (`PatientCaseRecords`, `Complaints`, `Prescriptions`, `Investigations`).
- **v4**: Google Review request tracking (`ReviewRequests`).
- **v5**: Walk-in visitor footfall logging (`Footfalls`).
- **v6**: Community outreach medical camps (`Camps`).
- **v7**: Referral partner directory (`ReferralContacts`).
- **v8**: Doctor letterhead branding and signature storage.
- **v9**: Teleconsultation / online clinic flags.
- **v10**: Deterministic sequential patient codes (`P-YYYY-NNNNN`) and memo numbering (`CM-YYYY-NNNNN`).
- **v11**: Lab investigation templates and file attachment paths.
- **v12**: Interactive odontogram JSON storage (adult & pediatric tooth charts).
- **v13**: SOAP clinical notes (Subjective, Objective, Assessment, Plan) + Vital signs strip.
- **v14**: Cloud backup connector configurations and sync timestamps.
- **v15**: In-clinic pharmacy inventory management (`Medicines` table: stock, batch, expiry, unit, cost, selling price).
- **v16**: DPDP/HIPAA encrypted export metadata and Cash Memo dispensed remedies notes summary.

> **CRITICAL RULE FOR FUTURE AGENTS:**  
> When modifying or adding tables, **NEVER** edit existing migration blocks in `app_database.dart`. Increment `schemaVersion` by 1, add an `if (from < N)` block in `migration.onUpgrade`, run `dart run build_runner build --delete-conflicting-outputs`, and write a migration test in `test/migration_test.dart`.

---

## 6. State Management & Riverpod Data-Flow Rules

1. **Unidirectional Reactive Flow**:
   - SQLite table mutations occur via Controller providers (`InventoryController`, `CashMemoNotifier`, `PatientNotifier`).
   - UI widgets observe reactive streams via StreamProviders (`inventoryStreamProvider`, `clinicsStreamProvider`, `patientListProvider`).
   - Mutations immediately trigger Drift table watchers, updating UI without manual refresh calls.
2. **Provider Scoping**:
   - Top-level `databaseProvider` provides the database instance.
   - Child providers depend explicitly on `databaseProvider`.
   - In unit tests, swap the database cleanly using:
     ```dart
     overrides: [databaseProvider.overrideWithValue(inMemoryDb)]
     ```
3. **Debounced Search**:
   - All search queries (`patientSearchQueryProvider`, `inventorySearchQueryProvider`) use debounced state updates to avoid unnecessary database queries on every keystroke.

---

## 7. Strict Design System & Zero Hardcoded Color Compliance

ClinicPilot enforces an automated design compliance rule:

```
                  ======================================
                  ZERO HARDCODED COLOR LITERALS IN UI
                  ======================================
```

- **Rule**: No widget inside `lib/features/` or `lib/core/widgets/` may call `Colors.xyz`, `Color(0x...)`, or `Colors.primaries`.
- **Allowed**: Only `Theme.of(context).colorScheme.xyz` and `Theme.of(context).textTheme.xyz` are permitted.
- **Tokens**: Spacing must strictly use `Spacing.xs`, `Spacing.sm`, `Spacing.md`, `Spacing.lg`, `Spacing.xl`, `Spacing.xxl` from `tokens.dart`.
- **Enforcement**: Running `flutter test test/theme_compliance_test.dart` checks all Dart files against an AST regex pattern. Any violation will immediately fail CI.

---

## 8. Data Privacy, DPDP 2023 & HIPAA Protection Standards

The platform handles Protected Health Information (PHI). Every export and backup mechanism adheres to:

1. **Local-First Zero-Knowledge**: No unencrypted health records are sent to third-party servers.
2. **Encrypted Container Format (`.cpbak`)**:
   - AES-256-GCM symmetric encryption.
   - PBKDF2 with HMAC-SHA256 (100,000 iterations) for key derivation from doctor passphrases.
   - Integrity checksums verified before restoring to prevent tampering.
3. **Data Protection & Privacy Guard**:
   - `ListExportService.maskPhone()`: Masks telephone numbers (`98****3210`) on exported lists.
   - `ListExportService.redactText()`: Redacts sensitive clinical findings when generating operational rosters.
   - `ListExportService.encryptToZip()`: Packages exported spreadsheets into password-protected encrypted ZIP archives.
   - Contextual DPDP 2023 / HIPAA consent sheets on all export triggers.

---

## 9. Testing Pipeline & Verification Matrix

The repository includes **75 test suites** and over **450 automated tests**.

```bash
# 1. Check Dart Code Formatting
dart format --output=none --set-exit-if-changed .

# 2. Run Static Analysis (Zero Warnings Permitted)
flutter analyze --no-fatal-infos

# 3. Run Design Compliance Verification
flutter test test/theme_compliance_test.dart

# 4. Run Full Regression Test Suite
flutter test
```

### Key Test Categories
- `test/theme_compliance_test.dart`: Enforces zero hardcoded colors across the codebase.
- `test/migration_test.dart`: Verifies sequential migrations from v1 through v16 without data corruption.
- `test/database_encryption_test.dart`: Verifies SQLCipher encryption keys and access rejection with invalid keys.
- `test/backup_container_service_test.dart`: Tests AES-GCM encryption, container packaging, and restore integrity.
- `test/encrypted_export_test.dart`: Tests phone masking, diagnosis redaction, and encrypted ZIP creation.
- `test/dispense_cash_memo_test.dart`: Tests end-to-end dispensing: UI selection, fee populating, memo notes, and atomic inventory stock deduction.
- `test/dental_chart_test.dart`: Tests 32-tooth odontogram state management and condition serialization.
- `test/soap_note_test.dart`: Tests SOAP note storage and vital signs recording.

---

## 10. Roadmap, Refactoring Targets & Next Agent Instructions

To the incoming coding agent: Here are your operational boundaries, open targets, and recommended enhancements:

### High-Priority Open Enhancements
1. **Prescription-to-Dispense Direct Pipeline**:
   - When a patient has an active prescription written in `ClinicalCaseSheetScreen`, provide a "Dispense from Prescription" shortcut in `NewCashMemoDialog` to populate prescribed remedies into the dispensing list with one tap.
2. **Barcode / QR Code Inventory Scanning**:
   - Integrate camera barcode scanning into `AddEditMedicineDialog` and `DispenseMedicinePickerSheet` to scan GS1/EAN barcodes on medicine packages for faster checkout.
3. **Batch-Specific Expiry Warnings in Dispense Sheet**:
   - Enhance `DispenseMedicinePickerSheet` to display an amber alert chip when a batch is within 30 days of expiry.
4. **GST / Tax Invoice Generation**:
   - Add optional GST percentage breakdown (CGST + SGST) for Indian medical retail compliance on cash memos.
5. **Multi-Currency & International Localization**:
   - Abstract the `₹` symbol into a user-configurable currency provider (`currencySymbolProvider`) loaded from settings for international deployments (USD, EUR, GBP, AED).

### Architectural Invariants (Never Break These)
- **Never bypass Drift migrations**: Always use `schemaVersion` and `onUpgrade`.
- **Never add hardcoded colors in widgets**: Always use `Theme.of(context).colorScheme`.
- **Never store plaintext passphrases**: Always use `SecurityService` / PBKDF2 / Keystore.
- **Never commit generated files manually**: Always run `dart run build_runner build --delete-conflicting-outputs`.
- **Maintain 100% test pass rate**: Always run `flutter test` and ensure all 75+ test suites pass before submitting PRs.

---
*End of ClinicPilot Master Project Handoff & Architecture Guide.*
