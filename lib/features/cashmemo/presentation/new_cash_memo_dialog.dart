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
import '../../clinics/providers/clinic_provider.dart';
import '../../patients/presentation/patient_picker.dart';
import '../providers/cash_memo_provider.dart';

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
    _selectedClinicId = ref.read(activeClinicIdProvider);

    final activeClinic = ref.read(activeClinicProvider);
    if (activeClinic != null) {
      _consultationController.text =
          activeClinic.defaultConsultationFee.toStringAsFixed(0);
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

  double get _total {
    final c = double.tryParse(_consultationController.text) ?? 0.0;
    final m = double.tryParse(_medicineController.text) ?? 0.0;
    final o = double.tryParse(_otherController.text) ?? 0.0;
    final d = double.tryParse(_discountController.text) ?? 0.0;
    return (c + m + o) - d;
  }

  bool _autoSyncPaidAmount = true;

  void _onFeeChanged() {
    setState(() {
      if (_autoSyncPaidAmount) {
        _paidAmountController.text = _total.toStringAsFixed(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicsStreamProvider);

    final clinics = clinicsAsync.value ?? [];

    if (_selectedClinicId == null && clinics.length == 1) {
      _selectedClinicId = clinics.first.id;
      final cl = clinics.first;
      _consultationController.text = cl.defaultConsultationFee.toStringAsFixed(0);
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
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
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
              options: clinics
                  .map((c) => PickerOption(
                        value: c.id,
                        label: c.name,
                        subtitle: c.address,
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedClinicId = val;
                  _clinicError = null;
                  final cl = clinics.firstWhere((c) => c.id == val);
                  _consultationController.text =
                      cl.defaultConsultationFee.toStringAsFixed(0);
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
              onSelected: (p) => setState(() {
                _selectedPatient = p;
                _patientError = null;
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
            const SizedBox(height: Spacing.md),
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
              hint: 'Amount collected today',
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
                      _paidAmountController.text = currentTotal.toStringAsFixed(0);
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

    if (!formOk || _selectedPatient == null || _selectedClinicId == null) return;

    setState(() => _submitting = true);

    final consult = double.tryParse(_consultationController.text) ?? 0.0;
    final med = double.tryParse(_medicineController.text) ?? 0.0;
    final other = double.tryParse(_otherController.text) ?? 0.0;
    final disc = double.tryParse(_discountController.text) ?? 0.0;
    final paid = double.tryParse(_paidAmountController.text) ?? _total;

    try {
      await ref.read(cashMemoNotifierProvider.notifier).createCashMemo(
            patientId: _selectedPatient!.id,
            clinicId: _selectedClinicId!,
            consultationFee: consult,
            medicineFee: med,
            otherFee: other,
            discount: disc,
            paidAmount: paid,
            paymentMethod: _paymentMethod,
            memoDate: _memoDate,
          );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create memo: \$e')),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
