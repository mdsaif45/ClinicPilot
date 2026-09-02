import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/practice_activity_provider.dart';

class MonthlyBubbleMatrix extends StatelessWidget {
  final List<BubbleCalendarDay> bubbleDays;
  final List<WeeklySubtotal> weeklySubtotals;
  final ActivityMetric metric;
  final ValueChanged<DateTime>? onDaySelected;

  const MonthlyBubbleMatrix({
    super.key,
    required this.bubbleDays,
    required this.weeklySubtotals,
    required this.metric,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final primaryColor =
        metric == ActivityMetric.revenue ? scheme.primary : scheme.secondary;

    const weekHeaderDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              weekHeaderDays.map((day) {
                return SizedBox(
                  width: 36,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: Spacing.sm),

        // Bubble Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: bubbleDays.length,
          itemBuilder: (context, index) {
            final day = bubbleDays[index];
            if (!day.isInSelectedMonth) {
              return const SizedBox.shrink();
            }

            final hasActivity = day.intensity > 0;
            final bubbleSize = (20.0 + (day.intensity * 18.0)).clamp(
              20.0,
              38.0,
            );
            final valText =
                metric == ActivityMetric.revenue
                    ? Formatters.formatCurrency(day.revenue)
                    : '${day.patients} ${day.patients == 1 ? 'patient' : 'patients'}';

            return Tooltip(
              message: valText,
              child: InkWell(
                onTap: () {
                  AppHaptics.selection();
                  onDaySelected?.call(day.date);
                },
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Proportional Bubble (only drawn if there is activity)
                      if (hasActivity)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: bubbleSize,
                          height: bubbleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(
                              alpha: 0.35 + (day.intensity * 0.65),
                            ),
                          ),
                        ),
                      // Day Number
                      Text(
                        '${day.dayNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight:
                              day.intensity > 0.4
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                          color:
                              day.intensity > 0.4
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: Spacing.lg),

        // Weekly Subtotals Section (Google Fit Month summary cards)
        Text(
          'Weekly Summary',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        ...weeklySubtotals.map((w) {
          final val =
              metric == ActivityMetric.revenue
                  ? Formatters.formatCurrency(w.revenue)
                  : '${w.patients} patients';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  w.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  val,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
