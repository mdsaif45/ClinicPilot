import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_pilot/core/widgets/floating_bottom_nav_bar.dart';

void main() {
  testWidgets('FloatingBottomNavBar renders items and responds to taps', (tester) async {
    int selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              bottomNavigationBar: FloatingBottomNavBar(
                selectedIndex: selected,
                onDestinationSelected: (index) {
                  setState(() {
                    selected = index;
                  });
                },
                destinations: const [
                  FloatingNavDestination(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: 'Dashboard',
                  ),
                  FloatingNavDestination(
                    icon: Icons.people_outline,
                    selectedIcon: Icons.people,
                    label: 'Patients',
                  ),
                  FloatingNavDestination(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'Settings',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Patients'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap on Patients
    await tester.tap(find.text('Patients'));
    await tester.pumpAndSettle();

    expect(selected, equals(1));
  });
}
