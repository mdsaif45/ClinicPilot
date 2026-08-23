import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/providers/security_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/security/presentation/lock_screen.dart';
import 'features/settings/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  runApp(
    const ProviderScope(
      child: ClinicPilotApp(),
    ),
  );
}

class ClinicPilotApp extends ConsumerStatefulWidget {
  const ClinicPilotApp({super.key});

  @override
  ConsumerState<ClinicPilotApp> createState() => _ClinicPilotAppState();
}

class _ClinicPilotAppState extends ConsumerState<ClinicPilotApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(appLockProvider.notifier);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      notifier.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      notifier.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(themeProvider);
    final lockState = ref.watch(appLockProvider);

    return MaterialApp.router(
      title: 'ClinicPilot',
      debugShowCheckedModeBanner: false,
      // Light only for now. The dark scheme and the palette machinery stay
      // wired up so restoring the choice is a settings change, not a rewrite.
      theme: AppTheme.build(Brightness.light, palette: prefs.palette),
      darkTheme: AppTheme.build(
        Brightness.dark,
        palette: prefs.palette,
        blackVariant: prefs.blackVariant,
      ),
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        if (lockState.isLocked) {
          return const LockScreen();
        }
        final appChild = child ?? const SizedBox.shrink();
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () {
              final nav = rootNavigatorKey.currentState;
              if (nav != null && nav.canPop()) {
                nav.maybePop();
              }
            },
          },
          child: Focus(
            autofocus: true,
            child: appChild,
          ),
        );
      },
    );
  }
}
