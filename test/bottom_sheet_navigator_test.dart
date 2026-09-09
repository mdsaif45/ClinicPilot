import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/picker_field.dart';

void main() {
  group('Modal Bottom Sheet Root Navigator Tests', () {
    testWidgets(
      'PickerField pushes bottom sheet to root navigator over nested bottom bar',
      (tester) async {
        final rootNavKey = GlobalKey<NavigatorState>();
        final nestedNavKey = GlobalKey<NavigatorState>();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              navigatorKey: rootNavKey,
              theme: AppTheme.lightTheme,
              home: Scaffold(
                bottomNavigationBar: Container(
                  key: const ValueKey('floating_bottom_bar'),
                  height: 60,
                  color: Colors.black,
                  child: const Center(child: Text('Floating Bar')),
                ),
                body: Navigator(
                  key: nestedNavKey,
                  onGenerateRoute:
                      (settings) => MaterialPageRoute(
                        builder:
                            (nestedContext) => Scaffold(
                              body: Center(
                                child: PickerField<String>(
                                  label: 'Select Option',
                                  value: 'Option A',
                                  options: const [
                                    PickerOption(
                                      value: 'Option A',
                                      label: 'Option A',
                                    ),
                                    PickerOption(
                                      value: 'Option B',
                                      label: 'Option B',
                                    ),
                                  ],
                                  onChanged: (_) {},
                                ),
                              ),
                            ),
                      ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Select Option'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('floating_bottom_bar')),
          findsOneWidget,
        );

        // Tap to open bottom sheet (InkWell contains selected label)
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        // The sheet should be opened
        expect(find.text('Option B'), findsOneWidget);

        // The ModalBottomSheetRoute must be on rootNavKey, NOT on nestedNavKey
        final rootNav = rootNavKey.currentState!;
        final nestedNav = nestedNavKey.currentState!;

        // Check that rootNav has more than 1 route (meaning the modal route was pushed to root)
        bool rootHasModal = false;
        rootNav.popUntil((route) {
          if (route is ModalBottomSheetRoute) {
            rootHasModal = true;
          }
          return true; // don't actually pop
        });

        // Nested nav should still only have its single base route
        bool nestedHasModal = false;
        nestedNav.popUntil((route) {
          if (route is ModalBottomSheetRoute) {
            nestedHasModal = true;
          }
          return true;
        });

        expect(
          rootHasModal,
          isTrue,
          reason: 'ModalBottomSheet must be pushed to root navigator',
        );
        expect(
          nestedHasModal,
          isFalse,
          reason: 'ModalBottomSheet must NOT be trapped in nested navigator',
        );
      },
    );
  });
}
