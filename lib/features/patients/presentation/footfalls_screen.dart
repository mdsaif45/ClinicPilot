import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/metric_strip.dart';
import '../providers/footfall_provider.dart';
import 'add_footfall_dialog.dart';
import 'add_patient_dialog.dart';

class FootfallsScreen extends ConsumerWidget {
  const FootfallsScreen({super.key});

  void _openAddFootfall(BuildContext context) {
    AppHaptics.selection();
    showDialog(context: context, builder: (_) => const AddFootfallDialog());
  }

  void _convertToPatient(
    BuildContext context,
    WidgetRef ref,
    FootfallWithDetails footfall,
  ) {
    AppHaptics.selection();
    showDialog<String>(
      context: context,
      builder: (_) => AddPatientDialog(
        initialName: footfall.footfall.name,
        initialPhone: footfall.footfall.phone,
        initialDisease: footfall.footfall.disease,
        initialClinicId: footfall.footfall.clinicId,
      ),
    ).then((newPatientId) {
      if (newPatientId != null && newPatientId.isNotEmpty) {
        ref.read(footfallNotifierProvider.notifier).convertFootfall(
              footfallId: footfall.footfall.id,
              patientId: newPatientId,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footfallsAsync = ref.watch(footfallsStreamProvider);
    final statsAsync = ref.watch(footfallStatsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddFootfall(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Walk-in'),
      ),
      body: footfallsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load footfalls: $e')),
        data: (footfalls) {
          if (footfalls.isEmpty) {
            return EmptyState.growth(
              title: 'No walk-in inquiries yet',
              message:
                  'Log clinic walk-ins, phone inquiries, and camp leads to track conversion into registered patients.',
              actionLabel: 'Log First Walk-in',
              onAction: () => _openAddFootfall(context),
            );
          }

          final stats = statsAsync.value;

          return ListView(
            padding: const EdgeInsets.only(bottom: Spacing.xxl * 2),
            children: [
              if (stats != null)
                MetricStrip(
                  metrics: [
                    Metric(
                      label: 'Walk-ins',
                      value: '${stats.totalCount}',
                    ),
                    Metric(
                      label: 'Converted',
                      value: '${stats.convertedCount}',
                    ),
                    Metric(
                      label: 'Conversion',
                      value: '${stats.conversionRate.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              const SizedBox(height: Spacing.sm),
              for (final f in footfalls)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.footfall.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  '${f.clinic.name} • ${Formatters.formatDate(f.footfall.date)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomBadge(
                            label: f.isConverted ? 'Converted' : 'Lead',
                            color: f.isConverted
                                ? scheme.primary
                                : scheme.outline,
                          ),
                        ],
                      ),
                      if (f.footfall.disease != null &&
                          f.footfall.disease!.isNotEmpty) ...[
                        const SizedBox(height: Spacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              f.footfall.disease!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (f.footfall.notes != null &&
                          f.footfall.notes!.isNotEmpty) ...[
                        const SizedBox(height: Spacing.xs),
                        Text(
                          f.footfall.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: Spacing.md),
                      Row(
                        children: [
                          if (f.footfall.phone != null &&
                              f.footfall.phone!.isNotEmpty) ...[
                            IconButton.outlined(
                              onPressed: () {
                                AppHaptics.selection();
                                ContactService.openWhatsApp(
                                  phone: f.footfall.phone!,
                                  message:
                                      'Hello ${f.footfall.name}, thank you for inquiring at ${f.clinic.name}. Feel free to let us know if you would like to book a consultation.',
                                );
                              },
                              icon: const Icon(Icons.chat_outlined, size: 18),
                              tooltip: 'WhatsApp Inquiry',
                            ),
                            const SizedBox(width: Spacing.sm),
                            IconButton.outlined(
                              onPressed: () {
                                AppHaptics.selection();
                                ContactService.call(f.footfall.phone!);
                              },
                              icon: const Icon(Icons.phone_outlined, size: 18),
                              tooltip: 'Call',
                            ),
                            const Spacer(),
                          ] else
                            const Spacer(),
                          if (!f.isConverted)
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  _convertToPatient(context, ref, f),
                              icon: const Icon(Icons.person_add_outlined,
                                  size: 16),
                              label: const Text('Convert to Patient'),
                            ),
                        ],
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
