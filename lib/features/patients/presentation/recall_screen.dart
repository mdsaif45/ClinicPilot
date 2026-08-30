import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/whatsapp_template_picker.dart';
import '../../visits/presentation/add_visit_dialog.dart';
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

          var hasRenderedFirstSection = false;

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Spacing.lg, 0, Spacing.xxl),
            children: [
              if (lists.overdue.isNotEmpty) ...[
                SectionHeader(
                  tightTop: !hasRenderedFirstSection,
                  title: 'Overdue',
                  subtitle: '${lists.overdue.length} '
                      '${lists.overdue.length == 1 ? 'patient' : 'patients'}',
                ),
                for (final e in lists.overdue) _RecallCard(entry: e),
                ...(() {
                  hasRenderedFirstSection = true;
                  return const <Widget>[];
                }()),
              ],
              if (lists.dueSoon.isNotEmpty) ...[
                SectionHeader(
                  tightTop: !hasRenderedFirstSection,
                  title: 'Due this week',
                  subtitle: '${lists.dueSoon.length} '
                      '${lists.dueSoon.length == 1 ? 'patient' : 'patients'}',
                ),
                for (final e in lists.dueSoon) _RecallCard(entry: e),
                ...(() {
                  hasRenderedFirstSection = true;
                  return const <Widget>[];
                }()),
              ],
              if (lists.upcoming.isNotEmpty) ...[
                SectionHeader(
                  tightTop: !hasRenderedFirstSection,
                  title: 'Upcoming Follow-ups',
                  subtitle: '${lists.upcoming.length} scheduled',
                ),
                for (final e in lists.upcoming) _RecallCard(entry: e),
                ...(() {
                  hasRenderedFirstSection = true;
                  return const <Widget>[];
                }()),
              ],
              if (lists.lapsed.isNotEmpty) ...[
                SectionHeader(
                  tightTop: !hasRenderedFirstSection,
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

class _RecallCard extends ConsumerWidget {
  final RecallEntry entry;

  const _RecallCard({required this.entry});

  Future<void> _confirmCancelFollowUp(BuildContext context, WidgetRef ref) async {
    AppHaptics.medium();
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Cancel Follow-up',
      message:
          'Are you sure you want to cancel the scheduled follow-up for ${entry.patient.name} (${entry.visit.disease})?',
      confirmLabel: 'Cancel Follow-up',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await (db.update(db.visits)..where((t) => t.id.equals(entry.visit.id))).write(
        const VisitsCompanion(nextFollowUpDate: Value(null)),
      );
      AppHaptics.medium();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Follow-up cancelled for ${entry.patient.name}.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left column: Patient identity, disease, clinic & last visit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  entry.visit.disease,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  entry.clinic.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Last visit ${Formatters.formatDate(entry.visit.visitDate)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Right column: Due status and compact action buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: urgent ? scheme.error : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.outlined(
                    onPressed: () => _confirmCancelFollowUp(context, ref),
                    icon: Icon(Icons.event_busy_outlined, size: 18, color: scheme.error),
                    tooltip: 'Cancel follow-up',
                  ),
                  const SizedBox(width: Spacing.xs),
                  IconButton.outlined(
                    onPressed: () {
                      AppHaptics.selection();
                      showDialog(
                        context: context,
                        builder: (_) => AddVisitDialog(patient: p),
                      );
                    },
                    icon: Icon(Icons.event_available_outlined, size: 18, color: scheme.primary),
                    tooltip: 'Record visit',
                  ),
                  const SizedBox(width: Spacing.xs),
                  IconButton.outlined(
                    onPressed: () {
                      AppHaptics.selection();
                      WhatsAppTemplatePickerSheet.show(
                        context,
                        patient: p,
                        clinicName: entry.clinic.name,
                        dueDate: entry.visit.nextFollowUpDate,
                      );
                    },
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    tooltip: 'WhatsApp reminder',
                  ),
                  const SizedBox(width: Spacing.xs),
                  IconButton.outlined(
                    onPressed: () {
                      AppHaptics.selection();
                      ContactService.call(p.phone);
                    },
                    icon: const Icon(Icons.phone_outlined, size: 18),
                    tooltip: 'Call patient',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
