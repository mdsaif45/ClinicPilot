import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/period_selector.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/payment_method_breakdown_provider.dart';

/// Collections breakdown by payment channel (Cash, UPI, Card, Bank Transfer).
class PaymentMethodBreakdownScreen extends ConsumerWidget {
  const PaymentMethodBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(paymentBreakdownProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: breakdownAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load breakdown: $e')),
        data: (data) {
          if (data.totalMemos == 0) {
            return Column(
              children: [
                const PeriodSelector(),
                Expanded(
                  child: EmptyState.growth(
                    title: 'No collections in period',
                    message:
                        'Create cash memos to see payment method distribution.',
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
            children: [
              const PeriodSelector(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total Collected',
                        value: Formatters.formatCurrency(data.totalCollected),
                        fg: scheme.primary,
                        bg: scheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Pending Balance',
                        value: Formatters.formatCurrency(data.totalPending),
                        fg: data.totalPending > 0
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                        bg: data.totalPending > 0
                            ? scheme.errorContainer
                            : scheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              if (data.methods.isNotEmpty && data.totalCollected > 0) ...[
                const SectionHeader(title: 'Distribution'),
                AppCard(
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: data.methods.map((m) {
                          final color = _colorForMethod(m.method, scheme);
                          return PieChartSectionData(
                            color: color,
                            value: m.totalCollected,
                            title: '${m.percentage.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
              const SectionHeader(title: 'By Payment Method'),
              for (final m in data.methods)
                AppCard(
                  margin: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    0,
                    Spacing.lg,
                    Spacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PaymentIcons.forMethod(m.method),
                            color: _colorForMethod(m.method, scheme),
                            size: 24,
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.method,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${m.count} ${m.count == 1 ? 'transaction' : 'transactions'}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.formatCurrency(m.totalCollected),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
                              ),
                              Text(
                                '${m.percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      ClipRRect(
                        borderRadius: Radii.pillAll,
                        child: LinearProgressIndicator(
                          value: (m.percentage / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: scheme.surfaceContainerHighest,
                          color: _colorForMethod(m.method, scheme),
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

  Color _colorForMethod(String method, ColorScheme scheme) {
    final lower = method.toLowerCase();
    if (lower.contains('cash')) return scheme.primary;
    if (lower.contains('upi')) return scheme.tertiary;
    if (lower.contains('card')) return scheme.secondary;
    return scheme.outline;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color fg;
  final Color bg;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.45),
        borderRadius: Radii.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: Spacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
