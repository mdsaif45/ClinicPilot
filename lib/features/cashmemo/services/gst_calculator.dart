import '../../../core/database/app_database.dart';
import '../presentation/widgets/dispense_medicine_picker_sheet.dart';

/// Slab applied when neither the medicine nor the clinic specifies a rate.
/// 12% is the common slab for homeopathic and ayurvedic preparations.
const double kDefaultGstRate = 12.0;

/// One GST slab and the tax charged at it.
class GstSlabLine {
  /// The slab as a percentage, e.g. 12.0.
  final double rate;

  /// Pre-tax value of the items taxed at this slab.
  final double taxableValue;

  /// Half of the slab's tax. Intra-state supply splits evenly into CGST/SGST,
  /// so a 12% slab bills 6% + 6%.
  final double cgst;
  final double sgst;

  const GstSlabLine({
    required this.rate,
    required this.taxableValue,
    required this.cgst,
    required this.sgst,
  });

  double get totalTax => cgst + sgst;
}

/// GST charged across a whole cash memo, grouped by slab.
class GstBreakdown {
  final List<GstSlabLine> lines;

  const GstBreakdown(this.lines);

  static const GstBreakdown empty = GstBreakdown([]);

  double get taxableValue => lines.fold(0.0, (sum, l) => sum + l.taxableValue);

  double get cgstAmount => lines.fold(0.0, (sum, l) => sum + l.cgst);

  double get sgstAmount => lines.fold(0.0, (sum, l) => sum + l.sgst);

  double get totalTax => cgstAmount + sgstAmount;

  bool get isEmpty => totalTax <= 0;
}

/// Computes the CGST/SGST breakdown for dispensed medicines.
///
/// Deliberately free of Riverpod and Flutter: these numbers go on a legal tax
/// invoice, so the rules that produce them are unit tested directly.
class GstCalculator {
  const GstCalculator._();

  /// Rounds money to paise, avoiding the long binary-fraction tails that make
  /// a printed invoice fail to foot (e.g. 6.000000000000001).
  static double roundMoney(double value) => (value * 100).roundToDouble() / 100;

  /// GST is charged only on goods dispensed, never on the consultation fee —
  /// a doctor's consultation is an exempt healthcare service.
  ///
  /// [defaultRate] applies to any medicine whose own `gstRate` is unset.
  /// A null or negative effective rate is treated as zero-rated.
  static GstBreakdown forDispensedItems(
    List<DispensedMedicineItem> items, {
    required double defaultRate,
  }) {
    if (items.isEmpty) return GstBreakdown.empty;

    // Group taxable value by slab so the invoice shows one line per rate,
    // which is what a GST invoice is required to present.
    final byRate = <double, double>{};
    for (final item in items) {
      final rate = item.medicine.gstRate ?? defaultRate;
      if (rate <= 0) continue;
      byRate.update(
        rate,
        (v) => v + item.totalPrice,
        ifAbsent: () => item.totalPrice,
      );
    }

    if (byRate.isEmpty) return GstBreakdown.empty;

    final rates = byRate.keys.toList()..sort();
    final lines = <GstSlabLine>[];

    for (final rate in rates) {
      final taxable = roundMoney(byRate[rate]!);
      if (taxable <= 0) continue;

      final tax = roundMoney(taxable * rate / 100);
      // Split after rounding the total, so cgst + sgst always re-adds to the
      // slab's tax exactly. Round SGST down and let CGST take any odd paise,
      // which is the usual convention on an Indian tax invoice.
      final sgst = (tax * 100 / 2).floorToDouble() / 100;
      final cgst = roundMoney(tax - sgst);

      lines.add(
        GstSlabLine(rate: rate, taxableValue: taxable, cgst: cgst, sgst: sgst),
      );
    }

    return GstBreakdown(lines);
  }

  /// Whether [clinic] is registered and should therefore issue tax invoices.
  ///
  /// An unregistered practice must not print anything resembling one, so the
  /// whole breakdown is suppressed rather than shown as zero.
  static bool isGstRegistered(Clinic? clinic) {
    final gstin = clinic?.gstin?.trim();
    return gstin != null && gstin.isNotEmpty;
  }
}
