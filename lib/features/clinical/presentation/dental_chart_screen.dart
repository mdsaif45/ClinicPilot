import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../models/case_record_models.dart';
import '../models/dental_chart_model.dart';
import '../providers/case_record_provider.dart';
import 'widgets/odontogram_chart_widget.dart';
import 'widgets/tooth_condition_sheet.dart';

/// Full-featured Dental Examination and 32-Tooth Odontogram Screen.
///
/// Supports:
/// - Interactive Maxillary & Mandibular 32-tooth odontogram.
/// - FDI (11..48) and Universal (1..32) numbering toggle.
/// - Tooth surface condition tracking (Caries, Fillings, RCT, Crowns, Missing, Implants).
/// - Dental treatment planning with scheduled procedures, estimated fees, and statuses.
/// - Seamless serialization into the unified [MasterCaseRecordData].
class DentalChartScreen extends ConsumerStatefulWidget {
  final Patient patient;
  final MasterCaseRecordData? existingRecord;

  const DentalChartScreen({
    super.key,
    required this.patient,
    this.existingRecord,
  });

  @override
  ConsumerState<DentalChartScreen> createState() => _DentalChartScreenState();
}

class _DentalChartScreenState extends ConsumerState<DentalChartScreen> {
  late DentalChartData _chartData;
  late TextEditingController _notesController;
  bool _isSaving = false;
  bool _isDirty = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _chartData = DentalChartData.fromMasterCaseRecord(widget.existingRecord!);
      _initialized = true;
    } else {
      _chartData = DentalChartData();
    }
    _notesController = TextEditingController(text: _chartData.generalNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _onToothTap(ToothData tooth) async {
    final updated = await ToothConditionSheet.show(
      context: context,
      tooth: tooth,
      notation: _chartData.notation,
      onAddProcedure: () => _showAddProcedureDialog(defaultTooth: tooth.fdiNumber),
    );

    if (updated != null && mounted) {
      setState(() {
        _chartData = _chartData.withUpdatedTooth(updated);
        _markDirty();
      });
      AppHaptics.selection();
    }
  }

  Future<void> _showAddProcedureDialog({int? defaultTooth}) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final titleController = TextEditingController();
    final teethController = TextEditingController(
      text: defaultTooth != null ? '$defaultTooth' : '',
    );
    final feeController = TextEditingController();
    final notesController = TextEditingController();
    String status = 'planned';

    final presets = [
      'Root Canal Treatment (RCT)',
      'Composite / GIC Restoration',
      'Tooth Extraction',
      'Ceramic / Zirconia Crown',
      'Dental Implant Placement',
      'Full Mouth Ultrasonic Scaling',
      'Orthodontic Alignment Consultation',
      'Bleaching / Teeth Whitening',
      'Removable Partial Denture',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: scheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: Spacing.sm),
                  const Text('Add Dental Procedure'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Preset suggestions chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          presets.take(4).map((p) {
                            return ActionChip(
                              label: Text(p, style: const TextStyle(fontSize: 11)),
                              backgroundColor: scheme.surfaceContainerHighest,
                              side: BorderSide(color: scheme.outlineVariant),
                              onPressed: () {
                                setDialogState(() => titleController.text = p);
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: Spacing.md),

                    CustomTextField(
                      controller: titleController,
                      label: 'Procedure Title *',
                      hint: 'e.g. Root Canal Treatment',
                      prefixIcon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: Spacing.md),

                    CustomTextField(
                      controller: teethController,
                      label: 'Target Teeth (FDI numbers, comma separated)',
                      hint: 'e.g. 16, 26 or leave empty for full mouth',
                      prefixIcon: Icons.grid_view_outlined,
                    ),
                    const SizedBox(height: Spacing.md),

                    CustomTextField(
                      controller: feeController,
                      label: 'Estimated Fee (₹)',
                      hint: 'e.g. 3500',
                      prefixIcon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: Spacing.md),

                    // Status Dropdown
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Procedure Status',
                        border: OutlineInputBorder(borderRadius: Radii.smAll),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.xs,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: status,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'planned',
                              child: Text('Planned / Scheduled'),
                            ),
                            DropdownMenuItem(
                              value: 'in_progress',
                              child: Text('In Progress'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => status = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),

                    CustomTextField(
                      controller: notesController,
                      label: 'Procedure Clinical Notes',
                      hint: 'e.g. Under local anesthesia, single sitting planned...',
                      prefixIcon: Icons.notes,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final fee = double.tryParse(feeController.text.trim()) ?? 0.0;
                    final teethParts = teethController.text
                        .split(RegExp(r'[, ]+'))
                        .map((s) => int.tryParse(s.trim()))
                        .whereType<int>()
                        .toList();

                    final newProc = DentalProcedure(
                      id: IdGenerator.generate(),
                      title: title,
                      toothNumbers: teethParts,
                      estimatedFee: fee,
                      status: status,
                      notes: notesController.text.trim(),
                      appointmentDate: DateTime.now(),
                    );

                    setState(() {
                      _chartData = _chartData.withAddedProcedure(newProc);
                      _markDirty();
                    });
                    AppHaptics.success();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Add to Plan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);

    // Sync general notes
    _chartData = _chartData.copyWith(
      generalNotes: _notesController.text.trim(),
      lastExaminedAt: DateTime.now(),
    );

    final caseRecordAsync = ref.read(
      patientCaseRecordProvider(widget.patient.id),
    );
    final existingCase = widget.existingRecord ?? caseRecordAsync.value;

    final masterRecord = _chartData.toMasterCaseRecord(
      patientId: widget.patient.id,
      existingRecord: existingCase,
    );

    try {
      final notifier = ref.read(caseRecordNotifierProvider.notifier);
      await notifier.saveCaseRecord(masterRecord);

      // If dental diagnosis was synthesized, update patient primaryDisease if empty
      if (widget.patient.primaryDisease == null ||
          widget.patient.primaryDisease!.isEmpty) {
        final db = ref.read(databaseProvider);
        await (db.update(db.patients)..where((t) => t.id.equals(widget.patient.id))).write(
          PatientsCompanion(
            primaryDisease: drift.Value(
              masterRecord.clinicalAssessment.provisionalDiagnosis,
            ),
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
          content: const Text('Dental Odontogram saved successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppHaptics.error();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save dental chart: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Listen to existing record if not initialized
    final caseRecordAsync = ref.watch(
      patientCaseRecordProvider(widget.patient.id),
    );
    final existingCase = caseRecordAsync.value;
    if (existingCase != null && !_initialized) {
      _chartData = DentalChartData.fromMasterCaseRecord(existingCase);
      _notesController.text = _chartData.generalNotes;
      _initialized = true;
    }

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Discard Unsaved Changes?'),
                content: const Text(
                  'You have unsaved changes to this dental chart. Are you sure you want to leave?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Stay'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Discard'),
                  ),
                ],
              ),
        );
        if (shouldLeave == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dental Odontogram',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.patient.name} • ${widget.patient.gender}, ${widget.patient.age}y',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.check, size: 18),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            // Oral Health Metric Summary Strip
            _buildMetricSummaryStrip(theme, scheme),
            const SizedBox(height: Spacing.md),

            // Interactive 32-Tooth Odontogram Chart
            OdontogramChartWidget(
              chartData: _chartData,
              onToothTap: _onToothTap,
              onNotationChanged: (notation) {
                setState(() {
                  _chartData = _chartData.copyWith(notation: notation);
                  _markDirty();
                });
              },
            ),
            const SizedBox(height: Spacing.lg),

            // Treatment Plan & Procedures Section
            _buildTreatmentPlanSection(theme, scheme),
            const SizedBox(height: Spacing.lg),

            // General Dental Examination Notes Card
            AppCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, size: 18, color: scheme.primary),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        'GENERAL ORAL & PERIODONTAL EXAMINATION NOTES',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  CustomTextField(
                    controller: _notesController,
                    label: 'Clinical Notes, Gingival Status & Occlusion',
                    hint:
                        'e.g. Gingival bleeding on probing in anterior sextant, moderate calculus deposits, Class I molar relationship...',
                    prefixIcon: Icons.edit_note,
                    maxLines: 3,
                    onChanged: (_) => _markDirty(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // Bottom Primary Save Button
            AppButton.primary(
              label: 'Save Dental Examination',
              icon: Icons.check_circle_outline,
              fullWidth: true,
              loading: _isSaving,
              onPressed: _handleSave,
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSummaryStrip(ThemeData theme, ColorScheme scheme) {
    final metrics = [
      (
        'Teeth Present',
        '${_chartData.totalTeethPresent}/32',
        scheme.primary,
        Icons.check_circle_outline,
      ),
      (
        'Caries',
        '${_chartData.cariesCount}',
        scheme.error,
        Icons.warning_amber_rounded,
      ),
      (
        'Filled',
        '${_chartData.filledCount}',
        scheme.secondary,
        Icons.brush_outlined,
      ),
      (
        'Root Canals',
        '${_chartData.rootCanalCount}',
        scheme.tertiary,
        Icons.flash_on_outlined,
      ),
      (
        'Crowns',
        '${_chartData.crownCount}',
        scheme.primary,
        Icons.workspace_premium_outlined,
      ),
      (
        'Missing',
        '${_chartData.missingCount}',
        scheme.outline,
        Icons.close_outlined,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            metrics.map((m) {
              return Container(
                margin: const EdgeInsets.only(right: Spacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: Radii.smAll,
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(m.$4, size: 16, color: m.$3),
                    const SizedBox(width: Spacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.$2,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: m.$3,
                          ),
                        ),
                        Text(
                          m.$1,
                          style: TextStyle(
                            fontSize: 10,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTreatmentPlanSection(ThemeData theme, ColorScheme scheme) {
    final procs = _chartData.procedures;
    final totalFees = _chartData.totalPlannedFees;

    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'TREATMENT PLAN & PROCEDURES',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showAddProcedureDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Procedure', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),

          if (totalFees > 0) ...[
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                Text(
                  'Total Estimated Treatment: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '₹${totalFees.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Spacing.md),

          // Procedures List or Empty Placeholder
          if (procs.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.format_list_bulleted_outlined,
                    size: 32,
                    color: scheme.outlineVariant,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'No dental procedures scheduled yet.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap "Add Procedure" or select a tooth above to schedule treatment.',
                    style: TextStyle(fontSize: 11, color: scheme.outline),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: procs.length,
              separatorBuilder:
                  (_, __) =>
                      Divider(height: 1, color: scheme.outlineVariant),
              itemBuilder: (context, index) {
                final p = procs[index];
                return _ProcedureTile(
                  procedure: p,
                  onToggleStatus: () {
                    final nextStatus =
                        p.status == 'completed'
                            ? 'planned'
                            : p.status == 'planned'
                            ? 'in_progress'
                            : 'completed';
                    setState(() {
                      _chartData = _chartData.withUpdatedProcedure(
                        p.copyWith(status: nextStatus),
                      );
                      _markDirty();
                    });
                    AppHaptics.selection();
                  },
                  onDelete: () {
                    setState(() {
                      _chartData = _chartData.withRemovedProcedure(p.id);
                      _markDirty();
                    });
                    AppHaptics.error();
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ProcedureTile extends StatelessWidget {
  final DentalProcedure procedure;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _ProcedureTile({
    required this.procedure,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDone = procedure.isCompleted;

    Color statusColor;
    String statusLabel;
    if (procedure.isCompleted) {
      statusColor = scheme.primary;
      statusLabel = 'COMPLETED';
    } else if (procedure.isInProgress) {
      statusColor = scheme.tertiary;
      statusLabel = 'IN PROGRESS';
    } else {
      statusColor = scheme.onSurfaceVariant;
      statusLabel = 'PLANNED';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Checkbox / Action
          IconButton(
            icon: Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? scheme.primary : scheme.outline,
              size: 22,
            ),
            onPressed: onToggleStatus,
            tooltip: 'Toggle status',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        procedure.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                          color:
                              isDone
                                  ? scheme.onSurfaceVariant
                                  : scheme.onSurface,
                        ),
                      ),
                    ),
                    if (procedure.estimatedFee > 0)
                      Text(
                        '₹${procedure.estimatedFee.toStringAsFixed(0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: Radii.pillAll,
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Teeth: ${procedure.toothSummary}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (procedure.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    procedure.notes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: scheme.error,
            ),
            onPressed: onDelete,
            tooltip: 'Remove procedure',
          ),
        ],
      ),
    );
  }
}
