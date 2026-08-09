import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/period_provider.dart';
import '../../features/clinics/providers/clinic_provider.dart';
import '../../features/clinics/presentation/clinics_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/patients/presentation/patients_screen.dart';
import '../../features/cashmemo/presentation/cash_memo_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/growth/presentation/growth_screen.dart';
import '../../features/growth/presentation/clinic_comparison_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

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
    final activeClinic = ref.watch(activeClinicProvider);
    final periodState = ref.watch(periodProvider);
    final clinicsAsync = ref.watch(clinicsStreamProvider);
    final clinics = clinicsAsync.value ?? [];
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: activeClinic?.id,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: primaryColor,
              items: clinics.map((c) {
                final isSelected = c.id == activeClinic?.id;
                Color clinicColor;
                try {
                  clinicColor = Color(int.parse(c.colorHex.replaceAll('#', '0xFF')));
                } catch (_) {
                  clinicColor = Colors.teal;
                }

                return DropdownMenuItem<String>(
                  value: c.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: clinicColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        c.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.amber, size: 16),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(activeClinicIdProvider.notifier).setClinicId(val);
                }
              },
            ),
          ],
        ),
        actions: [
          // Period Filter Dropdown
          DropdownButton<PeriodFilter>(
            value: periodState.filter,
            underline: const SizedBox(),
            icon: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
            dropdownColor: primaryColor,
            items: PeriodFilter.values
                .map((pf) => DropdownMenuItem(
                      value: pf,
                      child: Text(
                        pf.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: pf == periodState.filter ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(periodProvider.notifier).setFilter(val);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Clinic Comparison',
            onPressed: () => context.push('/comparison'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        indicatorColor: primaryColor.withValues(alpha: 0.2),
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
            selectedIcon: Icon(Icons.dashboard, color: primaryColor),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: primaryColor),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: primaryColor),
            label: 'Cash Memo',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: primaryColor),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up, color: primaryColor),
            label: 'Growth',
          ),
        ],
      ),
    );
  }
}
