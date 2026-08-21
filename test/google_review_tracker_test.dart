import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/growth/presentation/record_review_dialog.dart';
import 'package:clinic_pilot/features/growth/providers/review_provider.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Google Review Tracker Unit & Provider Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      // Seed clinic
      await db.into(db.clinics).insert(
            ClinicsCompanion.insert(
              id: 'clinic-1',
              name: 'Test Clinic',
            ),
          );
      // Seed patient
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'pat-1',
              patientCode: const drift.Value('P-2026-00001'),
              serialNo: const drift.Value('101'),
              primaryClinicId: const drift.Value('clinic-1'),
              name: 'Test Reviewer',
              phone: '9876543210',
              age: 30,
              gender: 'Female',
              primaryDisease: const drift.Value('Sinusitis'),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('records review request and marks patient review_asked_at', () async {
      final notifier = ReviewNotifier(db);
      await notifier.requestReview(
        patientId: 'pat-1',
        clinicId: 'clinic-1',
        notes: 'Sent via WhatsApp',
      );

      final requests = await db.select(db.reviewRequests).get();
      expect(requests.length, equals(1));
      expect(requests.first.patientId, equals('pat-1'));
      expect(requests.first.notes, equals('Sent via WhatsApp'));

      final patient = await (db.select(db.patients)..where((t) => t.id.equals('pat-1'))).getSingle();
      expect(patient.reviewAskedAt, isNotNull);
      expect(patient.reviewGiven, isFalse);
    });

    test('records review submission with rating and marks patient review_given', () async {
      final notifier = ReviewNotifier(db);
      await notifier.requestReview(
        patientId: 'pat-1',
        clinicId: 'clinic-1',
      );

      final req = (await db.select(db.reviewRequests).get()).first;

      await notifier.recordReviewSubmitted(
        requestId: req.id,
        patientId: 'pat-1',
        rating: 5,
        notes: 'Left 5 star rating',
      );

      final updatedReq = await (db.select(db.reviewRequests)..where((t) => t.id.equals(req.id))).getSingle();
      expect(updatedReq.rating, equals(5));
      expect(updatedReq.reviewedAt, isNotNull);

      final patient = await (db.select(db.patients)..where((t) => t.id.equals('pat-1'))).getSingle();
      expect(patient.reviewGiven, isTrue);
    });
  });

  group('RecordReviewDialog Widget Test', () {
    final testPatient = Patient(
      id: 'pat-1',
      patientCode: 'P-2026-00001',
      serialNo: '101',
      primaryClinicId: 'clinic-1',
      name: 'Test Reviewer',
      phone: '9876543210',
      age: 30,
      gender: 'Female',
      primaryDisease: 'Sinusitis',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      reviewGiven: false,
    );

    testWidgets('renders rating stars and submits review', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: RecordReviewDialog(patient: testPatient),
            ),
          ),
        ),
      );

      expect(find.text('Record Google Review'), findsOneWidget);
      expect(find.text('Rating given:'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
      expect(find.text('Save Review'), findsOneWidget);
    });
  });
}
