import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/custom_badge.dart';
import '../../services/prescription_dispense_matcher.dart';
import 'dispense_medicine_picker_sheet.dart';

/// Confirmation sheet listing every remedy on the patient's active
/// prescription alongside what clinic inventory can actually supply.
///
/// Dispensing bills the patient and permanently decrements stock, so the
/// doctor reviews and confirms rather than having items added silently.
class PrescriptionDispenseReviewSheet extends ConsumerStatefulWidget {
  final List<PrescriptionMatch> matches;
  final DateTime? prescriptionDate;

  const PrescriptionDispenseReviewSheet({
    super.key,
    required this.matches,
    this.prescriptionDate,
  });

  static Future<List<DispensedMedicineItem>?> show(
    BuildContext context, {
    required List<PrescriptionMatch> matches,
    DateTime? prescriptionDate,
  }) {
    return showModalBottomSheet<List<DispensedMedicineItem>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => PrescriptionDispenseReviewSheet(
            matches: matches,
            prescriptionDate: prescriptionDate,
          ),
    );
  }

  @override
  ConsumerState<PrescriptionDispenseReviewSheet> createState() =>
      _PrescriptionDispenseReviewSheetState();
}

class _PrescriptionDispenseReviewSheetState
    extends ConsumerState<PrescriptionDispenseReviewSheet> {
  /// Prescription row id -> included in the dispense.
  final Map<String, bool> _included = {};

  @override
  void initState() {
    super.initState();
    for (final m in widget.matches) {
      // Unavailable rows start unchecked and cannot be enabled.
      _included[m.prescription.id] = m.isDispensable;
    }
  }

  List<PrescriptionMatch> get _selectedMatches =>
      widget.matches
          .where(
            (m) => m.isDispensable && (_included[m.prescription.id] ?? false),
          )
          .toList();

  double get _totalPrice => _selectedMatches.fold(0.0, (sum, m) {
    final price = m.medicine!.sellingPrice ?? m.medicine!.costPrice ?? 0.0;
    return sum + (price * m.availableQuantity);
  });

  void _confirm() {
    AppHaptics.selection();
    final items =
        _selectedMatches.map((m) {
          final med = m.medicine!;
          return DispensedMedicineItem(
            medicine: med,
            quantity: m.availableQuantity,
            unitPrice: med.sellingPrice ?? med.costPrice ?? 0.0,
          );
        }).toList();
    Navigator.of(context).pop(items);
  }

  Color _statusColor(DispenseMatchStatus status, ColorScheme scheme) {
    return switch (status) {
      DispenseMatchStatus.matched => scheme.primary,
      DispenseMatchStatus.partialStock => scheme.tertiary,
      DispenseMatchStatus.potencyMismatch => scheme.tertiary,
      DispenseMatchStatus.notStocked => scheme.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dispensableCount =
        widget.matches.where((m) => m.isDispensable).length;
    final unavailable = widget.matches.length - dispensableCount;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          0,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispense from Prescription',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              widget.prescriptionDate != null
                  ? 'Prescribed ${_formatDate(widget.prescriptionDate!)} · '
                      '${widget.matches.length} '
                      '${widget.matches.length == 1 ? 'remedy' : 'remedies'}'
                  : '${widget.matches.length} '
                      '${widget.matches.length == 1 ? 'remedy' : 'remedies'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.md),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.matches.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final m = widget.matches[index];
                  final rx = m.prescription;
                  final enabled = m.isDispensable;
                  final checked = _included[rx.id] ?? false;
                  final price =
                      m.medicine?.sellingPrice ?? m.medicine?.costPrice ?? 0.0;

                  return CheckboxListTile(
                    value: checked,
                    // Unavailable remedies stay locked off; the doctor can add
                    // a substitute through the manual inventory picker.
                    onChanged:
                        enabled
                            ? (v) =>
                                setState(() => _included[rx.id] = v ?? false)
                            : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${rx.remedyName} ${rx.potency}'.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled ? null : scheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: Spacing.xxs),
                      child: Row(
                        children: [
                          CustomBadge(
                            label: m.statusLabel,
                            color: _statusColor(m.status, scheme),
                          ),
                          if (enabled) ...[
                            const SizedBox(width: Spacing.sm),
                            Text(
                              '× ${m.availableQuantity.toStringAsFixed(0)} '
                              '${m.medicine!.unit} · '
                              '₹${(price * m.availableQuantity).toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (unavailable > 0) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.10),
                  borderRadius: Radii.smAll,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: scheme.tertiary),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        '$unavailable '
                        '${unavailable == 1 ? 'remedy is' : 'remedies are'} '
                        'unavailable and will not be dispensed.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total  ₹${_totalPrice.toStringAsFixed(0)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: Spacing.sm),
                FilledButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    _selectedMatches.isEmpty
                        ? 'Dispense'
                        : 'Dispense ${_selectedMatches.length}',
                  ),
                  onPressed: _selectedMatches.isEmpty ? null : _confirm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
