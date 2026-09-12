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
        overrides: [databaseProvider.overrideWithValue(db)],
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

    test(
      'supports first and last name separation and greetingName getter',
      () async {
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );

        final notifier = container.read(doctorProfileNotifierProvider.notifier);

        await notifier.updateProfile(
          firstName: 'Dr. Md.',
          lastName: 'Saifuddin',
          email: 'saif@example.com',
        );

        final profile = await container.read(
          doctorProfileStreamProvider.future,
        );
        expect(profile.firstName, 'Dr. Md.');
        expect(profile.lastName, 'Saifuddin');
        expect(profile.displayName, 'Dr. Md. Saifuddin');
        expect(profile.greetingName, 'Dr. Saifuddin');
      },
    );

    test('onboarding completes with full doctor profile', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      final controller = container.read(onboardingControllerProvider);

      await controller.complete(
        doctorName: 'Dr. Sarah Connor',
        doctorEmail: 'sarah@clinic.com',
        doctorPhone: '9876543210',
        doctorQualification: 'MD, BHMS',
        doctorRegNumber: 'REG-12345',
        clinics: [const DraftClinic(name: 'Healing Centre')],
      );

      final profile = await container.read(doctorProfileStreamProvider.future);
      expect(profile.name, 'Dr. Sarah Connor');
      expect(profile.email, 'sarah@clinic.com');
      expect(profile.phone, '9876543210');
      expect(profile.qualification, 'MD, BHMS');
      expect(profile.regNumber, 'REG-12345');
      expect(profile.specialty, ClinicalSpecialty.homeopathy);
    });

    test(
      'ClinicalSpecialty auto-infers from qualification and parses fromId',
      () {
        expect(
          ClinicalSpecialty.fromId('homeopathy'),
          ClinicalSpecialty.homeopathy,
        );
        expect(ClinicalSpecialty.fromId('dental'), ClinicalSpecialty.dental);
        expect(
          ClinicalSpecialty.fromId('general_practice'),
          ClinicalSpecialty.generalPractice,
        );
        expect(
          ClinicalSpecialty.fromId('ayurveda'),
          ClinicalSpecialty.ayurveda,
        );
        expect(
          ClinicalSpecialty.fromId('multi_specialty'),
          ClinicalSpecialty.multiSpecialty,
        );

        // Inferred from qualifications
        expect(
          ClinicalSpecialty.fromId(
            null,
            qualificationFallback: 'BHMS, MD (Hom.)',
          ),
          ClinicalSpecialty.homeopathy,
        );
        expect(
          ClinicalSpecialty.fromId('', qualificationFallback: 'BDS, MDS'),
          ClinicalSpecialty.dental,
        );
        expect(
          ClinicalSpecialty.fromId(
            null,
            qualificationFallback: 'MBBS, MD (Medicine)',
          ),
          ClinicalSpecialty.generalPractice,
        );
        expect(
          ClinicalSpecialty.fromId(
            null,
            qualificationFallback: 'BAMS, MD (Ayu)',
          ),
          ClinicalSpecialty.ayurveda,
        );
        expect(
          ClinicalSpecialty.fromId(
            null,
            qualificationFallback: 'Certified Therapist',
          ),
          ClinicalSpecialty.multiSpecialty,
        );
      },
    );

    test('saves and updates practice specialty', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(doctorProfileNotifierProvider.notifier);

      await notifier.updateProfile(
        name: 'Dr. A. K. Sharma',
        qualification: 'BDS',
        specialty: ClinicalSpecialty.dental,
      );

      final profile = await container.read(doctorProfileStreamProvider.future);
      expect(profile.specialty, ClinicalSpecialty.dental);
      expect(profile.isDental, isTrue);
      expect(profile.isHomeopathy, isFalse);

      await notifier.updateProfile(
        name: 'Dr. A. K. Sharma',
        specialty: ClinicalSpecialty.generalPractice,
      );

      final updated = await container.read(doctorProfileStreamProvider.future);
      expect(updated.specialty, ClinicalSpecialty.generalPractice);
      expect(updated.isGeneralPractice, isTrue);
    });
  });

  group('DoctorProfileScreen Widget Tests', () {
    testWidgets('renders doctor profile details and opens edit dialog', (
      t,
    ) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      await container
          .read(doctorProfileNotifierProvider.notifier)
          .updateProfile(
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
      expect(find.text('Practice Specialty'), findsOneWidget);

      // Tap Edit Profile icon in AppBar
      await t.tap(find.byIcon(Icons.edit_outlined));
      await t.pumpAndSettle();

      expect(find.text('Edit Doctor Profile'), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders doctor profile card header', (t) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      await container
          .read(doctorProfileNotifierProvider.notifier)
          .updateProfile(
            name: 'Dr. Alice Smith',
            email: 'alice@practice.com',
            qualification: 'BHMS, MD',
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
      expect(find.text('BHMS, MD'), findsOneWidget);
    });
  });
}
