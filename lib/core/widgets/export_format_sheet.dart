import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// The file formats a per-list export can be saved as.
enum ExportFormat {
  csv('CSV', 'Opens in any spreadsheet app.', Icons.table_chart_outlined),
  xlsx(
    'Excel (XLSX)',
    'Keeps numbers as numbers, not text.',
    Icons.grid_on_outlined,
  ),
  pdf(
    'PDF',
    'A printable report, not for re-importing.',
    Icons.picture_as_pdf_outlined,
  );

  final String label;
  final String description;
  final IconData icon;

  const ExportFormat(this.label, this.description, this.icon);
}

/// User choices for an export operation, including security and privacy parameters.
class ExportOptions {
  final ExportFormat format;
  final bool isPasswordProtected;
  final String? password;
  final bool redactSensitiveData;

  const ExportOptions({
    required this.format,
    this.isPasswordProtected = false,
    this.password,
    this.redactSensitiveData = false,
  });
}

/// Modal bottom sheet for configuring export format, optional password encryption,
/// and privacy guard (de-identification) options.
class ExportOptionsSheet extends StatefulWidget {
  final bool hasPatientData;

  const ExportOptionsSheet({super.key, this.hasPatientData = true});

  @override
  State<ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<ExportOptionsSheet> {
  ExportFormat _selectedFormat = ExportFormat.xlsx;
  bool _isPasswordProtected = false;
  bool _redactSensitiveData = false;
  bool _obscurePassword = true;
  String? _passwordError;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _onExport() {
    if (_isPasswordProtected) {
      final pwd = _passwordController.text.trim();
      if (pwd.isEmpty) {
        setState(() {
          _passwordError = 'Enter a password to encrypt your export';
        });
        return;
      }
      if (pwd.length < 4) {
        setState(() {
          _passwordError = 'Password must be at least 4 characters';
        });
        return;
      }
    }

    Navigator.of(context).pop(
      ExportOptions(
        format: _selectedFormat,
        isPasswordProtected: _isPasswordProtected,
        password: _isPasswordProtected ? _passwordController.text.trim() : null,
        redactSensitiveData: _redactSensitiveData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.xl,
              Spacing.sm,
              Spacing.xl,
              Spacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Export Records',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),

                // Sensitive Data Notice
                if (widget.hasPatientData)
                  Container(
                    margin: const EdgeInsets.only(bottom: Spacing.md),
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.security, size: 20, color: scheme.primary),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Privacy Notice',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Exported records contain patient data. Use password protection or privacy redaction when sharing externally.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Format Picker Section
                Text(
                  'Choose Format',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    for (final format in ExportFormat.values)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap:
                                () => setState(() => _selectedFormat = format),
                            borderRadius: BorderRadius.circular(Radii.md),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.md,
                                horizontal: Spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _selectedFormat == format
                                        ? scheme.primaryContainer
                                        : scheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(Radii.md),
                                border: Border.all(
                                  color:
                                      _selectedFormat == format
                                          ? scheme.primary
                                          : scheme.outlineVariant.withValues(
                                            alpha: 0.4,
                                          ),
                                  width: _selectedFormat == format ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    format.icon,
                                    size: 22,
                                    color:
                                        _selectedFormat == format
                                            ? scheme.onPrimaryContainer
                                            : scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    format.name.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color:
                                          _selectedFormat == format
                                              ? scheme.onPrimaryContainer
                                              : scheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.md),

                const Divider(),
                const SizedBox(height: Spacing.xs),

                // Privacy Guard (De-Identification) Toggle
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.primary,
                    child: const Icon(Icons.masks_outlined, size: 20),
                  ),
                  title: const Text(
                    'Privacy Guard (De-Identify)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Mask phone numbers (e.g. 98765•••••) and redact confidential notes for accountants or external audits.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  value: _redactSensitiveData,
                  onChanged: (val) {
                    setState(() => _redactSensitiveData = val);
                  },
                ),

                const SizedBox(height: Spacing.xs),

                // Password Protection Toggle
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.surfaceContainerHighest,
                    foregroundColor: scheme.primary,
                    child: const Icon(Icons.lock_outline, size: 20),
                  ),
                  title: const Text(
                    'Password Protection',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Encapsulate file inside a password-protected ZIP archive (opens on Windows, Mac, Android, iOS).',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  value: _isPasswordProtected,
                  onChanged: (val) {
                    setState(() {
                      _isPasswordProtected = val;
                      _passwordError = null;
                    });
                  },
                ),

                // Password Input (revealed when switch is ON)
                if (_isPasswordProtected) ...[
                  const SizedBox(height: Spacing.sm),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Set Archive Password *',
                      hintText: 'e.g. Clinic@2026',
                      prefixIcon: const Icon(Icons.key_outlined, size: 20),
                      errorText: _passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),
                ],

                const SizedBox(height: Spacing.lg),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        icon: Icon(
                          _isPasswordProtected
                              ? Icons.lock_outline
                              : Icons.download_outlined,
                          size: 18,
                        ),
                        label: Text(
                          _isPasswordProtected
                              ? 'Encrypt & Save'
                              : 'Export File',
                        ),
                        onPressed: _onExport,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet offering comprehensive export configuration (format, password, privacy).
Future<ExportOptions?> pickExportOptions(
  BuildContext context, {
  bool hasPatientData = true,
}) {
  return showModalBottomSheet<ExportOptions>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => ExportOptionsSheet(hasPatientData: hasPatientData),
  );
}

/// Backward-compatible picker returning only [ExportFormat].
Future<ExportFormat?> pickExportFormat(BuildContext context) async {
  final options = await pickExportOptions(context, hasPatientData: false);
  return options?.format;
}
