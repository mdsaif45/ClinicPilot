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
                builder: (context, state) => const GrowthScreen(),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        titleSpacing: Spacing.sm,
        // Only the active clinic lives here now. The period filter moved onto
        // the analytics screens it actually scopes, and clinic comparison sits
        // with the other growth views.
        title: const ClinicSwitcher(),
        actions: [
          IconButton(
            icon: ref.watch(availableUpdateProvider).when(
                  data: (update) =>
                      (update != null && !ref.watch(updateBadgeDismissedProvider))
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
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
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
