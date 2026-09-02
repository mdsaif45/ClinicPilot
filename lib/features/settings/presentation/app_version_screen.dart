import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/services/update_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/release_provider.dart';
import '../providers/update_provider.dart';

/// Release notes for the published version, with the update action when one
/// is available.
///
/// Settings only shows the running version now; everything about releases
/// lives here, so the settings list stays a list rather than carrying a card
/// with its own internal states.
class AppVersionScreen extends ConsumerWidget {
  const AppVersionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releaseAsync = ref.watch(latestReleaseProvider);
    final running = ref.watch(runningVersionProvider).value ?? '…';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Version'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(latestReleaseProvider);
              ref.invalidate(availableUpdateProvider);
            },
          ),
        ],
      ),
      body: releaseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load release notes',
              message:
                  'You are running v$running. '
                  'Connect to the internet and pull to refresh.',
            ),
        data: (release) {
          if (release == null) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'No release information',
              message:
                  'You are running v$running. Release notes will appear '
                  'once this device has been online.',
            );
          }

          final isUpdate =
              UpdateService.compareVersions(release.version, running) > 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
            children: [
              AppCard(
                margin: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isUpdate
                              ? Icons.system_update
                              : Icons.check_circle_outline,
                          color:
                              isUpdate
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUpdate
                                    ? 'Update available'
                                    : 'You are up to date',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                isUpdate
                                    ? 'v$running installed · v${release.version} available'
                                    : 'v$running installed',
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isUpdate && release.apkUrl != null) ...[
                      const SizedBox(height: Spacing.lg),
                      _DownloadButton(release: release),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Row(
                  children: [
                    Text(
                      release.tagName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.formatDate(release.publishedAt),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: _ReleaseNotes(notes: release.notes),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Renders the subset of markdown GitHub release notes actually use, rather
/// than pulling in a markdown package for headings and bullets.
class _ReleaseNotes extends StatelessWidget {
  final String notes;

  const _ReleaseNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (notes.trim().isEmpty) {
      return Text(
        'No notes for this release.',
        style: theme.textTheme.bodyMedium,
      );
    }

    final widgets = <Widget>[];
    for (final raw in notes.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: Spacing.sm));
        continue;
      }

      if (line.startsWith('#')) {
        final text = line.replaceFirst(RegExp(r'^#+\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.xs),
            child: Text(text, style: theme.textTheme.titleSmall),
          ),
        );
        continue;
      }

      if (line.trimLeft().startsWith('* ') ||
          line.trimLeft().startsWith('- ')) {
        final text = line.trimLeft().substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: Text(
                    _stripInline(text),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Text(_stripInline(line), style: theme.textTheme.bodyMedium),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Drops the markdown emphasis and link syntax that would otherwise show as
  /// literal asterisks and brackets.
  static String _stripInline(String s) {
    return s
        .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!)
        .replaceAllMapped(RegExp(r'\[(.+?)\]\((.+?)\)'), (m) => m.group(1)!)
        // Bare URLs add nothing on a phone and push the text off the line.
        // Removing them can leave a dangling connector ("... by @me in"), so
        // those are trimmed too rather than left mid-sentence.
        .replaceAll(RegExp(r'\s*https?://\S+'), '')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'\s+(in|at|by|to)\s*$'), '')
        .replaceAll(RegExp(r':\s*$'), '')
        .trim();
  }
}

class _DownloadButton extends ConsumerWidget {
  final AppRelease release;

  const _DownloadButton({required this.release});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateDownloadProvider);
    final notifier = ref.read(updateDownloadProvider.notifier);
    final theme = Theme.of(context);

    if (state.status == DownloadStatus.downloading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: Radii.pillAll,
            child: LinearProgressIndicator(value: state.progress, minHeight: 8),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '${(state.progress * 100).toStringAsFixed(0)}% of '
            '${(state.totalBytes / 1048576).toStringAsFixed(1)} MB',
            style: theme.textTheme.labelMedium,
          ),
        ],
      );
    }

    if (state.status == DownloadStatus.ready) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            // Android cannot install silently; saying so up front stops the
            // system prompt reading as something going wrong.
            'Android will ask you to confirm the install. Your clinic data is '
            'not affected by an update.',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: Spacing.md),
          FilledButton.icon(
            onPressed: () {
              final path = state.downloadedFilePath;
              if (path != null) {
                ref.read(updateServiceProvider).installApk(path);
              }
            },
            icon: const Icon(Icons.install_mobile),
            label: const Text('Install now'),
          ),
        ],
      );
    }

    final matchedApk = ref.watch(matchedApkProvider(release));
    final sizeLabel = matchedApk.when(
      data: (asset) {
        final bytes = asset?.sizeBytes ?? release.apkSizeBytes;
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      },
      loading: () => '',
      error:
          (_, __) =>
              '${(release.apkSizeBytes / 1048576).toStringAsFixed(1)} MB',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.status == DownloadStatus.error) ...[
          Text(
            state.errorMessage ?? 'Download failed.',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
        FilledButton.icon(
          onPressed: () => notifier.startDownload(release),
          icon: const Icon(Icons.download),
          label: Text(
            sizeLabel.isEmpty
                ? 'Download v${release.version}'
                : 'Download v${release.version} · $sizeLabel',
          ),
        ),
      ],
    );
  }
}
