import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/services/app_haptics.dart';
import '../../../patients/providers/recall_provider.dart';
import '../../../settings/providers/update_provider.dart';

/// Modal bottom sheet for viewing clinic alerts and follow-up notifications.
class NotificationCenterSheet extends ConsumerWidget {
  const NotificationCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final recallLists = ref.watch(recallListProvider).value;
    final overdueCount = recallLists == null
        ? 0
        : recallLists.overdue.length + recallLists.lapsed.length;

    final updateRelease = ref.watch(availableUpdateProvider).value;
    final hasUpdate = updateRelease != null;

    final totalAlerts = (overdueCount > 0 ? 1 : 0) + (hasUpdate ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.xxl),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (totalAlerts > 0) ...[
                      const SizedBox(width: Spacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalAlerts',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Notification List
            if (totalAlerts == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 48,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'All caught up!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No pending patient follow-ups or system alerts.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // 1. Patient Follow-up Overdue Alert
              if (overdueCount > 0)
                Material(
                  color: scheme.errorContainer.withValues(alpha: 0.35),
                  borderRadius: Radii.mdAll,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      AppHaptics.selection();
                      Navigator.of(context).pop();
                      context.go('/patients?tab=follow-ups');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.error.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: scheme.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  overdueCount == 1
                                      ? '1 patient needs following up'
                                      : '$overdueCount patients need following up',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Overdue for consultation or review. Tap to view and send reminders.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Icon(
                            Icons.chevron_right,
                            color: scheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 2. App Update Notification
              if (hasUpdate) ...[
                const SizedBox(height: Spacing.sm),
                Material(
                  color: scheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: Radii.mdAll,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      AppHaptics.selection();
                      Navigator.of(context).pop();
                      context.push('/settings');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.system_update_outlined,
                              color: scheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Update Available (${updateRelease.tagName})',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'A new version of ClinicPilot is ready to install.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Icon(
                            Icons.chevron_right,
                            color: scheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
