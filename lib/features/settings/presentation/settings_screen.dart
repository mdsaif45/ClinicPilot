import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../clinics/presentation/clinics_screen.dart';
import '../../clinics/providers/clinic_provider.dart';
import '../../security/presentation/security_settings_card.dart';
import '../providers/doctor_profile_provider.dart';
import '../providers/release_provider.dart';
import '../providers/update_provider.dart';
import 'appearance_section.dart';
import 'app_version_screen.dart';
import 'backup_restore_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clinics = ref.watch(clinicsStreamProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, Spacing.sm, 0, Spacing.xxl),
        children: [
          const _DoctorProfileHeader(),
          const AppearanceSection(),
          SettingsGroup(
            title: 'Clinics',
            children: [
              AppListTile(
                icon: Icons.local_hospital_outlined,
                title: 'Manage clinics',
                subtitle: clinics.isEmpty
                    ? 'No clinics yet'
                    : '${clinics.length} ${clinics.length == 1 ? 'clinic' : 'clinics'}',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClinicsScreen()),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Backup & Restore',
            children: [
              AppListTile(
                icon: Icons.history,
                title: 'Backup and restore',
                subtitle: 'Create or restore a backup, Periodic backups',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BackupRestoreScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SecuritySettingsCard(),
          SettingsGroup(
            title: 'Information',
            children: [
              AppListTile(
                icon: Icons.code,
                title: 'GitHub repository',
                onTap: () => _openUrl(
                  'https://github.com/mdsaif45/ClinicPilot',
                ),
              ),
              const AppListTile(
                icon: Icons.favorite_outline,
                title: 'Developed by mdsaif45',
              ),
              Consumer(builder: (context, ref, _) {
                final running =
                    ref.watch(runningVersionProvider).value ?? '…';
                final updateWaiting =
                    ref.watch(availableUpdateProvider).value != null;
                return AppListTile(
                  icon: Icons.smartphone,
                  title: 'App Version',
                  subtitle: 'v$running',
                  trailing: updateWaiting
                      ? Icon(Icons.circle,
                          size: 10, color: Theme.of(context).colorScheme.tertiary)
                      : const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AppVersionScreen(),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorProfileHeader extends ConsumerWidget {
  const _DoctorProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(doctorProfileStreamProvider).value ?? const DoctorProfile();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final displayName = profile.displayName.isNotEmpty
        ? profile.displayName
        : 'Doctor Profile';
    final avatarLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'D';

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      onTap: () => context.push('/settings/profile'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.primary,
            child: Text(
              avatarLetter,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.qualification.isNotEmpty
                    ? profile.qualification
                    : 'Tap to view credentials & contact info',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: scheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
