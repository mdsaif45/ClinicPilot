import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design/tokens.dart';
import '../../features/clinics/providers/clinic_provider.dart';

/// Active-clinic control for the app bar.
///
/// A bare DropdownButton in an AppBar is awkward: the menu inherits the bar's
/// colour, the selected label fights the action icons for width, and the tap
/// target is only as wide as the text. This presents the current clinic as a
/// single tappable pill and opens a proper sheet, which also has room to show
/// each clinic's address.
class ClinicSwitcher extends ConsumerWidget {
  const ClinicSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeClinicProvider);
    final clinics = ref.watch(clinicsStreamProvider).value ?? [];
    final scheme = Theme.of(context).colorScheme;
    // The app bar sits on the surface colour, so its contents must use
    // onSurface. Using onPrimary here would paint white text on a white bar.
    final onBar = scheme.onSurface;

    if (active == null) {
      return Text(
        'ClinicPilot',
        style: TextStyle(color: onBar, fontWeight: FontWeight.w600),
      );
    }

    return InkWell(
      borderRadius: Radii.pillAll,
      onTap: clinics.length < 2 ? null : () => _open(context, ref, clinics),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: Radii.smAll,
              ),
              child: Icon(
                Icons.local_hospital_outlined,
                color: scheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Flexible(
              child: Text(
                active.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onBar,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (clinics.length > 1) ...[
              const SizedBox(width: Spacing.xs),
              Icon(Icons.expand_more, color: onBar, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> clinics,
  ) async {
    final activeId = ref.read(activeClinicProvider)?.id;
    final scheme = Theme.of(context).colorScheme;

    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Text(
                    'Active clinic',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                for (final c in clinics)
                  ListTile(
                    title: Text(
                      c.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle:
                        (c.address == null || (c.address as String).isEmpty)
                            ? null
                            : Text(c.address as String),
                    trailing:
                        c.id == activeId
                            ? Icon(Icons.check_circle, color: scheme.primary)
                            : null,
                    onTap: () => Navigator.of(ctx).pop(c.id as String),
                  ),
                const SizedBox(height: Spacing.sm),
              ],
            ),
          ),
    );

    if (chosen != null) {
      ref.read(activeClinicIdProvider.notifier).setClinicId(chosen);
    }
  }
}
