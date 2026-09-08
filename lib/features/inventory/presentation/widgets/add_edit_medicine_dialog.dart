import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/picker_field.dart';
import '../../../../core/widgets/remedy_autocomplete_field.dart';
import '../../providers/inventory_provider.dart';
import '../../services/barcode_matcher.dart';
import 'barcode_scanner_sheet.dart';

const List<String> kMedicineCategories = [
  'Dilution',
  'Mother Tincture',
  'Biochemic / Trituration',
  'Tablets / Capsules',
  'Ointment / Syrup',
  'Consumables',
];

const List<String> kCommonUnits = [
  'Bottles (30ml)',
  'Bottles (100ml)',
  'Bottles (450ml)',
  'Vials (1 dram)',
  'Vials (2 dram)',
  'Strips',
  'Tablets',
  'Packs',
  'Box',
];

const List<String> kCommonForms = [
  'Liquid Dilution',
  'Globules / Pellets',
  'Mother Tincture',
  'Tablets',
  'Cream / Ointment',
  'Syrup / Tonic',
  'Drops',
  'Powder',
];

class AddEditMedicineDialog extends ConsumerStatefulWidget {
  final Medicine? existingMedicine;

  const AddEditMedicineDialog({super.key, this.existingMedicine});

  static Future<void> show(BuildContext context, {Medicine? existingMedicine}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEditMedicineDialog(existingMedicine: existingMedicine),
    );
  }

  @override
  ConsumerState<AddEditMedicineDialog> createState() =>
      _AddEditMedicineDialogState();
}

class _AddEditMedicineDialogState extends ConsumerState<AddEditMedicineDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _potencyController;
  late final TextEditingController _stockController;
  late final TextEditingController _reorderController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _gstRateController;
  late final TextEditingController _batchController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _notesController;

  late String _category;
  late String _form;
  late String _unit;
  DateTime? _expiryDate;
  bool _submitting = false;

  bool get isEditing => widget.existingMedicine != null;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMedicine;
    _nameController = TextEditingController(text: m?.name ?? '');
    _potencyController = TextEditingController(text: m?.potency ?? '30C');
    _stockController = TextEditingController(
      text: m != null ? m.currentStock.toStringAsFixed(0) : '10',
    );
    _reorderController = TextEditingController(
      text: m != null ? m.reorderLevel.toStringAsFixed(0) : '3',
    );
    _costPriceController = TextEditingController(
      text: m?.costPrice != null ? m!.costPrice!.toStringAsFixed(0) : '',
    );
    _sellingPriceController = TextEditingController(
      text: m?.sellingPrice != null ? m!.sellingPrice!.toStringAsFixed(0) : '',
    );
    _gstRateController = TextEditingController(
      text: m?.gstRate != null ? m!.gstRate!.toStringAsFixed(0) : '',
    );
    _batchController = TextEditingController(text: m?.batchNumber ?? '');
    _barcodeController = TextEditingController(text: m?.barcode ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');

    _category = m?.category ?? 'Dilution';
    _form = m?.form ?? 'Liquid Dilution';
    _unit = m?.unit ?? 'Bottles (30ml)';
    _expiryDate = m?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _potencyController.dispose();
    _stockController.dispose();
    _reorderController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _gstRateController.dispose();
    _batchController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    AppHaptics.selection();
    final code = await BarcodeScannerSheet.show(context);
    if (code == null || !mounted) return;
    setState(() => _barcodeController.text = code);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      AppHaptics.error();
      return;
    }

    final name = _nameController.text.trim();
    final potency = _potencyController.text.trim();
    final stock = double.tryParse(_stockController.text.trim()) ?? 0.0;
    final reorder = double.tryParse(_reorderController.text.trim()) ?? 3.0;
    final cost = double.tryParse(_costPriceController.text.trim());
    final selling = double.tryParse(_sellingPriceController.text.trim());
    final gstRate = double.tryParse(_gstRateController.text.trim());
    final batch = _batchController.text.trim();
    final barcode = BarcodeMatcher.normalize(_barcodeController.text);
    final notes = _notesController.text.trim();

    setState(() => _submitting = true);
    final controller = ref.read(inventoryControllerProvider);

    try {
      if (isEditing) {
        final updated = widget.existingMedicine!.copyWith(
          name: name,
          category: _category,
          potency: Value(potency.isNotEmpty ? potency : null),
          form: Value(_form),
          currentStock: stock,
          unit: _unit,
          reorderLevel: reorder,
          costPrice: Value(cost),
          sellingPrice: Value(selling),
          gstRate: Value(gstRate),
          batchNumber: Value(batch.isNotEmpty ? batch : null),
          barcode: Value(barcode.isNotEmpty ? barcode : null),
          expiryDate: Value(_expiryDate),
          notes: Value(notes.isNotEmpty ? notes : null),
        );
        await controller.updateMedicine(updated);
      } else {
        await controller.addMedicine(
          name: name,
          category: _category,
          potency: potency.isNotEmpty ? potency : null,
          form: _form,
          currentStock: stock,
          unit: _unit,
          reorderLevel: reorder,
          costPrice: cost,
          sellingPrice: selling,
          gstRate: gstRate,
          batchNumber: batch.isNotEmpty ? batch : null,
          barcode: barcode.isNotEmpty ? barcode : null,
          expiryDate: _expiryDate,
          notes: notes.isNotEmpty ? notes : null,
        );
      }

      AppHaptics.success();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medicine: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: isEditing ? 'Edit Medicine Stock' : 'Add Medicine to Inventory',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(isEditing ? 'Update' : 'Save Item'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remedy / Medicine Name Autocomplete
            RemedyAutocompleteField(
              controller: _nameController,
              label: 'Medicine / Remedy Name *',
              hint: 'e.g. Arnica Montana, Paracetamol',
              validator:
                  (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Enter medicine name'
                          : null,
            ),
            const SizedBox(height: Spacing.md),

            // Category & Form Pickers
            Row(
              children: [
                Expanded(
                  child: PickerField<String>(
                    label: 'Category',
                    value: _category,
                    options:
                        kMedicineCategories
                            .map((c) => PickerOption(value: c, label: c))
                            .toList(),
                    onChanged: (val) {
                      setState(() => _category = val);
                    },
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Dispensing Form',
                    value: _form,
                    options:
                        kCommonForms
                            .map((f) => PickerOption(value: f, label: f))
                            .toList(),
                    onChanged: (val) {
                      setState(() => _form = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Potency Field with quick chips
            CustomTextField(
              controller: _potencyController,
              label: 'Potency / Strength',
              hint: 'e.g. 30C, 200C, 1M, Q, 500mg',
            ),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              children: [
                for (final p in ['30C', '200C', '1M', 'Q', '6X', '500mg'])
                  ActionChip(
                    label: Text(p, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      AppHaptics.selection();
                      setState(() => _potencyController.text = p);
                    },
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Current Stock & Unit
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _stockController,
                    label: 'Current Stock *',
                    hint: 'e.g. 10',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter quantity';
                      }
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 0) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: PickerField<String>(
                    label: 'Unit of Measure',
                    value: _unit,
                    options:
                        kCommonUnits
                            .map((u) => PickerOption(value: u, label: u))
                            .toList(),
                    onChanged: (val) {
                      setState(() => _unit = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Reorder Level & Expiry Date
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _reorderController,
                    label: 'Re-order Threshold',
                    hint: '3',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: DateField(
                    label: 'Expiry Date (Optional)',
                    value: _expiryDate,
                    onChanged: (d) => setState(() => _expiryDate = d),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2040),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Pricing details (Cost Price vs Selling Price)
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _costPriceController,
                    label: 'Cost Price (₹)',
                    hint: 'Optional',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.currency_rupee,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: CustomTextField(
                    controller: _sellingPriceController,
                    label: 'Dispense Fee (₹)',
                    hint: 'Optional',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixIcon: Icons.currency_rupee,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // GST slab for this item. Blank inherits the clinic default
            // rather than zero-rating, so untouched stock keeps billing as-is.
            CustomTextField(
              controller: _gstRateController,
              label: 'GST Rate (%)',
              hint: 'Leave blank to use the clinic default',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixIcon: Icons.percent,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final rate = double.tryParse(v.trim());
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Enter a rate between 0 and 100';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),

            // Batch number
            CustomTextField(
              controller: _batchController,
              label: 'Batch / Lot Number',
              hint: 'e.g. B-2026-X9',
            ),
            const SizedBox(height: Spacing.md),

            // Barcode, scanned off the pack or typed in.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _barcodeController,
                    label: 'Barcode (optional)',
                    hint: 'e.g. 8901234567894',
                    prefixIcon: Icons.qr_code_2_outlined,
                    validator: (v) {
                      final code = BarcodeMatcher.normalize(v ?? '');
                      if (code.isEmpty) return null;
                      // Only 13-digit codes carry a GS1 check digit; shorter
                      // in-house labels are accepted as typed.
                      if (code.length == 13 &&
                          !BarcodeMatcher.isValidEan13(code)) {
                        return 'Check digit does not match';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scan barcode',
                    onPressed: _scanBarcode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Clinical / Storage Notes
            CustomTextField(
              controller: _notesController,
              label: 'Storage Location / Clinical Notes',
              hint: 'e.g. Cabinet A - Shelf 2',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
