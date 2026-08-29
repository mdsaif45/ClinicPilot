import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/media_attachment_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../visits/providers/visit_provider.dart';
import '../models/case_record_models.dart';
import '../providers/case_record_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/investigation_provider.dart';
import '../providers/prescription_provider.dart';
import 'add_edit_complaint_dialog.dart';
import 'add_edit_investigation_dialog.dart';
import 'add_edit_prescription_dialog.dart';
import 'master_case_taking_screen.dart';

class ClinicalCaseSheetScreen extends ConsumerStatefulWidget {
  final Patient patient;

  const ClinicalCaseSheetScreen({super.key, required this.patient});

  @override
  ConsumerState<ClinicalCaseSheetScreen> createState() => _ClinicalCaseSheetScreenState();
}

class _ClinicalCaseSheetScreenState extends ConsumerState<ClinicalCaseSheetScreen> {
  int _selectedTab = 0; // 0: Baseline Case Record, 1: Follow-Up Visits History
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSection = 'All';

  static const List<String> _sections = [
    'All',
    'Complaints',
    'HPI',
    'Past History',
    'Family',
    'Physical Generals',
    'Mental Generals',
    'Lifestyle',
    'Vitals & Exam',
    'Miasm & Totality',
    'Diagnosis',
    'Prescription',
    'Investigations',
    'Outcome',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(List<String?> contents) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return contents.any((c) => c != null && c.toLowerCase().contains(q));
  }

  bool _isSectionVisible(String sectionKey, List<String?> contents) {
    if (_selectedSection != 'All' && _selectedSection != sectionKey) {
      return false;
    }
    return _matchesSearch(contents);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final recordAsync = ref.watch(patientCaseRecordProvider(widget.patient.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clinical Case Sheet',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_selectedTab == 0)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Master Case Taking',
              onPressed: () => _openEditor(context),
            )
          else
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add Follow-Up Entry',
              onPressed: () => _showFollowUpActionsSheet(context),
            ),
        ],
      ),
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showFollowUpActionsSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
            )
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.edit_note),
              label: const Text('Edit Case Taking'),
            ),
      body: recordAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Text(
              'Error loading case record: $err',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          ),
        ),
        data: (record) {
          if (record == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_late_outlined,
                      size: 64,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'No Case Record Found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'A comprehensive homeopathic case taking has not been recorded yet for this patient.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    AppButton.primary(
                      label: 'Start Clinical Case Taking',
                      icon: Icons.add_chart,
                      onPressed: () => _openEditor(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Top Sub-segmented Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
                color: scheme.surface,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: Radii.lgAll,
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SubTabButton(
                          isSelected: _selectedTab == 0,
                          icon: Icons.assignment_outlined,
                          label: 'Master Baseline Record',
                          onTap: () {
                            AppHaptics.selection();
                            setState(() => _selectedTab = 0);
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _SubTabButton(
                          isSelected: _selectedTab == 1,
                          icon: Icons.timeline_outlined,
                          label: 'Follow-Up Visits History',
                          onTap: () {
                            AppHaptics.selection();
                            setState(() => _selectedTab = 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: _selectedTab == 0
                    ? Column(
                        children: [
                          // Search & Section Jump Filter Bar
                          _buildSearchAndFilterHeader(context),

                          // Main Clinical Content Area
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.lg,
                                vertical: Spacing.md,
                              ),
                              children: [
                                // 1. Patient & Executive Clinical Summary Card
                                if (_selectedSection == 'All' && _searchQuery.isEmpty) ...[
                                  _buildPatientHeader(context, record),
                                  const SizedBox(height: Spacing.md),
                                ],

                      // 2. Chief Complaints
                      if (_isSectionVisible('Complaints', [
                        ...record.chiefComplaints.map((c) => '${c.complaint} ${c.sensation} ${c.location} ${c.modalitiesAgg} ${c.modalitiesAmel} ${c.concomitants} ${c.causation}'),
                        record.additionalComplaints,
                      ]))
                        _buildChiefComplaintsSection(context, record),

                    // 3. History of Present Illness (HPI)
                    if (_isSectionVisible('HPI', [
                      record.hpi.chronologicalDevelopment,
                      record.hpi.firstOccurrence,
                      record.hpi.progression,
                      record.hpi.previousEpisodes,
                      record.hpi.previousTreatment,
                      record.hpi.responseToTreatment,
                      record.hpi.relevantPrecipitatingFactors,
                    ]))
                      _buildHpiSection(context, record),

                    // 4. Past Medical History & Allergies
                    if (_isSectionVisible('Past History', [
                      record.pastHistory.allergies,
                      record.pastHistory.childhoodIllnesses,
                      record.pastHistory.majorIllnesses,
                      record.pastHistory.chronicDiseases,
                      record.pastHistory.surgeries,
                      record.pastHistory.previousHomeopathicTreatment,
                    ]))
                      _buildPastHistorySection(context, record),

                    // 5. Family History
                    if (_isSectionVisible('Family', [
                      record.familyHistory.father,
                      record.familyHistory.mother,
                      record.familyHistory.siblings,
                      record.familyHistory.majorFamilialDiseases,
                      record.familyHistory.hereditaryDiseases,
                    ]))
                      _buildFamilyHistorySection(context, record),

                    // 6. Physical Generals
                    if (_isSectionVisible('Physical Generals', [
                      record.physicalGenerals.thermal,
                      record.physicalGenerals.appetite,
                      record.physicalGenerals.thirst,
                      record.physicalGenerals.cravings,
                      record.physicalGenerals.aversions,
                      record.physicalGenerals.sleep,
                      record.physicalGenerals.dreams,
                      record.physicalGenerals.perspiration,
                      record.physicalGenerals.stool,
                      record.physicalGenerals.urine,
                    ]))
                      _buildPhysicalGeneralsSection(context, record),

                    // 7. Mental Generals
                    if (_isSectionVisible('Mental Generals', [
                      record.mentalGenerals.generalMentalState,
                      record.mentalGenerals.disposition,
                      record.mentalGenerals.anxiety,
                      record.mentalGenerals.fears,
                      record.mentalGenerals.sadnessGrief,
                      record.mentalGenerals.anger,
                      record.mentalGenerals.responseToStress,
                    ]))
                      _buildMentalGeneralsSection(context, record),

                    // 8. Lifestyle & Habits
                    if (_isSectionVisible('Lifestyle', [
                      record.lifestyleHabits.diet,
                      record.lifestyleHabits.physicalActivity,
                      record.lifestyleHabits.occupationWorkPattern,
                      record.lifestyleHabits.financialOccupationalStressors,
                      record.lifestyleHabits.otherHabits,
                    ]))
                      _buildLifestyleSection(context, record),

                    // 9. Clinical Examination & Vitals
                    if (_isSectionVisible('Vitals & Exam', [
                      record.clinicalExam.bloodPressure,
                      record.clinicalExam.pulse,
                      record.clinicalExam.temperature,
                      record.clinicalExam.respiratoryRate,
                      record.clinicalExam.spo2,
                      record.clinicalExam.weightKg,
                      record.clinicalExam.heightCm,
                      record.clinicalExam.bmi,
                      record.clinicalExam.generalAppearance,
                      record.clinicalExam.respiratoryExamination,
                      record.clinicalExam.cvsExamination,
                      record.clinicalExam.abdominalExamination,
                      record.clinicalExam.skinExamination,
                    ]))
                      _buildClinicalExamSection(context, record),

                    // 10. Miasmatic Analysis & Totality of Symptoms
                    if (_isSectionVisible('Miasm & Totality', [
                      record.miasmaticAnalysis.dominantMiasm,
                      record.miasmaticAnalysis.secondaryMixedMiasm,
                      record.caseTotality.totalityOfSymptoms,
                      record.caseTotality.characteristicSymptoms,
                      record.caseTotality.generals,
                      record.caseTotality.finalRemedySelection,
                      record.caseTotality.potency,
                    ]))
                      _buildMiasmAndTotalitySection(context, record),

                    // 11. Diagnosis & Working Assessment
                    if (_isSectionVisible('Diagnosis', [
                      record.clinicalAssessment.finalWorkingDiagnosis,
                      record.clinicalAssessment.provisionalDiagnosis,
                      record.clinicalAssessment.differentialDiagnosis,
                      record.clinicalAssessment.clinicalRemarks,
                    ]))
                      _buildDiagnosisSection(context, record),

                    // 12. Baseline Prescription Plan
                    if (_isSectionVisible('Prescription', [
                      record.baselinePrescription.remedyName,
                      record.baselinePrescription.potency,
                      record.baselinePrescription.dose,
                      record.baselinePrescription.repetitionFrequency,
                      record.baselinePrescription.route,
                      record.baselinePrescription.dietRegimenAdvice,
                      record.baselinePrescription.lifestyleAdvice,
                    ]))
                      _buildPrescriptionSection(context, record),

                    // 13. Investigations & Diagnostic Reports
                    if (_isSectionVisible('Investigations', [
                      record.investigations.investigationName,
                      record.investigations.reportSummary,
                      record.investigations.normalAbnormal,
                    ]))
                      _buildInvestigationsSection(context, record),

                    // 14. Follow-Up & Outcome Notes
                    if (_isSectionVisible('Outcome', [
                      record.displayOutcome,
                      record.outcomeDetails.degreeOfImprovement,
                      record.outcomeDetails.treatmentDuration,
                      record.followUpDetails.overallResponse,
                      record.followUpDetails.followUpRemarks,
                      record.followUpDetails.chiefComplaintChanges,
                      record.followUpDetails.nextFollowUp,
                    ]))
                      _buildFollowUpSection(context, record),

                    const SizedBox(height: Spacing.sm),

                    // Bottom Edit Button
                    AppButton.primary(
                      label: 'Edit Master Case Record',
                      icon: Icons.edit_note_outlined,
                      fullWidth: true,
                      onPressed: () => _openEditor(context),
                    ),
                                const SizedBox(height: Spacing.xxl),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _buildFollowUpHistoryView(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFollowUpHistoryView(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final visitsAsync = ref.watch(patientVisitsStreamProvider(widget.patient.id));
    final complaintsAsync = ref.watch(patientComplaintsProvider(widget.patient.id));
    final prescriptionsAsync = ref.watch(patientPrescriptionsProvider(widget.patient.id));
    final investigationsAsync = ref.watch(patientInvestigationsProvider(widget.patient.id));

    final allVisits = visitsAsync.value ?? [];
    final allComplaints = complaintsAsync.value ?? [];
    final allPrescriptions = prescriptionsAsync.value ?? [];
    final allInvestigations = investigationsAsync.value ?? [];

    final followUpComplaints = allComplaints.where((c) => !(c.isBaseline ?? true)).toList();
    final followUpPrescriptions = allPrescriptions.where((p) => !(p.isBaseline ?? true)).toList();
    final followUpInvestigations = allInvestigations.where((i) => !(i.isBaseline ?? true)).toList();

    final hasFollowUps = allVisits.length > 1 ||
        followUpComplaints.isNotEmpty ||
        followUpPrescriptions.isNotEmpty ||
        followUpInvestigations.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
      children: [
        // Summary Metric Badges (Visits, Complaints, Prescriptions, Lab Reports)
        Row(
          children: [
            Expanded(
              child: _MetricPill(
                icon: Icons.event_available,
                label: 'Visits',
                value: '${allVisits.length}',
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: _MetricPill(
                icon: Icons.healing_outlined,
                label: 'Complaints',
                value: '${followUpComplaints.length}',
                color: scheme.tertiary,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: _MetricPill(
                icon: Icons.medication_outlined,
                label: 'Remedies',
                value: '${followUpPrescriptions.length}',
                color: scheme.secondary,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: _MetricPill(
                icon: Icons.biotech_outlined,
                label: 'Lab Tests',
                value: '${followUpInvestigations.length}',
                color: scheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),

        if (!hasFollowUps) ...[
          AppCard(
            margin: EdgeInsets.zero,
            child: EmptyState(
              icon: Icons.timeline,
              title: 'No Follow-Up Visits Logged Yet',
              message:
                  'Initial Master Case Taking is safely locked as baseline. When the patient returns for subsequent visits, add new follow-up complaints, remedy adjustments, and progress photos here.',
              actionLabel: 'Log First Follow-Up Complaint',
              onAction: () {
                AppHaptics.selection();
                showDialog(
                  context: context,
                  builder: (_) => AddEditComplaintDialog(
                    patientId: widget.patient.id,
                    defaultIndex: allComplaints.length + 1,
                    defaultIsBaseline: false,
                  ),
                );
              },
            ),
          ),
        ] else ...[
          // Chronological Follow-Up Timeline Feed
          Text(
            'Chronological Follow-Up Encounters & Progression',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Follow-up Complaints Section
          if (followUpComplaints.isNotEmpty) ...[
            _SectionHeaderCard(
              title: 'Follow-Up Complaints & Condition Changes (${followUpComplaints.length})',
              icon: Icons.healing,
              color: scheme.tertiary,
            ),
            const SizedBox(height: Spacing.xs),
            for (final c in followUpComplaints) ...[
              _FollowUpComplaintCard(complaint: c, patientId: widget.patient.id),
              const SizedBox(height: Spacing.xs),
            ],
            const SizedBox(height: Spacing.md),
          ],

          // Follow-up Prescriptions Section
          if (followUpPrescriptions.isNotEmpty) ...[
            _SectionHeaderCard(
              title: 'Follow-Up Remedies Prescribed (${followUpPrescriptions.length})',
              icon: Icons.medication,
              color: scheme.secondary,
            ),
            const SizedBox(height: Spacing.xs),
            for (final p in followUpPrescriptions) ...[
              _FollowUpPrescriptionCard(prescription: p),
              const SizedBox(height: Spacing.xs),
            ],
            const SizedBox(height: Spacing.md),
          ],

          // Follow-up Lab Tests Section
          if (followUpInvestigations.isNotEmpty) ...[
            _SectionHeaderCard(
              title: 'Follow-Up Diagnostic Tests & Reports (${followUpInvestigations.length})',
              icon: Icons.biotech,
              color: scheme.error,
            ),
            const SizedBox(height: Spacing.xs),
            for (final inv in followUpInvestigations) ...[
              _FollowUpInvestigationCard(investigation: inv),
              const SizedBox(height: Spacing.xs),
            ],
            const SizedBox(height: Spacing.md),
          ],

          // Clinical Visits Log
          if (allVisits.isNotEmpty) ...[
            _SectionHeaderCard(
              title: 'Clinical Consultation History (${allVisits.length})',
              icon: Icons.history_edu,
              color: scheme.primary,
            ),
            const SizedBox(height: Spacing.xs),
            for (final v in allVisits) ...[
              _VisitSummaryCard(visitWithDetails: v),
              const SizedBox(height: Spacing.xs),
            ],
          ],
        ],
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => MasterCaseTakingScreen(patient: widget.patient),
      ),
    );
  }

  void _showFollowUpActionsSheet(BuildContext context) {
    AppHaptics.selection();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final allComplaints = ref.read(patientComplaintsProvider(widget.patient.id)).value ?? [];
    final allPrescriptions = ref.read(patientPrescriptionsProvider(widget.patient.id)).value ?? [];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            0,
            Spacing.lg,
            Spacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Follow-Up Entry',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Record clinical progression for ${widget.patient.name}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.tertiary,
                  child: const Icon(Icons.healing_outlined, size: 20),
                ),
                title: const Text('Add Follow-Up Complaint'),
                subtitle: const Text('Progress, new modalities, symptom severity'),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showDialog(
                    context: context,
                    builder: (_) => AddEditComplaintDialog(
                      patientId: widget.patient.id,
                      defaultIndex: allComplaints.length + 1,
                      defaultIsBaseline: false,
                    ),
                  );
                },
              ),
              const SizedBox(height: Spacing.xs),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.secondary,
                  child: const Icon(Icons.medication_outlined, size: 20),
                ),
                title: const Text('Prescribe Follow-Up Remedy'),
                subtitle: const Text('New potency, dose change, or repeat Rx'),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showDialog(
                    context: context,
                    builder: (_) => AddEditPrescriptionDialog(
                      patientId: widget.patient.id,
                      defaultIndex: allPrescriptions.length + 1,
                      defaultIsBaseline: false,
                    ),
                  );
                },
              ),
              const SizedBox(height: Spacing.xs),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.error,
                  child: const Icon(Icons.biotech_outlined, size: 20),
                ),
                title: const Text('Upload Lab / Scan Report'),
                subtitle: const Text('Test values, reference ranges, report scans'),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showDialog(
                    context: context,
                    builder: (_) => AddEditInvestigationDialog(
                      patientId: widget.patient.id,
                      defaultIsBaseline: false,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Search & Section Quick-Jump Filter Header ---
  Widget _buildSearchAndFilterHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.xs,
        bottom: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search symptoms, modalities, remedies...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(Icons.search, size: 20, color: scheme.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: Radii.smAll,
                borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: Radii.smAll,
                borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Radii.smAll,
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs + 2),

          // Horizontal Quick-Jump Chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
              itemBuilder: (context, index) {
                final s = _sections[index];
                final isSelected = _selectedSection == s;

                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedSection = s);
                    }
                  },
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                  selectedColor: scheme.primary,
                  backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: Radii.pillAll,
                    side: BorderSide(
                      color: isSelected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Banner with Patient Identity & Key Highlights ---
  Widget _buildPatientHeader(BuildContext context, MasterCaseRecordData record) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final miasm = record.miasmaticAnalysis.dominantMiasm;
    final thermal = record.physicalGenerals.thermal;
    final rawRemedy = record.caseTotality.selectedRemedy.trim();
    final cleanRemedy = rawRemedy.split(' selected')[0].split(' based')[0].trim();
    final remedy = cleanRemedy.isNotEmpty ? cleanRemedy : rawRemedy;
    final potency = record.caseTotality.potency;
    final outcome = record.displayOutcome;

    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  widget.patient.name.isNotEmpty ? widget.patient.name[0].toUpperCase() : 'P',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: Spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.patient.patientCode.isNotEmpty)
                          Text(
                            widget.patient.patientCode,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (widget.patient.patientCode.isNotEmpty)
                          Text('•', style: TextStyle(color: scheme.outline)),
                        Text(
                          '${widget.patient.age}y, ${widget.patient.gender}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        if (widget.patient.area != null && widget.patient.area!.isNotEmpty) ...[
                          Text('•', style: TextStyle(color: scheme.outline)),
                          Text(
                            widget.patient.area!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Case Recorded: ${Formatters.formatDate(record.recordDate)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (miasm.isNotEmpty || thermal.isNotEmpty || remedy.isNotEmpty || outcome.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            const Divider(height: 1),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                if (miasm.isNotEmpty)
                  CustomBadge(
                    label: 'Miasm: $miasm',
                    color: scheme.primary,
                    icon: Icons.coronavirus_outlined,
                  ),
                if (thermal.isNotEmpty)
                  CustomBadge(
                    label: 'Thermal: $thermal',
                    color: scheme.tertiary,
                    icon: Icons.thermostat_outlined,
                  ),
                if (remedy.isNotEmpty)
                  CustomBadge(
                    label: 'Remedy: $remedy $potency'.trim(),
                    color: scheme.secondary,
                    icon: Icons.medication_outlined,
                  ),
                if (outcome.isNotEmpty)
                  CustomBadge(
                    label: outcome,
                    color: scheme.primary,
                    icon: Icons.flag_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- 1. Chief Complaints ---
  Widget _buildChiefComplaintsSection(BuildContext context, MasterCaseRecordData record) {
    if (record.chiefComplaints.isEmpty && record.additionalComplaints.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _SectionCard(
      title: 'Chief Complaints',
      icon: Icons.healing_outlined,
      children: [
        for (final (i, c) in record.chiefComplaints.indexed) ...[
          if (c.complaint.isNotEmpty) ...[
            if (i > 0) const Divider(height: Spacing.lg),
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      c.complaint,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  if (c.severity.isNotEmpty)
                    CustomBadge(
                      label: c.severity,
                      color: c.severity.toLowerCase().contains('severe')
                          ? scheme.error
                          : (c.severity.toLowerCase().contains('mild')
                              ? scheme.primary
                              : scheme.tertiary),
                    ),
                ],
              ),
            ),
            _ClinicalRow(label: 'Location / Organ', value: c.location),
            _ClinicalRow(label: 'Sensation / Character', value: c.sensation),
            _ClinicalRow(label: 'Duration / Chronicity', value: c.duration),
            if (c.modalitiesAgg.isNotEmpty)
              _ModalityRow(
                isAggravation: true,
                label: 'Aggravation (<)',
                value: c.modalitiesAgg,
              ),
            if (c.modalitiesAmel.isNotEmpty)
              _ModalityRow(
                isAggravation: false,
                label: 'Amelioration (>)',
                value: c.modalitiesAmel,
              ),
            _ClinicalRow(label: 'Concomitants', value: c.concomitants),
            _ClinicalRow(label: 'Aetiology / Cause', value: c.causation),
          ],
        ],
        if (record.additionalComplaints.isNotEmpty)
          _ClinicalRow(label: 'Additional Complaints', value: record.additionalComplaints),
      ],
    );
  }

  // --- 2. HPI ---
  Widget _buildHpiSection(BuildContext context, MasterCaseRecordData record) {
    final hpi = record.hpi;
    final hasData = hpi.chronologicalDevelopment.isNotEmpty ||
        hpi.firstOccurrence.isNotEmpty ||
        hpi.progression.isNotEmpty ||
        hpi.previousEpisodes.isNotEmpty ||
        hpi.previousTreatment.isNotEmpty ||
        hpi.responseToTreatment.isNotEmpty ||
        hpi.relevantPrecipitatingFactors.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'History of Present Illness (HPI)',
      icon: Icons.history_edu_outlined,
      children: [
        _ClinicalRow(label: 'Chronological Development', value: hpi.chronologicalDevelopment),
        _ClinicalRow(label: 'First Occurrence & Trigger', value: hpi.firstOccurrence),
        _ClinicalRow(label: 'Disease Pace & Course', value: hpi.progression),
        _ClinicalRow(label: 'Previous Episodes / Remissions', value: hpi.previousEpisodes),
        _ClinicalRow(label: 'Past Treatments Taken', value: hpi.previousTreatment),
        _ClinicalRow(label: 'Response to Past Therapies', value: hpi.responseToTreatment),
        _ClinicalRow(label: 'Precipitating Factors', value: hpi.relevantPrecipitatingFactors),
      ],
    );
  }

  // --- 3. Past History ---
  Widget _buildPastHistorySection(BuildContext context, MasterCaseRecordData record) {
    final p = record.pastHistory;
    final hasData = p.allergies.isNotEmpty ||
        p.childhoodIllnesses.isNotEmpty ||
        p.majorIllnesses.isNotEmpty ||
        p.chronicDiseases.isNotEmpty ||
        p.surgeries.isNotEmpty ||
        p.previousHomeopathicTreatment.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'Past Medical History & Allergies',
      icon: Icons.medical_information_outlined,
      children: [
        if (p.allergies.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: Spacing.sm),
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: Radii.smAll,
              border: Border.all(color: scheme.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error),
                const SizedBox(width: Spacing.xs + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Known Allergies / Hypersensitivities',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: scheme.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.allergies,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        _ClinicalRow(label: 'Childhood Illnesses', value: p.childhoodIllnesses),
        _ClinicalRow(label: 'Major Illnesses / Admissions', value: p.majorIllnesses),
        _ClinicalRow(label: 'Chronic Diseases', value: p.chronicDiseases),
        _ClinicalRow(label: 'Surgeries / Trauma', value: p.surgeries),
        _ClinicalRow(label: 'Prior Homeopathy Experience', value: p.previousHomeopathicTreatment),
      ],
    );
  }

  // --- 4. Family History ---
  Widget _buildFamilyHistorySection(BuildContext context, MasterCaseRecordData record) {
    final f = record.familyHistory;
    final hasData = f.father.isNotEmpty ||
        f.mother.isNotEmpty ||
        f.siblings.isNotEmpty ||
        f.majorFamilialDiseases.isNotEmpty ||
        f.hereditaryDiseases.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Family Medical History',
      icon: Icons.family_restroom_outlined,
      children: [
        _ClinicalRow(label: 'Father Health & Diseases', value: f.father),
        _ClinicalRow(label: 'Mother Health & Diseases', value: f.mother),
        _ClinicalRow(label: 'Siblings / Children', value: f.siblings),
        _ClinicalRow(label: 'Familial Chronic Diseases', value: f.majorFamilialDiseases),
        _ClinicalRow(label: 'Hereditary Tendencies / Miasm', value: f.hereditaryDiseases),
      ],
    );
  }

  // --- 5. Physical Generals ---
  Widget _buildPhysicalGeneralsSection(BuildContext context, MasterCaseRecordData record) {
    final pg = record.physicalGenerals;
    final hasData = pg.thermal.isNotEmpty ||
        pg.appetite.isNotEmpty ||
        pg.thirst.isNotEmpty ||
        pg.cravings.isNotEmpty ||
        pg.aversions.isNotEmpty ||
        pg.sleep.isNotEmpty ||
        pg.dreams.isNotEmpty ||
        pg.perspiration.isNotEmpty ||
        pg.stool.isNotEmpty ||
        pg.urine.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Physical Generals & Modalities',
      icon: Icons.accessibility_new_outlined,
      children: [
        _ClinicalRow(label: 'Thermal Reaction', value: pg.thermal),
        _ClinicalRow(label: 'Appetite & Hunger Timing', value: pg.appetite),
        _ClinicalRow(label: 'Thirst (Quantity & Frequency)', value: pg.thirst),
        _ClinicalRow(label: 'Food Cravings', value: pg.cravings),
        _ClinicalRow(label: 'Food Aversions & Intolerances', value: pg.aversions),
        _ClinicalRow(label: 'Sleep Quality & Pattern', value: pg.sleep),
        _ClinicalRow(label: 'Dreams & Subconscious', value: pg.dreams),
        _ClinicalRow(label: 'Perspiration & Distribution', value: pg.perspiration),
        _ClinicalRow(label: 'Bowel / Stool Habits', value: pg.stool),
        _ClinicalRow(label: 'Urine & Urinary Tract', value: pg.urine),
      ],
    );
  }

  // --- 6. Mental Generals ---
  Widget _buildMentalGeneralsSection(BuildContext context, MasterCaseRecordData record) {
    final mg = record.mentalGenerals;
    final hasData = mg.generalMentalState.isNotEmpty ||
        mg.disposition.isNotEmpty ||
        mg.anxiety.isNotEmpty ||
        mg.fears.isNotEmpty ||
        mg.sadnessGrief.isNotEmpty ||
        mg.anger.isNotEmpty ||
        mg.responseToStress.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Mental Generals & Emotional Disposition',
      icon: Icons.psychology_outlined,
      children: [
        _ClinicalRow(label: 'General Mental State', value: mg.generalMentalState),
        _ClinicalRow(label: 'Disposition & Temperament', value: mg.disposition),
        _ClinicalRow(label: 'Anxiety & Phobias / Fears', value: mg.fears.isNotEmpty ? mg.fears : mg.anxiety),
        _ClinicalRow(label: 'Sadness, Grief & Depression', value: mg.sadnessGrief),
        _ClinicalRow(label: 'Anger & Irritability', value: mg.anger),
        _ClinicalRow(label: 'Reaction to Stress & Friction', value: mg.responseToStress),
      ],
    );
  }

  // --- 7. Lifestyle ---
  Widget _buildLifestyleSection(BuildContext context, MasterCaseRecordData record) {
    final l = record.lifestyleHabits;
    final hasData = l.diet.isNotEmpty ||
        l.physicalActivity.isNotEmpty ||
        l.occupationWorkPattern.isNotEmpty ||
        l.financialOccupationalStressors.isNotEmpty ||
        l.otherHabits.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Lifestyle, Diet & Occupation',
      icon: Icons.nature_people_outlined,
      children: [
        _ClinicalRow(label: 'Dietary Habits', value: l.diet),
        _ClinicalRow(label: 'Physical Activity & Exercise', value: l.physicalActivity),
        _ClinicalRow(label: 'Occupational Routine', value: l.occupationWorkPattern),
        _ClinicalRow(label: 'Key Life Stress Factors', value: l.financialOccupationalStressors),
        _ClinicalRow(label: 'Habits & Substances', value: l.otherHabits),
      ],
    );
  }

  // --- 8. Clinical Exam & Vitals ---
  Widget _buildClinicalExamSection(BuildContext context, MasterCaseRecordData record) {
    final ce = record.clinicalExam;
    final hasData = ce.bloodPressure.isNotEmpty ||
        ce.pulse.isNotEmpty ||
        ce.temperature.isNotEmpty ||
        ce.respiratoryRate.isNotEmpty ||
        ce.spo2.isNotEmpty ||
        ce.weightKg.isNotEmpty ||
        ce.heightCm.isNotEmpty ||
        ce.generalAppearance.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'Clinical Examination & Physical Vitals',
      icon: Icons.monitor_heart_outlined,
      children: [
        if (ce.bloodPressure.isNotEmpty || ce.pulse.isNotEmpty || ce.temperature.isNotEmpty || ce.weightKg.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                if (ce.bloodPressure.isNotEmpty)
                  CustomBadge(
                    label: 'BP: ${ce.bloodPressure}',
                    color: scheme.primary,
                  ),
                if (ce.pulse.isNotEmpty)
                  CustomBadge(
                    label: 'Pulse: ${ce.pulse}',
                    color: scheme.secondary,
                  ),
                if (ce.temperature.isNotEmpty)
                  CustomBadge(
                    label: 'Temp: ${ce.temperature}',
                    color: scheme.tertiary,
                  ),
                if (ce.spo2.isNotEmpty)
                  CustomBadge(
                    label: 'SpO2: ${ce.spo2}',
                    color: scheme.primary,
                  ),
                if (ce.weightKg.isNotEmpty)
                  CustomBadge(
                    label: 'Wt: ${ce.weightKg}',
                    color: scheme.onSurfaceVariant,
                  ),
                if (ce.bmi.isNotEmpty)
                  CustomBadge(
                    label: 'BMI: ${ce.bmi}',
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        _ClinicalRow(label: 'General Appearance & Build', value: ce.generalAppearance),
        _ClinicalRow(label: 'Respiratory Examination', value: ce.respiratoryExamination),
        _ClinicalRow(label: 'Cardiovascular System', value: ce.cvsExamination),
        _ClinicalRow(label: 'Abdominal Examination', value: ce.abdominalExamination),
        _ClinicalRow(label: 'Skin & Mucosa Findings', value: ce.skinExamination),
      ],
    );
  }

  // --- 9. Miasm & Totality ---
  Widget _buildMiasmAndTotalitySection(BuildContext context, MasterCaseRecordData record) {
    final m = record.miasmaticAnalysis;
    final t = record.caseTotality;
    final hasData = m.dominantMiasm.isNotEmpty ||
        t.totalityOfSymptoms.isNotEmpty ||
        t.characteristicSymptoms.isNotEmpty ||
        t.finalRemedySelection.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Miasmatic Analysis & Case Totality',
      icon: Icons.balance_outlined,
      children: [
        _ClinicalRow(label: 'Dominant Miasm', value: m.dominantMiasm),
        _ClinicalRow(label: 'Secondary / Mixed Miasm', value: m.secondaryMixedMiasm),
        _ClinicalRow(label: 'Totality of Symptoms', value: t.totalityOfSymptoms),
        _ClinicalRow(label: 'Characteristic Particulars', value: t.characteristicSymptoms),
        _ClinicalRow(label: 'Generals (Mental & Physical)', value: t.generals),
        _ClinicalRow(
          label: 'Selected Simillimum Remedy',
          value: t.finalRemedySelection.isNotEmpty
              ? '${t.finalRemedySelection} ${t.potency}'.trim()
              : '',
          valueColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  // --- 10. Diagnosis & Assessment ---
  Widget _buildDiagnosisSection(BuildContext context, MasterCaseRecordData record) {
    final a = record.clinicalAssessment;
    final hasData = a.finalWorkingDiagnosis.isNotEmpty ||
        a.provisionalDiagnosis.isNotEmpty ||
        a.differentialDiagnosis.isNotEmpty ||
        a.clinicalRemarks.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Diagnosis & Clinical Assessment',
      icon: Icons.fact_check_outlined,
      children: [
        _ClinicalRow(
          label: 'Final Working Diagnosis',
          value: a.finalWorkingDiagnosis.isNotEmpty ? a.finalWorkingDiagnosis : a.provisionalDiagnosis,
          valueColor: Theme.of(context).colorScheme.primary,
        ),
        _ClinicalRow(label: 'Provisional Diagnosis', value: a.provisionalDiagnosis),
        _ClinicalRow(label: 'Differential Diagnosis', value: a.differentialDiagnosis),
        _ClinicalRow(label: 'Clinical Remarks & Notes', value: a.clinicalRemarks),
      ],
    );
  }

  // --- 11. Baseline Prescription ---
  Widget _buildPrescriptionSection(BuildContext context, MasterCaseRecordData record) {
    final p = record.baselinePrescription;
    final hasData = p.remedyName.isNotEmpty ||
        p.dose.isNotEmpty ||
        p.repetitionFrequency.isNotEmpty ||
        p.dietRegimenAdvice.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _SectionCard(
      title: 'Baseline Prescription Plan',
      icon: Icons.local_pharmacy_outlined,
      children: [
        // Prescription Hero Card
        Container(
          margin: const EdgeInsets.only(bottom: Spacing.sm),
          padding: const EdgeInsets.all(Spacing.sm + 2),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: Radii.smAll,
            border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '℞',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p.remedyName} ${p.potency}'.trim(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                    if (p.dose.isNotEmpty || p.pharmaceuticalForm.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${p.dose} (${p.pharmaceuticalForm}) • ${p.repetitionFrequency}'.trim(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _ClinicalRow(label: 'Route of Administration', value: p.route),
        _ClinicalRow(label: 'Dietary Regimen & Restrictions', value: p.dietRegimenAdvice),
        _ClinicalRow(label: 'Lifestyle & Adjunctive Advice', value: p.lifestyleAdvice),
      ],
    );
  }

  // --- 12. Investigations ---
  Widget _buildInvestigationsSection(BuildContext context, MasterCaseRecordData record) {
    final inv = record.investigations;
    final hasData = inv.investigationName.isNotEmpty || inv.reportSummary.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Diagnostic Investigations & Lab Tests',
      icon: Icons.biotech_outlined,
      children: [
        _ClinicalRow(label: 'Test Advised / Performed', value: inv.investigationName),
        _ClinicalRow(label: 'Report Findings Summary', value: inv.reportSummary),
        _ClinicalRow(label: 'Status / Clinical Normalcy', value: inv.normalAbnormal),
      ],
    );
  }

  // --- 13. Follow-Up & Outcome ---
  Widget _buildFollowUpSection(BuildContext context, MasterCaseRecordData record) {
    final fu = record.followUpDetails;
    final out = record.outcomeDetails;
    final remarks = fu.followUpRemarks.isNotEmpty
        ? fu.followUpRemarks
        : (record.followUpNotes.isNotEmpty && !record.followUpNotes.startsWith('{')
            ? record.followUpNotes
            : '');
    final hasData = record.displayOutcome.isNotEmpty ||
        fu.overallResponse.isNotEmpty ||
        out.degreeOfImprovement.isNotEmpty ||
        out.treatmentDuration.isNotEmpty ||
        remarks.isNotEmpty ||
        fu.chiefComplaintChanges.isNotEmpty ||
        fu.nextFollowUp.isNotEmpty;

    if (!hasData) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Treatment Outcome & Follow-Up',
      icon: Icons.insights_outlined,
      children: [
        _ClinicalRow(label: 'Current Clinical Status', value: record.displayOutcome),
        _ClinicalRow(label: 'Degree of Improvement', value: out.degreeOfImprovement),
        _ClinicalRow(label: 'Treatment Duration', value: out.treatmentDuration),
        _ClinicalRow(label: 'Overall Patient Response', value: fu.overallResponse),
        _ClinicalRow(label: 'Chief Complaint Changes', value: fu.chiefComplaintChanges),
        _ClinicalRow(label: 'Next Follow-Up Target', value: fu.nextFollowUp),
        _ClinicalRow(label: 'Case Notes & Observations', value: remarks),
      ],
    );
  }
}

// --- Standard Section Card matching AppCard styling ---

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
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
                padding: const EdgeInsets.all(Spacing.xs + 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: Radii.smAll,
                ),
                child: Icon(icon, size: 18, color: scheme.primary),
              ),
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
          const SizedBox(height: Spacing.sm),
          const Divider(height: 1),
          const SizedBox(height: Spacing.xs),
          ...children,
        ],
      ),
    );
  }
}

// --- Clean Standardized Medical Key-Value Row ---

class _ClinicalRow extends StatelessWidget {
  final String label;
  final String? value;
  final Color? valueColor;

  const _ClinicalRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.xs + 1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              v,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? scheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Visual Modality Row (< Aggravation and > Amelioration) ---

class _ModalityRow extends StatelessWidget {
  final bool isAggravation;
  final String label;
  final String value;

  const _ModalityRow({
    required this.isAggravation,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.trim();
    if (v.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final badgeColor = isAggravation ? scheme.error : scheme.primary;
    final symbol = isAggravation ? '<' : '>';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs + 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: Radii.smAll,
                  ),
                  child: Text(
                    symbol,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              v,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs + 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.mdAll,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeaderCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _FollowUpComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final String patientId;

  const _FollowUpComplaintCard({
    required this.complaint,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final beforeImgs = ComplaintNotifier.parseImages(complaint.beforeImages);
    final afterImgs = ComplaintNotifier.parseImages(complaint.afterImages);
    final totalPhotos = beforeImgs.length + afterImgs.length;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(Spacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  '#${complaint.complaintIndex}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  complaint.complaintName,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              CustomBadge(
                label: complaint.status,
                color: scheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Recorded: ${Formatters.formatDate(complaint.complaintDate ?? complaint.createdAt)} • Severity: ${complaint.severity}/10',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          if (totalPhotos > 0) ...[
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                Icon(Icons.photo_library_outlined, size: 14, color: scheme.primary),
                const SizedBox(width: 4),
                Text(
                  '$totalPhotos progress photos (${beforeImgs.length} Before / ${afterImgs.length} After)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if ((complaint.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              complaint.notes!,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _FollowUpPrescriptionCard extends StatelessWidget {
  final Prescription prescription;

  const _FollowUpPrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = prescription;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(Spacing.sm + 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: Radii.smAll,
            ),
            child: Icon(Icons.medication, size: 16, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.remedyName} ${p.potency}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${Formatters.formatDate(p.prescriptionDate ?? p.createdAt)} • ${p.doseCount ?? ''} ${p.frequency ?? ''} • ${p.vehicle ?? ''}'.trim(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpInvestigationCard extends StatelessWidget {
  final Investigation investigation;

  const _FollowUpInvestigationCard({required this.investigation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inv = investigation;
    final attachments = InvestigationNotifier.parseAttachments(inv.reportAttachments);

    final (flagColor, flagBg) = switch (inv.flag) {
      'High' => (scheme.error, scheme.errorContainer),
      'Low' => (scheme.tertiary, scheme.tertiaryContainer),
      'Abnormal' => (scheme.error, scheme.errorContainer),
      _ => (scheme.primary, scheme.primaryContainer),
    };

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(Spacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  inv.testName,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: flagBg, borderRadius: Radii.smAll),
                child: Text(
                  inv.flag.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: flagColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${Formatters.formatDate(inv.testDate ?? inv.createdAt)} • Result: ${inv.numericValue != null ? '${inv.numericValue} ${inv.unit ?? ''}' : (inv.stringValue ?? 'Recorded')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              children: attachments.map((a) {
                return ActionChip(
                  avatar: const Icon(Icons.attach_file, size: 12),
                  label: Text('Report (${a.split(RegExp(r'[\\/]')).last})', style: const TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => MediaAttachmentService.openAttachment(a),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _VisitSummaryCard extends StatelessWidget {
  final VisitWithDetails visitWithDetails;

  const _VisitSummaryCard({required this.visitWithDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final v = visitWithDetails.visit;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(Spacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 14, color: scheme.primary),
              const SizedBox(width: 4),
              Text(
                Formatters.formatDate(v.visitDate),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              CustomBadge(
                label: v.visitType,
                color: scheme.primary,
              ),
            ],
          ),
          if ((v.disease).isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Condition: ${v.disease}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
          if ((v.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              v.notes!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          if (v.nextFollowUpDate != null) ...[
            const SizedBox(height: 2),
            Text(
              'Next Follow-Up: ${Formatters.formatDate(v.nextFollowUpDate!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubTabButton extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SubTabButton({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.mdAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? scheme.surface : scheme.surface.withValues(alpha: 0),
            borderRadius: Radii.mdAll,
            border: isSelected
                ? Border.all(color: scheme.primary.withValues(alpha: 0.25))
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

