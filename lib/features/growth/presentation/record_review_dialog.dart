import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../providers/review_provider.dart';

class RecordReviewDialog extends ConsumerStatefulWidget {
  final Patient patient;
  final String? clinicId;
  final String? existingRequestId;

  const RecordReviewDialog({
    super.key,
    required this.patient,
    this.clinicId,
    this.existingRequestId,
  });

  @override
  ConsumerState<RecordReviewDialog> createState() => _RecordReviewDialogState();
}

class _RecordReviewDialogState extends ConsumerState<RecordReviewDialog> {
  int _rating = 5;
  final _notesController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    AppHaptics.medium();

    try {
      if (widget.existingRequestId != null) {
        await ref
            .read(reviewNotifierProvider.notifier)
            .recordReviewSubmitted(
              requestId: widget.existingRequestId!,
              patientId: widget.patient.id,
              rating: _rating,
              notes:
                  _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
            );
      } else {
        // Record both request and immediate submission
        await ref
            .read(reviewNotifierProvider.notifier)
            .requestReview(
              patientId: widget.patient.id,
              clinicId: widget.clinicId,
              notes:
                  _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
            );
      }
      AppHaptics.success();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      AppHaptics.error();
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not record review: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppFormDialog(
      title: 'Record Google Review',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: const Text('Save Review'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient: ${widget.patient.name}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: Spacing.md),
          Text('Rating given:', style: theme.textTheme.labelMedium),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                onPressed: () {
                  AppHaptics.selection();
                  setState(() => _rating = star);
                },
                icon: Icon(
                  star <= _rating ? Icons.star : Icons.star_border,
                  color: scheme.tertiary,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Feedback / Note (optional)',
            ),
          ),
        ],
      ),
    );
  }
}
