import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../providers/dashboard_provider.dart';

class GoalTrackerCard extends ConsumerWidget {
  final DashboardStats stats;
  final DateTime now;

  const GoalTrackerCard({
    super.key,
    required this.stats,
    required this.now,
  });

  void _openEditGoalsDialog(BuildContext context, WidgetRef ref) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => _EditGoalsDialog(
        currentRevenueGoal: stats.monthlyRevenueGoal,
        currentPatientGoal: stats.monthlyNewPatientGoal,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDay - now.day) + 1;
    final expectedPace = now.day / lastDay;

    // Revenue calculations
    final remainingRev = stats.monthlyRevenueGoal - stats.monthlyRevenue;
    final revPct = stats.monthlyRevenueGoal > 0
        ? (stats.monthlyRevenue / stats.monthlyRevenueGoal * 100)
        : 0.0;
    final perDayRev = daysLeft > 0 && remainingRev > 0 ? remainingRev / daysLeft : 0.0;

    final (revColor, revBg, revStatus) = _evalPace(
      actualProgress: stats.revenueGoalProgress,
      expectedPace: expectedPace,
      scheme: scheme,
    );

    // Patient goal calculations
    final remainingPts = stats.monthlyNewPatientGoal - stats.monthlyNewPatients;
    final ptsPct = stats.monthlyNewPatientGoal > 0
        ? (stats.monthlyNewPatients / stats.monthlyNewPatientGoal * 100)
        : 0.0;

    final (ptColor, ptBg, ptStatus) = _evalPace(
      actualProgress: stats.newPatientGoalProgress,
      expectedPace: expectedPace,
      scheme: scheme,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit action
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly Practice Targets',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune_outlined, size: 20),
                tooltip: 'Set Monthly Goals',
                onPressed: () => _openEditGoalsDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // 1. Revenue Goal Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(stats.monthlyRevenue),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: revColor,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'of ${Formatters.formatCurrency(stats.monthlyRevenueGoal)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs + 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: revBg,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  '$revStatus • ${revPct.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: revColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: stats.revenueGoalProgress),
            duration: Motion.slow,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: Radii.pillAll,
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: revColor,
                ),
              );
            },
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            remainingRev <= 0
                ? '🎉 Revenue target achieved for ${Formatters.formatMonthYear(now)}!'
                : '${Formatters.formatCurrency(remainingRev)} needed • ${Formatters.formatCurrency(perDayRev)}/day over remaining $daysLeft days',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: Spacing.lg),
          const Divider(height: 1),
          const SizedBox(height: Spacing.md),

          // 2. New Patients Goal Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.monthlyNewPatients}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ptColor,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'of ${stats.monthlyNewPatientGoal} new patients',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs + 2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: ptBg,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  '$ptStatus • ${ptsPct.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ptColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: stats.newPatientGoalProgress),
            duration: Motion.slow,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: Radii.pillAll,
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: ptColor,
                ),
              );
            },
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            remainingPts <= 0
                ? '🎯 Patient acquisition target reached!'
                : '$remainingPts new patients needed to meet monthly target',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String) _evalPace({
    required double actualProgress,
    required double expectedPace,
    required ColorScheme scheme,
  }) {
    if (actualProgress >= 1.0) {
      return (scheme.primary, scheme.primaryContainer, 'Achieved');
    }
    if (actualProgress >= expectedPace * 0.85) {
      return (scheme.primary, scheme.primaryContainer, 'On Track');
    }
    if (actualProgress >= expectedPace * 0.55) {
      return (scheme.tertiary, scheme.tertiaryContainer, 'Behind Pace');
    }
    return (scheme.error, scheme.errorContainer, 'Off Track');
  }
}

class _EditGoalsDialog extends ConsumerStatefulWidget {
  final double currentRevenueGoal;
  final int currentPatientGoal;

  const _EditGoalsDialog({
    required this.currentRevenueGoal,
    required this.currentPatientGoal,
  });

  @override
  ConsumerState<_EditGoalsDialog> createState() => _EditGoalsDialogState();
}

class _EditGoalsDialogState extends ConsumerState<_EditGoalsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _revController;
  late final TextEditingController _patController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _revController = TextEditingController(
      text: widget.currentRevenueGoal.toStringAsFixed(0),
    );
    _patController = TextEditingController(
      text: widget.currentPatientGoal.toString(),
    );
  }

  @override
  void dispose() {
    _revController.dispose();
    _patController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    final db = ref.read(databaseProvider);
    final rev = double.tryParse(_revController.text.trim()) ?? 50000.0;
    final pat = int.tryParse(_patController.text.trim()) ?? 10;

    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_revenue_goal',
            value: rev.toStringAsFixed(0),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

    await db.into(db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: 'monthly_new_patient_goal',
            value: pat.toString(),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

    AppHaptics.success();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Set Monthly Targets',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _save,
          child: const Text('Save Targets'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _revController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Revenue Goal (₹)',
                hintText: 'e.g. 50000',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (v) =>
                  v == null || double.tryParse(v.trim()) == null ? 'Enter valid amount' : null,
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _patController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly New Patient Goal',
                hintText: 'e.g. 15',
                prefixIcon: Icon(Icons.person_add_outlined),
              ),
              validator: (v) =>
                  v == null || int.tryParse(v.trim()) == null ? 'Enter valid number' : null,
            ),
          ],
        ),
      ),
    );
  }
}
