import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/whatsapp_template_picker.dart';
import '../providers/recall_provider.dart';
import 'patient_profile_screen.dart';

/// Patients worth contacting today, across every clinic.
///
/// The practice sees roughly 2 new patients a month against 6 repeat visits,
/// so the cheapest growth available is the patient who already came once and
/// then stopped. This screen exists to make those people visible without the
/// doctor having to remember them.
class RecallScreen extends ConsumerWidget {
  /// Whether to draw its own app bar.
  ///
  /// False when embedded as a section of the Patients tab, which already has
  /// a header — two stacked titles would say the same thing twice.
  final bool showAppBar;

  const RecallScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(recallListProvider);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: const Text('Follow-ups'))
          : null,
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (lists) {
          if (lists.total == 0) {
            return EmptyState.recall(
              title: 'All caught up!',
              message: 'No patients are currently due for recall or follow-up.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
            children: [
              if (lists.overdue.isNotEmpty) ...[
                SectionHeader(
                  title: 'Overdue',
                  subtitle: '${lists.overdue.length} '
                      '${lists.overdue.length == 1 ? 'patient' : 'patients'}',
                ),
                for (final e in lists.overdue) _RecallCard(entry: e),
              ],
              if (lists.dueSoon.isNotEmpty) ...[
                SectionHeader(
                  title: 'Due this week',
                  subtitle: '${lists.dueSoon.length} '
                      '${lists.dueSoon.length == 1 ? 'patient' : 'patients'}',
                ),
                for (final e in lists.dueSoon) _RecallCard(entry: e),
              ],
              if (lists.upcoming.isNotEmpty) ...[
                SectionHeader(
                  title: 'Upcoming Follow-ups',
                  subtitle: '${lists.upcoming.length} scheduled',
                ),
                for (final e in lists.upcoming) _RecallCard(entry: e),
              ],
              if (lists.lapsed.isNotEmpty) ...[
                SectionHeader(
                  title: 'Not seen recently',
                  subtitle: 'No follow-up was scheduled',
                ),
                for (final e in lists.lapsed) _RecallCard(entry: e),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RecallCard extends StatelessWidget {
  final RecallEntry entry;

  const _RecallCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = entry.patient;

    final label = entry.isDueToday
        ? 'Due today'
        : entry.isOverdue
            ? '${entry.daysOverdue} '
                '${entry.daysOverdue == 1 ? 'day' : 'days'} overdue'
            : 'In ${-entry.daysOverdue} '
                '${-entry.daysOverdue == 1 ? 'day' : 'days'}';

    final urgent = entry.isOverdue || entry.isDueToday;

    return AppCard(
      margin: const EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.md,
      ),
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => PatientProfileScreen(patient: p),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: urgent ? scheme.error : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            '${p.patientCode} · ${entry.visit.disease} · ${entry.clinic.name}',
            style: theme.textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Last visit ${Formatters.formatDate(entry.visit.visitDate)}',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ContactService.call(p.phone),
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => WhatsAppTemplatePickerSheet.show(
                    context,
                    patient: p,
                    clinicName: entry.clinic.name,
                    dueDate: entry.visit.nextFollowUpDate,
                  ),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
