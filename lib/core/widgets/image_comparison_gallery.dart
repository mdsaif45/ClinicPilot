import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../services/app_haptics.dart';
import '../services/media_attachment_service.dart';

/// Interactive Before & After clinical image gallery for Complaints & Clinical Outcomes.
class ImageComparisonGallery extends StatelessWidget {
  final String patientId;
  final List<String> beforeImages;
  final List<String> afterImages;
  final ValueChanged<List<String>> onBeforeImagesChanged;
  final ValueChanged<List<String>> onAfterImagesChanged;
  final bool readOnly;

  const ImageComparisonGallery({
    super.key,
    required this.patientId,
    required this.beforeImages,
    required this.afterImages,
    required this.onBeforeImagesChanged,
    required this.onAfterImagesChanged,
    this.readOnly = false,
  });

  Future<void> _pickImageSection(BuildContext context, bool isBefore) async {
    AppHaptics.selection();
    final picked = await MediaAttachmentService.pickImages(patientId: patientId);
    if (picked.isEmpty) return;

    if (isBefore) {
      onBeforeImagesChanged([...beforeImages, ...picked]);
    } else {
      onAfterImagesChanged([...afterImages, ...picked]);
    }
  }

  void _removeImage(bool isBefore, int index) {
    AppHaptics.medium();
    if (isBefore) {
      final updated = List<String>.from(beforeImages)..removeAt(index);
      onBeforeImagesChanged(updated);
    } else {
      final updated = List<String>.from(afterImages)..removeAt(index);
      onAfterImagesChanged(updated);
    }
  }

  void _previewImage(BuildContext context, String imagePath, String title) {
    AppHaptics.selection();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(Spacing.md),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: Radii.lgAll,
              ),
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: Spacing.md),
                  ClipRRect(
                    borderRadius: Radii.mdAll,
                    child: kIsWeb
                        ? Image.network(imagePath, fit: BoxFit.contain, height: 360)
                        : Image.file(File(imagePath), fit: BoxFit.contain, height: 360),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinical Photos (Before & After Progression)',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Before Column
            Expanded(
              child: _PhotoSection(
                title: 'Before Treatment',
                badgeColor: scheme.primaryContainer,
                badgeTextColor: scheme.onPrimaryContainer,
                images: beforeImages,
                readOnly: readOnly,
                onAdd: () => _pickImageSection(context, true),
                onRemove: (idx) => _removeImage(true, idx),
                onPreview: (path) => _previewImage(context, path, 'Before Treatment Photo'),
              ),
            ),
            const SizedBox(width: Spacing.md),
            // After Column
            Expanded(
              child: _PhotoSection(
                title: 'Follow-Up / After',
                badgeColor: scheme.tertiaryContainer,
                badgeTextColor: scheme.onTertiaryContainer,
                images: afterImages,
                readOnly: readOnly,
                onAdd: () => _pickImageSection(context, false),
                onRemove: (idx) => _removeImage(false, idx),
                onPreview: (path) => _previewImage(context, path, 'Follow-Up / After Photo'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final String title;
  final Color badgeColor;
  final Color badgeTextColor;
  final List<String> images;
  final bool readOnly;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<String> onPreview;

  const _PhotoSection({
    required this.title,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.images,
    required this.readOnly,
    required this.onAdd,
    required this.onRemove,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: Radii.pillAll,
                  ),
                  child: Text(
                    '$title (${images.length})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (!readOnly)
                IconButton(
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  tooltip: 'Add Photo',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onAdd,
                ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          if (images.isEmpty)
            Container(
              height: 64,
              alignment: Alignment.center,
              child: Text(
                'No photos attached',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.xs),
                itemBuilder: (ctx, idx) {
                  final path = images[idx];
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GestureDetector(
                        onTap: () => onPreview(path),
                        child: ClipRRect(
                          borderRadius: Radii.smAll,
                          child: Container(
                            width: 72,
                            height: 72,
                            color: scheme.surfaceContainerHighest,
                            child: kIsWeb
                                ? Image.network(path, fit: BoxFit.cover)
                                : Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 24),
                                  ),
                          ),
                        ),
                      ),
                      if (!readOnly)
                        GestureDetector(
                          onTap: () => onRemove(idx),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: scheme.error,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Icon(Icons.close, size: 12, color: scheme.onError),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
