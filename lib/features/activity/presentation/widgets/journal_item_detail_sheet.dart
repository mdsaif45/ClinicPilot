import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../providers/practice_journal_provider.dart';

/// Modal bottom sheet presenting Google Fit Activity Detail layout for a clinical journal event.
class JournalItemDetailSheet extends StatelessWidget {
  final PracticeJournalEntry entry;

  const JournalItemDetailSheet({
    super.key,
    required this.entry,
  });

  static Future<void> show(BuildContext context, PracticeJournalEntry entry) {
    AppHaptics.medium();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => JournalItemDetailSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final formattedFullDate = DateFormat('EEEE, d MMMM yyyy • h:mm a').format(entry.timestamp);

    // Resolve Category Visuals
    IconData heroIcon;
    Color heroColor;
    String statusTitle;
    String statusSubtitle;

    switch (entry.type) {
      case JournalEventType.consultation:
        heroIcon = Icons.medical_services_outlined;
        heroColor = scheme.secondary;
        statusTitle = 'Consultation Logged';
        statusSubtitle = 'Clinical notes and examination recorded in patient history.';
        break;
      case JournalEventType.dispense:
        heroIcon = Icons.medication_outlined;
        heroColor = scheme.primary;
        statusTitle = 'Payment & Dispense Settled';
        statusSubtitle = 'Cash memo receipt generated and clinic ledger updated.';
        break;
      case JournalEventType.expense:
        heroIcon = Icons.receipt_long_outlined;
        heroColor = scheme.error;
        statusTitle = 'Expense Disbursed';
        statusSubtitle = 'Operational clinic payout documented.';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.xl, Spacing.md, Spacing.xl, Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: Spacing.sm),

              // 2. Action Header Bar (Close + Share/Info)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      if (entry.patientId != null)
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          tooltip: 'Open Patient Profile',
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push('/patients/${entry.patientId}');
                          },
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: Spacing.xs),

              // 3. Hero Title & Timestamp (Google Fit Style)
              Text(
                entry.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: Spacing.xs),

              Row(
                children: [
                  Icon(
                    heroIcon,
                    size: 15,
                    color: heroColor,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    formattedFullDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Spacing.xl),

              // 4. Big Center Hero Numbers (Like 💚 31  ⚡ 3,580 in Google Fit)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.lg),
                  decoration: BoxDecoration(
                    color: heroColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: heroColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (entry.amount != null) ...[
                        Icon(
                          Icons.currency_rupee,
                          size: 26,
                          color: heroColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatCurrency(entry.amount!),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: heroColor,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.medical_services_outlined,
                          size: 26,
                          color: heroColor,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          entry.visitType ?? 'Consultation',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: heroColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: Spacing.md),

              // 5. Celebration / Status Callout Banner (Like ❤️ You rocked it!)
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: heroColor.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: heroColor,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            statusSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // 6. Key-Value Metric Rows (Google Fit Style Data Rows)
              Text(
                'Clinical Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: Spacing.sm),

              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    if (entry.patientName != null)
                      _buildMetricRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'Patient',
                        value: entry.patientCode != null
                            ? '${entry.patientName} (${entry.patientCode})'
                            : entry.patientName!,
                      ),
                    if (entry.disease != null && entry.disease!.isNotEmpty)
                      _buildMetricRow(
                        context,
                        icon: Icons.healing_outlined,
                        label: 'Condition',
                        value: entry.disease!,
                      ),
                    if (entry.memoNumber != null)
                      _buildMetricRow(
                        context,
                        icon: Icons.receipt_outlined,
                        label: 'Invoice No.',
                        value: '#${entry.memoNumber}',
                      ),
                    if (entry.paymentMethod != null)
                      _buildMetricRow(
                        context,
                        icon: Icons.payments_outlined,
                        label: 'Payment Method',
                        value: entry.paymentMethod!,
                        trailingBadge: CustomBadge(
                          label: entry.paymentMethod!,
                          color: scheme.primary,
                        ),
                      ),
                    if (entry.category != null)
                      _buildMetricRow(
                        context,
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: entry.category!,
                      ),
                    if (entry.notes != null && entry.notes!.isNotEmpty)
                      _buildMetricRow(
                        context,
                        icon: Icons.notes_outlined,
                        label: 'Clinical Notes',
                        value: entry.notes!,
                        isLast: true,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // 7. Action Button
              if (entry.patientId != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push('/patients/${entry.patientId}');
                    },
                    icon: const Icon(Icons.person_search_outlined),
                    label: const Text('Open Patient Profile & Records'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? trailingBadge,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.md),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (trailingBadge != null)
                trailingBadge
              else
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: Spacing.md,
            endIndent: Spacing.md,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}
