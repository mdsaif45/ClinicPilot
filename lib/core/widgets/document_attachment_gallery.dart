import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../design/tokens.dart';
import '../services/app_haptics.dart';
import '../services/media_attachment_service.dart';

/// Document attachment manager for lab investigations & diagnostic test reports (PDF, images).
class DocumentAttachmentGallery extends StatelessWidget {
  final String patientId;
  final List<String> attachments;
  final ValueChanged<List<String>> onAttachmentsChanged;
  final bool readOnly;

  const DocumentAttachmentGallery({
    super.key,
    required this.patientId,
    required this.attachments,
    required this.onAttachmentsChanged,
    this.readOnly = false,
  });

  Future<void> _pickDocuments(BuildContext context) async {
    AppHaptics.selection();
    final picked = await MediaAttachmentService.pickDocuments(
      patientId: patientId,
    );
    if (picked.isEmpty) return;
    onAttachmentsChanged([...attachments, ...picked]);
  }

  void _removeAttachment(int index) {
    AppHaptics.medium();
    final updated = List<String>.from(attachments)..removeAt(index);
    onAttachmentsChanged(updated);
  }

  void _openFile(String filePath) {
    AppHaptics.selection();
    MediaAttachmentService.openAttachment(filePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Test Report Attachments (PDF / Scans)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!readOnly)
              TextButton.icon(
                icon: const Icon(Icons.attach_file_outlined, size: 16),
                label: const Text('Attach File'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                ),
                onPressed: () => _pickDocuments(context),
              ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        if (attachments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: Spacing.md,
              horizontal: Spacing.md,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: Radii.mdAll,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  'No report files attached (PDF, JPG, PNG)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attachments.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.xs),
            itemBuilder: (context, index) {
              final path = attachments[index];
              final fileName = p.basename(path);
              final isPdf = path.toLowerCase().endsWith('.pdf');

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: Radii.mdAll,
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                      size: 24,
                      color: isPdf ? scheme.error : scheme.primary,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openFile(path),
                        child: Text(
                          fileName.isNotEmpty
                              ? fileName
                              : 'Attached Report #${index + 1}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      tooltip: 'Open document',
                      onPressed: () => _openFile(path),
                    ),
                    if (!readOnly)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: scheme.error,
                        ),
                        tooltip: 'Remove file',
                        onPressed: () => _removeAttachment(index),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
