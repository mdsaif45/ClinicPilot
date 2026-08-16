import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

import 'tables/clinics.dart';
import 'tables/patients.dart';
import 'tables/visits.dart';
import 'tables/cash_memos.dart';
import 'tables/expenses.dart';
import 'tables/settings.dart';

part 'app_database.g.dart';

// Type-safe database powered by Drift ORM (Schema Version 2)
@DriftDatabase(tables: [Clinics, Patients, Visits, CashMemos, Expenses, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedSettings();
          await _createIndices();
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
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
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
}
