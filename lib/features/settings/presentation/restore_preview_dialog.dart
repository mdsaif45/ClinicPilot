import 'package:flutter/material.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/backup_container_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_badge.dart';

/// Pre-restore inspection modal presenting exact record counts and backup details.
class RestorePreviewDialog extends StatefulWidget {
  final BackupMetadata metadata;
  final Future<void> Function() onConfirm;

  const RestorePreviewDialog({
    super.key,
    required this.metadata,
    required this.onConfirm,
  });

  @override
  State<RestorePreviewDialog> createState() => _RestorePreviewDialogState();
}

class _RestorePreviewDialogState extends State<RestorePreviewDialog> {
  bool _isRestoring = false;

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final counts = widget.metadata.counts;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.restore_outlined, color: scheme.primary),
          const SizedBox(width: Spacing.sm),
          const Text('Restore Practice Data'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Header Banner
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: Radii.mdAll,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Backup File Validated',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      CustomBadge(
                        label: 'v${widget.metadata.appVersion}',
                        color: scheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Created: ${Formatters.formatFullDate(widget.metadata.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Item counts headline
            Text(
              'Contents (${widget.metadata.totalRecords} total records)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // Detailed Counts Grid
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: Radii.mdAll,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    context,
                    icon: Icons.people_outline,
                    label: 'Patients',
                    count: counts['patients'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.assignment_outlined,
                    label: 'Master Case Records',
                    count: counts['patientCaseRecords'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.healing_outlined,
                    label: 'Clinical Complaints',
                    count: counts['complaints'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.medication_outlined,
                    label: 'Prescriptions',
                    count: counts['prescriptions'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.biotech_outlined,
                    label: 'Lab Investigations',
                    count: counts['investigations'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Visits & Follow-ups',
                    count: counts['visits'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.receipt_long_outlined,
                    label: 'Cash Memos',
                    count: counts['cashMemos'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Expenses',
                    count: counts['expenses'] ?? 0,
                  ),
                  const Divider(height: 12),
                  _buildStatRow(
                    context,
                    icon: Icons.storefront_outlined,
                    label: 'Clinics',
                    count: counts['clinics'] ?? 0,
                  ),
                  if (widget.metadata.mediaCount > 0) ...[
                    const Divider(height: 12),
                    _buildStatRow(
                      context,
                      icon: Icons.photo_library_outlined,
                      label: 'Photos & Lab Reports (PDF)',
                      count: widget.metadata.mediaCount,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Warning Banner
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: Radii.smAll,
                border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Restoring this backup will replace existing data on this phone with the backup records.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isRestoring ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isRestoring
              ? null
              : () async {
                  setState(() => _isRestoring = true);
                  try {
                    await widget.onConfirm();
                  } finally {
                    if (mounted) setState(() => _isRestoring = false);
                  }
                },
          child: _isRestoring
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Restore Data Now'),
        ),
      ],
    );
  }
}
