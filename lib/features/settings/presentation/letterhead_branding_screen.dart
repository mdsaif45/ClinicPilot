import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/entitlement/entitlement_model.dart';
import '../../../core/entitlement/entitlement_provider.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pro_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/letterhead_branding_provider.dart';
import 'widgets/pro_upgrade_sheet.dart';

/// Manages the clinic logo and doctor signature printed on prescriptions.
///
/// The images stay editable on the Free tier — a lapsed subscription must not
/// strand a doctor's uploads — but a locked practice is told plainly that
/// prescriptions will print without them until Pro is active.
class LetterheadBrandingScreen extends ConsumerWidget {
  const LetterheadBrandingScreen({super.key});

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref, {
    required bool isLogo,
  }) async {
    AppHaptics.selection();
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(letterheadBrandingStoreProvider);
    try {
      final saved = await store.pickAndSave(isLogo: isLogo);
      if (saved) ref.invalidate(storedLetterheadBrandingProvider);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save image: $e')),
      );
    }
  }

  Future<void> _clear(WidgetRef ref, {required bool isLogo}) async {
    AppHaptics.selection();
    await ref.read(letterheadBrandingStoreProvider).clear(isLogo: isLogo);
    ref.invalidate(storedLetterheadBrandingProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unlocked = ref.watch(
      featureUnlockedProvider(AppFeature.customLetterheadBranding),
    );
    final storedAsync = ref.watch(storedLetterheadBrandingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Letterhead')),
      body: storedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load branding: $e')),
        data: (stored) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.md,
              Spacing.lg,
              Spacing.xxl,
            ),
            children: [
              if (!unlocked) ...[
                AppCard(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: scheme.tertiary,
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Branding is a Pro feature',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                const ProBadge(compact: true),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'You can still set these up. Prescriptions will '
                              'print the plain letterhead until Pro is active.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: Spacing.sm),
                            AppButton.primary(
                              label: 'Upgrade to Pro',
                              icon: Icons.workspace_premium,
                              onPressed: () => ProUpgradeSheet.show(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),
              ],

              const SectionHeader(
                title: 'Clinic Logo',
                subtitle: 'Printed at the top-left of every prescription',
                tightTop: true,
              ),
              _BrandingImageCard(
                bytes: stored.logo,
                emptyLabel: 'No logo added',
                onPick: () => _pick(context, ref, isLogo: true),
                onClear: () => _clear(ref, isLogo: true),
              ),

              const SizedBox(height: Spacing.lg),
              const SectionHeader(
                title: 'Doctor Signature',
                subtitle: 'Printed above the signature line',
              ),
              _BrandingImageCard(
                bytes: stored.signature,
                emptyLabel: 'No signature added',
                onPick: () => _pick(context, ref, isLogo: false),
                onClear: () => _clear(ref, isLogo: false),
              ),

              const SizedBox(height: Spacing.lg),
              Text(
                'A signature image is a facsimile, not a digital signature. '
                'Use it only where your medical council permits one on a '
                'printed prescription.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandingImageCard extends StatelessWidget {
  final Uint8List? bytes;
  final String emptyLabel;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _BrandingImageCard({
    required this.bytes,
    required this.emptyLabel,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = bytes != null && bytes!.isNotEmpty;

    return AppCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: Radii.smAll,
              ),
              alignment: Alignment.center,
              child:
                  hasImage
                      ? Padding(
                        padding: const EdgeInsets.all(Spacing.sm),
                        child: Image.memory(bytes!, fit: BoxFit.contain),
                      )
                      : Text(
                        emptyLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    label: hasImage ? 'Replace' : 'Add Image',
                    icon: Icons.image_outlined,
                    onPressed: onPick,
                  ),
                ),
                if (hasImage) ...[
                  const SizedBox(width: Spacing.sm),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: scheme.error,
                    tooltip: 'Remove',
                    onPressed: onClear,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
