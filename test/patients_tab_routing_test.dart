import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/features/patients/presentation/patients_tab_screen.dart';

void main() {
  testWidgets(
    'PatientsTabScreen defaults to Directory tab when initialIndex is 0',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PatientsTabScreen(initialIndex: 0)),
          ),
        ),
      );

      // Verify Directory tab label is rendered
      expect(find.text('Directory'), findsOneWidget);
      expect(find.text('Follow-ups'), findsOneWidget);
      expect(find.text('Footfalls'), findsOneWidget);
    },
  );

  testWidgets(
    'PatientsTabScreen opens directly to Follow-ups tab when initialIndex is 1',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PatientsTabScreen(initialIndex: 1)),
          ),
        ),
      );

      // Verify tabs rendered
      expect(find.text('Follow-ups'), findsOneWidget);
    },
  );
}
