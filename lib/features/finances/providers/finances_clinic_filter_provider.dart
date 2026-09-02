import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active clinic filter for the Finances module.
/// `null` means "All Clinics" (Consolidated Practice), or a specific clinic ID.
final financesClinicFilterProvider = StateProvider<String?>((ref) => null);
