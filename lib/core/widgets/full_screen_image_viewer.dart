import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../services/app_haptics.dart';

/// Immersive full-screen clinical image viewer with pinch-to-zoom, pan, and gallery swiping.
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    required this.title,
  });

  /// Convenient helper to open the viewer modally.
  static Future<void> open(
    BuildContext context, {
    required List<String> imagePaths,
    int initialIndex = 0,
    required String title,
  }) {
    AppHaptics.selection();
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullScreenImageViewer(
          imagePaths: imagePaths,
          initialIndex: initialIndex,
          title: title,
        ),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, TransformationController> _transformControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imagePaths.isEmpty ? 0 : widget.imagePaths.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _transformControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TransformationController _getTransformController(int index) {
    return _transformControllers.putIfAbsent(index, () => TransformationController());
  }

  void _handleDoubleTap(int index) {
    final controller = _getTransformController(index);
    AppHaptics.selection();
    if (controller.value.isIdentity()) {
      // Zoom in
      controller.value = Matrix4.identity()..scale(2.5);
    } else {
      // Reset zoom
      controller.value = Matrix4.identity();
    }
  }

  void _resetCurrentZoom() {
    final controller = _getTransformController(_currentIndex);
    controller.value = Matrix4.identity();
    AppHaptics.selection();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = widget.imagePaths.length;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close Viewer',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (total > 1)
              Text(
                'Photo ${_currentIndex + 1} of $total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map_outlined),
            tooltip: 'Reset Zoom',
            onPressed: _resetCurrentZoom,
          ),
        ],
      ),
      body: total == 0
          ? Center(
              child: Text(
                'No image to display',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: total,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final path = widget.imagePaths[index];
                    final transformController = _getTransformController(index);

                    return GestureDetector(
                      onDoubleTap: () => _handleDoubleTap(index),
                      child: Container(
                        color: scheme.surface,
                        alignment: Alignment.center,
                        child: InteractiveViewer(
                          transformationController: transformController,
                          minScale: 1.0,
                          maxScale: 5.0,
                          clipBehavior: Clip.none,
                          child: Center(
                            child: kIsWeb
                                ? Image.network(
                                    path,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => _buildErrorWidget(context),
                                  )
                                : Image.file(
                                    File(path),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => _buildErrorWidget(context),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Bottom Page Indicator Dots (when multiple photos)
                if (total > 1)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.lg),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                          borderRadius: Radii.pillAll,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(total, (i) {
                            final isSelected = i == _currentIndex;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isSelected ? 12 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? scheme.primary : scheme.outlineVariant,
                                borderRadius: Radii.pillAll,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 48, color: scheme.error),
          const SizedBox(height: Spacing.sm),
          Text(
            'Unable to load image',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
