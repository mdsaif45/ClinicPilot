import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinics/providers/clinic_provider.dart';
import 'package:clinic_pilot/features/patients/presentation/footfalls_screen.dart';
import 'package:clinic_pilot/features/patients/providers/footfall_provider.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Footfalls / Walk-in Lead Tracking Unit & Provider Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      // Seed clinic
      await db
          .into(db.clinics)
          .insert(ClinicsCompanion.insert(id: 'c1', name: 'Main Clinic'));
      // Seed patient
      await db
          .into(db.patients)
          .insert(
            PatientsCompanion.insert(
              id: 'p1',
              patientCode: const drift.Value('P-2026-00001'),
              serialNo: const drift.Value('1'),
              primaryClinicId: const drift.Value('c1'),
              name: 'Converted Patient',
              phone: '9876543210',
              age: 28,
              gender: 'Male',
              primaryDisease: const drift.Value('Asthma'),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('logs walk-in footfall with normalized disease name', () async {
      final notifier = FootfallNotifier(db);
      final id = await notifier.addFootfall(
        clinicId: 'c1',
        name: 'Walk-in Visitor',
        phone: '9988776655',
        disease: 'allergic rhinitis',
        notes: 'Inquired about medicine cost',
      );

      final footfalls = await db.select(db.footfalls).get();
      expect(footfalls.length, equals(1));
      expect(footfalls.first.id, equals(id));
      expect(footfalls.first.name, equals('Walk-in Visitor'));
      expect(footfalls.first.disease, equals('Allergic Rhinitis'));
      expect(footfalls.first.convertedPatientId, isNull);
    });

    test('converts footfall to registered patient', () async {
      final notifier = FootfallNotifier(db);
      final id = await notifier.addFootfall(
        clinicId: 'c1',
        name: 'Walk-in Visitor',
        phone: '9988776655',
      );

      await notifier.convertFootfall(footfallId: id, patientId: 'p1');

      final footfall =
          await (db.select(db.footfalls)
            ..where((t) => t.id.equals(id))).getSingle();
      expect(footfall.convertedPatientId, equals('p1'));
    });
  });

  group('FootfallsScreen & AddFootfallDialog Widget Tests', () {
    testWidgets('renders empty state and opens AddFootfallDialog', (
      tester,
    ) async {
      final clinic = Clinic(
        id: 'c1',
        name: 'Main Clinic',
        monthlyRent: 0,
        defaultConsultationFee: 0,
        openDays: '1,2,3,4,5,6',
        colorHex: '#0F5132',
        isActive: true,
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clinicsStreamProvider.overrideWith((ref) => Stream.value([clinic])),
            footfallsStreamProvider.overrideWith((ref) => Stream.value([])),
            footfallStatsProvider.overrideWithValue(
              const AsyncData(
                FootfallStats(
                  totalCount: 0,
                  convertedCount: 0,
                  pendingCount: 0,
                  conversionRate: 0.0,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FootfallsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No walk-in inquiries yet'), findsOneWidget);
      expect(find.text('Log Walk-in'), findsOneWidget);

      // Tap Log Walk-in FAB
      await tester.tap(find.text('Log Walk-in'));
      await tester.pumpAndSettle();

      expect(find.text('Log Walk-in / Inquiry'), findsOneWidget);
      expect(find.text('Visitor Name *'), findsOneWidget);
    });
  });
}
