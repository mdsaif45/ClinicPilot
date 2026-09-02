import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../visits/providers/visit_provider.dart';
import '../../providers/complaint_provider.dart';
import '../add_edit_complaint_dialog.dart';

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
      builder: (ctx) => AppConfirmDialog(
        title: 'Delete Complaint',
        message: 'Are you sure you want to remove "${complaint.complaintName}"?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          await ref.read(complaintNotifierProvider.notifier).deleteComplaint(complaint.id);
          AppHaptics.medium();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(patientComplaintsProvider(patient.id));
    final visitsAsync = ref.watch(patientVisitsStreamProvider(patient.id));
    final theme = Theme.of(context);

    final complaints = complaintsAsync.value ?? [];
    final visitCount = visitsAsync.value?.length ?? 0;

    if (complaints.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: AppCard(
          margin: EdgeInsets.zero,
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
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                visitCount > 0
                    ? '${complaints.length} ${complaints.length == 1 ? 'Complaint' : 'Complaints'} ($visitCount ${visitCount == 1 ? 'Visit' : 'Visits'})'
                    : '${complaints.length} ${complaints.length == 1 ? 'Complaint' : 'Complaints'}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          for (var i = 0; i < complaints.length; i++) ...[
            if (i > 0) const SizedBox(height: Spacing.md),
            _ComplaintCard(
              complaint: complaints[i],
              onEdit: () => _openEditComplaint(context, complaints[i]),
              onDelete: () => _confirmDelete(context, ref, complaints[i]),
              onStatusChanged: (newStatus) {
                AppHaptics.selection();
                ref.read(complaintNotifierProvider.notifier).updateStatus(complaints[i].id, newStatus);
              },
            ),
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

    final statusColor = switch (complaint.status.toLowerCase()) {
      'active' => scheme.primary,
      'improving' => scheme.tertiary,
      'resolved' => scheme.secondary,
      'recurrent' => scheme.error,
      _ => scheme.onSurfaceVariant,
    };

    final beforeImgs = ComplaintNotifier.parseImages(complaint.beforeImages);
    final afterImgs = ComplaintNotifier.parseImages(complaint.afterImages);
    final totalPhotos = beforeImgs.length + afterImgs.length;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm + 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Date & Visit Nature (Date-First Approach)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 13, color: scheme.primary),
              const SizedBox(width: 5),
              Text(
                Formatters.formatDate(complaint.complaintDate ?? complaint.createdAt),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              Text(
                ' • ${(complaint.isBaseline ?? true) ? 'Initial Baseline' : 'Follow-Up Visit'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 24,
                height: 24,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Complaint')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: scheme.error)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs + 2),

          // Main Title Row: Index + Complaint Name
          Row(
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
            ],
          ),
          const SizedBox(height: Spacing.xs + 2),

          // Badges: Severity + Status Menu Pill + Photos count
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CustomBadge(
                label: 'Severity: ${complaint.severity}/10',
                color: sevColor,
              ),
              PopupMenuButton<String>(
                tooltip: 'Change Status',
                onSelected: onStatusChanged,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'Active', child: Text('Active')),
                  PopupMenuItem(value: 'Improving', child: Text('Improving')),
                  PopupMenuItem(value: 'Resolved', child: Text('Resolved')),
                  PopupMenuItem(value: 'Recurrent', child: Text('Recurrent')),
                ],
                child: CustomBadge(
                  label: '${complaint.status} ▾',
                  color: statusColor,
                ),
              ),
              if (totalPhotos > 0)
                CustomBadge(
                  label: '📷 $totalPhotos ${totalPhotos == 1 ? 'Photo' : 'Photos'}',
                  color: scheme.tertiary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
