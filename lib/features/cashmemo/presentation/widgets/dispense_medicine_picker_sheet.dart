import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../inventory/providers/inventory_provider.dart';

/// A single medicine line item selected for dispensing.
class DispensedMedicineItem {
  final Medicine medicine;
  double quantity;
  double unitPrice;

  DispensedMedicineItem({
    required this.medicine,
    this.quantity = 1.0,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}

/// True when [medicine] has a batch expiry within the next 30 days.
///
/// Matches the "Expiring Soon" threshold already used by the inventory
/// valuation and filtering (see `inventory_provider.dart`), so a batch
/// flagged here is not already counted as fully expired.
bool _isExpiringSoon(Medicine medicine) {
  final expiry = medicine.expiryDate;
  if (expiry == null) return false;
  final now = DateTime.now();
  if (expiry.isBefore(now)) return false;
  return expiry.isBefore(now.add(const Duration(days: 30)));
}

/// Modal bottom sheet allowing the clinician to search clinic inventory,
/// choose remedies, adjust quantities, and return line items to the Cash Memo.
class DispenseMedicinePickerSheet extends ConsumerStatefulWidget {
  final List<DispensedMedicineItem> initialSelection;

  const DispenseMedicinePickerSheet({
    super.key,
    this.initialSelection = const [],
  });

  static Future<List<DispensedMedicineItem>?> show(
    BuildContext context, {
    List<DispensedMedicineItem> currentSelection = const [],
  }) {
    return showModalBottomSheet<List<DispensedMedicineItem>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) =>
              DispenseMedicinePickerSheet(initialSelection: currentSelection),
    );
  }

  @override
  ConsumerState<DispenseMedicinePickerSheet> createState() =>
      _DispenseMedicinePickerSheetState();
}

class _DispenseMedicinePickerSheetState
    extends ConsumerState<DispenseMedicinePickerSheet> {
  final _searchController = TextEditingController();
  final Map<String, DispensedMedicineItem> _selectedMap = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    for (final item in widget.initialSelection) {
      _selectedMap[item.medicine.id] = DispensedMedicineItem(
        medicine: item.medicine,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    return _selectedMap.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get _totalItems {
    return _selectedMap.length;
  }

  void _toggleMedicine(Medicine med) {
    AppHaptics.selection();
    setState(() {
      if (_selectedMap.containsKey(med.id)) {
        _selectedMap.remove(med.id);
      } else {
        final defaultPrice = med.sellingPrice ?? med.costPrice ?? 0.0;
        _selectedMap[med.id] = DispensedMedicineItem(
          medicine: med,
          quantity: 1.0,
          unitPrice: defaultPrice,
        );
      }
    });
  }

  void _updateQuantity(String medId, double delta) {
    AppHaptics.selection();
    setState(() {
      final item = _selectedMap[medId];
      if (item != null) {
        final newQty = item.quantity + delta;
        if (newQty <= 0) {
          _selectedMap.remove(medId);
        } else {
          item.quantity = newQty;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final medicinesAsync = ref.watch(inventoryStreamProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dispense from Inventory',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xl,
                  Spacing.xs,
                  Spacing.xl,
                  Spacing.sm,
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search remedy name, potency, category...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                            : null,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim().toLowerCase());
                  },
                ),
              ),

              // Inventory medicine list
              Expanded(
                child: medicinesAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (e, _) => Center(
                        child: Text(
                          'Error loading medicines: $e',
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                  data: (allMedicines) {
                    final filtered =
                        allMedicines.where((med) {
                          if (_searchQuery.isEmpty) return true;
                          final n = med.name.toLowerCase().contains(
                            _searchQuery,
                          );
                          final p =
                              med.potency?.toLowerCase().contains(
                                _searchQuery,
                              ) ??
                              false;
                          final c = med.category.toLowerCase().contains(
                            _searchQuery,
                          );
                          final f =
                              med.form?.toLowerCase().contains(_searchQuery) ??
                              false;
                          return n || p || c || f;
                        }).toList();

                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.medication_outlined,
                        title:
                            _searchQuery.isEmpty
                                ? 'No Inventory Medicines Found'
                                : 'No Matching Remedies',
                        message:
                            _searchQuery.isEmpty
                                ? 'Add medicines in Settings > Practice Management > Medicine Inventory.'
                                : 'No remedies match "$_searchQuery".',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xl,
                        vertical: Spacing.xs,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final med = filtered[idx];
                        final isSelected = _selectedMap.containsKey(med.id);
                        final selectedItem = _selectedMap[med.id];
                        final isOutOfStock = med.currentStock <= 0;
                        final isLowStock =
                            !isOutOfStock &&
                            med.currentStock <= med.reorderLevel;
                        final isExpiringSoon = _isExpiringSoon(med);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.xs,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(Radii.sm),
                                  onTap: () => _toggleMedicine(med),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Spacing.xs,
                                    ),
                                    child: Row(
                                      children: [
                                        // Checkbox / Selector
                                        Checkbox(
                                          value: isSelected,
                                          onChanged:
                                              (_) => _toggleMedicine(med),
                                        ),
                                        const SizedBox(width: Spacing.xs),

                                        // Remedy Name, Potency, and Stock Badge
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      med.name,
                                                      style: theme
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (med.potency != null &&
                                                      med
                                                          .potency!
                                                          .isNotEmpty) ...[
                                                    const SizedBox(
                                                      width: Spacing.xs,
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal:
                                                                Spacing.xs,
                                                            vertical: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            scheme
                                                                .primaryContainer,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Radii.sm,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        med.potency!,
                                                        style: theme
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color:
                                                                  scheme
                                                                      .onPrimaryContainer,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                spacing: Spacing.xs,
                                                runSpacing: 2,
                                                children: [
                                                  Text(
                                                    '${med.currentStock.toStringAsFixed(med.currentStock % 1 == 0 ? 0 : 1)} ${med.unit}',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              scheme
                                                                  .onSurfaceVariant,
                                                          fontSize: 11,
                                                        ),
                                                  ),
                                                  if (isOutOfStock)
                                                    CustomBadge(
                                                      label: 'Out of Stock',
                                                      color: scheme.error,
                                                    )
                                                  else if (isLowStock)
                                                    CustomBadge(
                                                      label: 'Low Stock',
                                                      color: scheme.tertiary,
                                                    ),
                                                  // Independent of stock level — a
                                                  // well-stocked batch can still be
                                                  // close to expiry.
                                                  if (isExpiringSoon)
                                                    CustomBadge(
                                                      label:
                                                          'Expires ${DateFormat('d MMM').format(med.expiryDate!)}',
                                                      color: scheme.tertiary,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Quantity Adjuster or Price Label
                              if (isSelected && selectedItem != null) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      visualDensity: VisualDensity.compact,
                                      onPressed:
                                          () => _updateQuantity(med.id, -1.0),
                                    ),
                                    Text(
                                      selectedItem.quantity.toStringAsFixed(0),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      visualDensity: VisualDensity.compact,
                                      onPressed:
                                          () => _updateQuantity(med.id, 1.0),
                                    ),
                                    const SizedBox(width: Spacing.xs),
                                    Text(
                                      '₹${selectedItem.totalPrice.toStringAsFixed(0)}',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: scheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                if (med.sellingPrice != null &&
                                    med.sellingPrice! > 0)
                                  Text(
                                    '₹${med.sellingPrice!.toStringAsFixed(0)}',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xl,
                  Spacing.sm,
                  Spacing.xl,
                  Spacing.md,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_totalItems selected',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '₹${_totalPrice.toStringAsFixed(0)} total',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm Dispensed'),
                      onPressed: () {
                        AppHaptics.success();
                        Navigator.of(context).pop(_selectedMap.values.toList());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
