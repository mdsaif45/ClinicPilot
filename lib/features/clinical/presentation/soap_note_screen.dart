import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../settings/providers/doctor_profile_provider.dart';
import '../models/case_record_models.dart';
import '../models/soap_note_model.dart';
import '../providers/case_record_provider.dart';
import '../providers/prescription_provider.dart';
import 'prescription_preview_dialog.dart';
import 'widgets/vital_signs_card.dart';

/// Fast, modern 4-step SOAP (Subjective, Objective, Assessment, Plan) Clinical
/// Note consultation screen for General Practice and routine outpatient visits.
class SoapNoteScreen extends ConsumerStatefulWidget {
  final Patient patient;
  final MasterCaseRecordData? existingRecord;

  const SoapNoteScreen({super.key, required this.patient, this.existingRecord});

  @override
  ConsumerState<SoapNoteScreen> createState() => _SoapNoteScreenState();
}

class _SoapNoteScreenState extends ConsumerState<SoapNoteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // S: Subjective
  final _chiefComplaintController = TextEditingController();
  final _durationController = TextEditingController();
  final _hpiController = TextEditingController();

  // O: Objective & Vitals
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _tempController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _respRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _sugarController = TextEditingController();
  final _examFindingsController = TextEditingController();

  // A: Assessment
  final _workingDiagController = TextEditingController();
  final _differentialDiagController = TextEditingController();
  final _comorbiditiesController = TextEditingController();
  final _remarksController = TextEditingController();

  // P: Plan
  final _prescriptionController = TextEditingController();
  final _investigationsController = TextEditingController();
  final _adviceController = TextEditingController();
  DateTime? _nextFollowUpDate;

  bool _initialized = false;
  bool _isDirty = false;
  bool _isSaving = false;
  String? _existingRecordId;

  static const List<String> _quickComplaints = [
    'Fever',
    'Cough & Cold',
    'Abdominal Pain',
    'Headache',
    'Bodyache',
    'Weakness / Fatigue',
    'Vomiting / Nausea',
    'Skin Rash / Itching',
    'Chest Pain',
    'Joint Pain',
  ];

  static const List<String> _quickDiagnoses = [
    'Acute URI (Upper Resp Infection)',
    'Acute Bronchitis',
    'Acute Gastroenteritis',
    'Essential Hypertension',
    'Type 2 Diabetes Mellitus',
    'Acid Peptic Disease / GERD',
    'Allergic Rhinitis',
    'Migraine',
    'Urinary Tract Infection (UTI)',
    'Viral Fever / Pyrexia',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.existingRecord != null) {
      _populateFromExisting(
        SoapNoteData.fromMasterCaseRecord(widget.existingRecord!),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chiefComplaintController.dispose();
    _durationController.dispose();
    _hpiController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    _respRateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _sugarController.dispose();
    _examFindingsController.dispose();
    _workingDiagController.dispose();
    _differentialDiagController.dispose();
    _comorbiditiesController.dispose();
    _remarksController.dispose();
    _prescriptionController.dispose();
    _investigationsController.dispose();
    _adviceController.dispose();
    super.dispose();
  }

  void _populateFromExisting(SoapNoteData data) {
    if (_initialized) return;
    _initialized = true;
    _existingRecordId = data.id;

    _chiefComplaintController.text = data.chiefComplaint;
    _durationController.text = data.symptomDuration;
    _hpiController.text = data.hpi;

    _bpController.text = data.vitals.bloodPressure;
    _pulseController.text = data.vitals.pulse;
    _tempController.text = data.vitals.temperature;
    _spo2Controller.text = data.vitals.spo2;
    _respRateController.text = data.vitals.respiratoryRate;
    _weightController.text = data.vitals.weightKg;
    _heightController.text = data.vitals.heightCm;
    _sugarController.text = data.vitals.bloodSugar;
    _examFindingsController.text = data.physicalExamFindings;

    _workingDiagController.text =
        data.workingDiagnosis.isNotEmpty
            ? data.workingDiagnosis
            : (widget.patient.primaryDisease ?? '');
    _differentialDiagController.text = data.differentialDiagnosis;
    _comorbiditiesController.text = data.comorbidities;
    _remarksController.text = data.clinicalRemarks;

    _prescriptionController.text = data.prescriptionNotes;
    _investigationsController.text = data.investigationsOrdered;
    _adviceController.text = data.adviceLifestyle;
    _nextFollowUpDate = data.nextFollowUpDate;
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    AppHaptics.medium();
    final discard = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AppConfirmDialog(
            title: 'Discard SOAP Note?',
            message:
                'You have unsaved changes in this consultation note. Are you sure you want to discard them?',
            confirmLabel: 'Discard',
            isDestructive: true,
            onConfirm: () => Navigator.of(ctx).pop(true),
          ),
    );
    return discard ?? false;
  }

  SoapNoteData _buildSoapData() {
    final bmi = VitalSigns.calculateBmi(
      _weightController.text,
      _heightController.text,
    );

    final vitals = VitalSigns(
      bloodPressure: _bpController.text.trim(),
      pulse: _pulseController.text.trim(),
      temperature: _tempController.text.trim(),
      spo2: _spo2Controller.text.trim(),
      respiratoryRate: _respRateController.text.trim(),
      weightKg: _weightController.text.trim(),
      heightCm: _heightController.text.trim(),
      bmi: bmi,
      bloodSugar: _sugarController.text.trim(),
    );

    return SoapNoteData(
      id: _existingRecordId,
      patientId: widget.patient.id,
      recordDate: DateTime.now(),
      chiefComplaint: _chiefComplaintController.text.trim(),
      symptomDuration: _durationController.text.trim(),
      hpi: _hpiController.text.trim(),
      vitals: vitals,
      physicalExamFindings: _examFindingsController.text.trim(),
      workingDiagnosis: _workingDiagController.text.trim(),
      differentialDiagnosis: _differentialDiagController.text.trim(),
      comorbidities: _comorbiditiesController.text.trim(),
      clinicalRemarks: _remarksController.text.trim(),
      prescriptionNotes: _prescriptionController.text.trim(),
      investigationsOrdered: _investigationsController.text.trim(),
      adviceLifestyle: _adviceController.text.trim(),
      nextFollowUpDate: _nextFollowUpDate,
    );
  }

  Future<void> _saveSoapNote({bool andOpenRx = false}) async {
    AppHaptics.selection();
    setState(() => _isSaving = true);

    final messenger = ScaffoldMessenger.of(context);
    final soap = _buildSoapData();
    final masterRecord = soap.toMasterCaseRecord();

    try {
      final notifier = ref.read(caseRecordNotifierProvider.notifier);
      await notifier.saveCaseRecord(masterRecord);

      // Update patient primary disease if provided
      if (soap.workingDiagnosis.isNotEmpty) {
        final db = ref.read(databaseProvider);
        await (db.update(db.patients)
          ..where((t) => t.id.equals(widget.patient.id))).write(
          PatientsCompanion(
            primaryDisease: drift.Value(soap.workingDiagnosis),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }

      _isDirty = false;
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppHaptics.success();

      messenger.showSnackBar(
        SnackBar(
          content: const Text('SOAP Clinical Note saved successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (andOpenRx) {
        _openPrescriptionPreview(soap);
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppHaptics.error();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save SOAP note: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPrescriptionPreview(SoapNoteData soap) async {
    final clinics = ref.read(clinicsStreamProvider).value ?? [];
    final activeClinic = ref.read(activeClinicProvider);
    final primaryClinic =
        clinics
            .where((c) => c.id == widget.patient.primaryClinicId)
            .firstOrNull;
    final fallbackClinic = Clinic(
      id: 'clinic-default',
      name: 'Clinic',
      monthlyRent: 0,
      defaultConsultationFee: 0,
      openDays: '1,2,3,4,5,6',
      colorHex: '#0F5132',
      isActive: true,
      isDeleted: false,
      createdAt: DateTime.now(),
    );
    final clinic =
        primaryClinic ??
        activeClinic ??
        (clinics.isNotEmpty ? clinics.first : fallbackClinic);

    final doctorProfile =
        ref.read(doctorProfileStreamProvider).value ?? const DoctorProfile();

    final prescriptions =
        ref.read(patientPrescriptionsProvider(widget.patient.id)).value ?? [];

    await PrescriptionPreviewDialog.show(
      context,
      patient: widget.patient,
      clinic: clinic,
      doctorProfile: doctorProfile,
      prescriptions: prescriptions,
      diagnosis: soap.workingDiagnosis,
      additionalAdvice: soap.adviceLifestyle,
      nextFollowUpDate: soap.nextFollowUpDate,
    );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Load existing record if any
    final caseRecordAsync = ref.watch(
      patientCaseRecordProvider(widget.patient.id),
    );
    final existingCase = caseRecordAsync.value;
    if (existingCase != null && !_initialized) {
      _populateFromExisting(SoapNoteData.fromMasterCaseRecord(existingCase));
    }

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SOAP Clinical Note',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.patient.name} • ${widget.patient.gender}, ${widget.patient.age}y',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            tabs: const [
              Tab(text: 'S - Subjective'),
              Tab(text: 'O - Objective'),
              Tab(text: 'A - Assess'),
              Tab(text: 'P - Plan'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSubjectiveTab(theme, scheme),
            _buildObjectiveTab(theme, scheme),
            _buildAssessmentTab(theme, scheme),
            _buildPlanTab(theme, scheme),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton.tonal(
                    label: 'Save & Prescription',
                    icon: Icons.print_outlined,
                    loading: _isSaving,
                    onPressed:
                        _isSaving ? null : () => _saveSoapNote(andOpenRx: true),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: AppButton.primary(
                    label: 'Save SOAP Note',
                    icon: Icons.check,
                    loading: _isSaving,
                    onPressed: _isSaving ? null : () => _saveSoapNote(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectiveTab(ThemeData theme, ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text(
          'Chief Complaints & Symptoms',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Tap common symptoms to add or type patient-reported complaints.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),

        // Quick symptom chips
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children:
              _quickComplaints.map((complaint) {
                return ActionChip(
                  label: Text(complaint),
                  onPressed: () {
                    AppHaptics.selection();
                    _markDirty();
                    final current = _chiefComplaintController.text.trim();
                    if (current.isEmpty) {
                      _chiefComplaintController.text = complaint;
                    } else if (!current.contains(complaint)) {
                      _chiefComplaintController.text = '$current, $complaint';
                    }
                  },
                );
              }).toList(),
        ),

        const SizedBox(height: Spacing.lg),
        CustomTextField(
          controller: _chiefComplaintController,
          label: 'Chief Complaint(s) *',
          hint: 'e.g. High grade fever with severe bodyache',
          prefixIcon: Icons.sick_outlined,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: _durationController,
          label: 'Duration / Onset',
          hint: 'e.g. 3 days, since yesterday',
          prefixIcon: Icons.timer_outlined,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: _hpiController,
          label: 'History of Present Illness (HPI)',
          hint:
              'Detailed narrative: progression, aggravating/relieving factors, associated symptoms...',
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  Widget _buildObjectiveTab(ThemeData theme, ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        VitalSignsCard(
          bpController: _bpController,
          pulseController: _pulseController,
          tempController: _tempController,
          spo2Controller: _spo2Controller,
          respRateController: _respRateController,
          weightController: _weightController,
          heightController: _heightController,
          sugarController: _sugarController,
          onChanged: _markDirty,
        ),
        const SizedBox(height: Spacing.lg),
        Text(
          'Physical & Systemic Examination',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Record general appearance, respiratory, CVS, abdomen, throat/ENT findings.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        CustomTextField(
          controller: _examFindingsController,
          label: 'Examination Findings',
          hint:
              'e.g. Throat congested, bilateral wheezing, soft abdomen, no organomegaly...',
          prefixIcon: Icons.assignment_outlined,
          maxLines: 4,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  Widget _buildAssessmentTab(ThemeData theme, ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text(
          'Clinical Assessment & Diagnosis',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Primary working diagnosis sets the patient disease in practice tracking.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),

        // Quick diagnosis chips
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children:
              _quickDiagnoses.map((diag) {
                return ActionChip(
                  label: Text(diag),
                  onPressed: () {
                    AppHaptics.selection();
                    _markDirty();
                    _workingDiagController.text = diag;
                  },
                );
              }).toList(),
        ),

        const SizedBox(height: Spacing.lg),
        CustomTextField(
          controller: _workingDiagController,
          label: 'Primary Working Diagnosis *',
          hint: 'e.g. Acute Bronchitis',
          prefixIcon: Icons.medical_services_outlined,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: _differentialDiagController,
          label: 'Differential Diagnosis',
          hint: 'e.g. Bronchial Asthma, COVID-19',
          prefixIcon: Icons.alt_route_outlined,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: _comorbiditiesController,
          label: 'Comorbidities / Pre-existing Conditions',
          hint: 'e.g. Type 2 Diabetes, Hypertension',
          prefixIcon: Icons.healing_outlined,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: _remarksController,
          label: 'Clinical Notes / Red Flags',
          hint: 'e.g. Advised immediate hospitalization if chest pain worsens',
          prefixIcon: Icons.warning_amber_outlined,
          maxLines: 2,
          onChanged: (_) => _markDirty(),
        ),
      ],
    );
  }

  Widget _buildPlanTab(ThemeData theme, ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text(
          'Treatment Plan & Orders',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Prescriptions, ordered laboratory diagnostics, and follow-up schedule.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        CustomTextField(
          controller: _prescriptionController,
          label: 'Prescription & Medication Plan',
          hint:
              'e.g. Paracetamol 650mg TDS x 3 days, Azithromycin 500mg OD x 5 days...',
          prefixIcon: Icons.medication_outlined,
          maxLines: 4,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: _investigationsController,
          label: 'Lab Investigations / Diagnostic Tests Ordered',
          hint: 'e.g. CBC, Serum Creatinine, Chest X-Ray PA View',
          prefixIcon: Icons.biotech_outlined,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        CustomTextField(
          controller: _adviceController,
          label: 'Dietary & Lifestyle Advice / Precautions',
          hint:
              'e.g. Drink plenty of warm fluids, steam inhalation 2x daily, avoid oily food',
          prefixIcon: Icons.lightbulb_outline,
          maxLines: 3,
          onChanged: (_) => _markDirty(),
        ),
        const SizedBox(height: Spacing.md),
        DateField(
          label: 'Next Follow-up Date',
          value: _nextFollowUpDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          onChanged: (date) {
            _markDirty();
            setState(() => _nextFollowUpDate = date);
          },
        ),
      ],
    );
  }
}
