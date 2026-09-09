import 'dart:io';

import 'package:clinic_pilot/core/database/app_database.dart';
import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/features/dashboard/presentation/dashboard_screen.dart';
import 'package:clinic_pilot/features/dashboard/presentation/widgets/medicine_inventory_card.dart';
import 'package:clinic_pilot/features/dashboard/providers/dashboard_provider.dart';
import 'package:clinic_pilot/features/inventory/providers/inventory_provider.dart';
import 'package:clinic_pilot/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync(
      'cp_dash_inventory_test_',
    );
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  });

  testWidgets(
    'MedicineInventoryCard renders empty state prompt when no medicines exist',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: MedicineInventoryCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medicine Inventory'), findsOneWidget);
      expect(find.text('No medicines cataloged yet'), findsOneWidget);
      expect(
        find.text('Tap to catalog medicines, batches & reorder levels'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'MedicineInventoryCard renders stock healthy badge and valuation when items exist',
    (tester) async {
      final sampleMed = Medicine(
        id: 'm1',
        name: 'Arnica Montana',
        category: 'Dilution',
        potency: '200C',
        currentStock: 10.0,
        unit: 'Bottles (30ml)',
        reorderLevel: 3.0,
        costPrice: 80.0,
        sellingPrice: 150.0,
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryStreamProvider.overrideWith(
              (ref) => Stream.value([sampleMed]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: MedicineInventoryCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medicine Inventory'), findsOneWidget);
      expect(find.text('1 remedy cataloged • 10 units'), findsOneWidget);
      expect(find.text('Stock Healthy'), findsOneWidget);
      expect(find.textContaining('Valuation:'), findsOneWidget);
    },
  );

  testWidgets(
    'MedicineInventoryCard renders alert badges when items are low or out of stock',
    (tester) async {
      final lowStockMed = Medicine(
        id: 'm1',
        name: 'Nux Vomica',
        category: 'Dilution',
        potency: '30C',
        currentStock: 2.0,
        unit: 'Bottles (30ml)',
        reorderLevel: 5.0,
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final outOfStockMed = Medicine(
        id: 'm2',
        name: 'Belladonna',
        category: 'Dilution',
        potency: '200C',
        currentStock: 0.0,
        unit: 'Bottles (30ml)',
        reorderLevel: 3.0,
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryStreamProvider.overrideWith(
              (ref) => Stream.value([lowStockMed, outOfStockMed]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: MedicineInventoryCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 Out of stock'), findsOneWidget);
      expect(find.text('1 Low in stock'), findsOneWidget);
      expect(find.text('Stock Healthy'), findsNothing);
    },
  );

  testWidgets(
    'DashboardScreen renders Medicine Inventory section and Quick Action',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const sampleStats = DashboardStats(
        todayRevenue: 1000.0,
        todayExpense: 200.0,
        todayNetProfit: 800.0,
        todayPatients: 5,
        monthlyRevenue: 25000.0,
        monthlyExpense: 5000.0,
        monthlyNetProfit: 20000.0,
        monthlyRevenueGoal: 50000.0,
        totalPatients: 100,
        totalRepeatPatients: 40,
        monthlyNewPatients: 20,
        monthlyRepeatPatients: 15,
        monthlyNewPatientGoal: 30,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryStreamProvider.overrideWith((ref) => Stream.value([])),
            dashboardStatsProvider.overrideWith(
              (ref) => Stream.value(sampleStats),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Medicine Inventory SectionHeader & Card
      expect(
        find.text('Medicine Inventory'),
        findsNWidgets(2),
      ); // Section header + card title
      // Verify Quick Action buttons
      expect(find.text('Add Patient'), findsOneWidget);
      expect(find.text('Create Memo'), findsOneWidget);
      expect(find.text('Log Expense'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen no longer renders Medicine Inventory & Dispensing',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage clinics'), findsOneWidget);
      expect(find.text('Prescription Letterhead'), findsOneWidget);
      expect(find.text('Medicine Inventory & Dispensing'), findsNothing);
    },
  );
}
