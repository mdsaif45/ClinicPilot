import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/clinical/presentation/widgets/complaint_list_view.dart';
import 'package:clinic_pilot/features/clinical/providers/complaint_provider.dart';
import 'package:drift/drift.dart' as drift;
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

  group('Complaint Notifier & Database Unit Tests', () {
    test('adds, updates and deletes a patient complaint record', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // Create a test patient
      await db.into(db.patients).insert(
            PatientsCompanion.insert(
              id: 'p_comp_1',
              name: 'John Doe',
              phone: '9999999999',
              age: 40,
              gender: 'Male',
              serialNo: const drift.Value('001'),
            ),
          );

      final notifier = container.read(complaintNotifierProvider.notifier);

      final complaintId = await notifier.addComplaint(
        patientId: 'p_comp_1',
        complaintIndex: 1,
        complaintName: 'Right Knee Osteoarthritis',
        location: 'Right knee joint',
        side: 'Right',
        onset: 'Gradual',
        duration: '1 year',
        sensation: 'Stitching, tearing pain',
        extension: 'Extending down to calf muscles',
        aggravatingFactors: 'Cold weather, walking, morning',
        amelioratingFactors: 'Warmth, rest',
        concomitants: 'Gastric flatulence',
        causation: 'Injury 5 years ago',
        periodicity: 'Worse in winter',
        severity: 8,
        status: 'Active',
      );

      final list = await db.select(db.complaints).get();
      expect(list.length, equals(1));
      expect(list.first.complaintName, equals('Right Knee Osteoarthritis'));
      expect(list.first.side, equals('Right'));
      expect(list.first.severity, equals(8));
      expect(list.first.aggravatingFactors, contains('Cold weather'));

      // Update status
      await notifier.updateStatus(complaintId, 'Improving');
      final updated = await (db.select(db.complaints)..where((t) => t.id.equals(complaintId))).getSingle();
      expect(updated.status, equals('Improving'));

      // Soft delete
      await notifier.deleteComplaint(complaintId);
      final activeList = await (db.select(db.complaints)..where((t) => t.isDeleted.equals(false))).get();
      expect(activeList, isEmpty);
    });
  });

  group('ComplaintListView & AddEditComplaintDialog Widget Tests', () {
    testWidgets('renders empty state and opens add complaint dialog', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final patient = Patient(
        id: 'p_widget_1',
        patientCode: 'P-2026-00002',
        name: 'Jane Smith',
        phone: '8888888888',
        age: 32,
        gender: 'Female',
        primaryClinicId: 'clinic_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        serialNo: '002',
        referralSource: 'Walk-in',
        reviewGiven: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            patientComplaintsProvider(patient.id).overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: ComplaintListView(patient: patient),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No complaints logged'), findsOneWidget);
      expect(find.text('Add Complaint'), findsOneWidget);

      await tester.tap(find.text('Add Complaint'));
      await tester.pumpAndSettle();

      expect(find.text('Add Clinical Complaint'), findsOneWidget);
      expect(find.text('Complaint / Condition *'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Side'), findsOneWidget);
      expect(find.text('5/10 • Moderate'), findsOneWidget);
    });
  });
}