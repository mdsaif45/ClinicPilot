import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/breakpoints.dart';
import '../design/tokens.dart';
import '../services/app_haptics.dart';
import '../widgets/animated_nav_icon.dart';
import '../widgets/clinic_switcher.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import '../../features/clinics/presentation/clinics_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/finances/presentation/finances_screen.dart';
import '../../features/patients/presentation/patients_tab_screen.dart';
import '../../features/patients/presentation/patient_profile_screen.dart';
import '../../features/patients/presentation/recall_screen.dart';
import '../../features/growth/presentation/growth_screen.dart';
import '../../features/growth/presentation/growth_hub_screen.dart';
import '../../features/growth/presentation/profit_summary_screen.dart';
import '../../features/growth/presentation/referral_source_screen.dart';
import '../../features/growth/presentation/clinic_comparison_screen.dart';
import '../../features/growth/presentation/camp_manager_screen.dart';
import '../../features/growth/presentation/disease_analytics_screen.dart';
import '../../features/growth/presentation/referral_crm_screen.dart';
import '../../features/activity/presentation/practice_activity_screen.dart';
import '../../features/activity/presentation/practice_journal_screen.dart';
import '../../features/settings/presentation/doctor_profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/dashboard/presentation/widgets/notification_center_sheet.dart';
import '../../features/patients/providers/recall_provider.dart';
import '../../features/settings/presentation/app_version_screen.dart';
import '../../features/settings/providers/release_provider.dart';
import '../../features/settings/providers/update_provider.dart';
import '../services/update_service.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // The redirect reads onboardingCompleteProvider, which resolves
  // asynchronously. Without this the first evaluation sees null, lets the
  // dashboard through, and never re-runs.
  ref.listen(onboardingCompleteProvider, (_, __) {});

  bool isDone = false;
  try {
    if (Hive.isBoxOpen('settings')) {
      isDone = Hive.box('settings').get(kOnboardingDoneKey, defaultValue: false) == true;
    }
  } catch (_) {}

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: _ProviderRefresh(ref, onboardingCompleteProvider),
    initialLocation: isDone ? '/dashboard' : '/onboarding',
    // First run has no clinic to attribute anything to, so the app cannot do
    // its job until setup is finished.
    redirect: (context, state) {
      final done = ref.read(onboardingCompleteProvider).value ?? isDone;
      if (!done && state.matchedLocation != '/onboarding') return '/onboarding';
      if (done && state.matchedLocation == '/onboarding') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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
                builder: (context, state) => const PatientsTabScreen(),
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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const DoctorProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/growth/overview',
        builder: (context, state) => const GrowthScreen(),
      ),
      GoRoute(
        path: '/growth/profit',
        builder: (context, state) => const ProfitSummaryScreen(),
      ),
      GoRoute(
        path: '/growth/referral',
        builder: (context, state) => const ReferralSourceScreen(),
      ),
      GoRoute(
        path: '/growth/camps',
        builder: (context, state) => const CampManagerScreen(),
      ),
      GoRoute(
        path: '/growth/diseases',
        builder: (context, state) => const DiseaseAnalyticsScreen(),
      ),
      GoRoute(
        path: '/growth/referral-crm',
        builder: (context, state) => const ReferralCrmScreen(),
      ),
      GoRoute(
        path: '/growth/activity',
        builder: (context, state) => const PracticeActivityScreen(),
      ),
      GoRoute(
        path: '/growth/journal',
        builder: (context, state) => const PracticeJournalScreen(),
      ),
      GoRoute(
        path: '/patients/:id',
        builder: (context, state) {
          final patientId = state.pathParameters['id']!;
          return PatientProfileLoaderScreen(patientId: patientId);
        },
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

/// Offers the update once, with an explicit way to stop being asked.
///
/// "Later" records the version so it never prompts again; the release stays
/// reachable from App Version whenever the doctor chooses. A prompt that
/// returns every launch trains people to dismiss it without reading.
Future<void> _showUpdatePrompt(
  BuildContext context,
  WidgetRef ref,
  AppRelease release,
) async {
  final notifier = ref.read(updatePromptProvider.notifier);

  final proceed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.system_update),
      title: Text('Version ${release.version} available'),
      content: Text(
        'You are running v${ref.read(runningVersionProvider).value ?? ''}. '
        'Updating does not affect your clinic data.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );

  if (proceed == true) {
    notifier.dismiss();
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AppVersionScreen()),
      );
    }
  } else {
    await notifier.skip(release);
  }
}

class _NavDestination {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination(this.index, this.icon, this.selectedIcon, this.label);
}

const _destinations = [
  _NavDestination(0, Icons.grid_view_outlined, Icons.grid_view_outlined, 'Dashboard'),
  _NavDestination(1, Icons.people_alt_outlined, Icons.people_alt_outlined, 'Patients'),
  _NavDestination(2, Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet_outlined, 'Finances'),
  _NavDestination(3, Icons.insights_outlined, Icons.insights_outlined, 'Growth'),
  _NavDestination(4, Icons.settings_outlined, Icons.settings_outlined, 'Settings'),
];

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  void initState() {
    super.initState();
    // Runs once per launch; the notifier itself decides whether this version
    // has already been declined.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updatePromptProvider.notifier).evaluate();
    });
  }

  /// Dashboard is the only tab with an app bar.
  ///
  /// Every other tab names itself in the bottom navigation, so a bar on top
  /// repeated that and cost a row of vertical space. Dashboard keeps one
  /// because the active clinic scopes its figures.
  static const _dashboardIndex = 0;
  static const _growthIndex = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDashboard = navigationShell.currentIndex == _dashboardIndex;

    // Prompt once per new version, after the first frame so it never races
    // the shell into existence.
    ref.listen(updatePromptProvider, (previous, next) {
      if (next != null && previous == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _showUpdatePrompt(context, ref, next);
        });
      }
    });

    // Settings is a tab now, so the update badge rides on it rather than on an
    // app bar icon that only existed on one screen.
    final updateWaiting = ref.watch(availableUpdateProvider).maybeWhen(
          data: (u) => u != null && !ref.watch(updateBadgeDismissedProvider),
          orElse: () => false,
        );

    final isTablet = context.isTablet;

    if (isTablet) {
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: navigationShell.currentIndex.clamp(0, 4),
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (index) {
                  final alwaysReset = index == _growthIndex || index == 4;
                  navigationShell.goBranch(
                    index,
                    initialLocation:
                        alwaysReset || index == navigationShell.currentIndex,
                  );
                },
                destinations: [
                  for (final d in _destinations)
                    NavigationRailDestination(
                      icon: d.index == 4 && updateWaiting
                          ? Badge(
                              smallSize: 8,
                              backgroundColor: scheme.tertiary,
                              child: AnimatedNavIcon(
                                icon: d.icon,
                                selectedIcon: d.selectedIcon,
                                selected:
                                    navigationShell.currentIndex == d.index,
                              ),
                            )
                          : AnimatedNavIcon(
                              icon: d.icon,
                              selectedIcon: d.selectedIcon,
                              selected:
                                  navigationShell.currentIndex == d.index,
                            ),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isDashboard)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          Spacing.lg,
                          Spacing.md,
                          Spacing.lg,
                          0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ClinicSwitcher(),
                        ),
                      ),
                    Expanded(
                      child: ResponsiveContent(
                        child: navigationShell,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final recallLists = ref.watch(recallListProvider).value;
    final overdueCount = recallLists == null
        ? 0
        : recallLists.overdue.length + recallLists.lapsed.length;
    final hasUnreadAlerts = overdueCount > 0 || updateWaiting;

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
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none_outlined, size: 24),
                        if (hasUnreadAlerts)
                          Positioned(
                            right: 1,
                            top: 1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: scheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Notifications',
                    onPressed: () {
                      AppHaptics.selection();
                      NotificationCenterSheet.show(context);
                    },
                  ),
                ),
              ],
            )
          : null,
      body: SafeArea(top: !isDashboard, bottom: false, child: navigationShell),
      bottomNavigationBar: FloatingBottomNavBar(
        selectedIndex: navigationShell.currentIndex.clamp(0, 4),
        onDestinationSelected: (index) {
          // Growth is a menu of sub-screens. A shell branch normally restores
          // whichever sub-route was last open, which would mean that once a
          // section had been visited the tab could never return to its menu.
          final alwaysReset = index == _growthIndex || index == 4;
          navigationShell.goBranch(
            index,
            initialLocation:
                alwaysReset || index == navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final d in _destinations)
            FloatingNavDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon,
              label: d.label,
              badge: d.index == 4 && updateWaiting
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: scheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

/// Rebuilds routes when a provider emits, so an async redirect re-evaluates.
class _ProviderRefresh extends ChangeNotifier {
  _ProviderRefresh(Ref ref, ProviderListenable<Object?> provider) {
    ref.listen(provider, (_, __) => notifyListeners());
  }
}
