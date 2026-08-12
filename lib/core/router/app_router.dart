import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/tokens.dart';
import '../widgets/clinic_switcher.dart';
import '../../features/clinics/presentation/clinics_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/finances/presentation/finances_screen.dart';
import '../../features/patients/presentation/patients_screen.dart';
import '../../features/patients/presentation/recall_screen.dart';
import '../../features/growth/presentation/growth_screen.dart';
import '../../features/growth/presentation/growth_hub_screen.dart';
import '../../features/growth/presentation/profit_summary_screen.dart';
import '../../features/growth/presentation/referral_source_screen.dart';
import '../../features/growth/presentation/clinic_comparison_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/providers/update_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/patients',
                builder: (context, state) => const PatientsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finances',
                builder: (context, state) => const FinancesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/growth',
                builder: (context, state) => const GrowthHubScreen(),
                routes: [
                  GoRoute(
                    path: 'overview',
                    builder: (context, state) => const GrowthScreen(),
                  ),
                  GoRoute(
                    path: 'profit',
                    builder: (context, state) => const ProfitSummaryScreen(),
                  ),
                  GoRoute(
                    path: 'referral',
                    builder: (context, state) => const ReferralSourceScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/clinics',
        builder: (context, state) => const ClinicsScreen(),
      ),
      GoRoute(
        path: '/comparison',
        builder: (context, state) => const ClinicComparisonScreen(),
      ),
      GoRoute(
        path: '/recall',
        builder: (context, state) => const RecallScreen(),
      ),
    ],
  );
});

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  /// Dashboard is the only tab with an app bar.
  ///
  /// Every other tab names itself in the bottom navigation, so a bar on top
  /// repeated that and cost a row of vertical space. Dashboard keeps one
  /// because the active clinic scopes its figures.
  static const _dashboardIndex = 0;
  static const _growthIndex = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDashboard = navigationShell.currentIndex == _dashboardIndex;

    // Settings is a tab now, so the update badge rides on it rather than on an
    // app bar icon that only existed on one screen.
    final updateWaiting = ref.watch(availableUpdateProvider).maybeWhen(
          data: (u) => u != null && !ref.watch(updateBadgeDismissedProvider),
          orElse: () => false,
        );

    return Scaffold(
      appBar: isDashboard
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 1,
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              titleSpacing: Spacing.sm,
              title: const ClinicSwitcher(),
            )
          : null,
      body: SafeArea(top: !isDashboard, bottom: false, child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          // Growth is a menu of sub-screens. A shell branch normally restores
          // whichever sub-route was last open, which would mean that once a
          // section had been visited the tab could never return to its menu.
          final alwaysReset = index == _growthIndex;
          navigationShell.goBranch(
            index,
            initialLocation:
                alwaysReset || index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finances',
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Growth',
          ),
          NavigationDestination(
            icon: updateWaiting
                ? Badge(
                    smallSize: 8,
                    backgroundColor: scheme.tertiary,
                    child: const Icon(Icons.settings_outlined),
                  )
                : const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
