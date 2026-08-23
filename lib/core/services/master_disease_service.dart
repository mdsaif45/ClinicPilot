import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/formatters.dart';

const List<String> kDefaultHomeopathicDiseases = [
  'Acid Peptic Disease / GERD',
  'Allergic Rhinitis / Sneezing',
  'Anxiety / Depression / Insomnia',
  'Asthma / Bronchial Allergy',
  'Atopic Dermatitis / Eczema',
  'Cervical Spondylosis / Neck Pain',
  'Childhood Immunity / Recurrent Cold',
  'Chronic Kidney Disease / Creatinine',
  'Diabetes Mellitus',
  'Fatty Liver / Digestive Disorder',
  'Fever / Viral Infection',
  'Fungal Infection / Ringworm',
  'General Consultation',
  'Hair Fall / Alopecia Areata',
  'Hypertension',
  'Irritable Bowel Syndrome (IBS)',
  'Joint Pain / Osteoarthritis',
  'Kidney Stone / Renal Calculi',
  'Lumbar Spondylosis / Sciatica',
  'Menstrual Disorder / Dysmenorrhea',
  'Migraine / Chronic Headache',
  'PCOS / PCOD',
  'Piles / Anal Fissure / Fistula',
  'Psoriasis',
  'Rheumatoid Arthritis',
  'Sinusitis / Nasal Polyps',
  'Skin Allergy / Urticaria',
  'Thyroid Disorder / Hypothyroid',
  'Tonsillitis / Adenoids',
  'Vitiligo / Leucoderma',
  'Warts / Corns',
  'Other',
];

class MasterDiseaseService {
  final AppDatabase _db;
  static const _uuid = Uuid();
  bool _initialized = false;

  MasterDiseaseService(this._db);

  Future<void> initTable() async {
    if (_initialized) return;
    await _db.customStatement('''
      CREATE TABLE IF NOT EXISTS master_diseases (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        normalized_name TEXT NOT NULL,
        usage_count INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      );
    ''');

    // Seed defaults if empty
    final countRes = await _db.customSelect('SELECT COUNT(*) as c FROM master_diseases').getSingle();
    final count = countRes.data['c'] as int? ?? 0;
    if (count == 0) {
      for (final disease in kDefaultHomeopathicDiseases) {
        final norm = disease.trim();
        if (norm.isEmpty) continue;
        await _db.customStatement('''
          INSERT OR IGNORE INTO master_diseases (id, name, normalized_name, usage_count, created_at)
          VALUES (?, ?, ?, 1, ?)
        ''', [
          _uuid.v4(),
          norm,
          norm.toLowerCase(),
          DateTime.now().toIso8601String(),
        ]);
      }
    }
    _initialized = true;
  }

  Future<List<String>> getAllDiseases() async {
    await initTable();
    final rows = await _db.customSelect('''
      SELECT name FROM master_diseases
      ORDER BY usage_count DESC, name ASC
    ''').get();

    final dbList = rows.map((r) => r.data['name'] as String).toList();
    if (dbList.isEmpty) return kDefaultHomeopathicDiseases;
    return dbList;
  }

  Future<List<String>> searchDiseases(String query) async {
    await initTable();
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      final rows = await _db.customSelect('''
        SELECT name FROM master_diseases
        ORDER BY usage_count DESC, name ASC
        LIMIT 10
      ''').get();
      return rows.map((r) => r.data['name'] as String).toList();
    }

    final rows = await _db.customSelect('''
      SELECT name FROM master_diseases
      WHERE normalized_name LIKE ? OR name LIKE ?
      ORDER BY usage_count DESC, name ASC
      LIMIT 15
    ''', variables: [
      Variable.withString('%$trimmed%'),
      Variable.withString('%$trimmed%'),
    ]).get();

    return rows.map((r) => r.data['name'] as String).toList();
  }

  Future<void> recordDisease(String? rawDisease) async {
    if (rawDisease == null) return;
    final trimmed = rawDisease.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'other') return;

    await initTable();
    final normalized = Formatters.toTitleCase(trimmed);

    await _db.customStatement('''
      INSERT INTO master_diseases (id, name, normalized_name, usage_count, created_at)
      VALUES (?, ?, ?, 1, ?)
      ON CONFLICT(name) DO UPDATE SET usage_count = usage_count + 1
    ''', [
      _uuid.v4(),
      normalized,
      normalized.toLowerCase(),
      DateTime.now().toIso8601String(),
    ]);
  }
}

final masterDiseaseServiceProvider = Provider<MasterDiseaseService>((ref) {
  final db = ref.watch(databaseProvider);
  return MasterDiseaseService(db);
});

final masterDiseasesListProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(masterDiseaseServiceProvider);
  return service.getAllDiseases();
});
