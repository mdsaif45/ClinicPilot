import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_palette.dart';
import '../../../core/design/tokens.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../providers/theme_provider.dart';

/// Display group: theme mode, true-black variant, colour palette, language.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  /// Flip to true to expose theme mode, the black variant and the palette
  /// picker again. Everything behind them is still wired up.
  static const bool _showThemeControls = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    // The app ships light only for now, so theme mode, the true-black variant
    // and the palette picker are all hidden. Every picker and its persistence
    // is left intact, so re-exposing them is a flag flip rather than a
    // rebuild.
    final showThemeControls = _showThemeControls;
    final showPalette = _showThemeControls;
    final isDark =
        showThemeControls && Theme.of(context).brightness == Brightness.dark;

    return SettingsGroup(
      title: 'Display',
      children: [
        if (showThemeControls)
          AppListTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: prefs.mode.label,
            onTap:
                () => _pick<AppThemeMode>(
                  context: context,
                  title: 'Theme',
                  values: AppThemeMode.values,
                  current: prefs.mode,
                  labelOf: (m) => m.label,
                  onSelected: notifier.setMode,
                ),
          ),
        // Only meaningful while a dark scheme is actually showing, so it is
        // hidden in light mode rather than shown as a dead toggle.
        if (isDark)
          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: const Text('Black theme variant'),
            subtitle: const Text('Pure black surfaces, better on OLED'),
            value: prefs.blackVariant,
            onChanged: notifier.setBlackVariant,
          ),
        if (showPalette)
          AppListTile(
            icon: Icons.format_paint_outlined,
            title: 'Color palette',
            subtitle: prefs.palette.label,
            trailing: _Swatch(color: prefs.palette.swatch),
            onTap: () => _pickPalette(context, prefs.palette, notifier),
          ),
        AppListTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'English',
          onTap: () => _showLanguageDialog(context),
        ),
      ],
    );
  }

  Future<void> _pick<T>({
    required BuildContext context,
    required String title,
    required List<T> values,
    required T current,
    required String Function(T) labelOf,
    required void Function(T) onSelected,
  }) async {
    final chosen = await showDialog<T>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: Text(title),
            children: [
              for (final v in values)
                RadioListTile<T>(
                  value: v,
                  groupValue: current,
                  title: Text(labelOf(v)),
                  onChanged: (val) => Navigator.of(ctx).pop(val),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: Spacing.lg),
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
    );
    if (chosen != null) onSelected(chosen);
  }

  Future<void> _pickPalette(
    BuildContext context,
    AppPalette current,
    ThemeNotifier notifier,
  ) async {
    final chosen = await showDialog<AppPalette>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: const Text('Color palette'),
            children: [
              for (final p in AppPalette.values)
                RadioListTile<AppPalette>(
                  value: p,
                  groupValue: current,
                  title: Text(p.label),
                  subtitle: Text(p.description),
                  secondary: _Swatch(color: p.swatch),
                  onChanged: (val) => Navigator.of(ctx).pop(val),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: Spacing.lg),
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
    );
    if (chosen != null) notifier.setPalette(chosen);
  }

  Future<void> _showLanguageDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: const Text('Language'),
            children: [
              RadioListTile<String>(
                value: 'en',
                groupValue: 'en',
                title: const Text('English'),
                onChanged: (_) => Navigator.of(ctx).pop(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xl,
                  Spacing.sm,
                  Spacing.xl,
                  0,
                ),
                child: Text(
                  'More languages will appear here once translations exist.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: Spacing.lg),
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;

  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}
