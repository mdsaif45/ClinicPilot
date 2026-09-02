import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../growth/providers/health_score_provider.dart';

class ClinicHealthScoreCard extends ConsumerWidget {
  final EdgeInsetsGeometry? margin;

  const ClinicHealthScoreCard({
    super.key,
    this.margin,
  });

  void _showBreakdownSheet(BuildContext context, ClinicHealthScore score) {
    AppHaptics.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HealthScoreBreakdownSheet(score: score),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScoreAsync = ref.watch(clinicHealthScoreProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final healthScore = healthScoreAsync.value;
    if (healthScore == null) {
      return const SizedBox.shrink();
    }

    final score = healthScore.totalScore;
    final (scoreColor, scoreBg) = switch (score) {
      >= 80 => (scheme.primary, scheme.primaryContainer),
      >= 60 => (scheme.tertiary, scheme.tertiaryContainer),
      >= 40 => (scheme.error, scheme.errorContainer),
      _ => (scheme.error, scheme.errorContainer),
    };

        return AppCard(
          margin: margin ??
              const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.xs,
              ),
          onTap: () => _showBreakdownSheet(context, healthScore),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scoreBg.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Practice Health Score',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs + 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scoreBg,
                            borderRadius: Radii.smAll,
                          ),
                          child: Text(
                            healthScore.grade,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scoreColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      healthScore.summaryReason,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 20),
            ],
          ),
        );
  }
}

class _HealthScoreBreakdownSheet extends StatelessWidget {
  final ClinicHealthScore score;

  const _HealthScoreBreakdownSheet({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
      padding: const EdgeInsets.all(Spacing.xl),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: Radii.pillAll,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice Health Breakdown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Overall Composite Score: ${score.totalScore}/100 (${score.grade})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${score.totalScore}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            for (final p in score.pillars) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${p.score.toStringAsFixed(1)} / ${p.maxScore.toStringAsFixed(0)} pts',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              ClipRRect(
                borderRadius: Radii.pillAll,
                child: LinearProgressIndicator(
                  value: (p.score / p.maxScore).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                p.detail,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
