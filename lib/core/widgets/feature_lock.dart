import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entitlement/entitlement_model.dart';
import '../entitlement/entitlement_provider.dart';
import 'empty_state.dart';

/// Wraps a Pro-only action so it soft-locks for Free/expired doctors.
///
/// This never hides or disables the surrounding screen — ClinicPilot's
/// entitlement model promises "zero clinical data locks", so the doctor can
/// always see what a Pro feature does. What [guard] intercepts is the
/// *action*: it returns [onUnlocked] unchanged when [feature] is unlocked,
/// or a callback that runs [onLocked] (typically `ProUpgradeSheet.show`)
/// instead. `onLocked` is a caller-supplied callback rather than something
/// this file shows itself, since `core/widgets` cannot import the
/// `features/settings` upgrade sheet without a cyclic dependency.
VoidCallback guardFeature(
  WidgetRef ref, {
  required AppFeature feature,
  required VoidCallback onUnlocked,
  required VoidCallback onLocked,
}) {
  final unlocked = ref.watch(featureUnlockedProvider(feature));
  return unlocked ? onUnlocked : onLocked;
}

/// Full-screen "this is a Pro feature" placeholder.
///
/// For a whole screen reached by more than one entry point — a menu tile
/// guarded with [guardFeature] plus a direct route push, say — gating only
/// the tile tap leaves the route itself open. This is the second layer: a
/// screen wraps its `body` in [FeatureLockedView] so navigating in directly
/// still shows an upgrade prompt instead of the real (non-clinical) content.
class FeatureLockedView extends StatelessWidget {
  final AppFeature feature;
  final VoidCallback onUpgrade;

  const FeatureLockedView({
    super.key,
    required this.feature,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.workspace_premium_outlined,
      title: '${feature.displayName} is a Pro feature',
      message: feature.description,
      actionLabel: 'Upgrade to ClinicPilot Pro',
      onAction: onUpgrade,
      actionIcon: Icons.workspace_premium,
    );
  }
}
