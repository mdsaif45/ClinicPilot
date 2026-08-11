import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/tokens.dart';
import '../widgets/clinic_switcher.dart';
import '../../features/clinics/presentation/clinics_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/patients/presentation/patients_screen.dart';
import '../../features/cashmemo/presentation/cash_memo_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
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
                path: '/cashmemo',
                builder: (context, state) => const CashMemoScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpensesScreen(),
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
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
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
  /// because the active clinic scopes its figures and it is the landing tab,
  /// which makes it the natural home for the settings entry point.
  static const _dashboardIndex = 0;
  static const _growthIndex = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDashboard = navigationShell.currentIndex == _dashboardIndex;

    return Scaffold(
      appBar: isDashboard
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 1,
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              titleSpacing: Spacing.sm,
              title: const ClinicSwitcher(),
              actions: [
                IconButton(
                  icon: ref.watch(availableUpdateProvider).when(
                        data: (update) => (update != null &&
                                !ref.watch(updateBadgeDismissedProvider))
                            ? Badge(
                                smallSize: 8,
                                backgroundColor: scheme.tertiary,
                                child: const Icon(Icons.settings_outlined),
                              )
                            : const Icon(Icons.settings_outlined),
                        loading: () => const Icon(Icons.settings_outlined),
                        error: (_, __) => const Icon(Icons.settings_outlined),
                      ),
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
              ],
            )
          : null,
      // Tabs without an app bar would otherwise start under the status bar.
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
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Cash Memo',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Growth',
          ),
        ],
      ),
    );
  }
}
