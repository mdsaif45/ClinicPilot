import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/period_selector.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/referral_provider.dart';

class ReferralSourceScreen extends ConsumerWidget {
  const ReferralSourceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(referralAnalyticsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Referral Source')),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (a) {
          if (a.stats.isEmpty) {
            return const Column(
              children: [
                PeriodSelector(),
                Expanded(
                  child: EmptyState.growth(
                    title: 'No referral data yet',
                    message: 'Ask each new patient how they heard about the '
                        'clinic and record it when registering them.',
                  ),
                ),
              ],
            );
          }

          final colours = SemanticColors.chartSeries(context);

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
            children: [
              const PeriodSelector(),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 58,
                        sections: [
                          for (var i = 0; i < a.stats.length; i++)
                            PieChartSectionData(
                              value: a.stats[i].patients.toDouble(),
                              color: colours[i % colours.length],
                              radius: 34,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total', style: theme.textTheme.labelMedium),
                        Text(
                          '${a.totalPatients}',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SectionHeader(title: 'Breakdown'),
              for (var i = 0; i < a.stats.length; i++)
                _SourceRow(
                  stat: a.stats[i],
                  share: a.shareOf(a.stats[i]),
                  colour: colours[i % colours.length],
                ),

              if (a.topBySource != null) ...[
                const SectionHeader(title: 'Top Source'),
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.topBySource!.source,
                                style: theme.textTheme.titleSmall),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              '${a.topBySource!.patients} '
                              '${a.topBySource!.patients == 1 ? 'patient' : 'patients'}',
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Revenue', style: theme.textTheme.labelSmall),
                          Text(
                            Formatters.formatCurrency(a.topBySource!.revenue),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: Spacing.lg),
              AppCard(
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Text(
                        // Explaining the model matters: without it, revenue
                        // exceeding what new patients paid looks like a bug.
                        'Revenue counts everything a patient pays, credited to '
                        'the source that first brought them in.',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final ReferralStat stat;
  final double share;
  final Color colour;

  const _SourceRow({
    required this.stat,
    required this.share,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              stat.source,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${share.toStringAsFixed(0)}% (${stat.patients})',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(width: Spacing.md),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.formatCurrency(stat.revenue),
              textAlign: TextAlign.right,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
