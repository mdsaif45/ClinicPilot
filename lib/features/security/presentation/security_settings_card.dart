import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/security_provider.dart';
import '../../../core/services/app_haptics.dart';
import '../../../core/widgets/app_list_tile.dart';
import 'security_privacy_screen.dart';

class SecuritySettingsCard extends ConsumerWidget {
  const SecuritySettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(appLockProvider);

    return SettingsGroup(
      title: 'Security & Privacy',
      children: [
        AppListTile(
          icon: Icons.shield_outlined,
          title: 'Security & Privacy',
          subtitle:
              lockState.isEnabled
                  ? 'App Lock active (4-digit PIN)'
                  : 'Off (protect patient records)',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            AppHaptics.selection();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()),
            );
          },
        ),
      ],
    );
  }
}
