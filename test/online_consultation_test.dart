import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/services/master_disease_service.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/cashmemo/presentation/new_cash_memo_dialog.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/patients/presentation/add_patient_dialog.dart';
import 'package:clinic_pilot/features/patients/providers/patient_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Online & Remote Teleconsultation Tests', () {
    test(
      'registerPatient with online mode creates clinic_online and assigns ONL serial',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        final patient = await container
            .read(patientNotifierProvider.notifier)
            .registerPatient(
              name: 'Pooja Sharma',
              phone: '9876543210',
              age: 28,
              gender: 'Female',
              area: 'Patna, Bihar',
              primaryClinicId: 'clinic_online',
              serialNo: '',
              disease: 'Hair Fall & Alopecia',
              referralSource: 'Social Media (Instagram / Facebook)',
              consultationType: 'online',
              notes: 'Consultation Medium: WhatsApp Video Call',
            );

        expect(patient.name, equals('Pooja Sharma'));
        expect(patient.primaryClinicId, equals('clinic_online'));
        expect(patient.serialNo, startsWith('ONL-'));
        expect(patient.area, equals('Patna, Bihar'));

        // Verify clinic_online exists in DB with 0 rent
        final onlineClinic =
            await (db.select(db.clinics)
              ..where((c) => c.id.equals('clinic_online'))).getSingle();
        expect(onlineClinic.name, contains('Online'));
        expect(onlineClinic.monthlyRent, equals(0.0));

        // Verify visit is marked online
        final visits =
            await (db.select(db.visits)
              ..where((v) => v.patientId.equals(patient.id))).get();
        expect(visits.length, equals(1));
        expect(visits.first.consultationType, equals('online'));
        expect(visits.first.clinicId, equals('clinic_online'));
      },
    );

    test(
      'registerPatient works seamlessly when patient has no phone number (Google Meet / Privacy)',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);

        final patient = await container
            .read(patientNotifierProvider.notifier)
            .registerPatient(
              name: 'Google Meet Patient',
              phone: '', // No phone provided
              email: 'patient@meet.google.com',
              age: 35,
              gender: 'Male',
              primaryClinicId: 'clinic_online',
              serialNo: '',
              disease: 'Chronic Anxiety',
              referralSource: 'Google Search / Website',
              consultationType: 'online',
              notes: 'Consultation Medium: Google Meet / Zoom',
            );

        expect(patient.name, equals('Google Meet Patient'));
        expect(patient.phone, isEmpty);
        expect(patient.email, equals('patient@meet.google.com'));
        expect(patient.primaryClinicId, equals('clinic_online'));
        expect(patient.serialNo, startsWith('ONL-'));
      },
    );

    testWidgets(
      'AddPatientDialog renders consultation mode toggle and toggles online fields',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final clinic = Clinic(
          id: 'c1',
          name: 'City Care Clinic',
          address: 'Market Complex',
          monthlyRent: 5000.0,
          defaultConsultationFee: 300.0,
          openDays: '1,2,3,4,5,6',
          colorHex: '#0F5132',
          isActive: true,
          isDeleted: false,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              clinicsStreamProvider.overrideWith(
                (ref) => Stream.value([clinic]),
              ),
              masterDiseasesListProvider.overrideWith(
                (ref) => kDefaultHomeopathicDiseases,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Builder(
                builder:
                    (ctx) => Scaffold(
                      body: ElevatedButton(
                        onPressed:
                            () => showDialog(
                              context: ctx,
                              builder: (_) => const AddPatientDialog(),
                            ),
                        child: const Text('Open Dialog 1'),
                      ),
                    ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog 1'));
        await tester.pumpAndSettle();

        // Mode switcher is visible
        expect(
          find.text('In-Clinic Visit', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text('Online / Remote', skipOffstage: false),
          findsOneWidget,
        );

        // In-Clinic mode initially: Serial No. and Locality / Area are visible
        expect(find.text('Serial No.', skipOffstage: false), findsOneWidget);
        expect(
          find.text('Locality / Area', skipOffstage: false),
          findsOneWidget,
        );

        // Tap "Online / Remote"
        await tester.tap(find.text('Online / Remote'));
        await tester.pumpAndSettle();

        // Serial No. is hidden, Locality label changes to City / State / Location
        expect(find.text('Serial No.', skipOffstage: false), findsNothing);
        expect(
          find.text('City / State / Location', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text('Consultation Medium', skipOffstage: false),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'AddPatientDialog auto-selects Online / Remote when active clinic is clinic_online',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final clinic = Clinic(
          id: 'c1',
          name: 'City Care Clinic',
          address: 'Market Complex',
          monthlyRent: 5000.0,
          defaultConsultationFee: 300.0,
          openDays: '1,2,3,4,5,6',
          colorHex: '#0F5132',
          isActive: true,
          isDeleted: false,
          createdAt: DateTime.now(),
        );

        final onlineClinic = Clinic(
          id: 'clinic_online',
          name: 'Online / Teleconsultation',
          address: 'Digital Practice',
          monthlyRent: 0.0,
          defaultConsultationFee: 300.0,
          openDays: '1,2,3,4,5,6,7',
          colorHex: '#2563EB',
          isActive: true,
          isDeleted: false,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              clinicsStreamProvider.overrideWith(
                (ref) => Stream.value([clinic, onlineClinic]),
              ),
              masterDiseasesListProvider.overrideWith(
                (ref) => kDefaultHomeopathicDiseases,
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Builder(
                builder:
                    (ctx) => Scaffold(
                      body: ElevatedButton(
                        onPressed:
                            () => showDialog(
                              context: ctx,
                              builder:
                                  (_) => const AddPatientDialog(
                                    initialClinicId: 'clinic_online',
                                  ),
                            ),
                        child: const Text('Open Dialog 2'),
                      ),
                    ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog 2'));
        await tester.pumpAndSettle();

        // Automatically starts in Online / Remote mode
        expect(find.text('Serial No.', skipOffstage: false), findsNothing);
        expect(
          find.text('City / State / Location', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text('Consultation Medium', skipOffstage: false),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'NewCashMemoDialog pre-fills UPI and online clinic for online patient',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final onlineClinic = Clinic(
          id: 'clinic_online',
          name: 'Online / Teleconsultation',
          address: 'Digital Practice',
          monthlyRent: 0.0,
          defaultConsultationFee: 300.0,
          openDays: '1,2,3,4,5,6,7',
          colorHex: '#2563EB',
          isActive: true,
          isDeleted: false,
          createdAt: DateTime.now(),
        );

        final onlinePatient = Patient(
          id: 'p_onl',
          patientCode: 'P-2026-00001',
          serialNo: 'ONL-00001',
          name: 'Ayesha Khan',
          phone: '9876543210',
          primaryClinicId: 'clinic_online',
          gender: 'Female',
          age: 26,
          isDeleted: false,
          reviewGiven: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              clinicsStreamProvider.overrideWith(
                (ref) => Stream.value([onlineClinic]),
              ),
              patientsStreamProvider.overrideWith(
                (ref) => Stream.value([onlinePatient]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Builder(
                builder:
                    (ctx) => Scaffold(
                      body: ElevatedButton(
                        onPressed:
                            () => showDialog(
                              context: ctx,
                              builder:
                                  (_) => NewCashMemoDialog(
                                    initialPatient: onlinePatient,
                                  ),
                            ),
                        child: const Text('Open Dialog'),
                      ),
                    ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Create Cash Memo'), findsOneWidget);
        expect(find.textContaining('Ayesha Khan'), findsWidgets);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      },
    );
  });
}
