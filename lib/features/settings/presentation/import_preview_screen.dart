import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/design/tokens.dart';
import '../../../core/services/import_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';

/// Shows what a filled-in template would do before anything is written -
/// counts of what imports cleanly, and every row that does not with enough
/// detail to find and fix it in the spreadsheet.
///
/// The doctor confirms from here; the write itself only happens on that
/// confirmation, in one transaction, so this screen and the database can
/// never disagree about what happened.
class ImportPreviewScreen extends ConsumerStatefulWidget {
  final List<int> bytes;
  final Map<String, String> clinicIdsByName;

  const ImportPreviewScreen({
    super.key,
    required this.bytes,
    required this.clinicIdsByName,
  });

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  late Future<ImportPreview> _previewFuture;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _previewFuture =
        ImportService.validate(widget.bytes, widget.clinicIdsByName);
  }

  Future<void> _confirmImport(ImportPreview preview) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import this data?'),
        content: Text(
          'This writes ${preview.patientCount} '
          '${preview.patientCount == 1 ? 'patient' : 'patients'}'
          '${preview.visitCount > 0 ? ', ${preview.visitCount} visits' : ''}'
          '${preview.memoCount > 0 ? ', ${preview.memoCount} cash memos' : ''}'
          '${preview.expenseCount > 0 ? ', ${preview.expenseCount} expenses' : ''} '
          'into the app. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _importing = true);

    try {
      final db = ref.read(databaseProvider);
      final service = ImportService(db);
      final result = await service.commit(widget.bytes, widget.clinicIdsByName);

      if (!mounted) return;
      context.go('/dashboard');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Imported ${result.patientCount} patients'
              '${result.visitCount > 0 ? ', ${result.visitCount} visits' : ''}'
              '${result.memoCount > 0 ? ', ${result.memoCount} memos' : ''}'
              '${result.expenseCount > 0 ? ', ${result.expenseCount} expenses' : ''}'),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _importing = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Import Preview')),
      body: FutureBuilder<ImportPreview>(
        future: _previewFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final preview = snapshot.data!;

          if (!preview.hasImportableData) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Nothing to import',
              message: preview.errors.isEmpty
                  ? 'The Patients sheet has no rows to import.'
                  : preview.errors.first.reason,
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ready to import',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: Spacing.md),
                    _CountRow(label: 'Patients', count: preview.patientCount),
                    _CountRow(label: 'Visits', count: preview.visitCount),
                    _CountRow(label: 'Cash Memos', count: preview.memoCount),
                    _CountRow(label: 'Expenses', count: preview.expenseCount),
                    if (preview.errors.isNotEmpty) ...[
                      const SizedBox(height: Spacing.md),
                      Text(
                        '${preview.errors.length} '
                        '${preview.errors.length == 1 ? 'row' : 'rows'} '
                        'skipped',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              if (preview.errors.isNotEmpty) ...[
                const SizedBox(height: Spacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child:
                      Text('Skipped rows', style: theme.textTheme.titleSmall),
                ),
                const SizedBox(height: Spacing.sm),
                AppCard(
                  child: Column(
                    children: [
                      for (final e in preview.errors)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.warning_amber_outlined),
                          title: Text('${e.sheet} row ${e.rowNumber}'),
                          subtitle: Text(e.reason),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Spacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: FilledButton(
                  onPressed:
                      _importing ? null : () => _confirmImport(preview),
                  child: _importing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Import ${preview.patientCount} '
                          '${preview.patientCount == 1 ? 'patient' : 'patients'}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final int count;

  const _CountRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text('$count', style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
