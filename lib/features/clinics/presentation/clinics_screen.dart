import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/entitlement/entitlement_model.dart';
import '../../../core/entitlement/entitlement_provider.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pro_badge.dart';
import '../../settings/presentation/widgets/pro_upgrade_sheet.dart';
import '../providers/clinic_provider.dart';
import 'add_edit_clinic_dialog.dart';

class ClinicsScreen extends ConsumerWidget {
  const ClinicsScreen({super.key});

  void _openAddClinic(
    BuildContext context,
    WidgetRef ref,
    int currentClinicCount,
  ) {
    AppHaptics.selection();
    final unlocked = ref.read(
      featureUnlockedProvider(AppFeature.multiClinicManagement),
    );
    if (currentClinicCount >= 1 && !unlocked) {
      ProUpgradeSheet.show(context);
      return;
    }
    showDialog(context: context, builder: (_) => const AddEditClinicDialog());
  }

  void _openEditClinic(BuildContext context, Clinic clinic) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditClinicDialog(clinic: clinic),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final activeId = ref.watch(activeClinicIdProvider);
    final unlocked = ref.watch(
      featureUnlockedProvider(AppFeature.multiClinicManagement),
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Clinics')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final count = clinicsAsync.value?.length ?? 0;
          _openAddClinic(context, ref, count);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Clinic'),
      ),
      body: clinicsAsync.when(
        data: (clinics) {
          if (clinics.isEmpty) {
            return const Center(child: Text('No clinics configured.'));
          }

          final effectiveActiveId =
              activeId ?? (clinics.isNotEmpty ? clinics.first.id : null);

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            children: [
              if (!unlocked)
                AppCard(
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: scheme.tertiary,
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Multi-Clinic Practice',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                const ProBadge(compact: true),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Free tier includes 1 clinic. Upgrade to Pro to manage 2+ clinics with cross-clinic comparison.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              for (int index = 0; index < clinics.length; index++) ...[
                if (index > 0) const SizedBox(height: Spacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color:
                        clinics[index].id == effectiveActiveId
                            ? scheme.primaryContainer.withValues(alpha: 0.3)
                            : scheme.surfaceContainerLow,
                    borderRadius: Radii.mdAll,
                    border: Border.all(
                      color:
                          clinics[index].id == effectiveActiveId
                              ? scheme.primary
                              : scheme.outlineVariant.withValues(alpha: 0.5),
                      width: clinics[index].id == effectiveActiveId ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    leading: Radio<String>(
                      value: clinics[index].id,
                      groupValue: effectiveActiveId,
                      activeColor: scheme.primary,
                      onChanged: (val) {
                        if (val != null) {
                          AppHaptics.selection();
                          ref
                              .read(activeClinicIdProvider.notifier)
                              .setClinicId(val);
                        }
                      },
                    ),
                    title: Text(
                      clinics[index].name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit Clinic Details & Targets',
                      onPressed: () => _openEditClinic(context, clinics[index]),
                    ),
                    onTap: () {
                      AppHaptics.selection();
                      ref
                          .read(activeClinicIdProvider.notifier)
                          .setClinicId(clinics[index].id);
                    },
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
