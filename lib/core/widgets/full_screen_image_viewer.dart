import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/tokens.dart';
import '../services/app_haptics.dart';

/// Immersive full-screen clinical image viewer with pinch-to-zoom, mouse drag/swipe,
/// desktop navigation chevrons, and keyboard shortcuts.
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
        builder:
            (_) => FullScreenImageViewer(
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
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.imagePaths.isEmpty ? 0 : widget.imagePaths.length - 1,
    );
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
    return _transformControllers.putIfAbsent(index, () {
      final ctrl = TransformationController();
      ctrl.addListener(() {
        final isZoomed = !ctrl.value.isIdentity();
        // If scale returns to 1.0, ensure state refreshes so page swipe re-enables
        if (!isZoomed && mounted) {
          setState(() {});
        }
      });
      return ctrl;
    });
  }

  bool _isZoomed(int index) {
    final controller = _transformControllers[index];
    if (controller == null) return false;
    return !controller.value.isIdentity();
  }

  void _handleDoubleTap(int index) {
    final controller = _getTransformController(index);
    AppHaptics.selection();
    setState(() {
      if (controller.value.isIdentity()) {
        controller.value = Matrix4.identity()..scale(2.5);
      } else {
        controller.value = Matrix4.identity();
      }
    });
  }

  void _goToNext() {
    final total = widget.imagePaths.length;
    if (_currentIndex < total - 1) {
      AppHaptics.selection();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      AppHaptics.selection();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = widget.imagePaths.length;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _goToPrevious,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _goToNext,
        const SingleActivator(LogicalKeyboardKey.escape):
            () => Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close Viewer (Esc)',
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
          ),
          body:
              total == 0
                  ? Center(
                    child: Text(
                      'No image to display',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                  : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Swipeable / Mouse-draggable PageView
                      ScrollConfiguration(
                        behavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                            PointerDeviceKind.stylus,
                          },
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          physics:
                              _isZoomed(_currentIndex)
                                  ? const NeverScrollableScrollPhysics()
                                  : const ClampingScrollPhysics(),
                          itemCount: total,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final path = widget.imagePaths[index];
                            final transformController = _getTransformController(
                              index,
                            );

                            return GestureDetector(
                              onDoubleTap: () => _handleDoubleTap(index),
                              child: Container(
                                color: scheme.surface,
                                alignment: Alignment.center,
                                child: InteractiveViewer(
                                  transformationController: transformController,
                                  minScale: 1.0,
                                  maxScale: 5.0,
                                  panEnabled: _isZoomed(index),
                                  clipBehavior: Clip.none,
                                  onInteractionEnd: (_) {
                                    if (mounted) setState(() {});
                                  },
                                  child: Center(
                                    child:
                                        kIsWeb
                                            ? Image.network(
                                              path,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      _buildErrorWidget(
                                                        context,
                                                      ),
                                            )
                                            : Image.file(
                                              File(path),
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      _buildErrorWidget(
                                                        context,
                                                      ),
                                            ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Left Chevron Button (Previous Image)
                      if (total > 1 && _currentIndex > 0)
                        Positioned(
                          left: Spacing.md,
                          child: Material(
                            color: scheme.surfaceContainerHighest.withValues(
                              alpha: 0.85,
                            ),
                            shape: const CircleBorder(),
                            elevation: 3,
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                                size: 30,
                              ),
                              tooltip: 'Previous Photo (Left Arrow)',
                              color: scheme.onSurface,
                              onPressed: _goToPrevious,
                            ),
                          ),
                        ),

                      // Right Chevron Button (Next Image)
                      if (total > 1 && _currentIndex < total - 1)
                        Positioned(
                          right: Spacing.md,
                          child: Material(
                            color: scheme.surfaceContainerHighest.withValues(
                              alpha: 0.85,
                            ),
                            shape: const CircleBorder(),
                            elevation: 3,
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                              ),
                              tooltip: 'Next Photo (Right Arrow)',
                              color: scheme.onSurface,
                              onPressed: _goToNext,
                            ),
                          ),
                        ),

                      // Bottom Page Indicator Dots (when multiple photos)
                      if (total > 1)
                        Positioned(
                          bottom: 0,
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: Spacing.lg,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.md,
                                  vertical: Spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest
                                      .withValues(alpha: 0.85),
                                  borderRadius: Radii.pillAll,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(total, (i) {
                                    final isSelected = i == _currentIndex;
                                    return InkWell(
                                      onTap: () {
                                        _pageController.animateToPage(
                                          i,
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          curve: Curves.easeInOutCubic,
                                        );
                                      },
                                      borderRadius: Radii.pillAll,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        width: isSelected ? 14 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? scheme.primary
                                                  : scheme.outlineVariant,
                                          borderRadius: Radii.pillAll,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
        ),
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
