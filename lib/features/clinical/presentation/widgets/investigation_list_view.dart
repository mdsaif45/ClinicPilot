import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../add_edit_investigation_dialog.dart';
import '../../providers/investigation_provider.dart';

class InvestigationListView extends ConsumerStatefulWidget {
  final Patient patient;
  final String? visitId;

  const InvestigationListView({
    super.key,
    required this.patient,
    this.visitId,
  });

  @override
  ConsumerState<InvestigationListView> createState() => _InvestigationListViewState();
}

class _InvestigationListViewState extends ConsumerState<InvestigationListView> {
  String? _selectedFilterTest;

  void _openAddInvestigation(BuildContext context) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditInvestigationDialog(
        patientId: widget.patient.id,
        visitId: widget.visitId,
      ),
    );
  }

  void _openEditInvestigation(BuildContext context, Investigation inv) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditInvestigationDialog(
        patientId: widget.patient.id,
        visitId: widget.visitId,
        existingInvestigation: inv,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Investigation inv) {
    AppHaptics.error();
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        title: 'Delete Lab Report',
        message: 'Are you sure you want to remove "${inv.testName}" recorded on ${Formatters.formatDate(inv.testDate ?? inv.createdAt)}?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          await ref.read(investigationNotifierProvider.notifier).deleteInvestigation(inv.id);
          AppHaptics.medium();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final investigationsAsync = ref.watch(patientInvestigationsProvider(widget.patient.id));
    final theme = Theme.of(context);

    final allInvestigations = investigationsAsync.value ?? [];

    if (allInvestigations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: AppCard(
          margin: EdgeInsets.zero,
          child: EmptyState(
            icon: Icons.biotech_outlined,
            title: 'No lab tests recorded',
            message: 'Track pathology and biochemistry investigations with auto-flagging and trend charts.',
            actionLabel: 'Record Lab Test',
            onAction: () => _openAddInvestigation(context),
          ),
        ),
      );
    }

    // Extract unique test names for filter tabs
    final testNames = allInvestigations.map((e) => e.testName).toSet().toList();

    final filteredList = _selectedFilterTest == null
        ? allInvestigations
        : allInvestigations.where((e) => e.testName == _selectedFilterTest).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              Text(
                '${allInvestigations.length} ${allInvestigations.length == 1 ? 'Report' : 'Reports'}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              AppButton.tonal(
                label: 'Add Lab Test',
                icon: Icons.add,
                onPressed: () => _openAddInvestigation(context),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Filter Chips (Parameters)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('All Tests'),
                  selected: _selectedFilterTest == null,
                  onSelected: (selected) {
                    AppHaptics.selection();
                    setState(() => _selectedFilterTest = null);
                  },
                ),
                const SizedBox(width: Spacing.xs),
                for (final name in testNames) ...[
                  FilterChip(
                    label: Text(name),
                    selected: _selectedFilterTest == name,
                    onSelected: (selected) {
                      AppHaptics.selection();
                      setState(() => _selectedFilterTest = selected ? name : null);
                    },
                  ),
                  const SizedBox(width: Spacing.xs),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // Parameter Trend Card (when a test with multiple readings is selected)
          if (_selectedFilterTest != null) ...[
            _ParameterTrendCard(
              testName: _selectedFilterTest!,
              investigations: filteredList,
            ),
            const SizedBox(height: Spacing.md),
          ],

          // Reports List
          for (var i = 0; i < filteredList.length; i++) ...[
            if (i > 0) const SizedBox(height: Spacing.md),
            _InvestigationCard(
              investigation: filteredList[i],
              onEdit: () => _openEditInvestigation(context, filteredList[i]),
              onDelete: () => _confirmDelete(context, ref, filteredList[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ParameterTrendCard extends StatelessWidget {
  final String testName;
  final List<Investigation> investigations;

  const _ParameterTrendCard({
    required this.testName,
    required this.investigations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final numericReadings = investigations
        .where((i) => i.numericValue != null)
        .toList()
      ..sort((a, b) => (a.testDate ?? a.createdAt).compareTo(b.testDate ?? b.createdAt));

    if (numericReadings.isEmpty) return const SizedBox.shrink();

    final first = numericReadings.first;
    final latest = numericReadings.last;
    final delta = (latest.numericValue! - first.numericValue!);
    final unit = latest.unit ?? '';

    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: scheme.primary, size: 20),
              const SizedBox(width: Spacing.xs),
              Text(
                'Clinical Trend: $testName',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Text(
                'Latest: ${latest.numericValue} $unit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (delta > 0
                          ? scheme.errorContainer
                          : (delta < 0 ? scheme.tertiaryContainer : scheme.surfaceContainerHigh)),
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  delta > 0
                      ? '▲ +${delta.toStringAsFixed(1)} $unit'
                      : (delta < 0 ? '▼ ${delta.toStringAsFixed(1)} $unit' : 'No change'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: (delta > 0
                        ? scheme.onErrorContainer
                        : (delta < 0 ? scheme.onTertiaryContainer : scheme.onSurface)),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          // Readings Mini Bar Visualizer
          Row(
            children: [
              for (final reading in numericReadings.take(8)) ...[
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${reading.numericValue}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: reading.flag == 'High'
                              ? scheme.error.withValues(alpha: 0.8)
                              : reading.flag == 'Low'
                                  ? scheme.tertiary.withValues(alpha: 0.8)
                                  : scheme.primary.withValues(alpha: 0.8),
                          borderRadius: Radii.smAll,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatDate(reading.testDate ?? reading.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InvestigationCard extends StatelessWidget {
  final Investigation investigation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InvestigationCard({
    required this.investigation,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inv = investigation;

    final (flagColor, flagBg) = switch (inv.flag) {
      'High' => (scheme.error, scheme.errorContainer),
      'Low' => (scheme.tertiary, scheme.tertiaryContainer),
      'Abnormal' => (scheme.error, scheme.errorContainer),
      _ => (scheme.primary, scheme.primaryContainer),
    };

    final valueText = inv.numericValue != null
        ? '${inv.numericValue} ${inv.unit ?? ''}'.trim()
        : (inv.stringValue ?? 'Recorded');

    final attachments = InvestigationNotifier.parseAttachments(inv.reportAttachments);

    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.testName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${inv.testCategory} • ${Formatters.formatDate(inv.testDate ?? inv.createdAt)} • ${(inv.isBaseline ?? true) ? 'Initial Baseline' : 'Follow-Up Test'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: flagBg,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  inv.flag.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: flagColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: scheme.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Value & Reference Range
          Row(
            children: [
              Text(
                valueText,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: flagColor,
                ),
              ),
              if (inv.refRangeMin != null || inv.refRangeMax != null) ...[
                const SizedBox(width: Spacing.sm),
                Text(
                  '(Normal Ref: ${inv.refRangeMin ?? '0'} - ${inv.refRangeMax ?? ''} ${inv.unit ?? ''})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),

          // Attachments chips if present
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: attachments.map((path) {
                final isPdf = path.toLowerCase().endsWith('.pdf');
                return ActionChip(
                  avatar: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                    size: 14,
                    color: isPdf ? scheme.error : scheme.primary,
                  ),
                  label: Text('Report (${path.split(RegExp(r'[\\/]')).last})'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    AppHaptics.selection();
                    // Open attachment
                  },
                );
              }).toList(),
            ),
          ],

          // Lab Name & Doctor Notes
          if ((inv.labName ?? '').isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                Icon(Icons.local_hospital_outlined, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Lab: ${inv.labName!}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if ((inv.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Container(
              padding: const EdgeInsets.all(Spacing.xs + 2),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: Radii.smAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 14, color: scheme.primary),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      inv.notes!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}