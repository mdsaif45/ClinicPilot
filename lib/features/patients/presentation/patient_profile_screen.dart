import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/chip_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entity_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_strip.dart';
import '../../../core/widgets/money_text.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../cashmemo/presentation/receipt_preview_dialog.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../visits/presentation/add_visit_dialog.dart';
import '../../visits/providers/visit_provider.dart';
import 'edit_patient_dialog.dart';

/// Everything known about one patient, on one page.
///
/// Uses segmented tabs rather than sub-navigation so identity, history, money
/// and outcomes are each one tap away — the database already holds far more
/// than the previous layout exposed.
class PatientProfileScreen extends ConsumerWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(patientVisitsStreamProvider(patient.id));
    final memosAsync = ref.watch(cashMemosStreamProvider);

    final patientMemos = (memosAsync.value ?? [])
        .where((m) => m.memo.patientId == patient.id)
        .toList();

    final lifetimeRevenue =
        patientMemos.fold<double>(0.0, (s, m) => s + m.memo.total);
    final totalPending =
        patientMemos.fold<double>(0.0, (s, m) => s + m.pendingAmount);
    final visits = visitsAsync.value ?? [];
    final totalVisits = visits.length;
    final avgBill = totalVisits > 0 ? lifetimeRevenue / totalVisits : 0.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // No app bar: it repeated the name the header already shows. Back
          // and edit ride on top of the header instead.
          SliverToBoxAdapter(
            child: EntityHeader(
              title: patient.name,
              subtitle: patient.patientCode,
              avatarText: patient.name,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit patient',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => EditPatientDialog(patient: patient),
                  ),
                ),
              ],
              badges: [
                if ((patient.area ?? '').isNotEmpty)
                  _Badge(icon: Icons.place_outlined, label: patient.area!),
                _Badge(
                  icon: Icons.event_outlined,
                  label: 'Since ${Formatters.formatDate(patient.createdAt)}',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
              child: MetricStrip(
                metrics: [
                  Metric(label: 'Visits', value: '$totalVisits'),
                  Metric(
                    label: 'Lifetime',
                    value: Formatters.formatCurrency(lifetimeRevenue),
                  ),
                  Metric(
                    label: 'Avg bill',
                    value: Formatters.formatCurrency(avgBill),
                  ),
                  Metric(
                    label: 'Pending',
                    value: Formatters.formatCurrency(totalPending),
                    signedAmount: totalPending > 0 ? -totalPending : 0,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ChipRow(labels: [
              if ((patient.primaryDisease ?? '').isNotEmpty)
                patient.primaryDisease!,
              if ((patient.referralSource ?? '').isNotEmpty)
                patient.referralSource!,
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.xxl),
              child: SegmentedTabs(
                tabs: [
                  SegmentedTab(
                    icon: Icons.info_outline,
                    label: 'Information',
                    builder: (_) => _InfoTab(patient: patient, visits: visits),
                  ),
                  SegmentedTab(
                    icon: Icons.timeline,
                    label: 'Visits',
                    builder: (_) => _VisitsTab(visits: visits),
                  ),
                  SegmentedTab(
                    icon: Icons.receipt_long_outlined,
                    label: 'Payments',
                    builder: (_) => _PaymentsTab(memos: patientMemos),
                  ),
                  SegmentedTab(
                    icon: Icons.event_repeat_outlined,
                    label: 'Follow-ups',
                    builder: (_) => _FollowUpsTab(visits: visits),
                  ),
                  SegmentedTab(
                    icon: Icons.insights_outlined,
                    label: 'Insights',
                    builder: (_) => _InsightsTab(visits: visits),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddVisitDialog(patient: patient),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Visit'),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: Spacing.xs),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  final Patient patient;
  final List<VisitWithDetails> visits;

  const _InfoTab({required this.patient, required this.visits});

  @override
  Widget build(BuildContext context) {
    DateTime? lastVisit;
    DateTime? nextFollowUp;
    if (visits.isNotEmpty) {
      lastVisit = visits.first.visit.visitDate;
      for (final v in visits) {
        final n = v.visit.nextFollowUpDate;
        if (n != null && (nextFollowUp == null || n.isAfter(nextFollowUp))) {
          nextFollowUp = n;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoRow(label: 'Serial No.', value: patient.serialNo),
        InfoRow(label: 'Patient code', value: patient.patientCode),
        InfoRow(label: 'Phone', value: patient.phone, icon: Icons.call_outlined),
        InfoRow(label: 'WhatsApp', value: patient.whatsapp),
        InfoRow(label: 'Age', value: '${patient.age}'),
        InfoRow(label: 'Gender', value: patient.gender),
        InfoRow(label: 'Area', value: patient.area),
        InfoRow(label: 'Address', value: patient.address),
        InfoRow(label: 'Occupation', value: patient.occupation),
        InfoRow(
          label: 'First seen',
          value: Formatters.formatDate(patient.createdAt),
        ),
        InfoRow(
          label: 'Last visit',
          value: lastVisit == null ? null : Formatters.formatDate(lastVisit),
        ),
        InfoRow(
          label: 'Next follow-up',
          value:
              nextFollowUp == null ? null : Formatters.formatDate(nextFollowUp),
        ),
        InfoRow(label: 'Notes', value: patient.notes),
      ],
    );
  }
}

class _VisitsTab extends StatelessWidget {
  final List<VisitWithDetails> visits;

  const _VisitsTab({required this.visits});

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return const EmptyState(
        icon: Icons.timeline,
        title: 'No visits recorded',
        message: 'Use Add Visit to log this patient’s first consultation.',
      );
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: Spacing.md),
        for (final v in visits)
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
                    Expanded(
                      child: Text(
                        Formatters.formatDate(v.visit.visitDate),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Chip(
                      label: Text(v.visit.visitType == 'new' ? 'New' : 'Repeat'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(v.visit.disease, style: theme.textTheme.bodyMedium),
                const SizedBox(height: Spacing.xs),
                Text(
                  '${v.clinic.name}'
                  '${v.visit.outcome != null ? ' · ${v.visit.outcome}' : ''}',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  final List<CashMemoWithDetails> memos;

  const _PaymentsTab({required this.memos});

  @override
  Widget build(BuildContext context) {
    if (memos.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No payments yet',
        message: 'Cash memos raised for this patient appear here.',
      );
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: Spacing.md),
        for (final m in memos)
          AppCard(
            margin: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.md,
            ),
            onTap: () => showDialog(
              context: context,
              builder: (_) => ReceiptPreviewDialog(
                cashMemo: m.memo,
                patient: m.patient,
                clinicName: m.clinic.name,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.memo.memoNumber, style: theme.textTheme.titleSmall),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        Formatters.formatDate(m.memo.createdAt),
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoneyText(
                      amount: m.memo.total,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (m.pendingAmount > 0) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Pending ${Formatters.formatCurrency(m.pendingAmount)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InsightsTab extends StatelessWidget {
  final List<VisitWithDetails> visits;

  const _InsightsTab({required this.visits});

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return const EmptyState(
        icon: Icons.insights_outlined,
        title: 'Not enough data',
        message: 'Insights appear once visits are recorded.',
      );
    }

    final outcomes = <String, int>{};
    final clinicSplit = <String, int>{};
    var newCount = 0;
    for (final v in visits) {
      final o = v.visit.outcome ?? 'Not recorded';
      outcomes[o] = (outcomes[o] ?? 0) + 1;
      clinicSplit[v.clinic.name] = (clinicSplit[v.clinic.name] ?? 0) + 1;
      if (v.visit.visitType == 'new') newCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.xs),
        const SectionHeader(title: 'Visit type', tightTop: true),
        InfoRow(label: 'New', value: '$newCount'),
        InfoRow(label: 'Repeat', value: '${visits.length - newCount}'),
        const SectionHeader(title: 'Outcomes'),
        for (final e in outcomes.entries)
          InfoRow(label: e.key, value: '${e.value}'),
        const SectionHeader(title: 'Clinics'),
        for (final e in clinicSplit.entries)
          InfoRow(label: e.key, value: '${e.value} visits'),
      ],
    );
  }
}

/// Scheduled and missed follow-ups.
///
/// visits.nextFollowUpDate has been in the schema since v2 with nowhere to
/// show it, so an overdue patient was invisible unless the doctor happened to
/// open the right visit.
class _FollowUpsTab extends StatelessWidget {
  final List<VisitWithDetails> visits;

  const _FollowUpsTab({required this.visits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final scheduled = visits
        .where((v) => v.visit.nextFollowUpDate != null)
        .toList()
      ..sort((a, b) =>
          a.visit.nextFollowUpDate!.compareTo(b.visit.nextFollowUpDate!));

    if (scheduled.isEmpty) {
      return const EmptyState(
        icon: Icons.event_repeat_outlined,
        title: 'No follow-ups scheduled',
        message: 'Set a follow-up date when recording a visit and it '
            'will appear here.',
      );
    }

    final overdue = scheduled
        .where((v) => v.visit.nextFollowUpDate!.isBefore(today))
        .toList();
    final upcoming = scheduled
        .where((v) => !v.visit.nextFollowUpDate!.isBefore(today))
        .toList();

    Widget row(VisitWithDetails v, {required bool isOverdue}) {
      final due = v.visit.nextFollowUpDate!;
      final days = due.difference(today).inDays;
      final label = isOverdue
          ? '${-days} ${(-days) == 1 ? 'day' : 'days'} overdue'
          : days == 0
              ? 'Due today'
              : 'In $days ${days == 1 ? 'day' : 'days'}';

      return AppCard(
        margin: const EdgeInsets.fromLTRB(
          Spacing.lg,
          0,
          Spacing.lg,
          Spacing.md,
        ),
        child: Row(
          children: [
            Icon(
              isOverdue ? Icons.warning_amber_outlined : Icons.event_available,
              color: isOverdue
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formatters.formatDate(due),
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    '${v.visit.disease} · ${v.clinic.name}',
                    style: theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isOverdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.xs),
        if (overdue.isNotEmpty) ...[
          const SectionHeader(title: 'Overdue', tightTop: true),
          for (final v in overdue) row(v, isOverdue: true),
        ],
        if (upcoming.isNotEmpty) ...[
          SectionHeader(title: 'Upcoming', tightTop: overdue.isEmpty),
          for (final v in upcoming) row(v, isOverdue: false),
        ],
      ],
    );
  }
}
