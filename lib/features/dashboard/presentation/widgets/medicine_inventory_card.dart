import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../clinics/providers/clinic_provider.dart';
import '../../../inventory/providers/inventory_clinic_filter_provider.dart';
import '../../../inventory/providers/inventory_provider.dart';

class MedicineInventoryCard extends ConsumerWidget {
  const MedicineInventoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeClinic = ref.watch(activeClinicProvider);
    final activeClinicId = ref.watch(activeClinicIdProvider);
    final valuation = ref.watch(
      scopedInventoryValuationProvider(activeClinicId),
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final hasMedicines = valuation.totalItems > 0;
    final hasAlerts =
        valuation.lowStockCount > 0 || valuation.outOfStockCount > 0;

    final String subtitle;
    if (!hasMedicines) {
      subtitle =
          activeClinic != null
              ? 'No medicines cataloged for ${activeClinic.name}'
              : 'No medicines cataloged yet';
    } else {
      final remediesCount =
          '${valuation.totalItems} ${valuation.totalItems == 1 ? 'remedy' : 'remedies'}';
      final unitsCount = '${valuation.totalUnits.toStringAsFixed(0)} units';
      subtitle =
          activeClinic != null
              ? '${activeClinic.name} • $remediesCount • $unitsCount'
              : '$remediesCount cataloged • $unitsCount';
    }

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      onTap: () {
        AppHaptics.selection();
        if (activeClinicId != null) {
          ref.read(inventoryClinicFilterProvider.notifier).state =
              activeClinicId;
        }
        context.push('/inventory');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: Radii.mdAll,
                ),
                child: Icon(
                  Icons.medication_outlined,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine Inventory',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (!hasMedicines)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: Radii.smAll,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Tap to catalog medicines, batches & reorder levels',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                if (valuation.outOfStockCount > 0)
                  _Badge(
                    icon: Icons.error_outline,
                    label: '${valuation.outOfStockCount} Out of stock',
                    backgroundColor: scheme.errorContainer,
                    foregroundColor: scheme.onErrorContainer,
                  ),
                if (valuation.lowStockCount > 0)
                  _Badge(
                    icon: Icons.warning_amber_rounded,
                    label: '${valuation.lowStockCount} Low in stock',
                    backgroundColor: scheme.tertiaryContainer,
                    foregroundColor: scheme.onTertiaryContainer,
                  ),
                if (!hasAlerts)
                  _Badge(
                    icon: Icons.check_circle_outline,
                    label: 'Stock Healthy',
                    backgroundColor: scheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    foregroundColor: scheme.primary,
                  ),
                _Badge(
                  icon: Icons.currency_rupee,
                  label:
                      'Valuation: ${Formatters.formatCurrency(valuation.totalSellingValue)}',
                  backgroundColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  foregroundColor: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: Radii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
