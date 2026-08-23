import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/disease_autocomplete_field.dart';
import 'package:clinic_pilot/features/growth/presentation/disease_analytics_screen.dart';
import 'package:clinic_pilot/features/growth/providers/disease_analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Disease Analytics & Curated Field Unit Tests', () {
    test('curated diseases list contains essential homeopathic conditions', () {
      expect(kCuratedDiseases, contains('Asthma / Bronchial Allergy'));
      expect(kCuratedDiseases, contains('Atopic Dermatitis / Eczema'));
      expect(kCuratedDiseases, contains('Psoriasis'));
      expect(kCuratedDiseases, contains('Joint Pain / Osteoarthritis'));
      expect(kCuratedDiseases, contains('Kidney Stone / Renal Calculi'));
      expect(kCuratedDiseases.length, greaterThan(20));
    });

    test('disease analytics summary groups revenue and patient metrics properly', () {
      const stat1 = DiseaseStat(
        disease: 'Eczema / Dermatitis',
        patientCount: 5,
        visitCount: 12,
        totalRevenue: 6000,
        repeatPatients: 4,
        repeatRate: 80.0,
        avgRevenuePerPatient: 1200,
      );

      const stat2 = DiseaseStat(
        disease: 'Asthma',
        patientCount: 3,
        visitCount: 4,
        totalRevenue: 2400,
        repeatPatients: 1,
        repeatRate: 33.3,
        avgRevenuePerPatient: 800,
      );

      const summary = DiseaseAnalyticsSummary(
        totalConditions: 2,
        topRevenueDisease: 'Eczema / Dermatitis',
        topRevenueAmount: 6000,
        topVolumeDisease: 'Eczema / Dermatitis',
        topVolumeCount: 5,
        totalRevenue: 8400,
        stats: [stat1, stat2],
      );

      expect(summary.totalConditions, equals(2));
      expect(summary.topRevenueDisease, equals('Eczema / Dermatitis'));
      expect(summary.totalRevenue, equals(8400.0));
      expect(summary.stats.first.repeatRate, equals(80.0));
    });
  });

  group('DiseaseAutocompleteField Widget Tests', () {
    testWidgets('renders autocomplete suggestions when typing', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: DiseaseAutocompleteField(
                controller: controller,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter partial query
      await tester.enterText(find.byType(TextFormField), 'Skin');
      await tester.pumpAndSettle();

      expect(find.text('Skin Allergy / Urticaria'), findsOneWidget);

      // Tap suggestion
      await tester.tap(find.text('Skin Allergy / Urticaria'));
      await tester.pumpAndSettle();

      expect(controller.text, equals('Skin Allergy / Urticaria'));
    });
  });

  group('DiseaseAnalyticsScreen Widget Tests', () {
    testWidgets('renders condition ranking and metrics', (tester) async {
      const stat1 = DiseaseStat(
        disease: 'Skin Allergy / Urticaria',
        patientCount: 8,
        visitCount: 15,
        totalRevenue: 9500,
        repeatPatients: 6,
        repeatRate: 75.0,
        avgRevenuePerPatient: 1187.5,
      );

      const summary = DiseaseAnalyticsSummary(
        totalConditions: 1,
        topRevenueDisease: 'Skin Allergy / Urticaria',
        topRevenueAmount: 9500,
        topVolumeDisease: 'Skin Allergy / Urticaria',
        topVolumeCount: 8,
        totalRevenue: 9500,
        stats: [stat1],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            diseaseAnalyticsProvider.overrideWithValue(
              const AsyncData(summary),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DiseaseAnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Disease & Condition Analytics'), findsOneWidget);
      expect(find.text('Skin Allergy / Urticaria'), findsWidgets);
      expect(find.text('₹ 9,500'), findsWidgets);
      expect(find.text('75% repeat'), findsOneWidget);
      expect(find.text('8 patients • 15 visits'), findsOneWidget);
    });
  });
}
