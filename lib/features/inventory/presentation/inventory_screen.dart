import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/custom_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../providers/inventory_clinic_filter_provider.dart';
import '../providers/inventory_provider.dart';
import 'widgets/add_edit_medicine_dialog.dart';
import 'widgets/inventory_clinic_filter_pill.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddMedicine() {
    AppHaptics.selection();
    final filterClinicId = ref.read(inventoryClinicFilterProvider);
    final activeClinicId = ref.read(activeClinicIdProvider);
    AddEditMedicineDialog.show(
      context,
      initialClinicId: filterClinicId ?? activeClinicId,
    );
  }

  void _openEditMedicine(Medicine item) {
    AppHaptics.selection();
    AddEditMedicineDialog.show(context, existingMedicine: item);
  }

  Future<void> _deleteMedicine(Medicine item) async {
    AppHaptics.error();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AppConfirmDialog(
            title: 'Delete Medicine',
            message:
                'Are you sure you want to remove "${item.name} (${item.potency ?? ''})" from inventory? This will not affect existing prescriptions.',
            confirmLabel: 'Delete',
            isDestructive: true,
            onConfirm: () => Navigator.of(ctx).pop(true),
          ),
    );

    if (confirmed == true) {
      final controller = ref.read(inventoryControllerProvider);
      await controller.deleteMedicine(item.id);
      AppHaptics.medium();
    }
  }

  Future<void> _adjustStock(Medicine item, double delta) async {
    AppHaptics.selection();
    final controller = ref.read(inventoryControllerProvider);
    try {
      await controller.adjustStock(item.id, delta);
      AppHaptics.light();
    } catch (e) {
      AppHaptics.error();
    }
  }

  Future<void> _showCustomStockDialog(Medicine item) async {
    AppHaptics.selection();
    final qtyController = TextEditingController();
    bool isAdding = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setDialogState) {
              final scheme = Theme.of(ctx).colorScheme;
              return AlertDialog(
                title: Text('Adjust Stock: ${item.name}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stock: ${item.currentStock.toStringAsFixed(0)} ${item.unit}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Add (+ Restock)'),
                          selected: isAdding,
                          onSelected:
                              (s) => setDialogState(() => isAdding = true),
                        ),
                        const SizedBox(width: Spacing.sm),
                        ChoiceChip(
                          label: const Text('Deduct (- Dispense)'),
                          selected: !isAdding,
                          onSelected:
                              (s) => setDialogState(() => isAdding = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    TextField(
                      controller: qtyController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            isAdding ? 'Quantity to Add' : 'Quantity to Deduct',
                        hintText: 'e.g. 5',
                        suffixText: item.unit,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  AppButton.primary(
                    label: 'Save Adjustment',
                    onPressed: () {
                      final n = double.tryParse(qtyController.text.trim());
                      if (n != null && n > 0) {
                        Navigator.of(ctx).pop(true);
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );

    if (confirmed == true) {
      final amount = double.tryParse(qtyController.text.trim()) ?? 0.0;
      if (amount > 0) {
        final delta = isAdding ? amount : -amount;
        await _adjustStock(item, delta);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final asyncFiltered = ref.watch(filteredInventoryProvider);
    final valuation = ref.watch(inventoryValuationProvider);
    final selectedCategory = ref.watch(inventoryCategoryFilterProvider);
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final clinics = clinicsAsync.value ?? [];
    final clinicFilter = ref.watch(inventoryClinicFilterProvider);
    final selectedClinic =
        clinicFilter != null
            ? clinics.where((c) => c.id == clinicFilter).firstOrNull
            : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Inventory'),
        actions: [
          const InventoryClinicFilterPill(),
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            tooltip: _showSearch ? 'Hide search' : 'Search inventory',
            onPressed: () {
              AppHaptics.selection();
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(inventorySearchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add new medicine',
            onPressed: _openAddMedicine,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Search Field (collapsible) ──
          if (_showSearch)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.xs,
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by remedy name, potency, category...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(inventorySearchQueryProvider.notifier)
                                    .state = '';
                              },
                            )
                            : null,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    ref.read(inventorySearchQueryProvider.notifier).state = val;
                  },
                ),
              ),
            ),

          // ── Practice Stock Valuation Banner ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              child: _buildValuationBanner(
                context,
                scheme,
                theme,
                valuation,
                selectedClinic,
              ),
            ),
          ),

          // ── Category Filter Bar ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                children: [
                  for (final cat in [
                    'All',
                    'Low Stock',
                    'Expiring Soon',
                    'Out of Stock',
                    'Dilution',
                    'Mother Tincture',
                    'Biochemic / Trituration',
                    'Tablets / Capsules',
                    'Ointment / Syrup',
                    'Consumables',
                  ]) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: Spacing.xs),
                      child: FilterChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                selectedCategory == cat
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                          ),
                        ),
                        selected: selectedCategory == cat,
                        onSelected: (_) {
                          AppHaptics.selection();
                          ref
                              .read(inventoryCategoryFilterProvider.notifier)
                              .state = cat;
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: Spacing.sm)),

          // ── Medicine Stock List ──
          asyncFiltered.when(
            loading:
                () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, _) => SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.xl),
                      child: Text(
                        'Error loading inventory: $err',
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                  ),
                ),
            data: (medicines) {
              if (medicines.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.medication_outlined,
                    title:
                        selectedCategory == 'All'
                            ? 'No Medicines in Inventory Yet'
                            : 'No Medicines in "$selectedCategory"',
                    message:
                        selectedCategory == 'All'
                            ? 'Tap "Add Item" to catalog your first clinic remedy, track bottles and expiry alerts.'
                            : 'No items currently match the "$selectedCategory" filter.',
                    actionLabel: 'Add Medicine',
                    onAction: _openAddMedicine,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = medicines[index];
                    return _buildMedicineCard(
                      context,
                      scheme,
                      theme,
                      item,
                      clinics,
                      clinicFilter,
                    );
                  }, childCount: medicines.length),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xxl)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
        onPressed: _openAddMedicine,
      ),
    );
  }

  Widget _buildValuationBanner(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
    InventoryValuation val,
    Clinic? selectedClinic,
  ) {
    final title =
        selectedClinic != null
            ? '${selectedClinic.name} Stock Valuation'
            : 'Practice Stock Valuation';
    final subtitle =
        selectedClinic != null
            ? '${val.totalItems} remedies • ${val.totalUnits.toStringAsFixed(0)} units on hand (incl. shared)'
            : '${val.totalItems} distinct remedies • ${val.totalUnits.toStringAsFixed(0)} total units on hand';
    final valueLabel = selectedClinic != null ? 'Branch Value' : 'Stock Value';

    return AppCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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
                if (val.totalCostValue > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(val.totalCostValue),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                      Text(
                        valueLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (val.lowStockCount > 0 ||
                val.expiringCount > 0 ||
                val.outOfStockCount > 0) ...[
              const SizedBox(height: Spacing.sm),
              const Divider(height: 1),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  if (val.outOfStockCount > 0)
                    CustomBadge(
                      label: '${val.outOfStockCount} Out of Stock',
                      color: scheme.error,
                    ),
                  if (val.lowStockCount > 0)
                    CustomBadge(
                      label: '${val.lowStockCount} Low Stock Alert',
                      color: scheme.tertiary,
                    ),
                  if (val.expiringCount > 0)
                    CustomBadge(
                      label: '${val.expiringCount} Expiring Soon',
                      color: scheme.error,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(
    BuildContext context,
    ColorScheme scheme,
    ThemeData theme,
    Medicine item,
    List<Clinic> clinics,
    String? clinicFilter,
  ) {
    final isOutOfStock = item.currentStock <= 0;
    final isLowStock = !isOutOfStock && item.currentStock <= item.reorderLevel;

    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    final isExpired =
        item.expiryDate != null && item.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon =
        item.expiryDate != null &&
        !isExpired &&
        item.expiryDate!.isBefore(thirtyDaysFromNow);

    return AppCard(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Name, Potency, Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (item.potency != null &&
                              item.potency!.isNotEmpty) ...[
                            const SizedBox(width: Spacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(Radii.sm),
                              ),
                              child: Text(
                                item.potency!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.category}${item.form != null ? " • ${item.form}" : ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (clinics.length >= 2) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              item.clinicId == null
                                  ? Icons.public_rounded
                                  : Icons.domain_rounded,
                              size: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.clinicId == null
                                    ? 'Shared Practice Stock'
                                    : (clinics
                                            .where((c) => c.id == item.clinicId)
                                            .firstOrNull
                                            ?.name ??
                                        'Branch Stock'),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (choice) {
                    if (choice == 'edit') {
                      _openEditMedicine(item);
                    } else if (choice == 'adjust') {
                      _showCustomStockDialog(item);
                    } else if (choice == 'delete') {
                      _deleteMedicine(item);
                    }
                  },
                  itemBuilder:
                      (ctx) => [
                        const PopupMenuItem(
                          value: 'adjust',
                          child: Row(
                            children: [
                              Icon(Icons.tune, size: 18),
                              SizedBox(width: Spacing.sm),
                              Text('Adjust Quantity'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: Spacing.sm),
                              Text('Edit Details'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: scheme.error,
                              ),
                              const SizedBox(width: Spacing.sm),
                              Text(
                                'Delete Item',
                                style: TextStyle(color: scheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: Spacing.sm),

            // Middle row: Stock level badge & Expiry Status
            Row(
              children: [
                Text(
                  '${item.currentStock.toStringAsFixed(item.currentStock % 1 == 0 ? 0 : 1)} ${item.unit}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                if (isOutOfStock)
                  CustomBadge(label: 'Out of Stock', color: scheme.error)
                else if (isLowStock)
                  CustomBadge(label: 'Low Stock', color: scheme.tertiary)
                else
                  CustomBadge(label: 'In Stock', color: scheme.primary),

                const Spacer(),

                if (isExpired)
                  CustomBadge(label: 'Expired', color: scheme.error)
                else if (isExpiringSoon)
                  CustomBadge(
                    label:
                        'Expires ${DateFormat('d MMM').format(item.expiryDate!)}',
                    color: scheme.error,
                  )
                else if (item.expiryDate != null)
                  Text(
                    'Exp: ${DateFormat('MMM yyyy').format(item.expiryDate!)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),

            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                item.notes!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: Spacing.sm),

            // Bottom quick action row: -1 Dispense & +1 Restock
            Row(
              children: [
                if (item.sellingPrice != null && item.sellingPrice! > 0)
                  Text(
                    'Fee: ₹${item.sellingPrice!.toStringAsFixed(0)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const Spacer(),
                OutlinedButton.icon(
                  icon: const Icon(Icons.remove, size: 14),
                  label: const Text(
                    '1 Dispense',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 0,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed:
                      item.currentStock > 0
                          ? () => _adjustStock(item, -1.0)
                          : null,
                ),
                const SizedBox(width: Spacing.xs),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text(
                    '1 Restock',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 0,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => _adjustStock(item, 1.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
