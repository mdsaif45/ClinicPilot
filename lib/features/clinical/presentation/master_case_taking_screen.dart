import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/picker_field.dart';
import '../models/case_record_models.dart';
import '../providers/case_record_provider.dart';

class MasterCaseTakingScreen extends ConsumerStatefulWidget {
  final Patient patient;

  const MasterCaseTakingScreen({super.key, required this.patient});

  @override
  ConsumerState<MasterCaseTakingScreen> createState() => _MasterCaseTakingScreenState();
}

class _MasterCaseTakingScreenState extends ConsumerState<MasterCaseTakingScreen> {
  bool _initialized = false;
  bool _saving = false;

  // Section 2: Chief Complaints (up to 3 blocks)
  final List<TextEditingController> _complaintControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _locationControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _sensationControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _aggControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _amelControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _concomitantControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _durationControllers = List.generate(3, (_) => TextEditingController());

  // Section 3: HPI
  final _hpiController = TextEditingController();

  // Section 4: Past History
  final _pastHistoryController = TextEditingController();

  // Section 5: Family History
  final _familyHistoryController = TextEditingController();

  // Section 6: Developmental History
  final _devHistoryController = TextEditingController();

  // Section 7: Physical Generals
  String _thermal = 'Ambithermal';
  final _thirstController = TextEditingController();
  final _appetiteController = TextEditingController();
  final _cravingsController = TextEditingController();
  final _aversionsController = TextEditingController();
  final _stoolController = TextEditingController();
  final _sweatController = TextEditingController();
  final _sleepController = TextEditingController();
  final _dreamsController = TextEditingController();

  // Section 8: Mental Generals
  final _mindController = TextEditingController();
  final _angerController = TextEditingController();
  final _fearsController = TextEditingController();
  final _consolationController = TextEditingController();

  // Section 9: Lifestyle & Habits
  final _lifestyleController = TextEditingController();

  // Section 10: Clinical Exam & Vitals
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _weightController = TextEditingController();
  final _tongueController = TextEditingController();
  final _examController = TextEditingController();

  // Section 11: Miasmatic Analysis
  String _dominantMiasm = 'Mixed / Dynamic';
  final _miasmFeaturesController = TextEditingController();

  // Section 12: Case Totality & Repertory
  final _totalityController = TextEditingController();
  final _rubricsController = TextEditingController();
  final _remedyController = TextEditingController();
  final _potencyController = TextEditingController();

  // Section 13: Baseline Prescription
  final _prescriptionController = TextEditingController();

  // Section 14: Investigations
  final _investigationsController = TextEditingController();

  // Section 15: Follow-up Notes
  final _followUpNotesController = TextEditingController();

  // Section 16: Outcome
  String _outcome = 'Under Active Treatment';

  @override
  void dispose() {
    for (var c in _complaintControllers) {
      c.dispose();
    }
    for (var c in _locationControllers) {
      c.dispose();
    }
    for (var c in _sensationControllers) {
      c.dispose();
    }
    for (var c in _aggControllers) {
      c.dispose();
    }
    for (var c in _amelControllers) {
      c.dispose();
    }
    for (var c in _concomitantControllers) {
      c.dispose();
    }
    for (var c in _durationControllers) {
      c.dispose();
    }

    _hpiController.dispose();
    _pastHistoryController.dispose();
    _familyHistoryController.dispose();
    _devHistoryController.dispose();
    _thirstController.dispose();
    _appetiteController.dispose();
    _cravingsController.dispose();
    _aversionsController.dispose();
    _stoolController.dispose();
    _sweatController.dispose();
    _sleepController.dispose();
    _dreamsController.dispose();
    _mindController.dispose();
    _angerController.dispose();
    _fearsController.dispose();
    _consolationController.dispose();
    _lifestyleController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _weightController.dispose();
    _tongueController.dispose();
    _examController.dispose();
    _miasmFeaturesController.dispose();
    _totalityController.dispose();
    _rubricsController.dispose();
    _remedyController.dispose();
    _potencyController.dispose();
    _prescriptionController.dispose();
    _investigationsController.dispose();
    _followUpNotesController.dispose();
    super.dispose();
  }

  void _populateFromExisting(MasterCaseRecordData record) {
    if (_initialized) return;
    _initialized = true;

    for (int i = 0; i < record.chiefComplaints.length && i < 3; i++) {
      final c = record.chiefComplaints[i];
      _complaintControllers[i].text = c.complaint;
      _locationControllers[i].text = c.location;
      _sensationControllers[i].text = c.sensation;
      _aggControllers[i].text = c.modalitiesAgg;
      _amelControllers[i].text = c.modalitiesAmel;
      _concomitantControllers[i].text = c.concomitants;
      _durationControllers[i].text = c.duration;
    }

    _hpiController.text = record.hpi;
    _pastHistoryController.text = record.pastHistory;
    _familyHistoryController.text = record.familyHistory;
    _devHistoryController.text = record.developmentalHistory;

    _thermal = record.physicalGenerals.thermal;
    _thirstController.text = record.physicalGenerals.thirst;
    _appetiteController.text = record.physicalGenerals.appetite;
    _cravingsController.text = record.physicalGenerals.cravings;
    _aversionsController.text = record.physicalGenerals.aversions;
    _stoolController.text = record.physicalGenerals.stool;
    _sweatController.text = record.physicalGenerals.perspiration;
    _sleepController.text = record.physicalGenerals.sleep;
    _dreamsController.text = record.physicalGenerals.dreams;

    _mindController.text = record.mentalGenerals.disposition;
    _angerController.text = record.mentalGenerals.irritabilityAnger;
    _fearsController.text = record.mentalGenerals.anxietyFears;
    _consolationController.text = record.mentalGenerals.consolationReaction;

    _lifestyleController.text = record.lifestyleHabits;

    _bpController.text = record.clinicalExam.bp;
    _pulseController.text = record.clinicalExam.pulse;
    _weightController.text = record.clinicalExam.weightKg;
    _tongueController.text = record.clinicalExam.tongueExam;
    _examController.text = record.clinicalExam.systemicFindings;

    _dominantMiasm = record.miasmaticAnalysis.dominantMiasm;
    _miasmFeaturesController.text = record.miasmaticAnalysis.psoricFeatures;

    _totalityController.text = record.caseTotality.characteristicSymptoms;
    _rubricsController.text = record.caseTotality.rubricsSelected;
    _remedyController.text = record.caseTotality.selectedRemedy;
    _potencyController.text = record.caseTotality.potency;

    _prescriptionController.text = record.baselinePrescription;
    _investigationsController.text = record.investigations;
    _followUpNotesController.text = record.followUpNotes;
    _outcome = record.outcome;
  }

  Future<void> _saveRecord([String? existingId]) async {
    setState(() => _saving = true);
    AppHaptics.medium();

    final complaints = <ChiefComplaintDetail>[];
    for (int i = 0; i < 3; i++) {
      if (_complaintControllers[i].text.trim().isNotEmpty) {
        complaints.add(ChiefComplaintDetail(
          complaint: _complaintControllers[i].text.trim(),
          location: _locationControllers[i].text.trim(),
          sensation: _sensationControllers[i].text.trim(),
          modalitiesAgg: _aggControllers[i].text.trim(),
          modalitiesAmel: _amelControllers[i].text.trim(),
          concomitants: _concomitantControllers[i].text.trim(),
          duration: _durationControllers[i].text.trim(),
        ));
      }
    }

    final physical = PhysicalGenerals(
      thermal: _thermal,
      thirst: _thirstController.text.trim(),
      appetite: _appetiteController.text.trim(),
      cravings: _cravingsController.text.trim(),
      aversions: _aversionsController.text.trim(),
      stool: _stoolController.text.trim(),
      perspiration: _sweatController.text.trim(),
      sleep: _sleepController.text.trim(),
      dreams: _dreamsController.text.trim(),
    );

    final mental = MentalGenerals(
      disposition: _mindController.text.trim(),
      irritabilityAnger: _angerController.text.trim(),
      anxietyFears: _fearsController.text.trim(),
      consolationReaction: _consolationController.text.trim(),
    );

    final clinicalExam = ClinicalExamVitals(
      bp: _bpController.text.trim(),
      pulse: _pulseController.text.trim(),
      weightKg: _weightController.text.trim(),
      tongueExam: _tongueController.text.trim(),
      systemicFindings: _examController.text.trim(),
    );

    final miasm = MiasmaticAnalysis(
      dominantMiasm: _dominantMiasm,
      psoricFeatures: _miasmFeaturesController.text.trim(),
    );

    final totality = CaseTotality(
      characteristicSymptoms: _totalityController.text.trim(),
      rubricsSelected: _rubricsController.text.trim(),
      selectedRemedy: _remedyController.text.trim(),
      potency: _potencyController.text.trim(),
    );

    final record = MasterCaseRecordData(
      id: existingId,
      patientId: widget.patient.id,
      recordDate: DateTime.now(),
      chiefComplaints: complaints,
      hpi: _hpiController.text.trim(),
      pastHistory: _pastHistoryController.text.trim(),
      familyHistory: _familyHistoryController.text.trim(),
      developmentalHistory: _devHistoryController.text.trim(),
      physicalGenerals: physical,
      mentalGenerals: mental,
      lifestyleHabits: _lifestyleController.text.trim(),
      clinicalExam: clinicalExam,
      miasmaticAnalysis: miasm,
      caseTotality: totality,
      baselinePrescription: _prescriptionController.text.trim(),
      investigations: _investigationsController.text.trim(),
      followUpNotes: _followUpNotesController.text.trim(),
      outcome: _outcome,
    );

    try {
      await ref.read(caseRecordNotifierProvider.notifier).saveCaseRecord(record);
      AppHaptics.success();
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Master Case Record saved successfully!')),
        );
      }
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving case record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseRecordAsync = ref.watch(patientCaseRecordProvider(widget.patient.id));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final existingRecord = caseRecordAsync.value;
    if (existingRecord != null && !_initialized) {
      _populateFromExisting(existingRecord);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clinical Case Taking', style: theme.textTheme.titleMedium),
            Text(
              '${widget.patient.name} (${widget.patient.patientCode})',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton.tonalIcon(
            onPressed: _saving ? null : () => _saveRecord(existingRecord?.id),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Record'),
          ),
          const SizedBox(width: Spacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl * 2),
        children: [
          // Section 1: Demographics Card
          _SectionCard(
            sectionNumber: '01',
            title: 'Patient Identification & Demographics',
            icon: Icons.person_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Fact(label: 'Name', value: widget.patient.name),
                    _Fact(label: 'Code', value: widget.patient.patientCode),
                    _Fact(label: 'Age / Sex', value: '${widget.patient.age}y / ${widget.patient.gender}'),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    _Fact(label: 'Phone', value: widget.patient.phone),
                    _Fact(label: 'Locality', value: widget.patient.area ?? 'Not specified'),
                    _Fact(label: 'Referral', value: widget.patient.referralSource ?? 'Direct / Walk-in'),
                  ],
                ),
              ],
            ),
          ),

          // Section 2: Chief Complaints (3 blocks)
          _SectionCard(
            sectionNumber: '02',
            title: 'Chief Complaints (3 Relational Blocks)',
            icon: Icons.healing_outlined,
            child: Column(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  ExpansionTile(
                    initiallyExpanded: i == 0,
                    title: Text(
                      'Complaint #${i + 1}${_complaintControllers[i].text.isNotEmpty ? ' • ${_complaintControllers[i].text}' : ''}',
                      style: theme.textTheme.titleSmall,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _complaintControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Complaint #${i + 1}',
                                hintText: 'e.g. Right Hip & Knee joint pain',
                              ),
                            ),
                            const SizedBox(height: Spacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _locationControllers[i],
                                    decoration: const InputDecoration(labelText: 'Location / Extension'),
                                  ),
                                ),
                                const SizedBox(width: Spacing.md),
                                Expanded(
                                  child: TextFormField(
                                    controller: _sensationControllers[i],
                                    decoration: const InputDecoration(labelText: 'Sensation / Character'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _aggControllers[i],
                                    decoration: const InputDecoration(labelText: 'Aggravation (<)'),
                                  ),
                                ),
                                const SizedBox(width: Spacing.md),
                                Expanded(
                                  child: TextFormField(
                                    controller: _amelControllers[i],
                                    decoration: const InputDecoration(labelText: 'Amelioration (>)'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Spacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _concomitantControllers[i],
                                    decoration: const InputDecoration(labelText: 'Concomitants'),
                                  ),
                                ),
                                const SizedBox(width: Spacing.md),
                                Expanded(
                                  child: TextFormField(
                                    controller: _durationControllers[i],
                                    decoration: const InputDecoration(labelText: 'Duration / Onset'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (i < 2) const Divider(),
                ],
              ],
            ),
          ),

          // Section 3: History of Present Illness (HPI)
          _SectionCard(
            sectionNumber: '03',
            title: 'History of Present Illness (HPI)',
            icon: Icons.history_edu_outlined,
            child: TextFormField(
              controller: _hpiController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Chronological progression, past medications, prior relief',
                hintText: 'e.g. Started after lifting heavy weight, worsening gradually...',
              ),
            ),
          ),

          // Section 4: Past Medical History
          _SectionCard(
            sectionNumber: '04',
            title: 'Past Medical History',
            icon: Icons.medical_information_outlined,
            child: TextFormField(
              controller: _pastHistoryController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Childhood illnesses, surgeries, chronic ailments, past treatments',
                hintText: 'e.g. Type 2 DM since 5 years, rectal abscess drained in 2021',
              ),
            ),
          ),

          // Section 5: Family History
          _SectionCard(
            sectionNumber: '05',
            title: 'Family Medical History',
            icon: Icons.family_restroom_outlined,
            child: TextFormField(
              controller: _familyHistoryController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Hereditary conditions (Diabetes, Hypertension, Cancer, Asthma, TB)',
                hintText: 'e.g. Father had HTN, Mother asthmatic',
              ),
            ),
          ),

          // Section 6: Intrauterine & Developmental History
          _SectionCard(
            sectionNumber: '06',
            title: 'Intrauterine & Developmental History',
            icon: Icons.child_care_outlined,
            child: TextFormField(
              controller: _devHistoryController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Maternal health during gestation, milestones, dentition',
                hintText: 'e.g. Normal delivery, timely milestones',
              ),
            ),
          ),

          // Section 7: Physical Generals
          _SectionCard(
            sectionNumber: '07',
            title: 'Physical Generals',
            icon: Icons.thermostat_outlined,
            child: Column(
              children: [
                PickerField<String>(
                  label: 'Thermal State',
                  value: _thermal,
                  options: const [
                    PickerOption(value: 'Hot', label: 'Hot (Prefers Winter / Open Air)'),
                    PickerOption(value: 'Chilly', label: 'Chilly (Prefers Warmth / Covers)'),
                    PickerOption(value: 'Ambithermal', label: 'Ambithermal (Neutral / Both)'),
                  ],
                  onChanged: (val) => setState(() => _thermal = val),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _thirstController,
                        decoration: const InputDecoration(labelText: 'Thirst (Quantity & Frequency)'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _appetiteController,
                        decoration: const InputDecoration(labelText: 'Appetite & Hunger'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cravingsController,
                        decoration: const InputDecoration(labelText: 'Desires / Cravings (Sweet, Salt, Spicy)'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _aversionsController,
                        decoration: const InputDecoration(labelText: 'Aversions / Intolerances'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stoolController,
                        decoration: const InputDecoration(labelText: 'Stool & Bowels'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _sweatController,
                        decoration: const InputDecoration(labelText: 'Perspiration & Odor'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sleepController,
                        decoration: const InputDecoration(labelText: 'Sleep Pattern & Position'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _dreamsController,
                        decoration: const InputDecoration(labelText: 'Dreams / Disturbances'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Section 8: Mental Generals
          _SectionCard(
            sectionNumber: '08',
            title: 'Mental Generals',
            icon: Icons.psychology_outlined,
            child: Column(
              children: [
                TextFormField(
                  controller: _mindController,
                  decoration: const InputDecoration(labelText: 'Disposition & Temperament'),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _angerController,
                        decoration: const InputDecoration(labelText: 'Anger / Irritability'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _fearsController,
                        decoration: const InputDecoration(labelText: 'Anxieties & Fears'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _consolationController,
                  decoration: const InputDecoration(labelText: 'Consolation Reaction & Social Preferences'),
                ),
              ],
            ),
          ),

          // Section 9: Lifestyle & Personal Habits
          _SectionCard(
            sectionNumber: '09',
            title: 'Personal Habits & Lifestyle',
            icon: Icons.fitness_center_outlined,
            child: TextFormField(
              controller: _lifestyleController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Diet, tea/coffee, physical activity, occupation, routine',
                hintText: 'e.g. Sedentary tailor work, irregular meal timings, 4 cups tea daily',
              ),
            ),
          ),

          // Section 10: Clinical Examination & Vitals
          _SectionCard(
            sectionNumber: '10',
            title: 'Clinical Examination & Vitals',
            icon: Icons.monitor_heart_outlined,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bpController,
                        decoration: const InputDecoration(labelText: 'Blood Pressure (mmHg)'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _pulseController,
                        decoration: const InputDecoration(labelText: 'Pulse (bpm)'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(labelText: 'Weight (kg)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _tongueController,
                  decoration: const InputDecoration(labelText: 'Tongue & Throat Findings'),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _examController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Systemic / Physical Findings'),
                ),
              ],
            ),
          ),

          // Section 11: Miasmatic Analysis
          _SectionCard(
            sectionNumber: '11',
            title: 'Miasmatic Analysis',
            icon: Icons.biotech_outlined,
            child: Column(
              children: [
                PickerField<String>(
                  label: 'Dominant Miasm',
                  value: _dominantMiasm,
                  options: const [
                    PickerOption(value: 'Psora', label: 'Psora (Functional / Hypersensitive)'),
                    PickerOption(value: 'Sycosis', label: 'Sycosis (Proliferative / Overgrowth)'),
                    PickerOption(value: 'Syphilis', label: 'Syphilis (Destructive / Degenerative)'),
                    PickerOption(value: 'Tubercular', label: 'Tubercular (Rapid Change / Suppressed)'),
                    PickerOption(value: 'Mixed / Dynamic', label: 'Mixed / Complex Dyserasia'),
                  ],
                  onChanged: (val) => setState(() => _dominantMiasm = val),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _miasmFeaturesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Supporting Characteristic Miasmatic Traits',
                    hintText: 'e.g. Warts (sycotic), burning eyes (psoric), joint destruction',
                  ),
                ),
              ],
            ),
          ),

          // Section 12: Totality of Symptoms & Repertorial Analysis
          _SectionCard(
            sectionNumber: '12',
            title: 'Case Totality & Repertory',
            icon: Icons.menu_book_outlined,
            child: Column(
              children: [
                TextFormField(
                  controller: _totalityController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Totality of Symptoms & Keynotes'),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _rubricsController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Repertorial Rubrics Selected'),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _remedyController,
                        decoration: const InputDecoration(labelText: 'Selected Similimum Remedy'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _potencyController,
                        decoration: const InputDecoration(labelText: 'Potency & Scale (e.g. 200CH, 1M, LM-01)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Section 13: Baseline Prescription
          _SectionCard(
            sectionNumber: '13',
            title: 'Baseline Prescription & Posology',
            icon: Icons.medication_outlined,
            child: TextFormField(
              controller: _prescriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Dosage, repetition, carrier form (globs/water), advice',
                hintText: 'e.g. Thuja 200CH 4 pills morning empty stomach for 3 days',
              ),
            ),
          ),

          // Section 14: Investigations & Lab Tracking
          _SectionCard(
            sectionNumber: '14',
            title: 'Investigations & Diagnostic Reports',
            icon: Icons.science_outlined,
            child: TextFormField(
              controller: _investigationsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Lab values, scans, HbA1c, pathology findings',
                hintText: 'e.g. Fasting Sugar 180 mg/dL, HbA1c 8.4%',
              ),
            ),
          ),

          // Section 15: Follow-up Record & Strategic Notes
          _SectionCard(
            sectionNumber: '15',
            title: 'Follow-up Record & Plan',
            icon: Icons.sync_alt_outlined,
            child: TextFormField(
              controller: _followUpNotesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Next visit scheduled plan, second prescription indications',
                hintText: 'e.g. Review after 15 days, watch for reduction in flatulence and knee pain',
              ),
            ),
          ),

          // Section 16: Case Outcome & Closure
          _SectionCard(
            sectionNumber: '16',
            title: 'Clinical Case Outcome',
            icon: Icons.check_circle_outline,
            child: PickerField<String>(
              label: 'Current Case Status',
              value: _outcome,
              options: const [
                PickerOption(value: 'Under Active Treatment', label: 'Under Active Treatment'),
                PickerOption(value: 'Significantly Improved', label: 'Significantly Improved'),
                PickerOption(value: 'Cured / Discharged', label: 'Cured / Discharged'),
                PickerOption(value: 'Re-evaluation Required', label: 'Re-evaluation Required'),
                PickerOption(value: 'Lapsed / Drop-out', label: 'Lapsed / Drop-out'),
              ],
              onChanged: (val) => setState(() => _outcome = val),
            ),
          ),

          const SizedBox(height: Spacing.xl),
          FilledButton.icon(
            onPressed: _saving ? null : () => _saveRecord(existingRecord?.id),
            icon: const Icon(Icons.save),
            label: const Text('Save Master Case Record'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String sectionNumber;
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.sectionNumber,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  sectionNumber,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          child,
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}