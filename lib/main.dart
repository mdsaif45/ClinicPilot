import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
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

class ClinicPilotApp extends ConsumerWidget {
  const ClinicPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(themeProvider);

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
    );
  }
}
