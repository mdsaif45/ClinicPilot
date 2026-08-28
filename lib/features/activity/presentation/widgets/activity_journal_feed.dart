import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

class ActivityJournalFeed extends StatelessWidget {
  final List<TimelineActivityItem> items;

  const ActivityJournalFeed({
    super.key,
    required this.items,
  });

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
            Icon(Icons.event_note, size: 36, color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: Spacing.sm),
            Text(
              'No practice activity logged for this period',
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
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.xs),
      itemBuilder: (context, index) {
        final item = items[index];

        IconData icon;
        Color iconBg;
        Color iconFg;

        switch (item.type) {
          case ActivityEventType.consultation:
            icon = Icons.medical_services_outlined;
            iconBg = scheme.secondary.withValues(alpha: 0.12);
            iconFg = scheme.secondary;
            break;
          case ActivityEventType.dispense:
            icon = Icons.medication_outlined;
            iconBg = scheme.primary.withValues(alpha: 0.12);
            iconFg = scheme.primary;
            break;
          case ActivityEventType.expense:
            icon = Icons.receipt_long_outlined;
            iconBg = scheme.error.withValues(alpha: 0.12);
            iconFg = scheme.error;
            break;
        }

        final timeStr = DateFormat('h:mm a').format(item.timestamp);
        final dateStr = DateFormat('d MMM').format(item.timestamp);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm + 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: Radii.mdAll,
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                ),
                child: Center(
                  child: Icon(icon, color: iconFg, size: 20),
                ),
              ),
              const SizedBox(width: Spacing.md),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$dateStr • $timeStr',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.diseaseTag?.isNotEmpty == true) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.diseaseTag!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: scheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Amount if applicable
              if (item.amount != null) ...[
                const SizedBox(width: Spacing.sm),
                Text(
                  item.type == ActivityEventType.expense
                      ? '-${Formatters.formatCurrency(item.amount!)}'
                      : Formatters.formatCurrency(item.amount!),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item.type == ActivityEventType.expense
                        ? scheme.error
                        : scheme.primary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
