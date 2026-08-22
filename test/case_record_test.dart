import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinical/models/case_record_models.dart';
import 'package:clinic_pilot/features/clinical/presentation/master_case_taking_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MasterCaseRecordData & Clinical Models Unit Tests', () {
    test('serializes and deserializes ChiefComplaintDetail properly', () {
      const complaint = ChiefComplaintDetail(
        complaint: 'Right Knee Joint Pain',
        location: 'Right knee joint extending to calf',
        sensation: 'Drawing, stitching pain',
        modalitiesAgg: 'Cold air, morning, walking',
        modalitiesAmel: 'Warm application, rest',
        concomitants: 'Gastric flatulence',
        duration: '6 months',
        severity: 'Severe',
      );

      final json = complaint.toJson();
      final parsed = ChiefComplaintDetail.fromJson(json);

      expect(parsed.complaint, equals('Right Knee Joint Pain'));
      expect(parsed.location, equals('Right knee joint extending to calf'));
      expect(parsed.modalitiesAgg, equals('Cold air, morning, walking'));
      expect(parsed.severity, equals('Severe'));
    });

    test('serializes and deserializes PhysicalGenerals and MiasmaticAnalysis', () {
      const physical = PhysicalGenerals(
        thermal: 'Hot',
        thirst: 'Profuse, drinks large quantities',
        appetite: 'Good, cannot tolerate hunger',
        cravings: 'Sweets, fresh fish, tea',
        perspiration: 'Profuse, offensive on exertion',
        sleep: 'Disturbed due to flatulence',
      );

      final pJson = physical.toJson();
      final pParsed = PhysicalGenerals.fromJson(pJson);

      expect(pParsed.thermal, equals('Hot'));
      expect(pParsed.cravings, contains('Sweets'));

      const miasm = MiasmaticAnalysis(
        dominantMiasm: 'Sycotic',
        psoricFeatures: 'Burning eyes, itching',
        sycoticFeatures: 'Warts on tongue and forehead',
      );

      final mJson = miasm.toJson();
      final mParsed = MiasmaticAnalysis.fromJson(mJson);

      expect(mParsed.dominantMiasm, equals('Sycotic'));
      expect(mParsed.sycoticFeatures, contains('Warts'));
    });
  });

  group('MasterCaseTakingScreen Widget Tests', () {
    testWidgets('renders all major clinical case taking sections', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final patient = Patient(
        id: 'p_test_1',
        patientCode: 'P-2026-00001',
        name: 'Demo Patient',
        phone: '9876543210',
        age: 45,
        gender: 'Male',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '001',
        referralSource: 'Direct / Walk-in',
        reviewGiven: false,
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: MasterCaseTakingScreen(patient: patient),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Complete Case Taking'), findsWidgets);
      expect(find.text('1. Patient Identification'), findsOneWidget);

      final scrollable = find.byType(Scrollable).first;

      final physicalFinder = find.text('8. Physical Generals – Complete');
      await tester.scrollUntilVisible(physicalFinder, 300, scrollable: scrollable);
      expect(physicalFinder, findsOneWidget);

      final mentalFinder = find.text('9. Mental Generals – Complete');
      await tester.scrollUntilVisible(mentalFinder, 300, scrollable: scrollable);
      expect(mentalFinder, findsOneWidget);

      final miasmFinder = find.text('12. Miasmatic Analysis');
      await tester.scrollUntilVisible(miasmFinder, 300, scrollable: scrollable);
      expect(miasmFinder, findsOneWidget);

      final saveButtonFinder = find.text('Save Master Case Record');
      await tester.scrollUntilVisible(saveButtonFinder, 300, scrollable: scrollable);
      expect(saveButtonFinder, findsOneWidget);
    });
  });
}
