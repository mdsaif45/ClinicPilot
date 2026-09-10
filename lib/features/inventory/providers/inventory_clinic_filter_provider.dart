import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active clinic filter for the Medicine Inventory module.
/// `null` means "All Clinics" (Consolidated Practice Stock), or a specific clinic ID.
final inventoryClinicFilterProvider = StateProvider<String?>((ref) => null);
