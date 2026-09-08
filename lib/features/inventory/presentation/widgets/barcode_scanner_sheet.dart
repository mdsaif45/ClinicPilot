import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../../core/widgets/app_button.dart';
import '../../services/barcode_matcher.dart';

/// Camera sheet that returns the first barcode it reads, or null if dismissed.
///
/// On a platform without a scanner implementation — ClinicPilot's Windows
/// build — [show] never opens the camera and instead offers a keyboard entry
/// dialog, so the same call site works everywhere.
class BarcodeScannerSheet extends StatefulWidget {
  const BarcodeScannerSheet({super.key});

  /// Scans a code, falling back to manual entry where a camera is not
  /// available. Returns the normalised code, or null if cancelled.
  static Future<String?> show(BuildContext context) {
    if (!isBarcodeScanningSupported) {
      return _showManualEntry(context);
    }
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const BarcodeScannerSheet(),
    );
  }

  static Future<String?> _showManualEntry(BuildContext context) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter Barcode'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. 8901234567894',
              helperText: 'Camera scanning is not available on this device.',
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Use Code'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (code == null) return null;
    final normalized = BarcodeMatcher.normalize(code);
    return normalized.isEmpty ? null : normalized;
  }

  @override
  State<BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.qrCode,
    ],
  );

  // The camera streams frames continuously and will re-read the same pack
  // many times a second; without this the sheet would pop repeatedly.
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final code = BarcodeMatcher.normalize(raw);
      if (code.isEmpty) continue;

      _handled = true;
      AppHaptics.success();
      Navigator.of(context).pop(code);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
              'Scan Barcode',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              'Point the camera at the barcode on the pack.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.md),
            ClipRRect(
              borderRadius: Radii.mdAll,
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
                    return ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(Spacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.no_photography_outlined,
                                color: scheme.error,
                                size: 28,
                              ),
                              const SizedBox(height: Spacing.sm),
                              Text(
                                'Camera unavailable. Grant camera permission '
                                'or enter the code by hand.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    label: 'Enter Manually',
                    icon: Icons.keyboard_outlined,
                    onPressed: () async {
                      final code = await BarcodeScannerSheet._showManualEntry(
                        context,
                      );
                      if (code != null && context.mounted) {
                        Navigator.of(context).pop(code);
                      }
                    },
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
