import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../add_edit_complaint_dialog.dart';
import '../../providers/complaint_provider.dart';

class ComplaintListView extends ConsumerWidget {
  final Patient patient;

  const ComplaintListView({super.key, required this.patient});

  void _openAddComplaint(BuildContext context, int defaultIndex) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditComplaintDialog(
        patientId: patient.id,
        defaultIndex: defaultIndex,
      ),
    );
  }

  void _openEditComplaint(BuildContext context, Complaint complaint) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditComplaintDialog(
        patientId: patient.id,
        existingComplaint: complaint,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Complaint complaint) {
    AppHaptics.error();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: Text('Are you sure you want to remove "${complaint.complaintName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(complaintNotifierProvider.notifier).deleteComplaint(complaint.id);
              AppHaptics.medium();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(patientComplaintsProvider(patient.id));
    final theme = Theme.of(context);

    final complaints = complaintsAsync.value ?? [];

    if (complaints.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md),
        child: AppCard(
          child: EmptyState(
            icon: Icons.healing_outlined,
            title: 'No complaints logged',
            message: 'Record specific patient complaints with location, sensation, and modalities.',
            actionLabel: 'Add Complaint',
            onAction: () => _openAddComplaint(context, 1),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${complaints.length} ${complaints.length == 1 ? 'Complaint' : 'Complaints'}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => _openAddComplaint(context, complaints.length + 1),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Complaint'),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          for (final c in complaints) ...[
            _ComplaintCard(
              complaint: c,
              onEdit: () => _openEditComplaint(context, c),
              onDelete: () => _confirmDelete(context, ref, c),
              onStatusChanged: (newStatus) {
                AppHaptics.selection();
                ref.read(complaintNotifierProvider.notifier).updateStatus(c.id, newStatus);
              },
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String> onStatusChanged;

  const _ComplaintCard({
    required this.complaint,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final sevColor = complaint.severity >= 8
        ? scheme.error
        : complaint.severity >= 5
            ? scheme.tertiary
            : scheme.primary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  '#${complaint.complaintIndex}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  complaint.complaintName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
          const SizedBox(height: Spacing.xs),

          // Badges: Severity + Status
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.12),
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  'Severity: ${complaint.severity}/10',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: sevColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (complaint.side != null && complaint.side != 'Not specified')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: Radii.smAll,
                  ),
                  child: Text(
                    complaint.side!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: complaint.status,
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Improving', child: Text('Improving')),
                    DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'Recurrent', child: Text('Recurrent')),
                  ],
                  onChanged: (val) {
                    if (val != null) onStatusChanged(val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Location & Sensation
          if ((complaint.location ?? '').isNotEmpty || (complaint.sensation ?? '').isNotEmpty) ...[
            if ((complaint.location ?? '').isNotEmpty)
              _FieldLine(
                label: 'Location',
                value: '${complaint.location!}${(complaint.extension ?? '').isNotEmpty ? ' → ${complaint.extension}' : ''}',
              ),
            if ((complaint.sensation ?? '').isNotEmpty)
              _FieldLine(label: 'Sensation', value: complaint.sensation!),
          ],

          // Modalities (< Aggravation / > Amelioration)
          if ((complaint.aggravatingFactors ?? '').isNotEmpty || (complaint.amelioratingFactors ?? '').isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Container(
              padding: const EdgeInsets.all(Spacing.xs + 2),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: Radii.smAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((complaint.aggravatingFactors ?? '').isNotEmpty)
                    Text(
                      '< Agg: ${complaint.aggravatingFactors}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if ((complaint.amelioratingFactors ?? '').isNotEmpty)
                    Text(
                      '> Amel: ${complaint.amelioratingFactors}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Concomitants & Causation
          if ((complaint.concomitants ?? '').isNotEmpty)
            _FieldLine(label: 'Concomitants', value: complaint.concomitants!),
          if ((complaint.causation ?? '').isNotEmpty)
            _FieldLine(label: 'Causation', value: complaint.causation!),
          if ((complaint.duration ?? '').isNotEmpty)
            _FieldLine(label: 'Duration', value: complaint.duration!),
        ],
      ),
    );
  }
}

class _FieldLine extends StatelessWidget {
  final String label;
  final String value;

  const _FieldLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}