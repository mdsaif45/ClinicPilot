import 'package:clinic_pilot/core/theme/app_theme.dart';
import 'package:clinic_pilot/core/widgets/full_screen_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FullScreenImageViewer renders single image, title, and handles close', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const FullScreenImageViewer(
          imagePaths: ['https://example.com/photo1.jpg'],
          title: 'Before Treatment Photo',
        ),
      ),
    );

    expect(find.text('Before Treatment Photo'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.zoom_out_map_outlined), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('FullScreenImageViewer renders gallery with multiple photos and page indicator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const FullScreenImageViewer(
          imagePaths: [
            'https://example.com/photo1.jpg',
            'https://example.com/photo2.jpg',
            'https://example.com/photo3.jpg',
          ],
          initialIndex: 0,
          title: 'Clinical Gallery',
        ),
      ),
    );

    expect(find.text('Clinical Gallery'), findsOneWidget);
    expect(find.text('Photo 1 of 3'), findsOneWidget);

    // Swipe to next photo
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Photo 2 of 3'), findsOneWidget);
  });
}
