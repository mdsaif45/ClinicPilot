import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';
import '../../providers/practice_journal_provider.dart';
import 'journal_item_detail_sheet.dart';

/// Clean, modern activity timeline feed styled faithfully after Google Fit (Image 2).
class ActivityJournalFeed extends StatelessWidget {
  final List<TimelineActivityItem> items;

  const ActivityJournalFeed({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Spacing.xl),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.event_note,
              size: 36,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'No practice activity logged for this date',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder:
          (_, __) => Divider(
            height: 1,
            indent: Spacing.sm,
            endIndent: Spacing.sm,
            color: scheme.outlineVariant.withValues(alpha: 0.25),
          ),
      itemBuilder: (context, index) {
        final item = items[index];

        IconData icon;
        Color iconColor;

        switch (item.type) {
          case ActivityEventType.consultation:
            icon = Icons.medical_services_outlined;
            iconColor = scheme.secondary;
            break;
          case ActivityEventType.dispense:
            icon = Icons.medication_outlined;
            iconColor = scheme.primary;
            break;
          case ActivityEventType.expense:
            icon = Icons.receipt_long_outlined;
            iconColor = scheme.error;
            break;
        }

        final timeStr = DateFormat('h:mm a').format(item.timestamp);

        return InkWell(
          onTap: () {
            // Map TimelineActivityItem to PracticeJournalEntry and open JournalItemDetailSheet
            final entry = PracticeJournalEntry(
              id: item.id,
              timestamp: item.timestamp,
              type:
                  item.type == ActivityEventType.consultation
                      ? JournalEventType.consultation
                      : item.type == ActivityEventType.dispense
                      ? JournalEventType.dispense
                      : JournalEventType.expense,
              title: item.title,
              subtitle: item.subtitle,
              amount: item.amount,
              paymentMethod: item.paymentMethod,
              patientName: item.patientName,
              patientId: item.patientId,
              patientCode: item.patientCode,
              disease: item.diseaseTag,
              memoNumber: item.memoNumber,
              visitType: item.visitType,
              notes: item.notes,
              category: item.category,
            );
            JournalItemDetailSheet.show(context, entry);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon on left
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: Spacing.md),

                // 2. Micro Time + Bold Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Micro Timestamp (Google Fit style)
                      Text(
                        timeStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Bold Title
                      Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Subtitle with condition / amount
                      Row(
                        children: [
                          if (item.diseaseTag != null &&
                              item.diseaseTag!.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                item.diseaseTag!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.amount != null) ...[
                              Text(
                                ' • ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ] else if (item.subtitle != null) ...[
                            Flexible(
                              child: Text(
                                item.subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.amount != null) ...[
                              Text(
                                ' • ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                          if (item.amount != null) ...[
                            Text(
                              item.type == ActivityEventType.expense
                                  ? '-${Formatters.formatCurrency(item.amount!)}'
                                  : Formatters.formatCurrency(item.amount!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    item.type == ActivityEventType.expense
                                        ? scheme.error
                                        : scheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
