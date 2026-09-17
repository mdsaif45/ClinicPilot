# ADR-003: GoRouter StatefulShellRoute for Multi-Branch State Preservation & Clinic Scoping

## Metadata
- **Status**: Accepted
- **Date**: 2026-03-12
- **Deciders**: Client Navigation Team, Frontend Architecture Lead, Lead UX Designer
- **Consulted**: Clinical Workflow Working Group, Riverpod State Architecture Group
- **Informed**: Mobile Developers, QA Test Engineers

---

## Context
A clinical consultation involves continuous multitasking. A doctor operating ClinicPilot rarely follows a linear, single-screen path:
1. While taking an elaborate 17-section homeopathic case record on the **Patients** tab, the doctor may need to briefly switch to the **Inventory** tab to verify the current stock and expiry date of a remedy.
2. A walk-in patient at the clinic door may prompt a sudden switch to the **Finances** tab to settle a pending cash memo, after which the doctor immediately returns to the clinical case in progress.
3. The doctor may inspect daily clinic metrics on the **Dashboard**, tap into a patient profile, review growth charts in **Growth**, and return.

In traditional mobile routing architectures (such as standard Flutter `Navigator` or basic `ShellRoute` implementations), navigating between bottom navigation destinations destroys the existing widget hierarchy and rebuilds the target view from scratch. In a medical practice, this default behavior creates severe clinical friction:
- Unsaved draft inputs in case history or prescription forms are wiped out.
- Long patient list scroll offsets and active search query filters are lost.
- UI rebuilds trigger redundant database queries, causing subtle visual stutter.

Additionally, ClinicPilot supports multi-practice solo doctors who manage 2 or more physical clinics. The active clinic scope must be switchable directly from the global app shell (via the top-bar `ClinicSwitcher`) without causing the active tab trees to be dismantled and recreated.

Finally, the application must seamlessly scale across hardware form factors: presenting a compact bottom navigation bar on mobile phones and a persistent side `NavigationRail` on clinic tablets and desktop workstations.

---

## Options Considered

The client architecture team evaluated four navigation architectures:

| Evaluation Dimension | 1. GoRouter `StatefulShellRoute.indexedStack` (Chosen) | 2. GoRouter Basic `ShellRoute` | 3. Manual `IndexedStack` + Custom State | 4. `PageView` / Pure TabBarController |
| :--- | :--- | :--- | :--- | :--- |
| **Tab State Preservation** | Complete; separate `Navigator` per branch preserves scroll & forms | None; unmounts and remounts branch widgets on every switch | Complete, but must be manually maintained | Preserved in memory, but lacks URL routing |
| **Deep Linking & URLs** | Native support; each branch has distinct URI hierarchy (`/patients`, etc.) | Native support | Very difficult; requires custom URI parsing | Impossible without substantial custom routing glue |
| **Sub-Route Navigation** | Each branch manages independent back-button navigation stack | Shared single stack; back button can pop entire shell | Manual stack management; high bug surface | Back button cannot step backward inside individual tabs |
| **Clinic Switcher Decoupling** | Top bar lives in shell; changes propagate via Riverpod reactively | Shell rebuilds, resetting child states | Requires manual state propagation | Requires manual state propagation |
| **Responsive Adaptability** | Trivial switch between `NavigationRail` (tablet) and Bottom Bar | Trivial layout switch, but state is lost | Complex layout synchronization | Complex layout synchronization |

### Detailed Evaluation of Alternatives

- **Option 2: GoRouter Basic `ShellRoute`**
  - *Pros*: Simple declarative setup in GoRouter.
  - *Cons*: Tapping another bottom tab unmounts the current route. Returning to the previous tab reloads the entire screen from scratch, resetting scroll positions and losing active form inputs.
- **Option 3: Manual `IndexedStack` + Custom State**
  - *Pros*: Keeps all tabs alive in memory.
  - *Cons*: Bypasses declarative routing. Deep linking to specific patient IDs (`/patients/:id`) or nested growth analytics screens (`/growth/profit`) requires brittle ad-hoc parameter passing; breaks web browser back/forward buttons.
- **Option 4: `PageView` / Pure TabBarController**
  - *Pros*: Familiar standard Flutter component.
  - *Cons*: Cannot handle deep hierarchical navigation inside individual tabs; lacks integration with system URL history and state restoration engines.

---

## Decision

We chose **GoRouter's `StatefulShellRoute.indexedStack`** as the core navigation backbone for ClinicPilot, encapsulated within `lib/core/router/app_router.dart`.

1. **Five Independent Stateful Branches**:
   The primary application shell defines 5 persistent branches, each retaining its own nested navigation stack:
   - Branch 0: `/dashboard` (Practice summary, revenue metrics, appointment agenda)
   - Branch 1: `/patients` (Patient directory, follow-up recalls, footfall tracking)
   - Branch 2: `/inventory` (Drug inventory, stock balances, barcode scanning)
   - Branch 3: `/finances` (Cash memos, expense ledger, GST invoices)
   - Branch 4: `/growth` (Clinical analytics, profit summaries, camp manager, CRM)

2. **Responsive Shell Architecture (`ScaffoldWithNavBar`)**:
   - **Tablet / Desktop Form Factor (`context.isTablet`)**: Renders a vertical `NavigationRail` alongside the content pane, maximizing horizontal screen real estate.
   - **Mobile Form Factor**: Renders a floating, ergonomic bottom navigation bar (`FloatingBottomNavBar`) optimized for single-thumb navigation.

3. **Decoupled Top-Bar Header & Clinic Scoping**:
   The `ClinicSwitcher` and notification badges reside directly in the shell header above the `navigationShell`. When the doctor toggles between clinics, `activeClinicIdProvider` updates in Riverpod; active tab views reactively re-filter their data queries without unmounting the route or resetting scroll positions:
   ```dart
   // Navigation shell switching in app_router.dart
   navigationShell.goBranch(
     index,
     initialLocation: alwaysReset || index == navigationShell.currentIndex,
   );
   ```

4. **Root Navigator Separation (`rootNavigatorKey`)**:
   Modal dialogs, onboarding (`/onboarding`), settings (`/settings`), and full-screen clinical media viewports are bound to `rootNavigatorKey`, allowing them to cover the entire viewport and navigation shell when presented.

---

## Rationale

1. **Clinical Context Continuity**:
   Doctors frequently pause case taking to inspect drug inventory or past invoices. `StatefulShellRoute.indexedStack` ensures that when the doctor taps back to the Patients tab, their exact scroll position, active search filter, and partial form data remain intact.
2. **Predictable Hardware Back-Button Behavior**:
   On Android devices and desktop environments, pressing the back button behaves deterministically: it steps backward through the history of the *currently active branch* rather than unexpectedly exiting the application or jumping erratically across tabs.
3. **Reactive Multi-Tenancy without Shell Teardown**:
   Because the clinic switcher sits at the shell level and communicates via Riverpod state (`ActiveClinicIdNotifier`), changing the active clinic updates stream listeners in the current view instantaneously without triggering routing re-evaluations or tab rebuilds.
4. **Clean Deep Linking and Onboarding Interception**:
   GoRouter declarative redirects evaluate whether onboarding is complete before allowing navigation into the shell branches:
   ```dart
   redirect: (context, state) {
     final done = ref.read(onboardingCompleteProvider).value ?? isDone;
     if (!done && state.matchedLocation != '/onboarding') return '/onboarding';
     if (done && state.matchedLocation == '/onboarding') return '/dashboard';
     return null;
   },
   ```

---

## Consequences

### Positive Impacts
- **Zero Loss of In-Progress Clinical Data**: Doctors can jump between clinical, inventory, and financial tasks without fear of losing typed observations or form selections.
- **Sub-Millisecond Tab Switching**: Because inactive branch trees remain mounted in the widget hierarchy, switching tabs is purely a rendering visibility toggle with zero disk or network overhead.
- **Adaptive Ergonomics**: Automatically transitions between desktop/tablet `NavigationRail` and mobile bottom navigation based on breakpoint detection (`lib/core/design/breakpoints.dart`).
- **Declarative Route Structure**: Deep links to specific sub-features (e.g. `/patients/:id`, `/growth/journal`) work seamlessly with proper parameter extraction.

### Negative Trade-offs
- **Higher Base Memory Footprint**: Maintaining five mounted branch hierarchies keeps widgets and state listeners resident in memory.
- **Stale Data Risks on Inactive Tabs**: An inactive tab might hold cached data while mutations occur in another tab (e.g., dispensing medicine in Patients alters stock displayed in Inventory).

### Mitigation Strategies
- **Reactive Drift Streams**: Because views observe SQLite via Riverpod streams (`StreamProvider`), background database updates automatically refresh inactive tabs the moment they are brought back into view.
- **Aggressive Sub-Resource Disposal**: Heavy sub-screens (such as high-resolution patient case photo viewers) are pushed onto `rootNavigatorKey` rather than inside the persistent branch stack, ensuring memory is freed immediately upon dismissal.

---

## Reconsideration Trigger

This architectural decision shall be formally reopened if:
1. **Multi-Window Desktop Architecture**: ClinicPilot implements multi-window support on Windows/macOS (e.g., placing the Patients list on Monitor 1 and the Consultation Case Sheet on Monitor 2), requiring a window-aware multi-navigator architecture beyond standard single-window GoRouter shells.
2. **Severe Low-End Device Memory Pressure**: Memory profiling on low-end Android devices (<=2GB RAM) reveals out-of-memory (OOM) operating system terminations due to concurrent branch retention, necessitating dynamic branch teardown strategies.
