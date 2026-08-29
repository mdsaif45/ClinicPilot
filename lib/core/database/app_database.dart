import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

import 'tables/clinics.dart';
import 'tables/patients.dart';
import 'tables/visits.dart';
import 'tables/cash_memos.dart';
import 'tables/expenses.dart';
import 'tables/settings.dart';
import 'tables/review_requests.dart';
import 'tables/footfalls.dart';
import 'tables/camps.dart';
import 'tables/patient_case_records.dart';
import 'tables/complaints.dart';
import 'tables/prescriptions.dart';
import 'tables/investigations.dart';
import 'tables/referral_contacts.dart';

part 'app_database.g.dart';

// Type-safe database powered by Drift ORM (Schema Version 15)
@DriftDatabase(tables: [Clinics, Patients, Visits, CashMemos, Expenses, Settings, ReviewRequests, Footfalls, Camps, PatientCaseRecords, Complaints, Prescriptions, Investigations, ReferralContacts])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.openConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedSettings();
          await _createIndices();
          await _createPatientSerialIndex();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // 1. Create new tables
            await m.createTable(visits);
            await m.createTable(settings);

            // 2. Add new columns only when absent
            await _addColumnIfMissing(m, clinics, clinics.address);
            await _addColumnIfMissing(m, clinics, clinics.phone);
            await _addColumnIfMissing(m, clinics, clinics.monthlyRent);
            await _addColumnIfMissing(m, clinics, clinics.defaultConsultationFee);
            await _addColumnIfMissing(m, clinics, clinics.openDays);
            await _addColumnIfMissing(m, clinics, clinics.colorHex);
            await _addColumnIfMissing(m, clinics, clinics.isActive);
            await _addColumnIfMissing(m, clinics, clinics.isDeleted);
            await _addColumnIfMissing(m, clinics, clinics.createdAt);

            await _addColumnIfMissing(m, patients, patients.patientCode);
            await _addColumnIfMissing(m, patients, patients.whatsapp);
            await _addColumnIfMissing(m, patients, patients.area);
            await _addColumnIfMissing(m, patients, patients.address);
            await _addColumnIfMissing(m, patients, patients.occupation);
            await _addColumnIfMissing(m, patients, patients.primaryClinicId);
            await _addColumnIfMissing(m, patients, patients.primaryDisease);
            await _addColumnIfMissing(m, patients, patients.referralSource);
            await _addColumnIfMissing(m, patients, patients.notes);
            await _addColumnIfMissing(m, patients, patients.isDeleted);
            await _addColumnIfMissing(m, patients, patients.updatedAt);

            await _addColumnIfMissing(m, cashMemos, cashMemos.clinicId);
            await _addColumnIfMissing(m, cashMemos, cashMemos.visitId);
            await _addColumnIfMissing(m, cashMemos, cashMemos.paidAmount);
            await _addColumnIfMissing(m, cashMemos, cashMemos.notes);
            await _addColumnIfMissing(m, cashMemos, cashMemos.isDeleted);

            await _addColumnIfMissing(m, expenses, expenses.subcategory);
            await _addColumnIfMissing(m, expenses, expenses.paymentMethod);
            await _addColumnIfMissing(m, expenses, expenses.isRecurring);
            await _addColumnIfMissing(m, expenses, expenses.isDeleted);
            await _addColumnIfMissing(m, expenses, expenses.createdAt);

            // 2.5 Copy renamed v1 columns into their v2 equivalents BEFORE visits backfill
            if (await _hasColumn('patients', 'clinic_id')) {
              await customStatement('''
                UPDATE patients
                SET primary_clinic_id = clinic_id
                WHERE primary_clinic_id IS NULL OR primary_clinic_id = ''
              ''');
            }
            if (await _hasColumn('patients', 'disease')) {
              await customStatement('''
                UPDATE patients
                SET primary_disease = disease
                WHERE primary_disease IS NULL OR primary_disease = ''
              ''');
            }

            // 3. Backfill non-null required fields & legacy values
            await customStatement('''
              UPDATE patients
              SET patient_code = 'P-MIG-' || substr(id, 1, 8),
                  is_deleted = 0
              WHERE patient_code IS NULL OR patient_code = ''
            ''');
            await customStatement('UPDATE patients SET updated_at = created_at WHERE updated_at IS NULL');
            await customStatement('UPDATE cash_memos SET is_deleted = 0 WHERE is_deleted IS NULL');
            await customStatement('UPDATE expenses SET is_deleted = 0, is_recurring = 0 WHERE is_deleted IS NULL');
            await customStatement('UPDATE expenses SET created_at = date WHERE created_at IS NULL');

            // 4. Backfill visits for existing patients
            await customStatement('''
              INSERT INTO visits (id, patient_id, clinic_id, visit_type,
                                  consultation_type, disease, referral_source,
                                  visit_date, is_deleted, created_at)
              SELECT
                'mig-' || p.id, p.id, COALESCE(p.primary_clinic_id, 'clinic_old'), 'new', 'clinic',
                COALESCE(p.primary_disease, 'General Consultation'), p.referral_source,
                p.created_at, 0, p.created_at
              FROM patients p
              WHERE NOT EXISTS (SELECT 1 FROM visits v WHERE v.patient_id = p.id)
            ''');

            // 5. Link existing memos to backfilled visits
            await customStatement('''
              UPDATE cash_memos
              SET visit_id  = 'mig-' || patient_id,
                  clinic_id = COALESCE(clinic_id, 'clinic_old')
              WHERE visit_id IS NULL OR clinic_id IS NULL
            ''');

            // 6. Set historical memos as fully paid
            await customStatement(
              'UPDATE cash_memos SET paid_amount = total WHERE paid_amount = 0 OR paid_amount IS NULL');

            await _seedClinics();
            await _seedSettings();

            await customStatement('UPDATE clinics SET is_active = 1, is_deleted = 0 WHERE is_deleted IS NULL');
            await customStatement('UPDATE clinics SET created_at = cast(strftime("%s", "now") as integer) WHERE created_at IS NULL');

            await _createIndices();
          }

          if (from < 3) {
            // Google review tracking.
            await _addColumnIfMissing(m, patients, patients.reviewAskedAt);
            await _addColumnIfMissing(m, patients, patients.reviewGiven);

            // A column default applies to rows inserted after the column
            // exists, not to rows already in the table. Without this backfill
            // every pre-existing patient reads back null on a non-nullable
            // field and the mapper throws.
            await customStatement(
                'UPDATE patients SET review_given = 0 WHERE review_given IS NULL');
          }

          if (from < 4) {
            // Revenue now reports on when the money moved, not on when the row
            // happened to be written.
            await _addColumnIfMissing(m, cashMemos, cashMemos.memoDate);

            // Existing memos were reported by created_at, so that is their
            // date. Copying it keeps every historical figure identical across
            // the upgrade; leaving it unset would date them to the epoch and
            // drop them out of every range the dashboard asks for.
            await customStatement(
                'UPDATE cash_memos SET memo_date = created_at WHERE memo_date IS NULL');
          }

          if (from < 5) {
            // The manual per-clinic register number the doctor already
            // writes on paper, separate from the app's own patientCode.
            await _addColumnIfMissing(m, patients, patients.serialNo);

            // Every existing patient currently reads serial_no = '' (the
            // column default). A UNIQUE index over (clinic, serial_no)
            // cannot go on top of that - SQLite treats two empty strings as
            // equal, so the second existing patient at any clinic would
            // collide with the first. Backfilling each to a distinct
            // placeholder makes the index buildable, and the doctor
            // corrects it to the real register number from Edit Patient at
            // their own pace.
            //
            // Built from id, not patient_code: the v1 -> v2 backfill above
            // derives patient_code from substr(id, 1, 8), which collides
            // whenever two ids share an 8-character prefix (as they did on
            // a real v1 database using short sequential ids) - a pre-
            // existing gap this migration must not inherit. id is this
            // table's actual primary key, so it is unique by definition.
            await customStatement('''
              UPDATE patients
              SET serial_no = 'LEGACY-' || id
              WHERE serial_no IS NULL OR serial_no = ''
            ''');

            await _createPatientSerialIndex();
          }

          if (from < 6) {
            await m.createTable(reviewRequests);
          }

          if (from < 7) {
            await m.createTable(footfalls);
          }

          if (from < 8) {
            await m.createTable(camps);
          }

          if (from < 9) {
            await m.createTable(patientCaseRecords);
          }

          if (from < 10) {
            await m.createTable(complaints);
          }

          if (from < 11) {
            await m.createTable(prescriptions);
          }

          if (from < 12) {
            await m.createTable(investigations);
          }

          if (from < 13) {
            await m.createTable(referralContacts);
          }

          if (from < 14) {
            await _addColumnIfMissing(m, patients, patients.email);
          }

          if (from < 15) {
            await _addColumnIfMissing(m, complaints, complaints.complaintDate);
            await _addColumnIfMissing(m, complaints, complaints.isBaseline);
            await _addColumnIfMissing(m, complaints, complaints.beforeImages);
            await _addColumnIfMissing(m, complaints, complaints.afterImages);
            await _addColumnIfMissing(m, prescriptions, prescriptions.isBaseline);
            await _addColumnIfMissing(m, investigations, investigations.isBaseline);
            await _addColumnIfMissing(m, investigations, investigations.reportAttachments);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          try {
            await customStatement("UPDATE complaints SET complaint_date = created_at WHERE complaint_date IS NULL;");
            await customStatement("UPDATE complaints SET is_baseline = 1 WHERE is_baseline IS NULL;");
            await customStatement("UPDATE prescriptions SET prescription_date = created_at WHERE prescription_date IS NULL;");
            await customStatement("UPDATE prescriptions SET is_baseline = 1 WHERE is_baseline IS NULL;");
            await customStatement("UPDATE investigations SET test_date = created_at WHERE test_date IS NULL;");
            await customStatement("UPDATE investigations SET is_baseline = 1 WHERE is_baseline IS NULL;");
          } catch (_) {}
        },
      );

  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.data['name'] == column);
  }

  Future<void> _addColumnIfMissing(
      Migrator m, TableInfo table, GeneratedColumn column) async {
    if (!await _hasColumn(table.actualTableName, column.name)) {
      try {
        await m.addColumn(table, column);
      } catch (_) {
        await customStatement(
            'ALTER TABLE ${table.actualTableName} ADD COLUMN ${column.name} INTEGER NULL;');
      }
    }
  }

  /// Creates the two clinic rows the v1 -> v2 migration attaches old data to.
  ///
  /// Only reachable from that migration, which assigns every pre-v2 memo and
  /// visit to `clinic_old` - without the row the foreign key fails. A fresh
  /// install gets its clinics from onboarding instead.
  ///
  /// Deliberately unnamed beyond "Clinic 1" and "Clinic 2": this app is not
  /// specific to one practice, and the doctor renames them in Settings.
  Future<void> _seedClinics() async {
    final now = DateTime.now();
    await into(clinics).insertOnConflictUpdate(
      ClinicsCompanion.insert(
        id: 'clinic_old',
        name: 'Clinic 1',
        openDays: const Value('1,3,5'),
        colorHex: const Value('#0F5132'),
        createdAt: Value(now),
      ),
    );
    await into(clinics).insertOnConflictUpdate(
      ClinicsCompanion.insert(
        id: 'clinic_new',
        name: 'Clinic 2',
        openDays: const Value('2,4,6'),
        colorHex: const Value('#1E88E5'),
        createdAt: Value(now),
      ),
    );
  }

  Future<void> _seedSettings() async {
    final defaultSettings = [
      ('monthly_revenue_goal', '50000'),
      ('monthly_new_patient_goal', '10'),
      ('active_clinic_id', 'clinic_old'),
      ('currency_symbol', 'Rs '),
      ('db_schema_version', '2'),
    ];

    for (final (k, v) in defaultSettings) {
      await into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: k,
          value: v,
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _createIndices() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_visits_date ON visits (visit_date)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_visits_clinic_date ON visits (clinic_id, visit_date)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_visits_patient ON visits (patient_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_visits_type_date ON visits (visit_type, visit_date)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_visits_followup ON visits (next_follow_up_date)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_memos_created ON cash_memos (created_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_memos_clinic_date ON cash_memos (clinic_id, created_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_memos_patient ON cash_memos (patient_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_memos_visit ON cash_memos (visit_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses (date)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_expenses_clinic_date ON expenses (clinic_id, date)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients (phone)');
  }

  /// Separate from [_createIndices]: that function also runs mid-upgrade
  /// inside the `from < 2` migration step, at a point where a database
  /// coming from v1 does not have serial_no yet. This one is only ever
  /// called once the column is guaranteed to exist - onCreate (a fresh
  /// database has every column already) and the v5 migration step, after
  /// its own backfill.
  Future<void> _createPatientSerialIndex() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_patients_clinic_serial
      ON patients (primary_clinic_id, serial_no)
    ''');
  }
  /// Completely resets all practice tables, patients, clinics, and settings for a clean restart.
  Future<void> clearAllPracticeData() async {
    await transaction(() async {
      await delete(prescriptions).go();
      await delete(investigations).go();
      await delete(complaints).go();
      await delete(patientCaseRecords).go();
      await delete(reviewRequests).go();
      await delete(footfalls).go();
      await delete(camps).go();
      await delete(referralContacts).go();
      await delete(expenses).go();
      await delete(cashMemos).go();
      await delete(visits).go();
      await delete(patients).go();
      await delete(clinics).go();
      await delete(settings).go();
      try {
        await customStatement('DELETE FROM master_diseases;');
      } catch (_) {}
    });
  }
}