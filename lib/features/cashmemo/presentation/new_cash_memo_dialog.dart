import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/choice_chip_field.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/date_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/picker_field.dart';
import '../../../core/services/app_haptics.dart';
import '../../clinical/providers/prescription_provider.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../patients/presentation/patient_picker.dart';
import '../providers/cash_memo_provider.dart';
import '../services/gst_calculator.dart';
import '../services/prescription_dispense_matcher.dart';
import 'widgets/dispense_medicine_picker_sheet.dart';
import 'widgets/prescription_dispense_review_sheet.dart';

class NewCashMemoDialog extends ConsumerStatefulWidget {
  final Patient? initialPatient;

  const NewCashMemoDialog({super.key, this.initialPatient});

  @override
  ConsumerState<NewCashMemoDialog> createState() => _NewCashMemoDialogState();
}

class _NewCashMemoDialogState extends ConsumerState<NewCashMemoDialog> {
  final _formKey = GlobalKey<FormState>();

  Patient? _selectedPatient;
  // PatientPickerField is not a FormField, so its error is tracked here.
  String? _patientError;
  String? _selectedClinicId;
  String? _clinicError;
  final _consultationController = TextEditingController(text: '300');
  final _medicineController = TextEditingController(text: '0');
  final _otherController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController();

  final List<DispensedMedicineItem> _dispensedItems = [];

  String _paymentMethod = 'Cash';
  DateTime _memoDate = DateTime.now();

  // Guards against a memo being created twice from taps queued while the
  // first write is still in flight.
  bool _submitting = false;
  final List<String> _paymentMethods = ['Cash', 'UPI', 'Card', 'Bank Transfer'];

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.initialPatient;
    if (widget.initialPatient != null &&
        widget.initialPatient!.primaryClinicId == 'clinic_online') {
      _selectedClinicId = 'clinic_online';
      _paymentMethod = 'UPI';
    } else {
      _selectedClinicId = ref.read(activeClinicIdProvider);
    }

    final activeClinic = ref.read(activeClinicProvider);
    if (activeClinic != null) {
      _consultationController.text = activeClinic.defaultConsultationFee
          .toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _consultationController.dispose();
    _medicineController.dispose();
    _otherController.dispose();
    _discountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  /// Clinic whose GSTIN and default slab apply to this memo.
  Clinic? get _selectedClinic {
    final id = _selectedClinicId;
    if (id == null) return null;
    final clinics = ref.read(clinicsStreamProvider).value ?? const [];
    for (final c in clinics) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// CGST/SGST on the dispensed medicines, or empty when the practice is not
  /// GST registered — an unregistered clinic must not issue a tax invoice.
  GstBreakdown get _gstBreakdown {
    final clinic = _selectedClinic;
    if (!GstCalculator.isGstRegistered(clinic)) return GstBreakdown.empty;
    if (_dispensedItems.isEmpty) return GstBreakdown.empty;
    return GstCalculator.forDispensedItems(
      _dispensedItems,
      defaultRate: clinic!.defaultGstRate ?? kDefaultGstRate,
    );
  }

  double get _total {
    final c = double.tryParse(_consultationController.text) ?? 0.0;
    final m = double.tryParse(_medicineController.text) ?? 0.0;
    final o = double.tryParse(_otherController.text) ?? 0.0;
    final d = double.tryParse(_discountController.text) ?? 0.0;
    return (c + m + o) - d + _gstBreakdown.totalTax;
  }

  bool _autoSyncPaidAmount = true;

  void _onFeeChanged() {
    setState(() {
      if (_autoSyncPaidAmount) {
        _paidAmountController.text = _total.toStringAsFixed(0);
      }
    });
  }

  /// Rewrites the medicine fee from the current dispensed line items.
  ///
  /// Call inside a [setState]; it mutates the fee controller only.
  void _syncMedicineFeeFromDispensed() {
    final totalMedFee = _dispensedItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    _medicineController.text = totalMedFee.toStringAsFixed(0);
  }

  Future<void> _openDispensePicker() async {
    AppHaptics.selection();
    final selected = await DispenseMedicinePickerSheet.show(
      context,
      currentSelection: _dispensedItems,
    );
    if (selected != null) {
      setState(() {
        _dispensedItems
          ..clear()
          ..addAll(selected);
        if (_dispensedItems.isNotEmpty) {
          _syncMedicineFeeFromDispensed();
          _onFeeChanged();
        }
      });
    }
  }

  /// Pulls the patient's most recent prescription into the dispense list,
  /// auto-matched against clinic inventory.
  ///
  /// Matches are reviewed and confirmed before anything is billed, since
  /// confirming decrements real stock.
  Future<void> _dispenseFromActivePrescription() async {
    final patient = _selectedPatient;
    if (patient == null) return;

    AppHaptics.selection();

    // Await the first emission rather than reading the cached value: these
    // streams may not have produced one yet, and treating that as "empty"
    // would wrongly report stocked remedies as unavailable.
    final prescriptions = await ref.read(
      patientPrescriptionsOnceProvider(patient.id).future,
    );
    final active = PrescriptionDispenseMatcher.activePrescription(
      prescriptions,
    );

    if (!mounted) return;
    if (active.isEmpty) {
      _showSnack('No active prescription found for ${patient.name}.');
      return;
    }

    final inventory = await ref.read(inventoryStreamProvider.future);
    final matches = PrescriptionDispenseMatcher.match(
      prescriptions: active,
      inventory: inventory,
    );

    if (!mounted) return;
    final items = await PrescriptionDispenseReviewSheet.show(
      context,
      matches: matches,
      prescriptionDate: active.first.prescriptionDate,
    );

    if (items == null || items.isEmpty || !mounted) return;

    setState(() {
      // Merge rather than replace: the doctor may have already added
      // over-the-counter items by hand before pulling the prescription.
      for (final item in items) {
        final existing = _dispensedItems.indexWhere(
          (d) => d.medicine.id == item.medicine.id,
        );
        if (existing >= 0) {
          _dispensedItems[existing] = item;
        } else {
          _dispensedItems.add(item);
        }
      }
      _syncMedicineFeeFromDispensed();
      _onFeeChanged();
    });
  }

  Widget _buildTaxRow(String label, double amount) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            Formatters.formatCurrency(amount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// One-tap shortcut shown only when the selected patient actually has a
  /// prescription on file, so the cash memo stays uncluttered otherwise.
  Widget _buildPrescriptionShortcut() {
    final patient = _selectedPatient;
    if (patient == null) return const SizedBox.shrink();

    final prescriptions =
        ref.watch(patientPrescriptionsOnceProvider(patient.id)).value ??
        const [];
    final active = PrescriptionDispenseMatcher.activePrescription(
      prescriptions,
    );
    if (active.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.receipt_long_outlined, size: 16),
        label: Text(
          'Dispense from Active Prescription (${active.length})',
          style: const TextStyle(fontSize: 12),
        ),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.secondary,
        ),
        onPressed: _dispenseFromActivePrescription,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);

    final clinics = clinicsAsync.value ?? [];

    if (_selectedClinicId == null && clinics.length == 1) {
      _selectedClinicId = clinics.first.id;
      final cl = clinics.first;
      _consultationController.text = cl.defaultConsultationFee.toStringAsFixed(
        0,
      );
      if (_autoSyncPaidAmount) {
        _paidAmountController.text = _total.toStringAsFixed(0);
      }
    }

    // A memo has to belong to a clinic - without one, the fee fields below
    // fill in for nothing, since the write can never succeed.
    if (clinicsAsync.hasValue && clinics.isEmpty) {
      return AlertDialog(
        title: const Text('Create Cash Memo'),
        content: EmptyState(
          icon: Icons.local_hospital_outlined,
          title: 'No clinic yet',
          message: 'Add a clinic before recording a memo.',
          actionLabel: 'Add clinic',
          onAction: () {
            Navigator.of(context).pop();
            context.push('/clinics');
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final gstBreakdown = _gstBreakdown;
    final currentTotal = _total;
    if (_paidAmountController.text.isEmpty && _autoSyncPaidAmount) {
      _paidAmountController.text = currentTotal.toStringAsFixed(0);
    }

    final paidNum = double.tryParse(_paidAmountController.text) ?? currentTotal;
    final pendingDue = currentTotal - paidNum;

    return AppFormDialog(
      title: 'Create Cash Memo',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child:
              _submitting
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Save & Issue Memo'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PickerField<String>(
              label: 'Clinic',
              prefixIcon: Icons.local_hospital,
              value: _selectedClinicId,
              errorText: _clinicError,
              options:
                  clinics
                      .map(
                        (c) => PickerOption(
                          value: c.id,
                          label: c.name,
                          subtitle: c.address,
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedClinicId = val;
                  _clinicError = null;
                  final cl = clinics.firstWhere((c) => c.id == val);
                  _consultationController.text = cl.defaultConsultationFee
                      .toStringAsFixed(0);
                  if (_autoSyncPaidAmount) {
                    _paidAmountController.text = _total.toStringAsFixed(0);
                  }
                });
              },
            ),
            const SizedBox(height: Spacing.md),
            DateField(
              label: 'Date',
              value: _memoDate,
              onChanged: (d) => setState(() => _memoDate = d),
            ),
            const SizedBox(height: Spacing.md),
            PatientPickerField(
              selected: _selectedPatient,
              onSelected:
                  (p) => setState(() {
                    _selectedPatient = p;
                    _patientError = null;
                    if (p.primaryClinicId == 'clinic_online') {
                      _selectedClinicId = 'clinic_online';
                      _paymentMethod = 'UPI';
                    }
                  }),
              errorText: _patientError,
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _consultationController,
              label: 'Consultation Fee (Rs)',
              prefixIcon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              onChanged: (_) => _onFeeChanged(),
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _medicineController,
              label: 'Medicine Fee (Rs)',
              prefixIcon: Icons.medication,
              keyboardType: TextInputType.number,
              onChanged: (_) => _onFeeChanged(),
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.medication_liquid_outlined, size: 16),
                  label: Text(
                    _dispensedItems.isEmpty
                        ? 'Dispense from Inventory'
                        : '${_dispensedItems.length} ${_dispensedItems.length == 1 ? 'remedy' : 'remedies'} selected',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: _openDispensePicker,
                ),
                if (_dispensedItems.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _dispensedItems.clear();
                        _syncMedicineFeeFromDispensed();
                        _onFeeChanged();
                      });
                    },
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            _buildPrescriptionShortcut(),
            if (_dispensedItems.isNotEmpty) ...[
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: [
                  for (final item in _dispensedItems)
                    Chip(
                      label: Text(
                        '${item.medicine.name}${item.medicine.potency != null && item.medicine.potency!.isNotEmpty ? ' ${item.medicine.potency}' : ''} × ${item.quantity.toStringAsFixed(0)} (₹${item.totalPrice.toStringAsFixed(0)})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                      onDeleted: () {
                        setState(() {
                          _dispensedItems.remove(item);
                          _syncMedicineFeeFromDispensed();
                          _onFeeChanged();
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
            ],
            const SizedBox(height: Spacing.sm),
            CustomTextField(
              controller: _otherController,
              label: 'Other Charges (Rs)',
              prefixIcon: Icons.add_circle_outline,
              keyboardType: TextInputType.number,
              onChanged: (_) => _onFeeChanged(),
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _discountController,
              label: 'Discount (Rs)',
              prefixIcon: Icons.discount,
              keyboardType: TextInputType.number,
              onChanged: (_) => _onFeeChanged(),
            ),
            const SizedBox(height: Spacing.md),
            CustomTextField(
              controller: _paidAmountController,
              label: 'Paid Amount (Rs) *',
              prefixIcon: Icons.payments,
              keyboardType: TextInputType.number,
              onChanged: (v) {
                setState(() {
                  _autoSyncPaidAmount = false;
                });
              },
            ),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                ActionChip(
                  label: const Text('Full Payment'),
                  avatar: const Icon(Icons.check, size: 14),
                  onPressed: () {
                    setState(() {
                      _autoSyncPaidAmount = true;
                      _paidAmountController.text = currentTotal.toStringAsFixed(
                        0,
                      );
                    });
                  },
                ),
                ActionChip(
                  label: const Text('Unpaid / Full Due (Rs 0)'),
                  avatar: const Icon(Icons.pending_actions, size: 14),
                  onPressed: () {
                    setState(() {
                      _autoSyncPaidAmount = false;
                      _paidAmountController.text = '0';
                    });
                  },
                ),
              ],
            ),
            if (pendingDue > 0) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                'Note: Rs ${pendingDue.toStringAsFixed(0)} will be recorded as Pending Due balance for this patient.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (!gstBreakdown.isEmpty) ...[
              const SizedBox(height: Spacing.md),
              for (final line in gstBreakdown.lines) ...[
                _buildTaxRow(
                  'CGST @ ${(line.rate / 2).toStringAsFixed(line.rate % 2 == 0 ? 0 : 2)}%',
                  line.cgst,
                ),
                _buildTaxRow(
                  'SGST @ ${(line.rate / 2).toStringAsFixed(line.rate % 2 == 0 ? 0 : 2)}%',
                  line.sgst,
                ),
              ],
            ],
            const SizedBox(height: Spacing.lg),
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: Radii.smAll,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payable:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    Formatters.formatCurrency(currentTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            ChoiceChipField<String>(
              label: 'Payment Method',
              options: _paymentMethods,
              value: _paymentMethod,
              labelOf: (m) => m,
              iconOf: PaymentIcons.forMethod,
              onChanged: (m) => setState(() => _paymentMethod = m),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final formOk = _formKey.currentState!.validate();

    // Surface the missing patient and clinic instead of failing silently.
    setState(() {
      _patientError = _selectedPatient == null ? 'Select a patient' : null;
      _clinicError = _selectedClinicId == null ? 'Select a clinic' : null;
    });

    if (!formOk || _selectedPatient == null || _selectedClinicId == null) {
      return;
    }

    setState(() => _submitting = true);

    final consult = double.tryParse(_consultationController.text) ?? 0.0;
    final med = double.tryParse(_medicineController.text) ?? 0.0;
    final other = double.tryParse(_otherController.text) ?? 0.0;
    final disc = double.tryParse(_discountController.text) ?? 0.0;
    // Snapshot the tax once so the amount persisted matches the total the
    // doctor was shown, even if inventory changes while the memo is saving.
    final gst = _gstBreakdown;
    final paid = double.tryParse(_paidAmountController.text) ?? _total;

    String? memoNotes;
    if (_dispensedItems.isNotEmpty) {
      final summary = _dispensedItems
          .map((i) {
            final potency =
                i.medicine.potency != null && i.medicine.potency!.isNotEmpty
                    ? ' ${i.medicine.potency}'
                    : '';
            final qty =
                i.quantity % 1 == 0
                    ? i.quantity.toInt().toString()
                    : i.quantity.toStringAsFixed(1);
            return '${i.medicine.name}$potency ($qty ${i.medicine.unit})';
          })
          .join(', ');
      memoNotes = 'Dispensed: $summary';
    }

    try {
      await ref
          .read(cashMemoNotifierProvider.notifier)
          .createCashMemo(
            patientId: _selectedPatient!.id,
            clinicId: _selectedClinicId!,
            consultationFee: consult,
            medicineFee: med,
            otherFee: other,
            discount: disc,
            paidAmount: paid,
            paymentMethod: _paymentMethod,
            memoDate: _memoDate,
            notes: memoNotes,
            cgstAmount: gst.cgstAmount,
            sgstAmount: gst.sgstAmount,
            gstin: gst.isEmpty ? null : _selectedClinic?.gstin,
          );

      if (_dispensedItems.isNotEmpty) {
        final inventory = ref.read(inventoryControllerProvider);
        for (final item in _dispensedItems) {
          await inventory.adjustStock(item.medicine.id, -item.quantity);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not create memo: $e')));
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
