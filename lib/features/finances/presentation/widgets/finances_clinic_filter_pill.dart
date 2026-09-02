import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/tokens.dart';
import '../../../clinics/providers/clinic_provider.dart';
import '../../providers/finances_clinic_filter_provider.dart';

/// Compact header pill for selecting the clinic scope in Finances.
/// Allows viewing "All Clinics" (Consolidated) or an individual clinic.
class FinancesClinicFilterPill extends ConsumerWidget {
  const FinancesClinicFilterPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final selectedClinicId = ref.watch(financesClinicFilterProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final clinics = clinicsAsync.value ?? [];
    // If only 0 or 1 clinic exists in database, no need to show switcher
    if (clinics.length < 2) return const SizedBox.shrink();

    final selectedClinic = selectedClinicId == null
        ? null
        : clinics.firstWhere(
            (c) => c.id == selectedClinicId,
            orElse: () => clinics.first,
          );

    final isFiltered = selectedClinicId != null;
    final label = isFiltered ? selectedClinic!.name : 'All Clinics';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: Radii.pillAll,
        onTap: () => _openClinicPickerSheet(context, ref, clinics, selectedClinicId),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isFiltered
                ? scheme.primary.withAlpha(25)
                : scheme.surfaceContainerHighest.withAlpha(140),
            borderRadius: Radii.pillAll,
            border: Border.all(
              color: isFiltered
                  ? scheme.primary.withAlpha(120)
                  : theme.dividerColor.withAlpha(80),
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
    List<dynamic> clinics,
    String? currentSelectedId,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Spacing.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                  'Financial Scope',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  'Filter cash flow, expenses & statements by branch',
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
                    side: currentSelectedId == null
                        ? BorderSide(color: scheme.primary.withAlpha(120), width: 1.5)
                        : BorderSide.none,
                  ),
                  tileColor: currentSelectedId == null
                      ? scheme.primary.withAlpha(20)
                      : scheme.surfaceContainerHighest.withAlpha(70),
                  leading: Container(
                    padding: const EdgeInsets.all(Spacing.xs),
                    decoration: BoxDecoration(
                      color: currentSelectedId == null
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      borderRadius: Radii.smAll,
                    ),
                    child: Icon(
                      Icons.public_rounded,
                      size: 20,
                      color: currentSelectedId == null
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    'All Clinics (Consolidated)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          currentSelectedId == null ? FontWeight.w700 : FontWeight.w500,
                      color: currentSelectedId == null
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Practice-wide total across all ${clinics.length} branches',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: currentSelectedId == null
                      ? Icon(Icons.check_circle, color: scheme.primary, size: 20)
                      : null,
                  onTap: () {
                    ref.read(financesClinicFilterProvider.notifier).state = null;
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
                      side: currentSelectedId == clinic.id
                          ? BorderSide(color: scheme.primary.withAlpha(120), width: 1.5)
                          : BorderSide.none,
                    ),
                    tileColor: currentSelectedId == clinic.id
                        ? scheme.primary.withAlpha(20)
                        : scheme.surfaceContainerHighest.withAlpha(70),
                    leading: Container(
                      padding: const EdgeInsets.all(Spacing.xs),
                      decoration: BoxDecoration(
                        color: currentSelectedId == clinic.id
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: Radii.smAll,
                      ),
                      child: Icon(
                        Icons.domain_rounded,
                        size: 20,
                        color: currentSelectedId == clinic.id
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      clinic.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: currentSelectedId == clinic.id
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: currentSelectedId == clinic.id
                            ? scheme.primary
                            : scheme.onSurface,
                      ),
                    ),
                    subtitle: clinic.address != null && clinic.address!.isNotEmpty
                        ? Text(
                            clinic.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                    trailing: currentSelectedId == clinic.id
                        ? Icon(Icons.check_circle, color: scheme.primary, size: 20)
                        : null,
                    onTap: () {
                      ref.read(financesClinicFilterProvider.notifier).state = clinic.id;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const SizedBox(height: Spacing.xs),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
