import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/chip_row.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entity_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_strip.dart';
import '../../../core/widgets/money_text.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../core/widgets/whatsapp_template_picker.dart';
import '../../cashmemo/presentation/receipt_preview_dialog.dart';
import '../../cashmemo/providers/cash_memo_provider.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../visits/presentation/add_visit_dialog.dart';
import '../../visits/providers/visit_provider.dart';
import '../../growth/presentation/record_review_dialog.dart';
import '../../clinical/presentation/master_case_taking_screen.dart';
import '../../clinical/presentation/widgets/complaint_list_view.dart';
import '../../clinical/presentation/widgets/prescription_list_view.dart';
import '../../clinical/presentation/widgets/investigation_list_view.dart';
import '../../clinical/providers/case_record_provider.dart';
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
    final clinicsAsync = ref.watch(clinicsStreamProvider);

    final clinics = clinicsAsync.value ?? [];
    final primaryClinic =
        clinics.where((c) => c.id == patient.primaryClinicId).firstOrNull;

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // No app bar: it repeated the name the header already shows. Back
          // and edit ride on top of the header instead.
          SliverToBoxAdapter(
            child: EntityHeader(
              title: patient.name,
              avatarText: patient.name,
              heroTag: 'patient-avatar-${patient.id}',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat_outlined),
                  tooltip: 'WhatsApp message',
                  onPressed: () => WhatsAppTemplatePickerSheet.show(
                    context,
                    patient: patient,
                    clinicName: primaryClinic?.name ?? 'Clinic',
                  ),
                ),
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
                if (primaryClinic != null)
                  _Badge(
                    icon: Icons.local_hospital_outlined,
                    label: primaryClinic.name,
                  ),
                if ((patient.area ?? '').isNotEmpty)
                  _Badge(icon: Icons.place_outlined, label: patient.area!),
                _Badge(
                  icon: Icons.person_outline,
                  label: '${patient.gender}, ${patient.age}y',
                ),
                _Badge(
                  icon: Icons.event_outlined,
                  label: 'Since ${Formatters.formatDate(patient.createdAt)}',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.md),
              child: MetricStrip(
                metrics: [
                  Metric(
                    label: 'Visits',
                    value: '$totalVisits',
                    icon: Icons.event_available_outlined,
                    color: scheme.primary,
                  ),
                  Metric(
                    label: 'Lifetime',
                    value: Formatters.formatCurrency(lifetimeRevenue),
                    icon: Icons.account_balance_wallet_outlined,
                    color: scheme.secondary,
                  ),
                  Metric(
                    label: 'Avg bill',
                    value: Formatters.formatCurrency(avgBill),
                    icon: Icons.calculate_outlined,
                    color: scheme.tertiary,
                  ),
                  Metric(
                    label: 'Pending',
                    value: Formatters.formatCurrency(totalPending),
                    signedAmount: totalPending > 0 ? -totalPending : 0,
                    icon: Icons.pending_actions_outlined,
                    color: totalPending > 0 ? scheme.error : null,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: ChipRow(labels: [
                if ((patient.primaryDisease ?? '').isNotEmpty)
                  patient.primaryDisease!,
                if ((patient.referralSource ?? '').isNotEmpty)
                  patient.referralSource!,
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.md, bottom: 96),
              child: SegmentedTabs(
                tabs: [
                  SegmentedTab(
                    icon: Icons.info_outline,
                    label: 'Information',
                    builder: (_) => _InfoTab(patient: patient, visits: visits),
                  ),
                  SegmentedTab(
                    icon: Icons.healing_outlined,
                    label: 'Complaints',
                    builder: (_) => ComplaintListView(patient: patient),
                  ),
                  SegmentedTab(
                    icon: Icons.assignment_outlined,
                    label: 'Case Record',
                    builder: (_) => _ClinicalCaseRecordTab(patient: patient),
                  ),
                  SegmentedTab(
                    icon: Icons.medication_outlined,
                    label: 'Prescriptions',
                    builder: (_) => PrescriptionListView(patient: patient),
                  ),
                  SegmentedTab(
                    icon: Icons.biotech_outlined,
                    label: 'Investigations',
                    builder: (_) => InvestigationListView(patient: patient),
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

    final hasNotes = (patient.notes ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Identifiers
        InfoRow(
          label: 'Serial No.',
          value: patient.serialNo,
          icon: Icons.tag,
        ),
        InfoRow(
          label: 'Patient code',
          value: patient.patientCode,
          icon: Icons.badge_outlined,
        ),

        const SizedBox(height: Spacing.sm),
        const Divider(height: 1, indent: Spacing.lg, endIndent: Spacing.lg),
        const SizedBox(height: Spacing.sm),

        // Communication
        InfoRow(
          label: 'Phone',
          value: patient.phone,
          icon: Icons.call_outlined,
          onTap: () => ContactService.call(patient.phone),
        ),
        InfoRow(
          label: 'WhatsApp',
          value: patient.whatsapp ?? patient.phone,
          icon: Icons.chat_outlined,
          onTap: () => WhatsAppTemplatePickerSheet.show(
            context,
            patient: patient,
            clinicName: visits.isNotEmpty ? visits.first.clinic.name : 'Clinic',
            dueDate: nextFollowUp,
          ),
        ),

        const SizedBox(height: Spacing.sm),
        const Divider(height: 1, indent: Spacing.lg, endIndent: Spacing.lg),
        const SizedBox(height: Spacing.sm),

        // Demographics & Location
        InfoRow(
          label: 'Age',
          value: '${patient.age}',
          icon: Icons.cake_outlined,
        ),
        InfoRow(
          label: 'Gender',
          value: patient.gender,
          icon: Icons.person_outline,
        ),
        InfoRow(
          label: 'Area',
          value: patient.area,
          icon: Icons.location_city_outlined,
        ),
        InfoRow(
          label: 'Address',
          value: patient.address,
          icon: Icons.home_outlined,
        ),
        InfoRow(
          label: 'Occupation',
          value: patient.occupation,
          icon: Icons.work_outline,
        ),

        const SizedBox(height: Spacing.sm),
        const Divider(height: 1, indent: Spacing.lg, endIndent: Spacing.lg),
        const SizedBox(height: Spacing.sm),

        // Timeline & Follow-ups
        InfoRow(
          label: 'First seen',
          value: Formatters.formatDate(patient.createdAt),
          icon: Icons.event_available_outlined,
        ),
        InfoRow(
          label: 'Last visit',
          value: lastVisit == null ? null : Formatters.formatDate(lastVisit),
          icon: Icons.history_outlined,
        ),
        InfoRow(
          label: 'Next follow-up',
          value:
              nextFollowUp == null ? null : Formatters.formatDate(nextFollowUp),
          icon: Icons.alarm_outlined,
        ),

        const SizedBox(height: Spacing.sm),
        const Divider(height: 1, indent: Spacing.lg, endIndent: Spacing.lg),
        const SizedBox(height: Spacing.sm),

        // Reviews & Notes
        InfoRow(
          label: 'Google Review',
          value: patient.reviewGiven
              ? 'Reviewed ★'
              : patient.reviewAskedAt != null
                  ? 'Asked ${Formatters.formatDate(patient.reviewAskedAt!)}'
                  : 'Not requested',
          icon: Icons.star_outline,
          onTap: () => showDialog(
            context: context,
            builder: (_) => RecordReviewDialog(
              patient: patient,
              clinicId: patient.primaryClinicId,
            ),
          ),
        ),
        if (hasNotes)
          InfoRow(
            label: 'Notes',
            value: patient.notes,
            icon: Icons.notes_outlined,
          ),
      ],
    );
  }
}

class _VisitsTab extends ConsumerWidget {
  final List<VisitWithDetails> visits;

  const _VisitsTab({required this.visits});

  Color _outcomeColor(String? outcome, ColorScheme scheme) {
    if (outcome == null) return scheme.outline;
    switch (outcome.toLowerCase()) {
      case 'recovered':
      case 'improved':
        return scheme.primary;
      case 'worse':
        return scheme.error;
      case 'lost_followup':
        return scheme.tertiary;
      case 'no_change':
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String _outcomeLabel(String outcome) {
    switch (outcome.toLowerCase()) {
      case 'improved':
        return 'Improved';
      case 'recovered':
        return 'Recovered';
      case 'no_change':
        return 'No change';
      case 'worse':
        return 'Worse';
      case 'lost_followup':
        return 'Lost follow-up';
      default:
        return outcome;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (visits.isEmpty) {
      return const EmptyState(
        icon: Icons.timeline,
        title: 'No visits recorded',
        message: 'Use Add Visit to log this patient’s first consultation.',
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        for (final v in visits)
          AppCard(
            margin: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.md,
            ),
            onLongPress: () async {
              AppHaptics.medium();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Visit Entry?'),
                  content: Text(
                    'Are you sure you want to delete the visit recorded on ${Formatters.formatDate(v.visit.visitDate)} for ${v.visit.disease}? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.error,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete Entry'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final db = ref.read(databaseProvider);
                await (db.delete(db.visits)..where((t) => t.id.equals(v.visit.id))).go();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visit entry deleted.')),
                  );
                }
              }
            },
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
                    CustomBadge(
                      label: v.visit.visitType == 'new'
                          ? 'New Visit'
                          : 'Repeat Visit',
                      color: v.visit.visitType == 'new'
                          ? scheme.primary
                          : scheme.secondary,
                    ),
                    if (v.visit.consultationType.isNotEmpty &&
                        v.visit.consultationType != 'clinic') ...[
                      const SizedBox(width: Spacing.xs),
                      CustomBadge(
                        label: v.visit.consultationType.toUpperCase(),
                        color: scheme.tertiary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  v.visit.disease,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((v.visit.chiefComplaint ?? '').isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs),
                  Text(
                    v.visit.chiefComplaint!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      v.clinic.name,
                      style: theme.textTheme.labelMedium,
                    ),
                    if (v.visit.outcome != null &&
                        v.visit.outcome!.isNotEmpty) ...[
                      const Spacer(),
                      CustomBadge(
                        label: _outcomeLabel(v.visit.outcome!),
                        color: _outcomeColor(v.visit.outcome, scheme),
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
    final scheme = theme.colorScheme;

    return Column(
      children: [
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      PaymentIcons.forMethod(m.memo.paymentMethod),
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        m.memo.memoNumber,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    MoneyText(
                      amount: m.memo.total,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Formatters.formatDate(m.memo.memoDate)} · ${m.clinic.name}',
                      style: theme.textTheme.labelMedium,
                    ),
                    if (m.pendingAmount > 0)
                      CustomBadge(
                        label:
                            'Pending ${Formatters.formatCurrency(m.pendingAmount)}',
                        color: scheme.error,
                      )
                    else
                      CustomBadge(
                        label: 'Paid',
                        color: scheme.primary,
                      ),
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
    final consultTypeSplit = <String, int>{};
    var newCount = 0;
    for (final v in visits) {
      final o = v.visit.outcome ?? 'Not recorded';
      outcomes[o] = (outcomes[o] ?? 0) + 1;
      clinicSplit[v.clinic.name] = (clinicSplit[v.clinic.name] ?? 0) + 1;
      final cType = v.visit.consultationType;
      consultTypeSplit[cType] = (consultTypeSplit[cType] ?? 0) + 1;
      if (v.visit.visitType == 'new') newCount++;
    }

    int? avgDaysBetweenVisits;
    if (visits.length > 1) {
      final sortedDates = visits.map((v) => v.visit.visitDate).toList()
        ..sort();
      final span = sortedDates.last.difference(sortedDates.first).inDays;
      avgDaysBetweenVisits = (span / (visits.length - 1)).round();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Visit breakdown', tightTop: true),
        InfoRow(label: 'Total visits', value: '${visits.length}'),
        InfoRow(label: 'New consultations', value: '$newCount'),
        InfoRow(label: 'Repeat follow-ups', value: '${visits.length - newCount}'),
        if (avgDaysBetweenVisits != null)
          InfoRow(
            label: 'Avg interval between visits',
            value: '$avgDaysBetweenVisits days',
          ),
        const SectionHeader(title: 'Consultation mode'),
        for (final e in consultTypeSplit.entries)
          InfoRow(label: e.key.toUpperCase(), value: '${e.value} visits'),
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
class _FollowUpsTab extends ConsumerWidget {
  final List<VisitWithDetails> visits;

  const _FollowUpsTab({required this.visits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        onLongPress: () async {
          AppHaptics.medium();
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Remove Scheduled Follow-up?'),
              content: Text(
                'Remove follow-up scheduled for ${Formatters.formatDate(due)} (${v.visit.disease})?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Remove Follow-up'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            final db = ref.read(databaseProvider);
            await (db.update(db.visits)..where((t) => t.id.equals(v.visit.id))).write(
              const VisitsCompanion(nextFollowUpDate: Value(null)),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scheduled follow-up removed.')),
              );
            }
          }
        },
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
            const SizedBox(width: Spacing.sm),
            IconButton.outlined(
              icon: const Icon(Icons.chat_outlined, size: 18),
              tooltip: 'Send WhatsApp reminder',
              onPressed: () {
                AppHaptics.selection();
                ContactService.openWhatsApp(
                  phone: v.patient.whatsapp ?? v.patient.phone,
                  message: ContactService.followUpMessage(
                    patientName: v.patient.name,
                    clinicName: v.clinic.name,
                  ),
                );
              },
            ),
            const SizedBox(width: Spacing.xs),
            IconButton.outlined(
              icon: const Icon(Icons.phone_outlined, size: 18),
              tooltip: 'Call Patient',
              onPressed: () {
                AppHaptics.selection();
                ContactService.call(v.patient.phone);
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

class _ClinicalCaseRecordTab extends ConsumerWidget {
  final Patient patient;

  const _ClinicalCaseRecordTab({required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseRecordAsync = ref.watch(patientCaseRecordProvider(patient.id));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final record = caseRecordAsync.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Spacing.xs + 2),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: Radii.smAll,
                      ),
                      child: Icon(Icons.assignment_outlined, color: scheme.primary),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master Clinical Case Record',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            record == null
                                ? 'No case taking form recorded yet'
                                : 'Recorded on ${Formatters.formatDate(record.recordDate)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                if (record != null) ...[
                  if (record.chiefComplaints.isNotEmpty &&
                      record.chiefComplaints.first.complaint.isNotEmpty)
                    InfoRow(
                      label: 'Chief Complaint',
                      value: record.chiefComplaints.first.complaint,
                      icon: Icons.healing_outlined,
                    ),
                  if (record.clinicalAssessment.finalWorkingDiagnosis.isNotEmpty ||
                      record.clinicalAssessment.provisionalDiagnosis.isNotEmpty)
                    InfoRow(
                      label: 'Diagnosis',
                      value: record.clinicalAssessment.finalWorkingDiagnosis.isNotEmpty
                          ? record.clinicalAssessment.finalWorkingDiagnosis
                          : record.clinicalAssessment.provisionalDiagnosis,
                      icon: Icons.medical_services_outlined,
                    ),
                  InfoRow(
                    label: 'Dominant Miasm',
                    value: record.miasmaticAnalysis.dominantMiasm,
                    icon: Icons.coronavirus_outlined,
                  ),
                  InfoRow(
                    label: 'Thermal State',
                    value: record.physicalGenerals.thermal,
                    icon: Icons.thermostat_outlined,
                  ),
                  InfoRow(
                    label: 'Simillimum Remedy',
                    value: record.caseTotality.selectedRemedy.isNotEmpty
                        ? '${record.caseTotality.selectedRemedy} ${record.caseTotality.potency}'.trim()
                        : null,
                    icon: Icons.medication_outlined,
                  ),
                  InfoRow(
                    label: 'Case Outcome',
                    value: record.displayOutcome,
                    icon: Icons.flag_outlined,
                  ),
                  if (record.outcomeDetails.degreeOfImprovement.isNotEmpty)
                    InfoRow(
                      label: 'Degree of Improvement',
                      value: record.outcomeDetails.degreeOfImprovement,
                      icon: Icons.trending_up_outlined,
                    ),
                  if (record.outcomeDetails.treatmentDuration.isNotEmpty)
                    InfoRow(
                      label: 'Treatment Duration',
                      value: record.outcomeDetails.treatmentDuration,
                      icon: Icons.timer_outlined,
                    ),
                  if (record.outcomeDetails.reasonForDiscontinuation.isNotEmpty)
                    InfoRow(
                      label: 'Discontinuation Reason',
                      value: record.outcomeDetails.reasonForDiscontinuation,
                      icon: Icons.cancel_outlined,
                    ),
                  if (record.outcomeDetails.lostToFollowUp.isNotEmpty)
                    InfoRow(
                      label: 'Lost to Follow-up',
                      value: record.outcomeDetails.lostToFollowUp,
                      icon: Icons.person_off_outlined,
                    ),
                  if (record.outcomeDetails.finalOutcomeNotes.isNotEmpty)
                    InfoRow(
                      label: 'Outcome Notes',
                      value: record.outcomeDetails.finalOutcomeNotes,
                      icon: Icons.notes_outlined,
                    ),
                  const SizedBox(height: Spacing.sm),
                ],
                AppButton.primary(
                  label: record == null
                      ? 'Start Clinical Case Taking'
                      : 'Edit Case Record',
                  icon: record == null
                      ? Icons.edit_note
                      : Icons.edit_outlined,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => MasterCaseTakingScreen(patient: patient),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
