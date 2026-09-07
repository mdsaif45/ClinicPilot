import '../../../core/database/app_database.dart';

/// Why a prescribed remedy could not be dispensed straight from stock.
enum DispenseMatchStatus {
  /// Matched an inventory item that has enough stock for the full quantity.
  matched,

  /// Matched an inventory item, but stock is below the prescribed quantity.
  partialStock,

  /// Matched by remedy name only — no inventory item carries this potency.
  potencyMismatch,

  /// No inventory item carries this remedy name at all.
  notStocked,
}

/// One prescribed remedy resolved against clinic inventory.
///
/// [medicine] is null only when the status is [DispenseMatchStatus.notStocked].
class PrescriptionMatch {
  final Prescription prescription;
  final Medicine? medicine;
  final DispenseMatchStatus status;

  /// Stock actually available to dispense — the prescribed quantity, or
  /// whatever remains on the shelf when that is less.
  final double availableQuantity;

  const PrescriptionMatch({
    required this.prescription,
    required this.medicine,
    required this.status,
    required this.availableQuantity,
  });

  /// True when this row can contribute a line item to the cash memo.
  bool get isDispensable =>
      medicine != null &&
      availableQuantity > 0 &&
      (status == DispenseMatchStatus.matched ||
          status == DispenseMatchStatus.partialStock);

  /// Short, human-readable reason shown beside the remedy in the review sheet.
  String get statusLabel => switch (status) {
    DispenseMatchStatus.matched => 'In stock',
    DispenseMatchStatus.partialStock =>
      'Only ${availableQuantity.toStringAsFixed(0)} left',
    DispenseMatchStatus.potencyMismatch => 'Potency not stocked',
    DispenseMatchStatus.notStocked => 'Not in inventory',
  };
}

/// Pure matching logic that maps a patient's active prescription onto the
/// clinic's medicine inventory.
///
/// Kept free of Riverpod and Flutter so the resolution rules — which decide
/// what gets billed and what stock is deducted — stay directly unit testable.
class PrescriptionDispenseMatcher {
  const PrescriptionDispenseMatcher._();

  /// Collapses remedy names and potencies to a comparable form.
  ///
  /// Prescriptions are typed by hand during consultation while inventory is
  /// entered from supplier labels, so the same remedy routinely differs by
  /// case, spacing, or punctuation ("Nux Vomica" vs "nux-vomica").
  static String normalize(String value) {
    final lowered = value.toLowerCase().trim();
    final stripped = lowered.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return stripped;
  }

  /// Returns the most recent prescription batch for a patient.
  ///
  /// A prescription is stored as one row per remedy sharing a
  /// [Prescription.prescriptionDate], so the "active" prescription is every
  /// row belonging to the newest date, ordered by `remedyIndex`.
  static List<Prescription> activePrescription(
    List<Prescription> prescriptions,
  ) {
    final live = prescriptions.where((p) => !p.isDeleted).toList();
    if (live.isEmpty) return const [];

    DateTime keyOf(Prescription p) => p.prescriptionDate ?? p.createdAt;

    final newest = live.map(keyOf).reduce((a, b) => a.isAfter(b) ? a : b);

    // Same-day rows belong to one prescription even when their timestamps
    // differ by the seconds it took the doctor to add each remedy.
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final batch =
        live.where((p) => sameDay(keyOf(p), newest)).toList()
          ..sort((a, b) => a.remedyIndex.compareTo(b.remedyIndex));

    return batch;
  }

  /// Resolves each prescribed remedy against [inventory].
  ///
  /// Preference order for a given remedy name:
  ///   1. exact name + exact potency, with enough stock
  ///   2. exact name + exact potency, partial stock
  ///   3. name only (potency differs) -> flagged, never auto-dispensed
  static List<PrescriptionMatch> match({
    required List<Prescription> prescriptions,
    required List<Medicine> inventory,
    double defaultQuantity = 1.0,
  }) {
    final live = inventory.where((m) => !m.isDeleted).toList();

    return prescriptions.map((rx) {
      final rxName = normalize(rx.remedyName);
      final rxPotency = normalize(rx.potency);

      final byName = live.where((m) => normalize(m.name) == rxName).toList();

      if (byName.isEmpty) {
        return PrescriptionMatch(
          prescription: rx,
          medicine: null,
          status: DispenseMatchStatus.notStocked,
          availableQuantity: 0,
        );
      }

      final byPotency =
          byName.where((m) => normalize(m.potency ?? '') == rxPotency).toList();

      if (byPotency.isEmpty) {
        // The remedy is carried, but not in the prescribed potency. Dispensing
        // a different potency is a clinical decision, so surface it instead.
        return PrescriptionMatch(
          prescription: rx,
          medicine: byName.first,
          status: DispenseMatchStatus.potencyMismatch,
          availableQuantity: 0,
        );
      }

      // Prefer the batch that can actually cover the dose; among those, the
      // one expiring soonest, so near-expiry stock moves first.
      byPotency.sort((a, b) {
        final aCovers = a.currentStock >= defaultQuantity;
        final bCovers = b.currentStock >= defaultQuantity;
        if (aCovers != bCovers) return aCovers ? -1 : 1;

        final aExp = a.expiryDate;
        final bExp = b.expiryDate;
        if (aExp != null && bExp != null) return aExp.compareTo(bExp);
        if (aExp != null) return -1;
        if (bExp != null) return 1;
        return b.currentStock.compareTo(a.currentStock);
      });

      final best = byPotency.first;
      final available =
          best.currentStock >= defaultQuantity
              ? defaultQuantity
              : best.currentStock;

      return PrescriptionMatch(
        prescription: rx,
        medicine: best,
        status:
            best.currentStock >= defaultQuantity
                ? DispenseMatchStatus.matched
                : DispenseMatchStatus.partialStock,
        availableQuantity: available < 0 ? 0 : available,
      );
    }).toList();
  }
}
