import 'package:flutter/material.dart';
import '../design/tokens.dart';

/// Layered vector illustration for empty states.
///
/// Features a subtle dual-layer glowing halo, floating micro-badges,
/// and a primary focal icon themed dynamically to the active palette.
class EmptyIllustration extends StatelessWidget {
  final IconData primaryIcon;
  final IconData? secondaryIcon;
  final Color? accentColor;
  final double size;

  const EmptyIllustration({
    super.key,
    required this.primaryIcon,
    this.secondaryIcon,
    this.accentColor,
    this.size = 110,
  });

  /// Illustration for empty patients list or patient search.
  const factory EmptyIllustration.patients({double size}) =
      _PatientsEmptyIllustration;

  /// Illustration for empty cash memos list.
  const factory EmptyIllustration.cashMemos({double size}) =
      _CashMemosEmptyIllustration;

  /// Illustration for empty expenses list.
  const factory EmptyIllustration.expenses({double size}) =
      _ExpensesEmptyIllustration;

  /// Illustration for empty growth & analytics reports.
  const factory EmptyIllustration.growth({double size}) =
      _GrowthEmptyIllustration;

  /// Illustration for empty recall list.
  const factory EmptyIllustration.recall({double size}) =
      _RecallEmptyIllustration;

  /// Illustration for empty clinics list.
  const factory EmptyIllustration.clinics({double size}) =
      _ClinicsEmptyIllustration;

  /// Illustration for empty search results.
  const factory EmptyIllustration.search({double size}) =
      _SearchEmptyIllustration;

  /// Illustration for generic icon.
  const factory EmptyIllustration.generic({
    required IconData icon,
    IconData? badgeIcon,
    Color? accentColor,
    double size,
  }) = _GenericEmptyIllustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primaryAccent = accentColor ?? scheme.primary;
    final secondaryAccent = scheme.tertiary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient glow ring
          Container(
            width: size * 0.95,
            height: size * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryAccent.withValues(alpha: 0.14),
                  primaryAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Inner tinted container
          Container(
            width: size * 0.68,
            height: size * 0.68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
              border: Border.all(
                color: primaryAccent.withValues(alpha: 0.22),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryAccent.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(primaryIcon, size: size * 0.34, color: primaryAccent),
            ),
          ),
          // Floating secondary badge if present
          if (secondaryIcon != null)
            Positioned(
              right: size * 0.12,
              bottom: size * 0.12,
              child: Container(
                padding: const EdgeInsets.all(Spacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surface,
                  border: Border.all(
                    color: secondaryAccent.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  secondaryIcon,
                  size: size * 0.18,
                  color: secondaryAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PatientsEmptyIllustration extends EmptyIllustration {
  const _PatientsEmptyIllustration({super.size = 110})
    : super(
        primaryIcon: Icons.person_search_outlined,
        secondaryIcon: Icons.health_and_safety_outlined,
      );
}

class _CashMemosEmptyIllustration extends EmptyIllustration {
  const _CashMemosEmptyIllustration({super.size = 110})
    : super(
        primaryIcon: Icons.receipt_long_outlined,
        secondaryIcon: Icons.currency_rupee,
      );
}

class _ExpensesEmptyIllustration extends EmptyIllustration {
  const _ExpensesEmptyIllustration({super.size = 110})
    : super(
        primaryIcon: Icons.account_balance_wallet_outlined,
        secondaryIcon: Icons.trending_down_outlined,
      );
}

class _GrowthEmptyIllustration extends EmptyIllustration {
  const _GrowthEmptyIllustration({super.size = 110})
    : super(
        primaryIcon: Icons.insights_outlined,
        secondaryIcon: Icons.auto_graph_outlined,
      );
}

class _RecallEmptyIllustration extends EmptyIllustration {
  const _RecallEmptyIllustration({super.size = 110})
    : super(
        primaryIcon: Icons.event_repeat_outlined,
        secondaryIcon: Icons.notifications_active_outlined,
      );
}

class _ClinicsEmptyIllustration extends EmptyIllustration {
  const _ClinicsEmptyIllustration({super.size = 110})
    : super(
        primaryIcon: Icons.local_hospital_outlined,
        secondaryIcon: Icons.location_city_outlined,
      );
}

class _SearchEmptyIllustration extends EmptyIllustration {
  const _SearchEmptyIllustration({super.size = 110})
    : super(
        primaryIcon: Icons.search_off_outlined,
        secondaryIcon: Icons.manage_search_outlined,
      );
}

class _GenericEmptyIllustration extends EmptyIllustration {
  const _GenericEmptyIllustration({
    required IconData icon,
    IconData? badgeIcon,
    super.accentColor,
    super.size = 110,
  }) : super(primaryIcon: icon, secondaryIcon: badgeIcon);
}
