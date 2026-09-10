import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/design/tokens.dart';
import '../../../clinics/providers/clinic_provider.dart';
import '../../providers/inventory_clinic_filter_provider.dart';

/// Compact header pill for selecting the clinic inventory scope in the Medicine Inventory screen.
/// Allows viewing "All Clinics" (Consolidated Practice Stock) or an individual clinic branch.
class InventoryClinicFilterPill extends ConsumerWidget {
  const InventoryClinicFilterPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final selectedClinicId = ref.watch(inventoryClinicFilterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final clinics = clinicsAsync.value ?? [];
    // If only 0 or 1 clinic exists in database, no need to show switcher
    if (clinics.length < 2) return const SizedBox.shrink();

    final selectedClinic =
        selectedClinicId == null
            ? null
            : clinics.where((c) => c.id == selectedClinicId).firstOrNull;

    final isFiltered = selectedClinicId != null;
    final label =
        isFiltered ? (selectedClinic?.name ?? 'Clinic') : 'All Clinics';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: Radii.pillAll,
        onTap:
            () =>
                _openClinicPickerSheet(context, ref, clinics, selectedClinicId),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color:
                isFiltered
                    ? scheme.primary.withValues(alpha: 0.1)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: Radii.pillAll,
            border: Border.all(
              color:
                  isFiltered
                      ? scheme.primary.withValues(alpha: 0.5)
                      : theme.dividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFiltered ? Icons.domain_rounded : Icons.public_rounded,
                size: 13,
                color: isFiltered ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xxs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 85),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isFiltered ? FontWeight.w700 : FontWeight.w600,
                    color: isFiltered ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down,
                size: 14,
                color: isFiltered ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openClinicPickerSheet(
    BuildContext context,
    WidgetRef ref,
    List<Clinic> clinics,
    String? currentSelectedId,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Spacing.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                0,
                Spacing.lg,
                Spacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Inventory Scope',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    'Filter physical medicine stock by clinic branch',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),

                  // Option: All Clinics
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xxs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: Radii.mdAll,
                      side:
                          currentSelectedId == null
                              ? BorderSide(
                                color: scheme.primary.withValues(alpha: 0.5),
                                width: 1.5,
                              )
                              : BorderSide.none,
                    ),
                    tileColor:
                        currentSelectedId == null
                            ? scheme.primary.withValues(alpha: 0.08)
                            : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                    leading: Container(
                      padding: const EdgeInsets.all(Spacing.xs),
                      decoration: BoxDecoration(
                        color:
                            currentSelectedId == null
                                ? scheme.primary
                                : scheme.surfaceContainerHighest,
                        borderRadius: Radii.smAll,
                      ),
                      child: Icon(
                        Icons.public_rounded,
                        size: 20,
                        color:
                            currentSelectedId == null
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      'All Clinics (Consolidated Stock)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            currentSelectedId == null
                                ? FontWeight.w700
                                : FontWeight.w500,
                        color:
                            currentSelectedId == null
                                ? scheme.primary
                                : scheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Total inventory across all ${clinics.length} branches & shared supply',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    trailing:
                        currentSelectedId == null
                            ? Icon(
                              Icons.check_circle,
                              color: scheme.primary,
                              size: 20,
                            )
                            : null,
                    onTap: () {
                      ref.read(inventoryClinicFilterProvider.notifier).state =
                          null;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: Spacing.sm),

                  // List of Individual Clinics
                  for (final clinic in clinics) ...[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.xxs,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: Radii.mdAll,
                        side:
                            currentSelectedId == clinic.id
                                ? BorderSide(
                                  color: scheme.primary.withValues(alpha: 0.5),
                                  width: 1.5,
                                )
                                : BorderSide.none,
                      ),
                      tileColor:
                          currentSelectedId == clinic.id
                              ? scheme.primary.withValues(alpha: 0.08)
                              : scheme.surfaceContainerHighest.withValues(
                                alpha: 0.3,
                              ),
                      leading: Container(
                        padding: const EdgeInsets.all(Spacing.xs),
                        decoration: BoxDecoration(
                          color:
                              currentSelectedId == clinic.id
                                  ? scheme.primary
                                  : scheme.surfaceContainerHighest,
                          borderRadius: Radii.smAll,
                        ),
                        child: Icon(
                          Icons.domain_rounded,
                          size: 20,
                          color:
                              currentSelectedId == clinic.id
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        clinic.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              currentSelectedId == clinic.id
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                          color:
                              currentSelectedId == clinic.id
                                  ? scheme.primary
                                  : scheme.onSurface,
                        ),
                      ),
                      subtitle:
                          clinic.address != null && clinic.address!.isNotEmpty
                              ? Text(
                                clinic.address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              )
                              : Text(
                                'Branch inventory & shared remedies',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                      trailing:
                          currentSelectedId == clinic.id
                              ? Icon(
                                Icons.check_circle,
                                color: scheme.primary,
                                size: 20,
                              )
                              : null,
                      onTap: () {
                        ref.read(inventoryClinicFilterProvider.notifier).state =
                            clinic.id;
                        Navigator.of(ctx).pop();
                      },
                    ),
                    const SizedBox(height: Spacing.xs),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
