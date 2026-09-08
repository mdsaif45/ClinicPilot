import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

/// Summary metrics for in-clinic pharmacy inventory.
class InventoryValuation {
  final int totalItems;
  final double totalUnits;
  final double totalCostValue;
  final double totalSellingValue;
  final int lowStockCount;
  final int outOfStockCount;
  final int expiringCount;

  const InventoryValuation({
    required this.totalItems,
    required this.totalUnits,
    required this.totalCostValue,
    required this.totalSellingValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.expiringCount,
  });

  factory InventoryValuation.empty() => const InventoryValuation(
    totalItems: 0,
    totalUnits: 0.0,
    totalCostValue: 0.0,
    totalSellingValue: 0.0,
    lowStockCount: 0,
    outOfStockCount: 0,
    expiringCount: 0,
  );
}

/// Reactive stream provider of all active (non-deleted) medicines.
final inventoryStreamProvider = StreamProvider<List<Medicine>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.medicines)
        ..where((tbl) => tbl.isDeleted.equals(false))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
      .watch();
});

/// Category filter options for inventory list.
final inventoryCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// Search query provider for filtering inventory.
final inventorySearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered inventory stream combining category filter and search query.
final filteredInventoryProvider = Provider<AsyncValue<List<Medicine>>>((ref) {
  final asyncMedicines = ref.watch(inventoryStreamProvider);
  final category = ref.watch(inventoryCategoryFilterProvider);
  final query = ref.watch(inventorySearchQueryProvider).trim().toLowerCase();

  return asyncMedicines.whenData((medicines) {
    return medicines.where((med) {
      // 1. Text Search query
      if (query.isNotEmpty) {
        final matchesName = med.name.toLowerCase().contains(query);
        final matchesPotency =
            med.potency?.toLowerCase().contains(query) ?? false;
        final matchesCategory = med.category.toLowerCase().contains(query);
        final matchesForm = med.form?.toLowerCase().contains(query) ?? false;
        if (!matchesName &&
            !matchesPotency &&
            !matchesCategory &&
            !matchesForm) {
          return false;
        }
      }

      // 2. Category Filter
      if (category == 'All') return true;
      if (category == 'Low Stock') {
        return med.currentStock > 0 && med.currentStock <= med.reorderLevel;
      }
      if (category == 'Out of Stock') {
        return med.currentStock <= 0;
      }
      if (category == 'Expiring Soon') {
        if (med.expiryDate == null) return false;
        final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
        return med.expiryDate!.isBefore(thirtyDaysFromNow);
      }

      return med.category.toLowerCase() == category.toLowerCase();
    }).toList();
  });
});

/// Computes inventory valuation and alerts from active inventory.
final inventoryValuationProvider = Provider<InventoryValuation>((ref) {
  final asyncMedicines = ref.watch(inventoryStreamProvider);
  return asyncMedicines.maybeWhen(
    data: (medicines) {
      if (medicines.isEmpty) return InventoryValuation.empty();

      int lowStock = 0;
      int outOfStock = 0;
      int expiring = 0;
      double totalUnits = 0.0;
      double totalCost = 0.0;
      double totalSelling = 0.0;
      final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));

      for (final med in medicines) {
        totalUnits += med.currentStock;
        if (med.costPrice != null && med.costPrice! > 0) {
          totalCost += med.currentStock * med.costPrice!;
        }
        if (med.sellingPrice != null && med.sellingPrice! > 0) {
          totalSelling += med.currentStock * med.sellingPrice!;
        }
        if (med.currentStock <= 0) {
          outOfStock++;
        } else if (med.currentStock <= med.reorderLevel) {
          lowStock++;
        }
        if (med.expiryDate != null &&
            med.expiryDate!.isBefore(thirtyDaysFromNow)) {
          expiring++;
        }
      }

      return InventoryValuation(
        totalItems: medicines.length,
        totalUnits: totalUnits,
        totalCostValue: totalCost,
        totalSellingValue: totalSelling,
        lowStockCount: lowStock,
        outOfStockCount: outOfStock,
        expiringCount: expiring,
      );
    },
    orElse: () => InventoryValuation.empty(),
  );
});

/// Controller/Notifier for Inventory CRUD operations.
class InventoryController {
  final AppDatabase _db;
  static const _uuid = Uuid();

  InventoryController(this._db);

  /// Inserts a new medicine into the inventory table.
  Future<String> addMedicine({
    required String name,
    required String category,
    String? potency,
    String? form,
    required double currentStock,
    required String unit,
    double reorderLevel = 3.0,
    double? costPrice,
    double? sellingPrice,
    String? batchNumber,
    DateTime? expiryDate,
    String? clinicId,
    String? notes,
    double? gstRate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db
        .into(_db.medicines)
        .insert(
          MedicinesCompanion.insert(
            id: id,
            name: name.trim(),
            category: category.trim(),
            potency: Value(potency?.trim()),
            form: Value(form?.trim()),
            currentStock: Value(currentStock),
            unit: unit.trim(),
            reorderLevel: Value(reorderLevel),
            costPrice: Value(costPrice),
            sellingPrice: Value(sellingPrice),
            batchNumber: Value(batchNumber?.trim()),
            expiryDate: Value(expiryDate),
            clinicId: Value(clinicId),
            notes: Value(notes?.trim()),
            gstRate: Value(gstRate),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return id;
  }

  /// Updates an existing medicine item.
  Future<void> updateMedicine(Medicine item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _db.update(_db.medicines).replace(updated);
  }

  /// Adjusts the stock quantity by a positive or negative delta.
  /// (e.g. +5 for restocking, -1 for dispensing).
  Future<double> adjustStock(String id, double delta) async {
    final item =
        await (_db.select(_db.medicines)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (item == null) {
      throw ArgumentError('Medicine item not found with id: $id');
    }

    final newStock = (item.currentStock + delta).clamp(0.0, 999999.0);
    final updated = item.copyWith(
      currentStock: newStock,
      updatedAt: DateTime.now(),
    );

    await _db.update(_db.medicines).replace(updated);
    return newStock;
  }

  /// Soft deletes a medicine item.
  Future<void> deleteMedicine(String id) async {
    final item =
        await (_db.select(_db.medicines)
          ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (item != null) {
      final updated = item.copyWith(isDeleted: true, updatedAt: DateTime.now());
      await _db.update(_db.medicines).replace(updated);
    }
  }
}

final inventoryControllerProvider = Provider<InventoryController>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryController(db);
});
