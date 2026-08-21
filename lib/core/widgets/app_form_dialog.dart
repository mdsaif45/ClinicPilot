import 'package:flutter/material.dart';

import '../design/breakpoints.dart';
import '../design/tokens.dart';

/// Standard dialog for every form in the app.
///
/// A bare AlertDialog sizes itself to its content, so each form ended up a
/// different width depending on its longest label. This fixes the width and
/// caps the height, which also stops a long form from running off the bottom
/// of a small screen.
class AppFormDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  /// Wide enough for a labelled field with a prefix icon, narrow enough to
  /// keep comfortable margins on a small phone.
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

    return AlertDialog(
      title: Text(title),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xl,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        Spacing.xl,
        Spacing.lg,
        Spacing.xl,
        0,
      ),
      content: SizedBox(
        width: maxWidth,
        child: ConstrainedBox(
          // Leaves room for the title and the action row on a short screen.
          constraints: BoxConstraints(
            maxHeight: media.size.height * (isShort ? 0.6 : 0.72),
          ),
          child: SingleChildScrollView(child: child),
        ),
      ),
      actions: actions,
    );
  }
}
