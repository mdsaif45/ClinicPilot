import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/services/contact_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../add_edit_prescription_dialog.dart';
import '../../providers/prescription_provider.dart';

class PrescriptionListView extends ConsumerWidget {
  final Patient patient;
  final String? visitId;

  const PrescriptionListView({
    super.key,
    required this.patient,
    this.visitId,
  });

  void _openAddPrescription(BuildContext context, int defaultIndex) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditPrescriptionDialog(
        patientId: patient.id,
        visitId: visitId,
        defaultIndex: defaultIndex,
      ),
    );
  }

  void _openEditPrescription(BuildContext context, Prescription rx) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (_) => AddEditPrescriptionDialog(
        patientId: patient.id,
        visitId: visitId,
        existingPrescription: rx,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Prescription rx) {
    AppHaptics.error();
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        title: 'Delete Prescription',
        message: 'Are you sure you want to remove "${rx.remedyName} ${rx.potency}"?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          await ref.read(prescriptionNotifierProvider.notifier).deletePrescription(rx.id);
          AppHaptics.medium();
        },
      ),
    );
  }

  void _shareViaWhatsApp(BuildContext context, List<Prescription> list) {
    AppHaptics.selection();
    final buffer = StringBuffer();
    buffer.writeln('📋 *PRESCRIPTION FOR ${patient.name.toUpperCase()}*');
    buffer.writeln('Patient ID: ${patient.patientCode}');
    buffer.writeln('Date: ${Formatters.formatDate(DateTime.now())}');
    buffer.writeln('--------------------------------');

    for (int i = 0; i < list.length; i++) {
      final rx = list[i];
      buffer.writeln('${i + 1}. *${rx.remedyName}* ${rx.potency}');
      if ((rx.doseCount ?? '').isNotEmpty || (rx.frequency ?? '').isNotEmpty) {
        buffer.writeln('   Dose: ${rx.doseCount ?? ''} • ${rx.frequency ?? ''}');
      }
      if ((rx.vehicle ?? '').isNotEmpty) {
        buffer.writeln('   Form: ${rx.vehicle}');
      }
      if ((rx.instructions ?? '').isNotEmpty) {
        buffer.writeln('   Timing: ${rx.instructions}');
      }
      if ((rx.durationDays ?? '').isNotEmpty) {
        buffer.writeln('   Duration: ${rx.durationDays}');
      }
      buffer.writeln();
    }

    if (list.isNotEmpty && (list.first.dietaryAdvice ?? '').isNotEmpty) {
      buffer.writeln('⚠️ *Dietary Advice:*');
      buffer.writeln(list.first.dietaryAdvice);
      buffer.writeln();
    }

    buffer.writeln('Take medicines as advised. For queries, contact clinic.');

    ContactService.openWhatsApp(
      phone: patient.whatsapp ?? patient.phone,
      message: buffer.toString(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = visitId != null
        ? ref.watch(visitPrescriptionsProvider(visitId!))
        : ref.watch(patientPrescriptionsProvider(patient.id));
    final theme = Theme.of(context);

    final prescriptions = prescriptionsAsync.value ?? [];

    if (prescriptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: AppCard(
          margin: EdgeInsets.zero,
          child: EmptyState(
            icon: Icons.medication_outlined,
            title: 'No prescriptions logged',
            message: 'Prescribe multi-remedy posology with Latin binomials, potency, and dosage.',
            actionLabel: 'Prescribe Remedy',
            onAction: () => _openAddPrescription(context, 1),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${prescriptions.length} ${prescriptions.length == 1 ? 'Remedy' : 'Remedies'} Prescribed',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                tooltip: 'Share Rx via WhatsApp',
                onPressed: () => _shareViaWhatsApp(context, prescriptions),
              ),
              AppButton.tonal(
                label: 'Add Remedy',
                icon: Icons.add,
                onPressed: () => _openAddPrescription(context, prescriptions.length + 1),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          for (var i = 0; i < prescriptions.length; i++) ...[
            if (i > 0) const SizedBox(height: Spacing.md),
            _PrescriptionCard(
              rx: prescriptions[i],
              onEdit: () => _openEditPrescription(context, prescriptions[i]),
              onDelete: () => _confirmDelete(context, ref, prescriptions[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Prescription rx;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PrescriptionCard({
    required this.rx,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Remedy Name (Italic) + Potency Badge + Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  'Rx #${rx.remedyIndex}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rx.remedyName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatDate(rx.prescriptionDate),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: Radii.smAll,
                ),
                child: Text(
                  rx.potency,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: scheme.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Posology details: Dose, Frequency, Vehicle
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              if ((rx.doseCount ?? '').isNotEmpty)
                _ChipInfo(icon: Icons.grain, text: rx.doseCount!),
              if ((rx.frequency ?? '').isNotEmpty)
                _ChipInfo(icon: Icons.schedule, text: rx.frequency!),
              if ((rx.vehicle ?? '').isNotEmpty)
                _ChipInfo(icon: Icons.water_drop_outlined, text: rx.vehicle!),
              if ((rx.durationDays ?? '').isNotEmpty)
                _ChipInfo(icon: Icons.calendar_today_outlined, text: rx.durationDays!),
            ],
          ),

          // Instructions & Timing
          if ((rx.instructions ?? '').isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: scheme.primary),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      rx.instructions!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Dietary Restrictions Advice
          if ((rx.dietaryAdvice ?? '').isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Container(
              padding: const EdgeInsets.all(Spacing.xs + 2),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: Radii.smAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.no_food_outlined, size: 14, color: scheme.tertiary),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Dietary note: ${rx.dietaryAdvice!}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ChipInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: Radii.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}