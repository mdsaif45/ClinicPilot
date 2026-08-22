import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/database/database_provider.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/onboarding/providers/onboarding_provider.dart';
import 'package:clinic_pilot/features/settings/presentation/doctor_profile_screen.dart';
import 'package:clinic_pilot/features/settings/presentation/settings_screen.dart';
import 'package:clinic_pilot/features/settings/providers/doctor_profile_provider.dart';
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

  group('DoctorProfileNotifier Unit Tests', () {
    test('saves and updates doctor profile in SQLite settings table', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      final notifier = container.read(doctorProfileNotifierProvider.notifier);

      // Save initial profile
      await notifier.updateProfile(
        name: 'Dr. Md. Saifuddin',
        email: 'saif@example.com',
        phone: '9830012345',
        qualification: 'BHMS, MD (Hom.)',
        regNumber: 'WBMC-9988',
      );

      final profile = await container.read(doctorProfileStreamProvider.future);
      expect(profile.name, 'Dr. Md. Saifuddin');
      expect(profile.email, 'saif@example.com');
      expect(profile.phone, '9830012345');
      expect(profile.qualification, 'BHMS, MD (Hom.)');
      expect(profile.regNumber, 'WBMC-9988');

      // Update qualification & phone
      await notifier.updateProfile(
        name: 'Dr. Md. Saifuddin',
        email: 'saif@example.com',
        phone: '9830099999',
        qualification: 'BHMS, MD (Hom.), PhD',
        regNumber: 'WBMC-9988',
      );

      final updated = await container.read(doctorProfileStreamProvider.future);
      expect(updated.phone, '9830099999');
      expect(updated.qualification, 'BHMS, MD (Hom.), PhD');
    });

    test('onboarding completes with full doctor profile', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      final controller = container.read(onboardingControllerProvider);

      await controller.complete(
        doctorName: 'Dr. Sarah Connor',
        doctorEmail: 'sarah@clinic.com',
        doctorPhone: '9876543210',
        doctorQualification: 'MD, BHMS',
        doctorRegNumber: 'REG-12345',
        clinics: [
          const DraftClinic(name: 'Healing Centre'),
        ],
      );

      final profile = await container.read(doctorProfileStreamProvider.future);
      expect(profile.name, 'Dr. Sarah Connor');
      expect(profile.email, 'sarah@clinic.com');
      expect(profile.phone, '9876543210');
      expect(profile.qualification, 'MD, BHMS');
      expect(profile.regNumber, 'REG-12345');
    });
  });

  group('DoctorProfileScreen Widget Tests', () {
    testWidgets('renders doctor profile details and opens edit dialog', (t) async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      await container.read(doctorProfileNotifierProvider.notifier).updateProfile(
        name: 'Dr. John Doe',
        email: 'john@example.com',
        phone: '9876500000',
        qualification: 'BHMS, MD',
        regNumber: 'MC-1010',
      );

      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DoctorProfileScreen(),
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text('Doctor Profile'), findsOneWidget);
      expect(find.text('Dr. John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('9876500000'), findsOneWidget);
      expect(find.text('BHMS, MD'), findsWidgets);
      expect(find.text('Reg: MC-1010'), findsOneWidget);

      // Tap Edit Profile icon in AppBar
      await t.tap(find.byIcon(Icons.edit_outlined));
      await t.pumpAndSettle();

      expect(find.text('Edit Doctor Profile'), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders doctor profile card header', (t) async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      await container.read(doctorProfileNotifierProvider.notifier).updateProfile(
        name: 'Dr. Alice Smith',
        email: 'alice@practice.com',
      );

      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      await t.pumpAndSettle();

      expect(find.text('Dr. Alice Smith'), findsOneWidget);
      expect(find.text('alice@practice.com'), findsOneWidget);
    });
  });
}
