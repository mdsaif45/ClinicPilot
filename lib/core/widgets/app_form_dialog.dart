import 'package:flutter/material.dart';

import '../design/breakpoints.dart';
import '../design/tokens.dart';

/// Standard dialog for every form in the app.
/// Enforces consistent width, height constraints, and vertical content-to-action gutter.
class AppFormDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  static const double maxWidth = Breakpoints.maxFormWidth;

  const AppFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isShort = media.size.height < 600;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.lg,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        Spacing.xl,
        Spacing.md,
        Spacing.xl,
        Spacing
            .lg, // Enforce clean 16dp separation between bottom form field and action buttons
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.md,
      ),
      content: SizedBox(
        width: maxWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: media.size.height * (isShort ? 0.75 : 0.82),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: child,
          ),
        ),
      ),
      actions: actions,
    );
  }
}
