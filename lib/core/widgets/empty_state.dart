import 'package:flutter/material.dart';

import '../design/tokens.dart';
import 'empty_illustration.dart';

/// Standard "nothing here yet" panel with custom vector illustration and optional CTA.
///
/// Replaces ad-hoc centered text widgets so every empty list reads consistently
/// and offers the obvious next action.
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final Widget? illustration;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const EmptyState({
    super.key,
    this.icon,
    this.illustration,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  }) : assert(
         icon != null || illustration != null,
         'Either icon or illustration must be provided to EmptyState',
       );

  /// Empty state for patients list.
  const factory EmptyState.patients({
    Key? key,
    String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) = _PatientsEmptyState;

  /// Empty state for cash memos list.
  const factory EmptyState.cashMemos({
    Key? key,
    String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) = _CashMemosEmptyState;

  /// Empty state for expenses list.
  const factory EmptyState.expenses({
    Key? key,
    String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) = _ExpensesEmptyState;

  /// Empty state for growth and analytics reports.
  const factory EmptyState.growth({
    Key? key,
    String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) = _GrowthEmptyState;

  /// Empty state for recall / follow-up list.
  const factory EmptyState.recall({
    Key? key,
    String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) = _RecallEmptyState;

  /// Empty state for clinics list.
  const factory EmptyState.clinics({
    Key? key,
    String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) = _ClinicsEmptyState;

  /// Empty state for search results with zero matches.
  const factory EmptyState.search({
    Key? key,
    String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) = _SearchEmptyState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artwork = illustration ?? EmptyIllustration.generic(icon: icon!);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            artwork,
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Spacing.xl),
              FilledButton.tonalIcon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.add, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PatientsEmptyState extends EmptyState {
  const _PatientsEmptyState({
    super.key,
    super.title = 'No patients found',
    super.message = 'Add your first patient to start recording visits.',
    super.actionLabel = 'Add Patient',
    super.onAction,
  }) : super(
         illustration: const EmptyIllustration.patients(),
         actionIcon: Icons.person_add_outlined,
       );
}

class _CashMemosEmptyState extends EmptyState {
  const _CashMemosEmptyState({
    super.key,
    super.title = 'No cash memos yet',
    super.message = 'Create a cash memo to record patient fees.',
    super.actionLabel = 'New Memo',
    super.onAction,
  }) : super(
         illustration: const EmptyIllustration.cashMemos(),
         actionIcon: Icons.add_card_outlined,
       );
}

class _ExpensesEmptyState extends EmptyState {
  const _ExpensesEmptyState({
    super.key,
    super.title = 'No expenses recorded',
    super.message = 'Track clinic supplies, travel, and camp costs here.',
    super.actionLabel = 'Add Expense',
    super.onAction,
  }) : super(
         illustration: const EmptyIllustration.expenses(),
         actionIcon: Icons.add_circle_outline,
       );
}

class _GrowthEmptyState extends EmptyState {
  const _GrowthEmptyState({
    super.key,
    super.title = 'No analytics available',
    super.message = 'Log visits and memos to unlock practice growth insights.',
    super.actionLabel,
    super.onAction,
  }) : super(illustration: const EmptyIllustration.growth());
}

class _RecallEmptyState extends EmptyState {
  const _RecallEmptyState({
    super.key,
    super.title = 'All caught up!',
    super.message = 'No patients are currently due for follow-up.',
    super.actionLabel,
    super.onAction,
  }) : super(illustration: const EmptyIllustration.recall());
}

class _ClinicsEmptyState extends EmptyState {
  const _ClinicsEmptyState({
    super.key,
    super.title = 'No clinics added',
    super.message = 'Add your primary clinic to configure rent and fees.',
    super.actionLabel = 'Add Clinic',
    super.onAction,
  }) : super(
         illustration: const EmptyIllustration.clinics(),
         actionIcon: Icons.add_business_outlined,
       );
}

class _SearchEmptyState extends EmptyState {
  const _SearchEmptyState({
    super.key,
    super.title = 'No results found',
    super.message = 'Try searching with a different name, code, or disease.',
    super.actionLabel,
    super.onAction,
  }) : super(illustration: const EmptyIllustration.search());
}
