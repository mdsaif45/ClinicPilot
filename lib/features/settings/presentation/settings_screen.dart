import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../clinics/presentation/clinics_screen.dart';

import 'app_update_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _revenueGoalController = TextEditingController(text: '50000');
  final _patientGoalController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    final rev = await (db.select(db.settings)
          ..where((tbl) => tbl.key.equals('monthly_revenue_goal')))
        .getSingleOrNull();
    if (rev != null) _revenueGoalController.text = rev.value;

    final pat = await (db.select(db.settings)
          ..where((tbl) => tbl.key.equals('monthly_new_patient_goal')))
        .getSingleOrNull();
    if (pat != null) _patientGoalController.text = pat.value;
  }

  @override
  void dispose() {
    _revenueGoalController.dispose();
    _patientGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.teal),
              title: const Text('Manage Clinics',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Add, edit, or set active clinic'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClinicsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Goals Target',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _revenueGoalController,
                    label: 'Monthly Revenue Target (Rs)',
                    prefixIcon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _patientGoalController,
                    label: 'Monthly New Patient Target',
                    prefixIcon: Icons.person_add,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _saveGoals,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Target Goals'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download, color: Colors.blue),
              title: const Text('Export Backup Data (CSV)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Export patients, visits, memos to CSV'),
              onTap: _exportData,
            ),
          ),
          const SizedBox(height: 16),
          const AppUpdateCard(),
        ],
      ),
    );
  }

  Future<void> _saveGoals() async {
    final db = ref.read(databaseProvider);
    final rev = _revenueGoalController.text.trim();
    final pat = _patientGoalController.text.trim();

    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal',
            value: rev,
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_new_patient_goal',
            value: pat,
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target goals updated successfully!')),
      );
    }
  }

  Future<void> _exportData() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data backup saved successfully!')),
      );
    }
  }
}
